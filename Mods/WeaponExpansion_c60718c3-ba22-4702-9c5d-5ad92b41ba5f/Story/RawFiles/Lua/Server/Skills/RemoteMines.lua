local function BreachHitTarget(source, target, minePosition)

end

---@param source EsvCharacter
---@param item EsvItem
local function RunBreachKnockback(source, item)
	local radius = GameHelpers.Stats.GetAttribute("Projectile_LLWEAPONEX_RemoteMine_Breach", "ExplodeRadius", 0)
	if radius > 0 then
		for target in GameHelpers.Grid.GetNearbyObjects(source, {Radius=radius, Position=item.WorldPos}) do
			local startPos = target.WorldPos
			local dir = GameHelpers.Math.GetDirectionVector(item.WorldPos, target.WorldPos)
			dir[1] = dir[1] * -1
			dir[3] = dir[3] * -1
			local tx,ty,tz = GameHelpers.Grid.GetValidPositionAlongLine(startPos, dir, 3)
			if tx ~= nil and tz ~= nil then
				GameHelpers.ForceMoveObjectToPosition(source, target, {tx,ty,tz})
			end
		end
	end
end

StatusManager.Subscribe.Applied("LLWEAPONEX_REMOTEMINE_DETONATE", function(e)
	if e.TargetGUID == e.SourceGUID or not GameHelpers.Character.CanAttackTarget(e.Target, e.Source, true) then
		-- Prevent the caster from detonating their own inventory, or an ally's
		return false
	end
	local target = e.Target
	if GameHelpers.Ext.ObjectIsItem(e.Target) then
		---@cast target EsvItem
		if target:HasTag("LLWEAPONEX_RemoteMine") then
			local skill = GetVarFixedString(e.TargetGUID, "LLWEAPONEX_Mine_Skill")
			if StringHelpers.IsNullOrEmpty(CharacterGetEquippedWeapon(e.SourceGUID)) then
				skill = GetVarFixedString(e.TargetGUID, "LLWEAPONEX_Mine_Skill_NoWeapon")
			end
			SetVarInteger(e.TargetGUID, "LLWEAPONEX_ItemAmount", target.Amount)
			if skill == "Projectile_LLWEAPONEX_RemoteMine_Breach" then
				RunBreachKnockback(e.Source, target)
			end
			GameHelpers.Skill.Explode(target.WorldPos, skill, e.Source)
			CharacterItemSetEvent(e.SourceGUID, e.TargetGUID, "LLWEAPONEX_RemoteMine_DetonationDone")
		else
			if GameHelpers.Item.IsDestructible(target) then
				local pos = {table.unpack(target.WorldPos)}
				--Grenade.itemScript
				local explodeSkill = GetVarObject(target.MyGuid, "ProjectileSkill")
				if StringHelpers.IsNullOrWhitespace(explodeSkill) then
					--PUZZLE_Mine.itemScript
					explodeSkill = GetVarObject(target.MyGuid, "MineProjectile")
				end
				if not StringHelpers.IsNullOrWhitespace(explodeSkill) then
					--In case it's a ProximityMine or a Grenade
					SetVarInteger(target.MyGuid, "Exploded", 1)
					ItemDestroy(target.MyGuid)
					GameHelpers.Skill.Explode(pos, explodeSkill, e.Source)
				end
			end
		end
		return true
	end
	local items = e.Target:GetInventoryItems()
	if items ~= nil and #items > 0 then
		local max = GameHelpers.GetExtraData("LLWEAPONEX_RemoteCharge_MaxInventoryDetonation", 5)
		if Settings.Global:FlagEquals("LLWEAPONEX_RemoteChargeDetonationCountDisabled", true) then
			max = 99
		end
		if max > 0 then
			local totalDetonated = 0
			local mines = {}
			for _,uuid in pairs(items) do
				local item = GameHelpers.GetItem(uuid)
				if item ~= nil and item:HasTag("LLWEAPONEX_RemoteMine") and not item:HasTag("LLWEAPONEX_RemoteMine_WorldOnly") then
					table.insert(mines, item.MyGuid)
				end
			end
			if #mines > 0 then
				if PersistentVars.SkillData.RemoteMineDetonation[e.TargetGUID] == nil then
					PersistentVars.SkillData.RemoteMineDetonation[e.TargetGUID] = {}
				end
				PersistentVars.SkillData.RemoteMineDetonation[e.TargetGUID][e.SourceGUID] = {
					Mines = mines,
					Remaining = max
				}
				Timer.StartObjectTimer("LLWEAPONEX_DetonateMines", e.Source, 50, {Target=e.TargetGUID})
			end
		end
	end
end)

---@param source UUID
---@param target UUID
local function OnDetonationTimer(source, target)
	local data = PersistentVars.SkillData.RemoteMineDetonation[target]
	if data ~= nil then
		local minesData = data[source]
		if minesData ~= nil then
			if minesData.Remaining > 0 then
				local detonated = false
				local attempts = 0
				while not detonated and attempts < 99 and #minesData.Mines > 0 do
					local rnd = Ext.Random(1,#minesData.Mines)
					local mineUUID = minesData.Mines[rnd]
					if mineUUID ~= nil then
						local item = GameHelpers.GetItem(mineUUID)
						if item and item.Amount > 0 then
							local skill = GetVarFixedString(mineUUID, "LLWEAPONEX_Mine_Skill")
							if StringHelpers.IsNullOrEmpty(CharacterGetEquippedWeapon(source)) then
								skill = GetVarFixedString(mineUUID, "LLWEAPONEX_Mine_Skill_NoWeapon")
							end
							local x,y,z = GetPosition(target)
							minesData.Remaining = minesData.Remaining - 1
							GameHelpers.ExplodeProjectile(source, {x,y,z}, skill)
							detonated = true
							item.Amount = item.Amount - 1
							SetVarInteger(target, "LLWEAPONEX_ItemAmount", item.Amount)
							if item.Amount <= 0 then
								ItemDestroy(item.MyGuid)
							end
						else
							minesData.Mines[rnd] = nil
						end
					end
					attempts = attempts + 1
				end

				if minesData.Remaining > 0 and #minesData.Mines > 0 then
					Timer.Start("LLWEAPONEX_DetonateMines", 500, source, target)
				else
					data[source] = nil
					if not Common.TableHasAnyEntry(data) then
						PersistentVars.SkillData.RemoteMineDetonation[target] = nil
					end
				end
			end
		end
	end
end

---@param e {Data:{UUID:string, Source:string}}
Timer.Subscribe("LLWEAPONEX_DetonateMines", function (e)
	if e.Data.UUID and e.Data.Source then
		OnDetonationTimer(e.Data.Source, e.Data.UUID)
	end
end)

-- SkillManager.Register.Cast("Projectile_LLWEAPONEX_RemoteMine_Breach", function(e)
-- 	local radius = GameHelpers.Stats.GetAttribute(e.Skill, "ExplodeRadius")
-- end)

StatusManager.Register.Applied("LLWEAPONEX_REMOTEMINE_BREACHED", function(target, status, source)
	if not GameHelpers.ObjectIsDead(target) then
		if GameHelpers.Ext.ObjectIsItem(target) then
			if target.CanBeMoved then
				GameHelpers.ForceMoveObject(source, target, 2)
			elseif target.CanUse and target.LockLevel <= 10 and target.LockLevel > 0 then
				ItemUnLock(target.MyGuid)
				ItemOpen(target.MyGuid)
				--GameHelpers.GetStringKeyText("LLWEAPONEX_Breached", "<font color='#FF9900' size='24'>Breached</font>")
				DisplayText(target.MyGuid, "LLWEAPONEX_Breached")
			end
		else
			GameHelpers.ForceMoveObject(source, target, 2)
		end
	end
end)
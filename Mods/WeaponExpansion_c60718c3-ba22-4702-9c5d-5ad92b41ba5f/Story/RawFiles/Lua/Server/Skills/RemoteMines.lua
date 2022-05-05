local function BreachHitTarget(source, target, minePosition)

end

---@param source EsvCharacter
---@param item EsvItem
local function RunBreachKnockback(source, item)
	local radius = Ext.StatGetAttribute("Projectile_LLWEAPONEX_RemoteMine_Breach", "ExplodeRadius")
	for i,v in pairs(item:GetNearbyCharacters(radius)) do
		local target = Ext.GetCharacter(v)
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

RegisterStatusListener("Applied", "LLWEAPONEX_REMOTEMINE_DETONATE", function(target, status, source)
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
	if target == source or CharacterIsAlly(target, source) == 1 then
		-- Prevent the caster from detonating their own inventory, or an ally's
		return false
	end
	if IsTagged(target, "LLWEAPONEX_RemoteMine") == 1 then
		local skill = GetVarFixedString(target, "LLWEAPONEX_Mine_Skill")
		if StringHelpers.IsNullOrEmpty(CharacterGetEquippedWeapon(source)) then
			skill = GetVarFixedString(target, "LLWEAPONEX_Mine_Skill_NoWeapon")
		end
		SetVarInteger(target, "LLWEAPONEX_ItemAmount", Ext.GetItem(target).Amount)
		if skill == "Projectile_LLWEAPONEX_RemoteMine_Breach" then
			RunBreachKnockback(Ext.GetCharacter(source), Ext.GetItem(target))
		end
		local x,y,z = GetPosition(target)
		GameHelpers.ExplodeProjectile(source, {x,y,z}, skill)
		CharacterItemSetEvent(source, target, "LLWEAPONEX_RemoteMine_DetonationDone")
		return true
	end
	local items = nil
	if ObjectIsCharacter(target) == 1 then
		items = Ext.GetCharacter(target):GetInventoryItems()
	elseif ObjectIsItem(target) == 1 then
		items = Ext.GetItem(target):GetInventoryItems()
	end
	if items ~= nil and #items > 0 then
		local max = GameHelpers.GetExtraData("LLWEAPONEX_RemoteCharge_MaxInventoryDetonation", 5)
		if GetSettings().Global:FlagEquals("LLWEAPONEX_RemoteChargeDetonationCountDisabled", true) then
			max = 99
		end
		if max > 0 then
			local totalDetonated = 0
			local mines = {}
			for _,uuid in pairs(items) do
				local item = Ext.GetItem(uuid)
				if item ~= nil and item:HasTag("LLWEAPONEX_RemoteMine") and not item:HasTag("LLWEAPONEX_RemoteMine_WorldOnly") then
					table.insert(mines, item.MyGuid)
				end
			end
			if #mines > 0 then
				if PersistentVars.SkillData.RemoteMineDetonation[target] == nil then
					PersistentVars.SkillData.RemoteMineDetonation[target] = {}
				end
				PersistentVars.SkillData.RemoteMineDetonation[target][source] = {
					Mines = mines,
					Remaining = max
				}
				Timer.Start("LLWEAPONEX_OnDetonationTimer", 50, source, target)
			end
		end
	end
end)

local function OnDetonationTimer(_, source, target)
	if source and target then
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
							local item = Ext.GetItem(mineUUID)
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
end

Timer.RegisterListener("LLWEAPONEX_DetonateMines", OnDetonationTimer)

RegisterSkillListener("Projectile_LLWEAPONEX_RemoteMine_Breach", function(skill, source, state, data)
	if state == SKILL_STATE.CAST then
		local radius = Ext.StatGetAttribute(skill, "ExplodeRadius")
		
	end
end)

RegisterStatusListener("Applied", "LLWEAPONEX_REMOTEMINE_BREACHED", function(target, status, source)
	local target = StringHelpers.GetUUID(target)
	local source = StringHelpers.GetUUID(source)
	if ObjectIsItem(target) == 1 and ItemIsDestroyed(target) == 0 then
		local item = Ext.GetItem(target)
		if item.CanBeMoved then
			GameHelpers.ForceMoveObject(Ext.GetCharacter(source), item, 2)
		elseif item.CanUse and item.LockLevel <= 10 and item.LockLevel > 0 then
			ItemUnLock(item.MyGuid)
			ItemOpen(item.MyGuid)
			DisplayText(item.MyGuid, "Breached!")
		end
	elseif ObjectIsCharacter(target) == 1 then
		-- if source == target then
		-- 	GameHelpers.ForceMoveObject(Ext.GetCharacter(source), Ext.GetCharacter(target), 2)
		-- else
		-- 	GameHelpers.ForceMoveObject(Ext.GetCharacter(source), Ext.GetCharacter(target), 2)
		-- end
	end
end)
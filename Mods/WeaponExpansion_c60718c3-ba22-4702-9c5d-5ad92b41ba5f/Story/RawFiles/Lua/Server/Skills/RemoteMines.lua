Config.Skill.RemoteMines = {
	ThrowSkills = {
		"Projectile_LLWEAPONEX_RemoteMine_Throw_Breach",
		"Projectile_LLWEAPONEX_RemoteMine_Throw_Displacement",
		"Projectile_LLWEAPONEX_RemoteMine_Throw_Explosive",
		"Projectile_LLWEAPONEX_RemoteMine_Throw_PoisonGas",
		"Projectile_LLWEAPONEX_RemoteMine_Throw_Shrapnel",
		"Projectile_LLWEAPONEX_RemoteMine_Throw_Tar",
	}
}

local function BreachHitTarget(source, target, minePosition)

end

---@param source EsvCharacter
---@param item EsvItem
local function RunBreachKnockback(source, item)
	local radius = GameHelpers.Stats.GetAttribute("Projectile_LLWEAPONEX_RemoteMine_Breach", "ExplodeRadius", 0)
	local knockbackDistance = GameHelpers.GetExtraData("LLWEAPONEX_RemoteMine_BreachKnockbackDistance", 3)
	if radius > 0 and knockbackDistance ~= 0 then
		for target in GameHelpers.Grid.GetNearbyObjects(source, {Radius=radius, Position=item.WorldPos}) do
			local startPos = target.WorldPos
			local dir = GameHelpers.Math.GetDirectionalVector(item.WorldPos, target.WorldPos)
			dir[1] = dir[1] * -1
			dir[3] = dir[3] * -1
			local tx,ty,tz = GameHelpers.Grid.GetValidPositionAlongLine(startPos, dir, knockbackDistance)
			if tx ~= nil and tz ~= nil then
				GameHelpers.ForceMoveObjectToPosition(source, target, {tx,ty,tz})
			end
		end
	end
end

--Prevent unlocking items if the lock level is too high, or if it requires a key
StatusManager.Subscribe.BeforeAttempt("LLWEAPONEX_REMOTEMINE_BREACHED", function (e)
	if GameHelpers.Ext.ObjectIsItem(e.Target) then
		local item = e.Target
		---@cast item EsvItem
		local lockLevel = GameHelpers.GetExtraData("LLWEAPONEX_RemoteMine_BreachLockMaxLevel", 10)
		if lockLevel == 0 or (lockLevel > 0 and item.LockLevel > lockLevel) or not StringHelpers.IsNullOrEmpty(item.Key) then
			e.PreventApply = true
		end
	end
end)

---@param target EsvItem|EsvCharacter
---@param source EsvCharacter
Config.Skill.RemoteMines.Detonate = function (target, source)
	if GameHelpers.Ext.ObjectIsItem(target) then
		if source == nil then
			local owner = GameHelpers.Item.GetOwner(target)
			if owner and GameHelpers.Ext.ObjectIsCharacter(owner) then
				source = owner
			end
		end
		---@cast target EsvItem
		if source and target:HasTag("LLWEAPONEX_RemoteMine") then
			SetVarInteger(target.MyGuid, "LLWEAPONEX_ItemAmount", target.Amount)
			local skill = GetVarFixedString(target.MyGuid, "LLWEAPONEX_Mine_Skill")
			if not StringHelpers.IsNullOrWhitespace(skill) then
				if skill == "Projectile_LLWEAPONEX_RemoteMine_Breach" then
					RunBreachKnockback(source, target)
				elseif skill == "Projectile_LLWEAPONEX_RemoteMine_Displacement" then
					PersistentVars.SkillData.RemoteMineDetonation[target.MyGuid] = {
						Position = target.WorldPos,
						Targets = {}
					}
					Timer.StartObjectTimer("LLWEAPONEX_Displacement_TeleportTargets", target, 1000)
				end
				local useSelfAsSource = GetVarInteger(target.MyGuid, "LLWEAPONEX_Mine_UseSelfAsSource") == 1
				if useSelfAsSource then
					GameHelpers.Skill.Explode(target.WorldPos, skill, target)
				else
					GameHelpers.Skill.Explode(target.WorldPos, skill, source)
				end
			end
			CharacterItemSetEvent(source.MyGuid, target.MyGuid, "LLWEAPONEX_RemoteMine_DetonationDone")
		else
			if GameHelpers.Item.IsDestructible(target) then
				local pos = target.WorldPos
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
					GameHelpers.Skill.Explode(pos, explodeSkill, source)
				end
			end
		end
		return true
	end
	if source then
		local items = target:GetInventoryItems()
		if items ~= nil and #items > 0 then
			local max = GameHelpers.GetExtraData("LLWEAPONEX_RemoteMine_MaxInventoryDetonation", 5)
			if GetSettings().Global:FlagEquals("LLWEAPONEX_RemoteChargeDetonationCountDisabled", true) then
				max = 99
			end
			if max > 0 then
				local mines = {}
				for _,uuid in pairs(items) do
					local item = GameHelpers.GetItem(uuid)
					if item ~= nil and item:HasTag("LLWEAPONEX_RemoteMine") and not item:HasTag("LLWEAPONEX_RemoteMine_WorldOnly") then
						table.insert(mines, item.MyGuid)
					end
				end
				if #mines > 0 then
					if PersistentVars.SkillData.RemoteMineDetonation[target.MyGuid] == nil then
						PersistentVars.SkillData.RemoteMineDetonation[target.MyGuid] = {}
					end
					PersistentVars.SkillData.RemoteMineDetonation[target.MyGuid][source.MyGuid] = {
						Mines = mines,
						Remaining = max
					}
					Timer.StartObjectTimer("LLWEAPONEX_DetonateMines", source, 50, {Target=target.MyGuid})
				end
			end
		end
	end
end

StatusManager.Subscribe.Applied("LLWEAPONEX_REMOTEMINE_DISPLACE", function(e)
	if e.Source then
		local data = PersistentVars.SkillData.RemoteMineDisplacement[e.SourceGUID]
		if not data then
			PersistentVars.SkillData.RemoteMineDisplacement[e.SourceGUID] = {}
			data = PersistentVars.SkillData.RemoteMineDisplacement[e.SourceGUID]
		end
		data.Targets[e.TargetGUID] = true
		Timer.RestartObjectTimer("LLWEAPONEX_Displacement_TeleportTargets", e.Source, 500)
	end
end)

Timer.Subscribe("LLWEAPONEX_Displacement_TeleportTargets", function (e)
	local data = PersistentVars.SkillData.RemoteMineDisplacement[e.Data.UUID]
	if data then
		local mineGUID = e.Data.UUID
		local targets = {}
		local len = 0
		for guid,b in pairs(data.Targets) do
			if GameHelpers.ObjectExists(guid) then
				len = len + 1
				targets[len] = guid
			end
		end
		PersistentVars.SkillData.RemoteMineDisplacement[e.Data.UUID] = nil
		local radius = GameHelpers.GetExtraData("LLWEAPONEX_RemoteMine_DisplacementTeleportRadius", 12)
		if len > 0 and radius > 0 then
			local otherDisplacementCharges = {}
			local totalFound = 0
			for item in GameHelpers.Grid.GetNearbyObjects(data.Position, {Type="Item", Position=data.Position}) do
				if item.MyGuid ~= mineGUID and item:HasTag("LLWEAPONEX_RemoteMine_Displacer") and item:HasTag("LLWEAPONEX_RemoteMine_Ready") then
					totalFound = totalFound + 1
					otherDisplacementCharges[totalFound] = item
				end
			end
			for i=1,len do
				local target = GameHelpers.TryGetObject(targets[i])
				if target then
					if totalFound > 0 then
						local charge = Common.GetRandomTableEntry(otherDisplacementCharges)
						EffectManager.PlayEffectAt("RS3_FX_Skills_Void_Netherswap_Disappear_Root_01", target.WorldPos)
						EffectManager.PlayEffect("RS3_FX_Skills_Void_Netherswap_Disappear_Overlay_01", target)
						local x,y,z = table.unpack(charge.WorldPos)
						Osi.LeaderLib_Behavior_TeleportTo(target.MyGuid, x, y, z)
						local targetGUID = target.MyGuid
					elseif GameHelpers.Ext.ObjectIsCharacter(target) then
						CharacterStatusText(target.MyGuid, "LLWEAPONEX_Status_DisplacementFailed")
					end
				end
			end
			if totalFound > 0 then
				Ext.OnNextTick(function (e)
					for i=1,len do
						local target = GameHelpers.TryGetObject(targets[i])
						if target then
							EffectManager.PlayEffect("RS3_FX_Skills_Void_Netherswap_Reappear_01", target)
						end
					end
				end)
			end
		end
	end
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_REMOTEMINE_DETONATE", function(e)
	if e.Source and not GameHelpers.Ext.ObjectIsItem(e.Source) then
		if e.TargetGUID == e.SourceGUID or not GameHelpers.Character.CanAttackTarget(e.Target, e.Source, true) then
			-- Prevent the caster from detonating their own inventory, or an ally's
			return
		end
	end
	Config.Skill.RemoteMines.Detonate(e.Target, e.Source)
end)

---@param source Guid
---@param target Guid
local function OnDetonationTimer(source, target)
	local data = PersistentVars.SkillData.RemoteMineDetonation[target]
	if data ~= nil then
		local minesData = data[source]
		if minesData ~= nil then
			if minesData.Remaining > 0 then
				local detonated = false
				local attempts = 0
				local len = #minesData.Mines
				while not detonated and attempts < 99 and len > 0 do
					local rnd = Ext.Utils.Random(1,len)
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
							table.remove(minesData.Mines, rnd)
							len = len - 1
						end
					end
					attempts = attempts + 1
				end

				if minesData.Remaining > 0 and len > 0 then
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

Events.Osiris.CanPickupItem:Subscribe(function (e)
	if e.Item:HasTag("LLWEAPONEX_RemoteMine") then
		Osi.CharacterItemSetEvent(e.CharacterGUID, e.ItemGUID, "LLWEAPONEX_RemoteMine_OnPrePickedUp")
	end
end)

--#region Holding Tag


Events.Osiris.ItemAddedToCharacter:Subscribe(function (e)
	if e.Item:HasTag("LLWEAPONEX_RemoteMine") then
		Osi.LeaderLib_Tags_PreserveTag(e.CharacterGUID, "LLWEAPONEX_HoldingRemoteMine")
	end
end)

Events.Osiris.ItemAddedToContainer:Subscribe(function (e)
	if e.Item:HasTag("LLWEAPONEX_RemoteMine") then
		Osi.SetTag(e.ContainerGUID, "LLWEAPONEX_HoldingRemoteMine")
	end
end)

Timer.Subscribe("LLWEAPONEX_CheckHoldingRemoteMineTag", function (e)
	local object = e.Data.Object
	if object then
		local _,total = GameHelpers.Item.FindTaggedItems(object, "LLWEAPONEX_RemoteMine")
		if total == 0 then
			Osi.LeaderLib_Tags_ClearPreservedTag(object.MyGuid, "LLWEAPONEX_HoldingRemoteMine")
		end
	end
end)

Events.Osiris.ItemRemovedFromCharacter:Subscribe(function (e)
	if e.Item:HasTag("LLWEAPONEX_RemoteMine") then
		Timer.StartObjectTimer("LLWEAPONEX_CheckHoldingRemoteMineTag", e.Character, 250)
	end
end)

Events.Osiris.ItemRemovedFromContainer:Subscribe(function (e)
	if e.Item:HasTag("LLWEAPONEX_RemoteMine") then
		Timer.StartObjectTimer("LLWEAPONEX_CheckHoldingRemoteMineTag", e.Container, 250)
	end
end)

--#endregion

--region Scripts\LLWEAPONEX_MovingObject.itemScript Interface

---@param e OnSkillStateSkillEventEventArgs
local function _OnThrow(e)
	if e.SourceItem and e.SourceItem:HasTag("LLWEAPONEX_RemoteMine") then
		PersistentVars.SkillData.RemoteMineLastThrown[e.CharacterGUID] = {
			UsedItem = e.SourceItem.MyGuid,
			Skill = e.Skill
		}
	end
end

Ext.Events.SessionLoaded:Subscribe(function (e)
	SkillManager.Subscribe.Used(Config.Skill.RemoteMines.ThrowSkills, _OnThrow)
end)

Events.ObjectEvent:Subscribe(function (e)
	local x,y,z = GameHelpers.Math.GetPosition(e.Objects[1], true)
	Osi.ItemMoveToPosition(e.ObjectGUID1, x, y, z, 20.0, 0.0, "", 0)
end, {MatchArgs={Event="LLWEAPONEX_MovingObjectRemoteMine_SnapToGround", EventType="StoryEvent"}})

Events.ObjectEvent:Subscribe(function (e)
	local owner = GameHelpers.Item.GetOwner(e.Objects[1])
	if owner then
		local data = PersistentVars.SkillData.RemoteMineLastThrown[owner.MyGuid]
		if data then
			Osi.SetVarObject(e.ObjectGUID1, "LLWEAPONEX_CauseItem", data.UsedItem)
			PersistentVars.SkillData.RemoteMineLastThrown[owner.MyGuid] = nil
		end
	end
end, {MatchArgs={Event="LLWEAPONEX_MovingObjectRemoteMine_Init", EventType="StoryEvent"}})

Events.ObjectEvent:Subscribe(function (e)
	local causeItem = Osi.GetVarObject(e.ObjectGUID2, "LLWEAPONEX_CauseItem")
	if Osi.ObjectExists(causeItem) == 1 then
		Osi.LeaderLib_Helper_CopyItemTransform(causeItem, e.ObjectGUID2, 0, 1, e.ObjectGUID1)
		Osi.SetStoryEvent(causeItem, "LLWEAPONEX_RemoteMine_Thrown")
	end
	Osi.SetOnStage(e.ObjectGUID2, 0)
	Osi.ItemDestroy(e.ObjectGUID2)
end, {MatchArgs={Event="LLWEAPONEX_MovingObjectRemoteMine_Landed", EventType="CharacterItemEvent"}})

--#endregion
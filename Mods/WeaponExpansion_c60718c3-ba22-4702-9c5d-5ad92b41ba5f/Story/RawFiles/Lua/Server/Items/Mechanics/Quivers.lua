if Config.Skill.Quivers == nil then
	Config.Skill.Quivers = {}
end

---@param character EsvCharacter
---@param quiver EsvItem
---@param addCharge integer|nil
local function _StartRecharge(character, quiver, addCharge)
	local shouldRecharge = false
	local max = quiver.Stats.MaxCharges
	if max > 0 then
		if addCharge ~= nil then
			ItemAddCharges(quiver.MyGuid, addCharge)
		end
		local charges = ItemGetCharges(quiver.MyGuid)
		if charges < max then
			shouldRecharge = true
			SetTag(quiver.MyGuid, "LLWEAPONEX_ItemNeedsRecharging")
		end
	end
	if shouldRecharge then
		local status = character:GetStatus("LLWEAPONEX_QUIVER_DRAW_RECHARGE")
		if status == nil then
			GameHelpers.Status.Apply(character.MyGuid, "LLWEAPONEX_QUIVER_DRAW_RECHARGE", 3.0, 0, character.MyGuid)
		else
			status.CurrentLifeTime = status.LifeTime
			status.RequestClientSync = true
		end
	else
		ClearTag(quiver.MyGuid, "LLWEAPONEX_ItemNeedsRecharging")
	end
end

SkillManager.Register.Cast("Shout_LLWEAPONEX_Quiver_DrawArrow", function(e)
	local addedArrow = false
	local weapon = GameHelpers.Character.GetEquippedWeapons(e.Character)
	if weapon then
		if weapon:HasTag("LLWEAPONEX_Greatbow") then
			CharacterGiveReward(e.Character.MyGuid, "ST_LLWEAPONEX_Quiver_GreatbowArrows", 1)
			addedArrow = true
		elseif weapon.Stats.WeaponType == "Bow" or weapon.Stats.WeaponType == "Crossbow" then
			CharacterGiveReward(e.Character.MyGuid, "ST_LLWEAPONEX_Quiver_Arrows", 1)
			addedArrow = true
		end
	end
	if addedArrow then
		for quiver in GameHelpers.Character.GetTaggedItems(e.Target, "LLWEAPONEX_Quiver", false, true) do
			_StartRecharge(e.Character, quiver)
		end
	end
end)

StatusManager.Subscribe.Removed("LLWEAPONEX_QUIVER_DRAW_RECHARGE", function(e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) and not GameHelpers.Character.IsDeadOrDying(e.Target) then
		for quiver in GameHelpers.Character.GetTaggedItems(e.Target, "LLWEAPONEX_Quiver", false, true) do
			_StartRecharge(e.Target, quiver, 1)
		end
	end
end)

---@param char CharacterParam
local function _RemoveTempArrows(char)
	local character = GameHelpers.GetCharacter(char)
	if character then
		for arrow in GameHelpers.Character.GetTaggedItems(character, "LLWEAPONEX_Quiver_TemporaryArrow") do
			ItemRemove(arrow.MyGuid)
		end
	end
end

EquipmentManager.Events.EquipmentChanged:Subscribe(function(e)
	if e.Equipped then
		_StartRecharge(e.Character, e.Item)
	else
		GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_QUIVER_DRAW_RECHARGE")
		_RemoveTempArrows(e.Character)
	end
end, {MatchArgs={Tag="LLWEAPONEX_Quiver"}})

Ext.Osiris.RegisterListener("ObjectLeftCombat", 2, "after", function (charGUID, combatID)
	if IsTagged(charGUID, "LLWEAPONEX_Quiver_Equipped") == 1 then
		_RemoveTempArrows(charGUID)
	end
end)

Config.Skill.Quivers.StartRecharge = _StartRecharge
Config.Skill.Quivers.RemoveTempArrows = _RemoveTempArrows
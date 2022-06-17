---@param character EsvCharacter
---@param quiver EsvItem
---@param addCharge integer|nil
local function Quiver_StartRecharge(character, quiver, addCharge)
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
		local quiver = GameHelpers.Item.GetItemInSlot(e.Character, "Belt")
		if quiver and GameHelpers.ItemHasTag(quiver, "LLWEAPONEX_Quiver") then
			Quiver_StartRecharge(e.Character, quiver)
		end
	end
end)

StatusManager.Register.Removed("LLWEAPONEX_QUIVER_DRAW_RECHARGE", function(target, status, source, statusType, statusEvent)
	if GameHelpers.Ext.ObjectIsCharacter(target) and not GameHelpers.Character.IsDeadOrDying(target) then
		local quiver = GameHelpers.Item.GetItemInSlot(target, "Belt")
		if quiver and GameHelpers.ItemHasTag(quiver, "LLWEAPONEX_Quiver") then
			Quiver_StartRecharge(target, quiver, 1)
		end
	end
end)

EquipmentManager:RegisterEquipmentChangedListener(function(e)
	if e.Equipped then
		Quiver_StartRecharge(e.Character, e.Item)
	else
		GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_QUIVER_DRAW_RECHARGE")
		Quiver_RemoveTempArrows(e.Character)
	end
end, {Tag = "LLWEAPONEX_Quiver"})

---@param char CharacterParam
function Quiver_RemoveTempArrows(char)
	local character = GameHelpers.GetCharacter(char)
	if character ~= nil then
		for i,v in pairs(character:GetInventoryItems()) do
			if IsTagged(v, "LLWEAPONEX_Quiver_TemporaryArrow") == 1 then
				ItemRemove(v)
			end
		end
	end
end
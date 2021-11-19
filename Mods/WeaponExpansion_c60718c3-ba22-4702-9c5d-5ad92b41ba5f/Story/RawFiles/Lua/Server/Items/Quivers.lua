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
			ApplyStatus(character.MyGuid, "LLWEAPONEX_QUIVER_DRAW_RECHARGE", 3.0, 0, character.MyGuid)
		else
			status.CurrentLifeTime = status.LifeTime
			status.RequestClientSync = true
		end
	else
		ClearTag(quiver.MyGuid, "LLWEAPONEX_ItemNeedsRecharging")
	end
end

RegisterSkillListener("Shout_LLWEAPONEX_Quiver_DrawArrow", function(skill, char, state, data)
	if state == SKILL_STATE.CAST then
		local character = Ext.GetCharacter(char)
		local addedArrow = false
		local weapon = CharacterGetEquippedItem(char, "Weapon")
		if not StringHelpers.IsNullOrEmpty(weapon) then
			weapon = Ext.GetItem(weapon)
			if weapon:HasTag("LLWEAPONEX_Greatbow") then
				CharacterGiveReward(char, "ST_LLWEAPONEX_Quiver_GreatbowArrows", 1)
				addedArrow = true
			elseif weapon.Stats.WeaponType == "Bow" then
				CharacterGiveReward(char, "ST_LLWEAPONEX_Quiver_Arrows", 1)
				addedArrow = true
			end
		end
		if addedArrow then
			local quiver = CharacterGetEquippedItem(character.MyGuid, "Belt")
			if not StringHelpers.IsNullOrEmpty(quiver) and IsTagged(quiver, "LLWEAPONEX_Quiver") == 1 then
				Quiver_StartRecharge(character, Ext.GetItem(quiver))
			end
		end
	end
end)

RegisterStatusListener("Removed", "LLWEAPONEX_QUIVER_DRAW_RECHARGE", function(char, status)
	local character = Ext.GetCharacter(char)
	if character ~= nil and not character.Dead then
		local shouldRecharge = false
		local quiver = CharacterGetEquippedItem(character.MyGuid, "Belt")
		if not StringHelpers.IsNullOrEmpty(quiver) and IsTagged(quiver, "LLWEAPONEX_Quiver") == 1 then
			Quiver_StartRecharge(character, Ext.GetItem(quiver), 1)
		end
	end
end)

RegisterItemListener("EquipmentChanged", "Tag", "LLWEAPONEX_Quiver", function(char, item, tag, equipped)
	if equipped then
		Quiver_StartRecharge(char, item)
	else
		RemoveStatus(char.MyGuid, "LLWEAPONEX_QUIVER_DRAW_RECHARGE")
		Quiver_RemoveTempArrows(char.MyGuid)
	end
end)

function Quiver_RemoveTempArrows(char)
	local character = Ext.GetCharacter(char)
	if character ~= nil then
		for i,v in pairs(character:GetInventoryItems()) do
			if IsTagged(v, "LLWEAPONEX_Quiver_TemporaryArrow") == 1 then
				ItemRemove(v)
			end
		end
	end
end
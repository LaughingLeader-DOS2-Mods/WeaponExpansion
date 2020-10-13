local function EquipBalrinAxe(char, refreshSkill, deleteData)
	local axeData = PersistentVars.SkillData.ThrowBalrinAxe[char]
	if axeData ~= nil then
		SetOnStage(axeData.Item, 1)
		NRD_CharacterEquipItem(char, axeData.Item, axeData.Slot, 0, 0, 1, 1)
		if refreshSkill == true then
			GameHelpers.Skill.SetCooldown(char, axeData.Skill, 0.0, true)
		end
		if deleteData ~= false then
			PersistentVars.SkillData.ThrowBalrinAxe[char] = nil
		end
		RemoveStatus(char, "LLWEAPONEX_BALRINAXE_DISARMED_INFO")
	end
end

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData|HitData
local function OnBalrinAxeThrown(skill, char, state, data)
	if state == SKILL_STATE.USED then
		local slot,item = GameHelpers.Item.GetEquippedTaggedItemSlot(char, "LLWEAPONEX_UniqueThrowingAxeA")
		if slot ~= nil then
			PersistentVars.SkillData.ThrowBalrinAxe[char] = {
				Item = item,
				Slot = slot,
				Skill = skill,
				Target = "",
			}
		end
	elseif state == SKILL_STATE.CAST then
		local axeData = PersistentVars.SkillData.ThrowBalrinAxe[char]
		CharacterUnequipItem(char, axeData.Item)
		SetOnStage(axeData.Item, 0)
		Osi.ProcObjectTimer(char, "LLWEAPONEX_Timers_Throwing_BalrinAxeThrowMissed", 1200)
		StartTimer("Timers_LLWEAPONEX_CheckForAxeMiss", 1200, char)
	elseif state == SKILL_STATE.HIT then
		CancelTimer("Timers_LLWEAPONEX_CheckForAxeMiss", char)
		if not data.Success then
			EquipBalrinAxe(char)
			CharacterStatusText(char, "LLWEAPONEX_StatusText_BalrinAxeTimedOut")
		else
			local axeData = PersistentVars.SkillData.ThrowBalrinAxe[char]
			if axeData ~= nil then
				axeData.Target = data.Target
				DeathManager.ListenForDeath("ThrowBalrinAxe", data.Target, char, 1000)
			end
		end
	elseif state == SKILL_STATE.PROJECTILEHIT then
		CancelTimer("Timers_LLWEAPONEX_CheckForAxeMiss", char)
		if StringHelpers.IsNullOrEmpty(data.Target) then
			EquipBalrinAxe(char)
			CharacterStatusText(char, "LLWEAPONEX_StatusText_BalrinAxeTimedOut")
		end
	end
end

DeathManager.RegisterListener("ThrowBalrinAxe", function(target, attacker, targetDied)
	if targetDied then
		EquipBalrinAxe(attacker, true)
	end
end)

RegisterSkillListener("Projectile_LLWEAPONEX_Throw_UniqueAxe_A", OnBalrinAxeThrown)
RegisterSkillListener("Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand", OnBalrinAxeThrown)

RegisterItemListener("EquipmentChanged", "Tag", "LLWEAPONEX_UniqueThrowingAxeA", function(char, item, tag, equipped)
	if equipped then
		local slot = GameHelpers.Item.GetEquippedSlot(char.MyGuid, item.MyGuid)
		if slot == "Weapon" then
			GameHelpers.Skill.Swap(char.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand", "Projectile_LLWEAPONEX_Throw_UniqueAxe_A", true, false)
		else
			GameHelpers.Skill.Swap(char.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A", "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand", true, false)
		end
	else
		if CharacterHasSkill(char.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A") then
			CharacterRemoveSkill(char.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A")
		end
		if CharacterHasSkill(char.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand") then
			CharacterRemoveSkill(char.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand")
		end
	end
end)

RegisterStatusListener("StatusApplied", "LLWEAPONEX_BALRINAXE_RECOVER_START", function(target, status, source)
	local data = PersistentVars.SkillData.ThrowBalrinAxe[target]
	if data ~= nil then
		EquipBalrinAxe(target, true)
		CharacterStatusText(target, "LLWEAPONEX_StatusText_BalrinAxeRetrieved")
		RemoveStatus(source, "LLWEAPONEX_WEAPON_THROW_UNIQUE_AXE1H_A")
		ApplyStatus(source, "LLWEAPONEX_BALRINAXE_DEBUFF", 6.0, 1, target)
	end
end)

RegisterStatusListener("StatusRemoved", "LLWEAPONEX_WEAPON_THROW_UNIQUE_AXE1H_A", function(target, status)
	for char,data in pairs(PersistentVars.SkillData.ThrowBalrinAxe) do
		if data.Target == target then
			EquipBalrinAxe(char, true)
			CharacterStatusText(char, "LLWEAPONEX_StatusText_BalrinAxeTimedOut")
			break
		end
	end
end)
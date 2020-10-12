function GainThrowingMasteryXP(uuid, target)
	if IsPlayer(uuid) then
		MasterySystem.GrantWeaponSkillExperience(uuid, target, "LLWEAPONEX_ThrowingAbility")
	end
end

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData|HitData
local function OnBalrinAxeThrow(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		GainThrowingMasteryXP(char, data.Target)
	end
end
RegisterSkillListener("Projectile_LLWEAPONEX_Throw_UniqueAxe_A", OnBalrinAxeThrow)
RegisterSkillListener("Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand", OnBalrinAxeThrow)


---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData|HitData
local function OnThrowWeapon(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		local mainhand = StringHelpers.GetUUID(CharacterGetEquippedItem(char, "Weapon"))
		local offhand = StringHelpers.GetUUID(CharacterGetEquippedItem(char, "Shield"))
		PersistentVars.SkillData.ThrowWeapon[char] = {
			Weapon = mainhand,
			Shield = offhand
		}
	elseif state == SKILL_STATE.HIT and data.Success then
		DeathManager.ListenForDeath("ThrowWeapon", data.Target, char, 500)
	end
end
RegisterSkillListener("Projectile_LLWEAPONEX_ThrowWeapon", OnThrowWeapon)
RegisterSkillListener("Projectile_LLWEAPONEX_ThrowWeapon_Enemy", OnThrowWeapon)

DeathManager.RegisterListener("ThrowWeapon", function(target, attacker)
	local data = PersistentVars.SkillData.ThrowWeapon[attacker]
	if data ~= nil then
		if not StringHelpers.IsNullOrEmpty(data.Weapon) then
			NRD_CharacterEquipItem(attacker, data.Weapon, "Weapon", 0, 0, 1, 1)
		end
		if not StringHelpers.IsNullOrEmpty(data.Shield) then
			NRD_CharacterEquipItem(attacker, data.Shield, "Shield", 0, 0, 1, 1)
		end
		PersistentVars.SkillData.ThrowWeapon[attacker] = nil
	end
end)
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
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Throw_UniqueAxe_A", OnBalrinAxeThrow)
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand", OnBalrinAxeThrow)
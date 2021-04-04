local PrepareEffects = {
	Projectile_LLWEAPONEX_Greatbow_PiercingShot = {
		DWARF = {
			[0] = "LLWEAPONEX_FX_GREATBOW_PIERCINGSHOT_PREPARE_DM",
			[1] = "LLWEAPONEX_FX_GREATBOW_PIERCINGSHOT_PREPARE_DF",
		},
		ELF = {
			[0] = "LLWEAPONEX_FX_GREATBOW_PIERCINGSHOT_PREPARE_EM",
			[1] = "LLWEAPONEX_FX_GREATBOW_PIERCINGSHOT_PREPARE_EF",
		},
		HUMAN = {
			[0] = "LLWEAPONEX_FX_GREATBOW_PIERCINGSHOT_PREPARE_HM",
			[1] = "LLWEAPONEX_FX_GREATBOW_PIERCINGSHOT_PREPARE_HF",
		},
		LIZARD = {
			[0] = "LLWEAPONEX_FX_GREATBOW_PIERCINGSHOT_PREPARE_LM",
			[1] = "LLWEAPONEX_FX_GREATBOW_PIERCINGSHOT_PREPARE_LF",
		},
	},
	Projectile_LLWEAPONEX_Greatbow_Knockback = {
		DWARF = {
			[0] = "LLWEAPONEX_FX_GREATBOW_CUSHIONFORCE_PREPARE_DM",
			[1] = "LLWEAPONEX_FX_GREATBOW_CUSHIONFORCE_PREPARE_DF",
		},
		ELF = {
			[0] = "LLWEAPONEX_FX_GREATBOW_CUSHIONFORCE_PREPARE_EM",
			[1] = "LLWEAPONEX_FX_GREATBOW_CUSHIONFORCE_PREPARE_EF",
		},
		HUMAN = {
			[0] = "LLWEAPONEX_FX_GREATBOW_CUSHIONFORCE_PREPARE_HM",
			[1] = "LLWEAPONEX_FX_GREATBOW_CUSHIONFORCE_PREPARE_HF",
		},
		LIZARD = {
			[0] = "LLWEAPONEX_FX_GREATBOW_CUSHIONFORCE_PREPARE_LM",
			[1] = "LLWEAPONEX_FX_GREATBOW_CUSHIONFORCE_PREPARE_LF",
		},
	}
}

PrepareEffects.Projectile_LLWEAPONEX_Greatbow_PiercingShot_Enemy = PrepareEffects.Projectile_LLWEAPONEX_Greatbow_PiercingShot
PrepareEffects.Projectile_LLWEAPONEX_Greatbow_Knockback_Enemy = PrepareEffects.Projectile_LLWEAPONEX_Greatbow_Knockback

local function PlaySkillEffect(char, state, funcParams, tagData)
	if state == SKILL_STATE.PREPARE or state == SKILL_STATE.USED then
		for tag,effectData in pairs(tagData) do
			if IsTagged(char,tag) == 1 then
				local isFemale = IsTagged(char, "FEMALE")
				local effectStatus = effectData[isFemale]
				if effectStatus ~= nil and HasActiveStatus(char, effectStatus) == 0 then
					if state == SKILL_STATE.PREPARE then
						if HasActiveStatus(char, effectStatus) == 0 then
							ApplyStatus(char, effectStatus, -1.0, 1, char)
						end
					else
						if HasActiveStatus(char, effectStatus) == 1 then
							RemoveStatus(char, effectStatus, -1.0, 1, char)
						end
					end
					return
				end
			end
		end
	end
end

for skill,tagData in pairs(PrepareEffects) do
	RegisterSkillListener(skill, function(char,state,funcParams) PlaySkillEffect(char,state,funcParams,tagData); end)
end
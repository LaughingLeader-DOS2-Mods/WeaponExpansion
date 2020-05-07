SKILL_STATE = LeaderLib.SKILL_STATE
local function AimedShotBonuses(char, state, funcParams)
	if state == SKILL_STATE.PREPARE then
		--ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", -1.0, 0, char)
		--Mods.LeaderLib.StartTimer("Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus", 1000, char)
	elseif state == SKILL_STATE.USED then
		if HasActiveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY") == 0 then
			ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", 12.0, 1, char)
		end
		if #funcParams == 1 then
			local target = funcParams[1]
			if HasActiveStatus(target, "MARKED") == 1 then
				ApplyStatus(_Char, "LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", 12.0, 1, char);
			end
		end
	elseif state == SKILL_STATE.CAST then
		Osi.LeaderLib_Timers_StartObjectTimer(char, 1500, "Timers_LLWEAPONEX_Rifle_AimedShot_ClearBonuses", "LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
	elseif state == SKILL_STATE.HIT then
		Osi.LeaderLib_Timers_CancelObjectObjectTimer(char, "Timers_LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
		SetStoryEvent(char, "LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
	end
end

LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Rifle_AimedShot", AimedShotBonuses)

-- local function CheckAimedShotBonus(funcParams)
-- 	local char = funcParams[1]
-- 	if char ~= nil and HasActiveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY") == 1 then
-- 		local removeStatus = false
-- 		local action = NRD_CharacterGetCurrentAction(char)
-- 		if action ~= "PrepareSkill" and action ~= "UseSkill" then
-- 			removeStatus = true
-- 		else
-- 			local skillprototype = NRD_ActionStateGetString(char, "SkillId")
-- 			if skillprototype ~= "" and skillprototype ~= nil then
-- 				local skill = string.gsub(skillprototype, "_%-?%d+$", "")
-- 				if skill ~= "Projectile_LLWEAPONEX_Rifle_AimedShot" then
-- 					removeStatus = true
-- 				end
-- 			end
-- 		end
-- 		if removeStatus then
-- 			RemoveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY")
-- 		else
-- 			Mods.LeaderLib.StartTimer("Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus", 1000, char)
-- 		end
-- 	end
-- end

-- OnTimerFinished["Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus"] = CheckAimedShotBonus
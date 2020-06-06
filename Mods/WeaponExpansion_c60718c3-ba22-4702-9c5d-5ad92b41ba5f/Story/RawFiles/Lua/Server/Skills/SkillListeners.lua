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
				ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", 12.0, 1, char);
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

local function Greatbow_PiercingShot_DragonBonus(char, state, funcParams)
	if state == SKILL_STATE.HIT then
		if #funcParams == 1 then
			local target = funcParams[1]
			if IsTagged(target, "DRAGON") == 1 then
				ApplyStatus(target, "LLWEAPONEX_DRAGONS_BANE", 6.0, 0, char)
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Greatbow_PiercingShot", Greatbow_PiercingShot_DragonBonus)

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

local function SkyShot(char, state, funcParams)
	if state == SKILL_STATE.HIT and ObjectGetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus") == 0 then
		local weapon = CharacterGetEquippedWeapon(char)
		if weapon ~= nil and GetTemplate(weapon) == "WPN_UNIQUE_LLWEAPONEX_Greatbow_Lightning_Bow_2H_A_7efec0e0-1c2e-4f0d-9ec5-e3a1f40c97b8" then
			local target = funcParams[1]
			if target ~= nil then
				GameHelpers.ExplodeProjectile(char, target, "Projectile_LLWEAPONEX_Greatbow_LightningStrike")
			end
		end
	elseif state == SKILL_STATE.USED then
		local weapon = CharacterGetEquippedWeapon(char)
		if weapon ~= nil and GetTemplate(weapon) == "WPN_UNIQUE_LLWEAPONEX_Greatbow_Lightning_Bow_2H_A_7efec0e0-1c2e-4f0d-9ec5-e3a1f40c97b8" then
			-- Position
			if #funcParams == 3 then
				local x = funcParams[1]
				local y = funcParams[2]
				local z = funcParams[3]
				SetVarFloat3(char, "LLWEAPONEX_Omnibolt_SkyShotWorldPosition", x,y,z)
				ObjectSetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus", 0)
			elseif #funcParams == 1 then
				ObjectClearFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus", 0)
			end
		end
	elseif state == SKILL_STATE.CAST then
		Mods.LeaderLib.StartTimer("Timers_LLWEAPONEX_ProcGreatbowLightningStrike", 750, char)
	end
end

LeaderLib.RegisterSkillListener("Projectile_SkyShot", SkyShot)
LeaderLib.RegisterSkillListener("Projectile_EnemySkyShot", SkyShot)

local function ProcGreatbowLightningStrike(funcParams)
	local char = funcParams[1]
	if char ~= nil and ObjectGetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus") == 1 then
		local x,y,z = GetVarFloat3(char, "LLWEAPONEX_Omnibolt_SkyShotWorldPosition")
		GameHelpers.ExplodeProjectileAtPosition(char, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", x,y,z)
	end
end

OnTimerFinished["Timers_LLWEAPONEX_ProcGreatbowLightningStrike"] = ProcGreatbowLightningStrike
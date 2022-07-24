local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 1, {
	rb:Create("GREATBOW_RICOCHET", {
		Skills = {"Projectile_Ricochet", "Projectile_EnemyRicochet"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Greatbow_Ricochet", "<font color='#F19824'>Eat hit deals [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet] in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet:ExplodeRadius]m radius around the target.</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			SetTag(e.Data.Target, "LLWEAPONEX_RicochetTarget")
			GameHelpers.Skill.Explode(e.Data.Target, "Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet", e.Character)
			Timer.StartObjectTimer("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", e.Data.Target, 50)
		end
	end).TimerFinished("LLWEAPONEX_MasteryBonus_ClearRicochetTarget", function (self, e, bonuses)
		if e.Data.UUID then
			ClearTag(e.Data.UUID, "LLWEAPONEX_RicochetTarget")
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Greatbow, 4, {
	
})

if not Vars.IsClient then
	local _RACE_ARROW_PREPARE_EFFECTS = {
		DWARF = {
			[true] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Arrow_Prepare_Dwarf_Female", Bone = "LowerArm_R_Twist_Bone", Delay = 425},
			[false] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Arrow_Prepare_Dwarf_Male", Bone = "LowerArm_R_Twist_Bone", Delay = 425},
		},
		ELF = {
			[true] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Arrow_Prepare_Elf_Female", Bone = "Dummy_R_Hand", Delay = 600},
			[false] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Arrow_Prepare_Elf_Male", Bone = "Dummy_R_Hand", Delay = 600},
		},
		HUMAN = {
			[true] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Arrow_Prepare_Human_Female", Bone = "Dummy_R_Hand", Delay = 825},
			[false] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Arrow_Prepare_Human_Male", Bone = "Dummy_R_Hand", Delay = 825},
		},
		LIZARD = {
			[true] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Arrow_Prepare_Lizard_Female", Bone = "LowerArm_R_Twist_Bone", Delay = 580},
			[false] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Arrow_Prepare_Lizard_Male", Bone = "LowerArm_R_Twist_Bone", Delay = 600},
		},
	}

	local _RACE_ARROW_PREPARE_EFFECTS_LIGHTNING = {
		DWARF = {
			[true] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Lightning_Prepare_Dwarf_Female", Bone = "LowerArm_R_Twist_Bone", Delay = 425},
			[false] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Lightning_Prepare_Dwarf_Male", Bone = "LowerArm_R_Twist_Bone", Delay = 425},
		},
		ELF = {
			[true] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Lightning_Prepare_Elf_Female", Bone = "Dummy_R_Hand", Delay = 600},
			[false] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Lightning_Prepare_Elf_Male", Bone = "Dummy_R_Hand", Delay = 600},
		},
		HUMAN = {
			[true] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Lightning_Prepare_Human_Female", Bone = "Dummy_R_Hand", Delay = 825},
			[false] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Lightning_Prepare_Human_Male", Bone = "Dummy_R_Hand", Delay = 825},
		},
		LIZARD = {
			[true] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Lightning_Prepare_Lizard_Female", Bone = "LowerArm_R_Twist_Bone", Delay = 580},
			[false] = {Effect = "LLWEAPONEX_FX_Projectiles_Greatbow_Lightning_Prepare_Lizard_Male", Bone = "LowerArm_R_Twist_Bone", Delay = 600},
		},
	}

	---@param character EsvCharacter
	local function PlayGreatbowArrowEffect(character)
		local race = GameHelpers.Character.GetBaseRace(character)
		if race then
			local isFemale = GameHelpers.Character.IsFemale(character)
			local effectData = nil
			if character:HasTag("LLWEAPONEX_Omnibolt_Equipped") then
				effectData = _RACE_ARROW_PREPARE_EFFECTS_LIGHTNING[race][isFemale]
			else
				effectData = _RACE_ARROW_PREPARE_EFFECTS[race][isFemale]
			end
			if effectData then
				local GUID = character.MyGuid
				EffectManager.PlayEffect(effectData.Effect, character, {Bone=effectData.Bone, Loop=true})
				local timerName = string.format("LLWEAPONEX_StopGreatbowEffect_%s", GUID)
				Timer.StartOneshot(timerName, effectData.Delay, function (e)
					--EffectManager.StopLoopEffectByHandle(fx.Handle)
					EffectManager.StopEffectsByNameForObject(effectData.Effect, GUID)
				end)
			end
		end
	end

	Ext.Events.SessionLoaded:Subscribe(function (e)
		if Ext.Mod.IsModLoaded(MODID.Mimicry) then
			SkillManager.Register.Used("Projectile_LLMIME_MimicGreatBowAttack", function (e)
				PlayGreatbowArrowEffect(e.Character)
			end)
		end
	end)

	Events.OnBasicAttackStart:Subscribe(function (e)
		if e.Attacker:HasTag("LLWEAPONEX_Greatbow_Equipped") then
			PlayGreatbowArrowEffect(e.Attacker)
		end
	end)

	SkillManager.Register.Hit({"Projectile_LLWEAPONEX_Greatbow_Knockback", "Projectile_LLWEAPONEX_Greatbow_Knockback_Enemy"}, function (e)
		if e.Data.Success then
			local maxDist = GameHelpers.GetExtraData("LLWEAPONEX_CushionForce_MaxPushDistance", 12)
			local skillRange = e.Data.SkillData.TargetRadius
			local subDist = math.max(maxDist, skillRange)
			local dist = math.max(1, subDist - GameHelpers.Math.GetDistance(e.Character, e.Data.TargetObject))
			GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_GREATBOW_CUSHION_FORCE", -2.0, true, e.Character)
			GameHelpers.ForceMoveObject(e.Character, e.Data.TargetObject, dist, e.Skill, nil, nil, "CushionForce")
		end
	end)

	Events.ForceMoveFinished:Subscribe(function (e)
		if e.Target and e.Source then
			GameHelpers.Status.Remove(e.Target, "LLWEAPONEX_GREATBOW_CUSHION_FORCE")
			local startPos = e.StartingPosition
			local landPos = e.Target.WorldPos
			local heightDiff = startPos[2] - landPos[2]
			fprint(LOGLEVEL.TRACE, "[WeaponExpansion:CushionForce] FallDistance(%s) PushDistance(%s)", heightDiff, e.Distance)
			EffectManager.PlayEffectAt("RS3_FX_Skills_Totem_Lash_Impact_Root_01", landPos)
			EffectManager.PlayEffect("RS3_FX_GP_Combat_CameraShake_A", e.Target)
			if GameHelpers.Character.CanAttackTarget(e.Target, e.Source) then
				local maxDist = GameHelpers.GetExtraData("LLWEAPONEX_CushionForce_MaxPushDistance", 12)
				local distDamageMult = ((math.min(maxDist, e.Distance) / maxDist) - 0.1) * 100
				GameHelpers.Damage.ApplySkillDamage(e.Source, e.Target, "Projectile_LLWEAPONEX_Status_CushionForce_DistDamage", {SkillDataParamModifiers={["Damage Multiplier"] = distDamageMult}})
				
				if heightDiff > 1 then
					local fallDamageMult = ((math.min(maxDist, e.Distance) / maxDist) + 0.25) * 100
					GameHelpers.Damage.ApplySkillDamage(e.Source, e.Target, "Projectile_LLWEAPONEX_Status_CushionForce_FallDamage", {SkillDataParamModifiers={["Damage Multiplier"] = fallDamageMult}})
				end
			end
		end
	end, {MatchArgs={ID="CushionForce"}})
end
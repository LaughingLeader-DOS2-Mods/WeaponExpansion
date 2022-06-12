local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData
local isClient = Ext.IsClient()

MasteryBonusManager.AddRankBonuses(MasteryID.Unarmed, 1, {
	rb:Create("UNARMED_PETRIFYING_SLAM", {
		Skills = {"Target_PetrifyingTouch", "Target_EnemyPetrifyingTouch"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Unarmed_PetrifyingTouch", "<font color='#FFCE58'>Slam the target with your palm, knocking them back <font color='#33FF00'>[ExtraData:LLWEAPONEX_MB_Unarmed_PetrifyingTouch_KnockbackDistance]m</font> and dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage].</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			PlayEffect(char, "RS3_FX_Char_Creatures_Condor_Cast_Warrior_01", "Dummy_R_HandFX")
			PlayEffect(char, "RS3_FX_Char_Creatures_Condor_Cast_Warrior_01", "Dummy_L_HandFX")
		elseif state == SKILL_STATE.HIT and data.Success then
			GameHelpers.Damage.ApplySkillDamage(char, data.Target, "Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit, GetDamageFunction = Skills.DamageFunctions.UnarmedSkillDamage})
			--GameHelpers.Skill.Explode(data.Target, "Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage", char)
			local forceDistance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Unarmed_PetrifyingTouch_KnockbackDistance", 4.0)
			if forceDistance > 0 then
				local x,y,z = GetPosition(data.Target)
				PlayEffectAtPosition("RS3_FX_Skills_Void_Power_Attack_Impact_01",x,y,z)
				PlayEffect(data.Target, "RS3_FX_Skills_Warrior_Impact_Weapon_01", "Dummy_BodyFX")
				GameHelpers.ForceMoveObject(char, data.Target, forceDistance, skill)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Unarmed, 2, {
	rb:Create("UNARMED_WHIRLWIND", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Unarmed_Whirlwind", "<font color='#FFCE58'>Targets hit are pulled in closer to you.</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success and UnarmedHelpers.HasUnarmedWeaponStats(e.Character.Stats) then
			local radius = e.Data.SkillData.AreaRadius
			if radius >= 2 then
				--Reduce the distance slightly so they don't land on top of you
				radius = radius - 1
			end
			if radius > 0 then
				GameHelpers.ForceMoveObject(e.Character, e.Data.Target, -radius, e.Skill)
			end
		end
	end),
	rb:Create("UNARMED_BLINKSTRIKE", {
		Skills = {"MultiStrike_BlinkStrike", "MultiStrike_EnemyBlinkStrike"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Unarmed_BlinkStrike", "<font color='#FFCE58'>Lower the cooldown of a random [Handle:h8e4bebcbg21c7g43dag8b05gd3b13c1be651:Warfare] skill for each target hit.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			if PersistentVars.MasteryMechanics.BlinkStrikeTargetsHit[char] == nil then
				PersistentVars.MasteryMechanics.BlinkStrikeTargetsHit[char] = 0
			end
			PersistentVars.MasteryMechanics.BlinkStrikeTargetsHit[char] = PersistentVars.MasteryMechanics.BlinkStrikeTargetsHit[char] + 1
			Timer.StartObjectTimer("LLWEAPONEX_Unarmed_BlinkStrikeBonus", char, 1000)
		end
	end),
})

if not isClient then
	local loweredCooldownText = ts:CreateFromKey("LLWEAPONEX_StatusText_Unarmed_BlinkStrikeBonus", "<font color='#FFCE58'>Unarmed Mastery: Lowered Cooldown of [1] by [2] Turn(s)</font>")
	Timer.RegisterListener("LLWEAPONEX_Unarmed_BlinkStrikeBonus", function (timerName, char)
		local targetsHit = PersistentVars.MasteryMechanics.BlinkStrikeTargetsHit[char] or 0
		if targetsHit > 0 then
			local character = GameHelpers.GetCharacter(char)
			if character then
				local skills = {}
				for i,v in pairs(character:GetSkills()) do
					local skill = character:GetSkillInfo(v)
					if skill.ActiveCooldown > 0 then
						local ability = Ext.StatGetAttribute(v, "Ability")
						if ability == "Warrior" then
							skills[#skills+1] = v
						end
					end
				end
				if #skills > 0 then
					local skill = Common.GetRandomTableEntry(skills)
					local cdReduction = (targetsHit * 6.0)
					local nextCooldown = math.max(0, character:GetSkillInfo(skill).ActiveCooldown - cdReduction)
					GameHelpers.Skill.SetCooldown(char, skill, nextCooldown)
					local displayNameKey = Ext.StatGetAttribute(skill, "DisplayName")
					local name = GameHelpers.GetStringKeyText(displayNameKey)
					CharacterStatusText(char, loweredCooldownText:ReplacePlaceholders(name, targetsHit))
				end
			end
		end
		PersistentVars.MasteryMechanics.BlinkStrikeTargetsHit[char] = nil
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Unarmed, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Unarmed, 4, {
	
})
UnarmedHelpers.RegisterUnarmedStat("ARM_UNIQUE_LLWEAPONEX_PowerGauntlets_A", "WPN_UNIQUE_LLWEAPONEX_PowerGauntlets_A")

if not Vars.IsClient then
	local function DealUnarmedArmorDamage(target, source)
		local unarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(source.Stats)
		if unarmedWeapon then
			local skillId = "Projectile_LLWEAPONEX_PowerGauntlets_ArmorDamageBonus"
			--SkillConfiguration.TempData.RecalculatedUnarmedSkillDamage[source.MyGuid] = skillId
			GameHelpers.Damage.ApplySkillDamage(source, target, skillId, {MainWeapon=unarmedWeapon, HitParams = HitFlagPresets.EventlessMagicHit})
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_ThrowObject_Impact_Light_Root_01", target.WorldPos)
		end
	end
	
	StatusManager.Register.Applied("LLWEAPONEX_POWERGAUNTLETS_HIT", function (target, status, source, statusType)
		local perc = GameHelpers.GetExtraData("LLWEAPONEX_PowerGauntlets_ArmorDamagePercentage", 20)
		if perc > 0
		and GameHelpers.Ext.ObjectIsCharacter(target)
		and GameHelpers.Ext.ObjectIsCharacter(source)
		and target.Stats.CurrentArmor > 0 and target.Stats.MaxArmor > 0
		then
			if not ArmorSystemIsDisabled() then
				local damage = Ext.Utils.Round(target.Stats.MaxArmor * (perc / 100))
				if damage > 0 then
					target.Stats.CurrentArmor = math.max(0, target.Stats.CurrentArmor - damage)
					CharacterStatusText(target.MyGuid, Text.StatusText.ArmorBreak:ReplacePlaceholders(string.format("<font color='%s'>-%i</font>", LocalizedText.DamageTypeNames.Physical.Color, damage)))
					--y = y + target.RootTemplate.AIBoundsHeight / 2
					EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_ThrowObject_Impact_Light_Root_01", target.WorldPos)
					--PlayEffectAtPosition("LLWEAPONEX_FX_Skills_ThrowObject_Impact_Light_Root_01", x, y, z)
				end
				
			else
				local armorBreakStatus = Ext.PrepareStatus(target.MyGuid, "LLWEAPONEX_POWERGAUNTLETS_ARMORBREAK", 6.0)
				if armorBreakStatus then
					armorBreakStatus.StatsMultiplier = GameHelpers.Math.Clamp(perc, 1.0, perc)
					armorBreakStatus.StatusSourceHandle = source.Handle
					Ext.ApplyStatus(armorBreakStatus)
				end
			end
		end
	end)
else
	local armorBreakText = Classes.TranslatedString:CreateFromKey("LLWEAPONEX_PowerGauntlets_ArmorBreak", "Destroy [1]% [2] on Unarmed Hit")
	local armorReductionText = Classes.TranslatedString:CreateFromKey("LLWEAPONEX_PowerGauntlets_ArmorReduction", "Lower [2] by [1]% on Unarmed Hit")

	TooltipParams.SpecialParamFunctions.LLWEAPONEX_PowerGauntletsBonus = function(param, statCharacter)
		local perc = GameHelpers.GetExtraData("LLWEAPONEX_PowerGauntlets_ArmorDamagePercentage", 20)
		if perc <= 0 then
			return ""
		end
		if not ArmorSystemIsDisabled() then
			return armorBreakText:ReplacePlaceholders(perc, LocalizedText.CharacterSheet.PhysicalArmour.Value)
		else
			local maxPhysArmor = GameHelpers.GetTranslatedString("h856999degd5aag435eg895fg50546f5a87f6", "Maximum Physical Armour")
			return armorReductionText:ReplacePlaceholders(perc, maxPhysArmor)
		end
	end
end
local LENGTH = 200

local function FindTooltipTypeIndex(ui, enumType)
	local index = 0
	local totalNil = 0
	while index < LENGTH and totalNil < 30 do
		index = index + 1
		local tooltipEntryType = ui:GetValue("tooltip_array", "number", index)
		if tooltipEntryType ~= nil then
			if tooltipEntryType == enumType then
				return index
			end
			if tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemName then
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemWeight then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemGoldValue then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemLevel then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemDescription then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemRarity then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemUseAPCost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemAttackAPCost then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ResistanceBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.AbilityBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.OtherStatBoost then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.VitalityBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ChanceToHitBoost then
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.DamageBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.APCostBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.APMaximumBoost then
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.APStartBoost then
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.APRecoveryBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.CritChanceBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ArmorBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumableDuration then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumablePermanentDuration then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumableEffect then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumableDamage then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ExtraProperties then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Flags then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ItemRequirement then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponDamage then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponDamagePenalty then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponCritMultiplier then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponCritChance then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponRange then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Durability then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.CanBackstab then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.AccuracyBoost then
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.DodgeBoost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.EquipmentUnlockedSkill then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.WandSkill then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.WandCharges then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ArmorValue then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ArmorSlotType then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Blocking then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.NeedsIdentifyLevel then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.IsQuestItem then
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.PriceToIdentify then
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.PriceToRepair then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.PickpocketInfo then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Engraving then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ContainerIsLocked then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Tags then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillName then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillIcon then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillSchool then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillTier then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillRequiredEquipment then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillAPCost then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillCooldown then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillDescription then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillProperties then
				index = index + 1
				index = index + 1
				local spacing = ui:GetValue("tooltip_array", "number", index)
				if spacing ~= nil and spacing > 0 then
					local i = 0
					while i < spacing do
						index = index + 1
						index = index + 1
						i = i + 1
					end
				end
				index = index + 1
				local resistIndex = ui:GetValue("tooltip_array", "number", index)
				if resistIndex ~= nil and resistIndex > 0 then
					local i = 0
					while i < resistIndex do
						index = index + 1
						index = index + 1
						i = i + 1
					end
				end
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillDamage then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillRange then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillExplodeRadius then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillCanPierce then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillCanFork then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillStrikeCount then
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillProjectileCount then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillCleansesStatus then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillMultiStrikeAttacks then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillWallDistance then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillPathSurface then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillPathDistance then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillHealAmount then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillDuration then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumableEffectUknown then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Reflection then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillAlreadyLearned then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillOnCooldown then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillAlreadyUsed then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.AbilityTitle then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.AbilityDescription then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.TalentTitle then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.TalentDescription then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillMPCost then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.MagicArmorValue then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.WarningText then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.RuneSlot then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.RuneEffect then
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Equipped then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.ShowSkillIcon then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SkillbookSkill then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.EmptyRuneSlot then
				index = index + 1
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatName then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsDescription then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsDescriptionBoost then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatSTRWeight then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatMEMSlot then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsPointValue then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsTalentsBoost then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsTalentsMalus then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsBaseValue then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsPercentageBoost then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsPercentageMalus then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsPercentageTotal then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsGearBoostNormal then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsATKAPCost then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsCriticalInfos then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPTitle then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPDesc then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPBase then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPBonus then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPMalus then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatsTotalDamage then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.TagDescription then
				index = index + 1
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatusImmunity then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatusBonus then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatusMalus then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.StatusDescription then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Title then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.SurfaceDescription then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Duration then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Fire then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Water then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Earth then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Air then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Poison then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Physical then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Sulfur then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Heal then
				index = index + 1
			elseif tooltipEntryType == LeaderLib.Data.UI.TOOLTIP_TYPE.Splitter then

			else
				Ext.PrintError("[FindTooltipTypeIndex] No valid enum match ("..tostring(tooltipEntryType)..") at index ", index)
				totalNil = totalNil + 1
				index = index + 1
			end
		else
			printValue(ui, index)
		end
		index = index + 1
	end
end

local function printValue(ui, index)
	local val = ui:GetValue("tooltip_array", "number", index)
	if val == nil then
		val = ui:GetValue("tooltip_array", "string", index)
		if val == nil then
			val = ui:GetValue("tooltip_array", "boolean", index)
		end
	end
	if val ~= nil then
		LeaderLib.PrintDebug(" ["..index.."] = ["..tostring(val).."]")
	end
end

local function increaseIndex(ui, index)
	index = index + 1
	printValue(ui, index)
	return index
end

local function tooltipEntryMatch(tooltipEntryType, enum, index)
	if tooltipEntryType == enum then
		LeaderLib.PrintDebug("["..index.."] = "..LeaderLib.Data.UI.TOOLTIP_ENUM[tooltipEntryType].." | "..tooltipEntryType)
		return true
	end
	return false
end

local function DumpTooltipArray(ui)
	LeaderLib.PrintDebug("[DumpTooltipArray]")
	LeaderLib.PrintDebug("=======================")
	local index = 0
	local totalNil = 0
	local typeError = false
	while index < LENGTH and totalNil < 30 do
		local tooltipEntryType = ui:GetValue("tooltip_array", "number", index)
		if tooltipEntryType ~= nil then
			tooltipEntryType = math.floor(tooltipEntryType)
			if tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemName, index) then
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemWeight, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemGoldValue, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemLevel, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemDescription, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemRarity, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemUseAPCost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemAttackAPCost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ResistanceBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.AbilityBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.OtherStatBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.VitalityBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ChanceToHitBoost, index) then
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.DamageBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.APCostBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.APMaximumBoost, index) then
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.APStartBoost, index) then
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.APRecoveryBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.CritChanceBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ArmorBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumableDuration, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumablePermanentDuration, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumableEffect, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumableDamage, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ExtraProperties, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Flags, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ItemRequirement, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponDamage, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponDamagePenalty, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponCritMultiplier, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponCritChance, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.WeaponRange, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Durability, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.CanBackstab, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.AccuracyBoost, index) then
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.DodgeBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.EquipmentUnlockedSkill, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.WandSkill, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.WandCharges, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ArmorValue, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ArmorSlotType, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Blocking, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.NeedsIdentifyLevel, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.IsQuestItem, index) then
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.PriceToIdentify, index) then
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.PriceToRepair, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.PickpocketInfo, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Engraving, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ContainerIsLocked, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Tags, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillName, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillIcon, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillSchool, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillTier, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillRequiredEquipment, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillAPCost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillCooldown, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillDescription, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillProperties, index) then
				index = increaseIndex(ui, index)
				index = index + 1
				local spacing = ui:GetValue("tooltip_array", "number", index)
				if spacing ~= nil and spacing > 0 then
					LeaderLib.PrintDebug(" ["..index.."] = Properties Count ["..tostring(math.floor(spacing)).."]")
					local i = 0
					while i < spacing do
						index = increaseIndex(ui, index)
						index = increaseIndex(ui, index)
						i = i + 1
					end
				end
				index = index + 1
				local resistIndex = ui:GetValue("tooltip_array", "number", index)
				if resistIndex ~= nil and resistIndex > 0 then
					LeaderLib.PrintDebug(" ["..index.."] = Resistances Count ["..tostring(math.floor(resistIndex)).."]")
					local i = 0
					while i < resistIndex do
						index = increaseIndex(ui, index)
						index = increaseIndex(ui, index)
						i = i + 1
					end
				end
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillDamage, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillRange, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillExplodeRadius, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillCanPierce, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillCanFork, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillStrikeCount, index) then
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillProjectileCount, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillCleansesStatus, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillMultiStrikeAttacks, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillWallDistance, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillPathSurface, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillPathDistance, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillHealAmount, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillDuration, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ConsumableEffectUknown, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Reflection, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillAlreadyLearned, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillOnCooldown, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillAlreadyUsed, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.AbilityTitle, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.AbilityDescription, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.TalentTitle, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.TalentDescription, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillMPCost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.MagicArmorValue, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.WarningText, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.RuneSlot, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.RuneEffect, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Equipped, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.ShowSkillIcon, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillbookSkill, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.EmptyRuneSlot, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatName, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsDescription, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsDescriptionBoost, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatSTRWeight, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatMEMSlot, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsPointValue, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsTalentsBoost, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsTalentsMalus, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsBaseValue, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsPercentageBoost, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsPercentageMalus, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsPercentageTotal, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsGearBoostNormal, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsATKAPCost, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsCriticalInfos, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPTitle, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPDesc, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPBase, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPBonus, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsAPMalus, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatsTotalDamage, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.TagDescription, index) then
				index = increaseIndex(ui, index)
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatusImmunity, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatusBonus, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatusMalus, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.StatusDescription, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Title, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.SurfaceDescription, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Duration, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Fire, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Water, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Earth, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Air, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Poison, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Physical, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Sulfur, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Heal, index) then
				index = increaseIndex(ui, index)
			elseif tooltipEntryMatch(tooltipEntryType, LeaderLib.Data.UI.TOOLTIP_TYPE.Splitter, index) then

			else
				Ext.PrintError("[DumpTooltipArray] No valid enum match ("..tostring(tooltipEntryType)..") at index ", index)
				totalNil = totalNil + 1
				index = index + 1
			end
		else
			printValue(ui, index)
		end
		index = index + 1
	end
	LeaderLib.PrintDebug("=======================")
end

return {
	FindTooltipTypeIndex = FindTooltipTypeIndex,
	DumpTooltipArray = DumpTooltipArray
}
---@type TranslatedString
local ts = LeaderLib.Classes.TranslatedString

local totalDamageText = ts:Create("h1035c3e5gc73dg4cc4ga914ga03a8a31e820", "Total damage: [1]-[2]")
--local weaponDamageText = Ext.GetTranslatedString("hfa8c138bg7c52g4b7fgaccdgbe39e6a3324c", "<br>From Weapon: [1]-[2]")
--local offhandWeaponDamageText = Ext.GetTranslatedString("hfe5601bdg2912g4beag895eg6c28772311fb", "From Offhand Weapon: [1]-[2]")
local fromFistsText = ts:Create("h0881bb60gf067g4223ga925ga343fa0f2cbd", "<br>From Fists: [1]-[2]")
local fromClawMainhandText = ts:Create("h9c185c53gfcdag4349gab64g314e51005c21", "From Right Claws: [1]-[2]")
local fromClawOffhandText = ts:Create("he27df360gc0cag4612gaec1g4d8fe4c76b1e", "From Left Claws: [1]-[2]")
local fromUnarmedWeaponText = ts:Create("h6d1ce292g842cg4decg89deg09ec0e293e5e", "<br>From Unarmed Weapon: [1]-[2]")
local dualWieldingPenaltyText = ts:Create("he3980bf8gf554g4dd8g823cgf2ccb71036a6", "Dual wielding penalty: [1]%")
local combatAbilityBoost = ts:Create("hd2273461gcca8g4f08g9eaeged96827308c2", "From [1]: [2] damage increased by [3]% (multiplicative)")
local fromText = ts:Create("h36a3adf0g9aebg448cga0degff9d9226bb56", "From [1]: [2][3]%")
local baseDamageText = ts:Create("haf8ef486g9b5eg46b0g95efg2c5795550240", "Base Damage")
local fromOffhandText = ts:Create("hfe5601bdg2912g4beag895eg6c28772311fb", "From Offhand Weapon: [1]-[2]")

---@param character EclCharacter
---@param stat string
---@param tooltip TooltipData
local function OnDamageStatTooltip(character, stat, tooltip)
	if UnarmedHelpers.HasUnarmedWeaponStats(character.Stats) then
		local weapon,boost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character.Stats)
		local isLizard = character:HasTag("LIZARD")

		if boost > 0 then
			local valueSymbol = "+"
			if boost < 0 then
				valueSymbol = ""
			end
			local rankText = Ext.GetTranslatedStringFromKey(string.format("LLWEAPONEX_Unarmed_Mastery%i", unarmedMasteryRank))
			local element = {
				Type = "StatsPercentageBoost",
				Label = string.format("%s (%s)", fromText:ReplacePlaceholders(rankText, valueSymbol, math.tointeger(boost)), baseDamageText.Value)
			}
			tooltip:AppendElementAfter(element, "StatsGearBoostNormal")
		end

		if hasUnarmedWeapon or not isLizard then
			local damageList,baseMin,baseMax,totalMin,totalMax = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, true, highestAttribute, false, false)

			local totalDamageFinalText = totalDamageText:ReplacePlaceholders(totalMin, totalMax)
			local weaponDamageFinalText = not hasUnarmedWeapon and fromFistsText:ReplacePlaceholders(baseMin, baseMax) or fromUnarmedWeaponText:ReplacePlaceholders(baseMin, baseMax)
			-- From Fists
			local element = tooltip:GetElement("StatsGearBoostNormal")
			element.Label = weaponDamageFinalText
			local element = tooltip:GetElement("StatsTotalDamage")
			element.Label = totalDamageFinalText
		else
			local _,baseMin,baseMax,totalMin,totalMax = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, true, highestAttribute, true, false)
			local dualWieldingPenalty = Ext.ExtraData.DualWieldingDamagePenalty
			local offhandTotalMin = Ext.Round(totalMin * dualWieldingPenalty)
			local offhandTotalMax = Ext.Round(totalMax * dualWieldingPenalty)
			local mainhand = fromClawMainhandText:ReplacePlaceholders(baseMin,baseMax)
			local offhand = fromClawOffhandText:ReplacePlaceholders(baseMin,baseMax)
			local element = tooltip:GetElement("StatsGearBoostNormal")
			element.Label = offhand
			element = {
				Type="StatsGearBoostNormal",
				Label=mainhand
			}
			tooltip:AppendElementAfter(element, "StatsGearBoostNormal")
			local element = tooltip:GetElement("StatsTotalDamage")
			local totalDamageFinalText = totalDamageText:ReplacePlaceholders(totalMin+offhandTotalMin, totalMax+offhandTotalMax)
			element.Label = totalDamageFinalText
		end
		
		local elements = tooltip:GetElements("StatsPercentageBoost")
		if highestAttribute ~= "Strength" then
			local attributeText = LocalizedText.AttributeNames.Strength.Value
			if highestAttribute == "Finesse" then
				attributeText = LocalizedText.AttributeNames.Finesse.Value
			elseif highestAttribute == "Constituton" then
				attributeText = LocalizedText.AttributeNames.Constituton.Value
			end
			local addedAttBoost = false
			local attPercentage = math.tointeger(Game.Math.ScaledDamageFromPrimaryAttribute(character.Stats[highestAttribute]) * 100)
			local valueSymbol = "+"
			if attPercentage < 0 then
				valueSymbol = ""
			end
			for i,v in pairs(elements) do
				if string.find(v.Label, LocalizedText.AttributeNames.Strength.Value) then
					addedAttBoost = true
					v.Label = fromText:ReplacePlaceholders(attributeText, valueSymbol, attPercentage)
					break
				end
			end
			if not addedAttBoost then
				element = {
					Type = "StatsPercentageBoost",
					Label = fromText:ReplacePlaceholders(attributeText, valueSymbol, attPercentage)
				}
				tooltip:AppendElementAfter(element, "StatsPercentageBoost")
			end
		else
			for i,v in pairs(elements) do
				if string.find(v.Label, LocalizedText.AttributeNames.Strength.Value) then
					tooltip:RemoveElement(v)
					tooltip:AppendElementAfter(v, "StatsGearBoostNormal")
					break
				end
			end
		end
		-- if Ext.ExtraData.SkillAbilityPhysicalDamageBoostPerPoint > 0 and character.Stats.WarriorLore > 0 then
		-- 	element = {
		-- 		Type = "StatsPercentageBoost",
		-- 		Label = combatAbilityBoost:ReplacePlaceholders(LocalizedText.AbilityNames.WarriorLore.Value, LocalizedText.DamageTypeHandles.Physical.Text.Value, math.tointeger(Ext.ExtraData.SkillAbilityPhysicalDamageBoostPerPoint * character.Stats.WarriorLore))
		-- 	}
		-- 	tooltip:AppendElementAfter(element, "StatsPercentageBoost")
		-- end
		if isLizard then
			local element = {
				Type = "StatsPercentageMalus",
				Label = dualWieldingPenaltyText:ReplacePlaceholders(string.format("-%s", math.tointeger(Ext.ExtraData.DualWieldingDamagePenalty * 100)))
			}
			tooltip:AppendElementAfter(element, "StatsPercentageBoost")
			local damageBoost = character.Stats.DualWielding * Ext.ExtraData.CombatAbilityDamageBonus
			if damageBoost > 0 then
				tooltip:AppendElementAfter({
					Type = "StatsPercentageBoost",
					Label = fromText:ReplacePlaceholders(LocalizedText.AbilityNames.DualWielding.Value, "+", math.tointeger(damageBoost))
				}, "StatsPercentageBoost")
			end
		else
			local damageBoost = character.Stats.SingleHanded * Ext.ExtraData.CombatAbilityDamageBonus
			if damageBoost > 0 then
				tooltip:AppendElementAfter({
					Type = "StatsPercentageBoost",
					Label = fromText:ReplacePlaceholders(LocalizedText.AbilityNames.SingleHanded.Value, "+", math.tointeger(damageBoost))
				}, "StatsPercentageBoost")
			end
		end
	end
end

local statHandlers = {
	Damage = OnDamageStatTooltip
}

---@param character EclCharacter
---@param stat string
---@param tooltip TooltipData
local function OnStatTooltip(character, stat, tooltip)
	--print(stat, Ext.JsonStringify(tooltip.Data))
	local handler = statHandlers[stat]
	if handler then
		local b,err = xpcall(handler, debug.traceback, character, stat, tooltip)
		if not b then
			Ext.PrintError(err)
		end
	end
end

return OnStatTooltip
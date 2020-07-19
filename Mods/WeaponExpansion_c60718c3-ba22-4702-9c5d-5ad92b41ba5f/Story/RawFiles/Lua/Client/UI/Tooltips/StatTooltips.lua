---@type LeaderLibLocalizedText
local LocalizedText = LeaderLib.LocalizedText

local totalDamageText = Ext.GetTranslatedString("h1035c3e5gc73dg4cc4ga914ga03a8a31e820", "Total damage: [1]-[2]")
--local weaponDamageText = Ext.GetTranslatedString("hfa8c138bg7c52g4b7fgaccdgbe39e6a3324c", "<br>From Weapon: [1]-[2]")
--local offhandWeaponDamageText = Ext.GetTranslatedString("hfe5601bdg2912g4beag895eg6c28772311fb", "From Offhand Weapon: [1]-[2]")
local fromFistsText = Ext.GetTranslatedString("h0881bb60gf067g4223ga925ga343fa0f2cbd", "<br>From Fists: [1]-[2]")
local fromUnarmedWeaponText = Ext.GetTranslatedString("h6d1ce292g842cg4decg89deg09ec0e293e5e", "<br>From Unarmed Weapon: [1]-[2]")

---@param character EsvCharacter
---@param tooltip TooltipData
local function OnDamageStatTooltip(character, stat, tooltip)
	CLIENT_UI.ACTIVE_CHARACTER = character.MyGuid
	--print(character, tooltip, Common.Dump(tooltip))
	if IsUnarmed(character.Stats) then
		local weapon,boost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = GetUnarmedWeapon(character.Stats)
		local baseMin,baseMax,totalMin,totalMax = Math.GetTotalBaseAndCalculatedWeaponDamage(character.Stats, weapon)

		local totalDamageFinalText = totalDamageText:gsub("%[1%]", totalMin):gsub("%[2%]", totalMax)
	
		local weaponDamageFinalText = ""
		if not hasUnarmedWeapon then
			weaponDamageFinalText = fromFistsText:gsub("%[1%]", baseMin):gsub("%[2%]", baseMax)
		else
			weaponDamageFinalText = fromUnarmedWeaponText:gsub("%[1%]", baseMin):gsub("%[2%]", baseMax)
		end

		local element = tooltip:GetElement("StatsTotalDamage")
		element.Label = totalDamageFinalText
		-- From Fists
		element = tooltip:GetElement("StatsGearBoostNormal")
		element.Label = weaponDamageFinalText
		local fromText = Ext.GetTranslatedString("h36a3adf0g9aebg448cga0degff9d9226bb56", "From [1]: [2][3]%")
		local elements = tooltip:GetElements("StatsPercentageBoost")
		if highestAttribute ~= "Strength" then
			local strengthText = Ext.GetTranslatedString("hb4e3a075g5f82g4a0dgaffbg456e5c15c3db", "Strength")
			local attributeText = strengthText
			if highestAttribute == "Finesse" then
				attributeText = LocalizedText.AttributeNames.Finesse.Value
			elseif highestAttribute == "Constituton" then
				attributeText = LocalizedText.AttributeNames.Constituton.Value
			end
			local addedAttBoost = false
			local attPercentage = math.floor(Game.Math.ScaledDamageFromPrimaryAttribute(character.Stats[highestAttribute]) * 100)
			local valueSymbol = "+"
			if attPercentage < 0 then
				valueSymbol = ""
			end
			for i,v in pairs(elements) do
				if string.find(v.Label, strengthText) then
					addedAttBoost = true
					v.Label = fromText:gsub("%[1%]", attributeText):gsub("%[2%]", valueSymbol):gsub("%[3%]", attPercentage)
					break
				end
			end
			if not addedAttBoost then
				element = {
					Type = "StatsPercentageBoost",
					Label = fromText:gsub("%[1%]", attributeText):gsub("%[2%]", valueSymbol):gsub("%[3%]", attPercentage)
				}
				tooltip:AppendElementAfter(element, "StatsPercentageBoost")
			end
		end
		if boost > 0 then
			local valueSymbol = "+"
			if boost < 0 then
				valueSymbol = ""
			end
			local rankText = Ext.GetTranslatedStringFromKey(string.format("LLWEAPONEX_Unarmed_Mastery%i", unarmedMasteryRank))
			element = {
				Type = "StatsPercentageBoost",
				Label = fromText:gsub("%[1%]", rankText):gsub("%[2%]", valueSymbol):gsub("%[3%]", boost)
			}
			tooltip:AppendElementAfter(element, "StatsPercentageBoost")
		end
	end
end

return {
	Damage = OnDamageStatTooltip
}
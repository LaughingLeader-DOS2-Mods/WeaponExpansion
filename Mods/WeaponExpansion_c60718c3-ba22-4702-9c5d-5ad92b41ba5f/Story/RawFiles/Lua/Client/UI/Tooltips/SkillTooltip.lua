---@type LeaderLibLocalizedText
local LocalizedText = LeaderLib.LocalizedText
---@type TranslatedString
local TranslatedString = LeaderLib.Classes.TranslatedString

---@type table<string,fun(character:EsvCharacter):string>
local AlternativeScaling = {
	---@param character EsvCharacter
	Target_LLWEAPONEX_Steal = function(character)
		return Text.SkillScaling.AttributeAndAbility:ReplacePlaceholders(LocalizedText.AbilityNames.RogueLore.Value, LocalizedText.AttributeNames[Skills.GetHighestAttribute(character.Stats, AttributeScaleTables.NoMemory)].Value)
	end	
}

---@type table<string, TranslatedString>
local AbilitySchool = {
	Target_LLWEAPONEX_Steal = Text.NewAbilitySchools.Pirate
}

local thiefGloveChanceBonusText = TranslatedString:Create("h1fce3bfeg41a6g41adgbc5bg03d39281b469", "<font color='#11D87A'>+[1]% chance from [2]</font>")

local AppendedText = {
	---@param character EsvCharacter
	Target_LLWEAPONEX_Steal = function(character)
		if character:HasTag("LLWEAPONEX_ThiefGloves_Equipped") then
			local chance = math.tointeger(Ext.ExtraData["LLWEAPONEX_Steal_GlovesBonusChance"] or 30.0)
			local ref,handle = Ext.GetTranslatedStringFromKey("ARM_UNIQUE_LLWEAPONEX_ThiefGloves_A_DisplayName")
			local gloveName = Ext.GetTranslatedString(handle, ref)
			return thiefGloveChanceBonusText:ReplacePlaceholders(chance, gloveName)
		end
	end
}

---@param checkText string
---@param character EsvCharacter
---@param element table
---@param func fun(character:EsvCharacter):string
local function ReplaceScalingText(checkText, character, element, func)
	local _,_,replaceText = string.find(element.Label, checkText)
	if replaceText ~= nil then
		local newText = func(character)
		if newText ~= nil then
			element.Label = string.gsub(element.Label, replaceText, newText)
			return true
		end
	end
	return false
end

---@param character EsvCharacter
---@param skill string
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	CLIENT_UI.ACTIVE_CHARACTER = character.MyGuid
	local descriptionElement = tooltip:GetElement("SkillDescription")
	local description = ""
	if descriptionElement ~= nil then
		description = descriptionElement.Label
	end

	local data = Mastery.Params.SkillData[skill]
	if data ~= nil then
		local descriptionText = TooltipHandler.GetDescriptionText(character, data)
		if descriptionText ~= "" then
			if descriptionElement ~= nil then
				if description == nil then 
					description = ""
				else
					description = description.."<br>"
				end
				description = description..descriptionText
				descriptionElement.Label = description
			else
				descriptionElement = {
					Label = descriptionText
				}
				description = descriptionText
				tooltip:AppendElement(descriptionElement)
			end
		end
	end

	if character:HasTag("LLWEAPONEX_Firearm_Equipped") then
		if not LeaderLib.StringHelpers.IsNullOrEmpty(description) then
			description = description:gsub("arrow", "bullet"):gsub("Arrow", "Bullet")
			descriptionElement.Label = description
		end
	end

	local getAltScalingText = AlternativeScaling[skill]
	if getAltScalingText ~= nil then
		local element = tooltip:GetElement("SkillProperties")
		if element ~= nil then
			for i,prop in pairs(element.Properties) do
				for key,text in pairs(Text.DefaultSkillScaling) do
					local checkText = text.Value:gsub("%[1%]", "(%%w+)")
					if ReplaceScalingText(checkText, character, prop, getAltScalingText) then
						break
					end
				end
			end
		end
	end
	if AbilitySchool[skill] ~= nil then
		local element = tooltip:GetElement("SkillSchool")
		if element ~= nil then
			element.Label = AbilitySchool[skill].Value
		end
	end

	if AppendedText[skill] ~= nil then
		local text = AppendedText[skill](character)
		if text ~= nil then
			local element = tooltip:GetElement("SkillProperties")
			if element ~= nil then
				table.insert(element.Properties, {
					Label = text
				})
			end
			-- if descriptionElement ~= nil then
			-- 	if description == nil then 
			-- 		description = ""
			-- 	else
			-- 		description = description.."<br>"
			-- 	end
			-- 	description = description..text
			-- 	descriptionElement.Label = description
			-- else
			-- 	descriptionElement = {
			-- 		Label = text
			-- 	}
			-- 	tooltip:AppendElement(descriptionElement)
			-- end
		end
	end

	if Skills.WarfareMeleeSkills[skill] == true and character:HasTag("LLWEAPONEX_NoMeleeWeaponEquipped") then
		local isRushSkill = Ext.StatGetAttribute(skill, "SkillType") == "Rush"
		local requirementName = Ext.GetTranslatedStringFromKey("LLWEAPONEX_NoMeleeWeaponEquipped")
		for i,element in pairs(tooltip:GetElements("SkillRequiredEquipment")) do
			if element.RequirementMet == false then
				if element.Label == Text.Game.NotImmobileRequirement.Value then
					tooltip:RemoveElement(element)
				elseif string.find(element.Label, requirementName) then
					local requiresText = Ext.GetTranslatedString("hf1571b7eg8f35g4da2g8e38g87fee1c3d79f", "Requires [1] [2]&lt;br&gt;")
					element.Label = Text.Game.RequiresTag:ReplacePlaceholders("", requirementName):gsub("  ", " ")
				end
			end
		end
	end

end

return OnSkillTooltip
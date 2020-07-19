---@type LeaderLibLocalizedText
local LocalizedText = LeaderLib.LocalizedText
---@type TranslatedString
local TranslatedString = LeaderLib.Classes.TranslatedString

local AlternativeScaling = {
	---@param character EsvCharacter
	Target_LLWEAPONEX_Steal = function(character)
		return Text.SkillScaling.AttributeAndAbility.ReplacePlaceholders(LocalizedText.AbilityNames.RogueLore.Value, LocalizedText.AttributeNames.Value)
	end	
}

---@type table<string, TranslatedString>
local AbilitySchool = {
	Target_LLWEAPONEX_Steal = Text.NewAbilitySchools.Pirate
}

---@param character EsvCharacter
---@param skill string
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	print(skill, Ext.JsonStringify(tooltip.Data))
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
				local descriptionElement = {
					Label = descriptionText
				}
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

	if AlternativeScaling[skill] ~= nil then

	end
	if AbilitySchool[skill] ~= nil then
		local element = tooltip:GetElement("SkillSchool")
		if element ~= nil then
			element.Label = AbilitySchool[skill].Value
		end
	end
end

return OnSkillTooltip
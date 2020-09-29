TooltipHandler = {}

local function sortTagParams(a,b)
	return a:upper() < b:upper()
end

---@param skill SkillEventData
---@param character StatCharacter
---@return string
LeaderLib.RegisterListener("GetTooltipSkillDamage", function(skill, character)
	local paramText = SkillGetDescriptionParam(skill, character, false, "Damage")
	if paramText ~= nil then
		return paramText
	end
	-- if character.Stats.MainWeapon == nil and character.Stats.OffHandWeapon == nil then
	-- 	local damageRange = nil
	-- 	local weapon = GetUnarmedWeapon(character)
	-- 	damageRange = Math.GetSkillDamageRange(character, skillData, weapon)
	-- 	return GameHelpers.Tooltip.FormatDamageRange(damageRange)
	-- end

end)
---@param skill SkillEventData
---@param character StatCharacter
---@return string
LeaderLib.RegisterListener("GetTooltipSkillParam", function(skill, character, param)
	local paramText = SkillGetDescriptionParam(skill, character, false, param)
	if paramText ~= nil then
		return paramText
	end
end)

---@param character EsvCharacter
---@param data table
function TooltipHandler.GetDescriptionText(character, data)
	local descriptionText = ""
	local namePrefix = ""
	if data.Tags ~= nil then
		local tagKeys = {}
		for tagName,tagData in pairs(data.Tags) do
			table.insert(tagKeys, tagName)
		end
		local count = #tagKeys
		table.sort(tagKeys, sortTagParams)
		for i,tagName in pairs(tagKeys) do
			local tagData = data.Tags[tagName]
			if SharedData.RegionData.LevelType == LeaderLib.LEVELTYPE.CHARACTER_CREATION or Mastery.HasMasteryRequirement(character, tagName) then
				if tagData.NamePrefix ~= nil then
					if namePrefix ~= "" then
						namePrefix = namePrefix .. " "
					end
					namePrefix = namePrefix .. tagData.NamePrefix
				end
				local paramText = ""
				--local tagLocalizedName = Text.MasteryRankTagText[tagName]
				local tagLocalizedName = Ext.GetTranslatedStringFromKey(tagName)
				if tagLocalizedName == nil then 
					tagLocalizedName = ""
				else
					tagLocalizedName = tagLocalizedName .. "<br>"
				end
				if tagData.Param ~= nil then
					if tagLocalizedName ~= "" then
						paramText = tagLocalizedName..tagData.Param.Value
					else
						paramText = tagData.Param.Value
					end
				end
				paramText = GameHelpers.Tooltip.ReplacePlaceholders(paramText)
				if tagData.GetParam ~= nil then
					local status,result = xpcall(tagData.GetParam, debug.traceback, character.Stats, tagName, tagLocalizedName, paramText)
					if status and result ~= nil then
						paramText = result
					elseif not status then
						Ext.PrintError("Error calling GetParam function for "..tagName..":\n", result)
					end
				end
				if descriptionText ~= "" then descriptionText = descriptionText .. "<br>" end
				descriptionText = descriptionText .. paramText
			end
		end
	end
	return descriptionText
end

local OnItemTooltip = Ext.Require("Client/UI/Tooltips/ItemTooltip.lua")
local OnSkillTooltip = Ext.Require("Client/UI/Tooltips/SkillTooltip.lua")
local OnStatusTooltip = Ext.Require("Client/UI/Tooltips/StatusTooltip.lua")

local statTooltips = Ext.Require("Client/UI/Tooltips/StatTooltips.lua")
local OnDamageStatTooltip = statTooltips.Damage

Ext.RegisterNetListener("LLWEAPONEX_SetWorldTooltipText", function(cmd, text)
	local ui = Ext.GetUIByType(44)
	if ui ~= nil then
		local main = ui:GetRoot()
		if main ~= nil then
			if main.tf ~= nil then
				main.tf.shortDesc = text
				main.tf.setText(text,0)
			else
				main.defaultTooltip.shortDesc = text
				main.defaultTooltip.setText(text,0)
			end
		end
	end
end)

---@param ui UIObject
---@param text string
local function OnWorldTooltip(ui, text, x, y, ...)
	local startPos,endPos = string.find(text, '<font size="15"><br>.-</font>')
	if startPos then
		local nextText = string.sub(text, 0, startPos-1)
		Ext.PostMessageToServer("LLWEAPONEX_SetWorldTooltipText_Request", Ext.JsonStringify({Client = LeaderLib.UI.ClientID, Text=nextText}))
	end
end

local function Init()
	Game.Tooltip.RegisterListener("Stat", "Damage", OnDamageStatTooltip)
	Game.Tooltip.RegisterListener("Skill", nil, OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltip)
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
	LeaderLib.UI.RegisterListener("OnWorldTooltip", OnWorldTooltip)
end
return {
	Init = Init
}
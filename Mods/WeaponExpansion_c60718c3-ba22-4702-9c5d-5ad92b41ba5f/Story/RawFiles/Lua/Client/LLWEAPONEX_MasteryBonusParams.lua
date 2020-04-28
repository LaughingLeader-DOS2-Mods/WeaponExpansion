--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function GetMasteryBonuses(skill, character, isFromItem, param)
	local data = Mastery.Params.SkillData[skill.Name]
	--Ext.Print(LeaderLib.Common.Dump(data))
	if data ~= nil then
		local paramText = ""
		if data.Tags ~= nil then
			for tagName,tagData in pairs(data.Tags) do
				if tagData.GetParam ~= nil and HasMasteryRequirement(character.Character, tagName) then
					local tagLocalizedName = Text.MasteryRankTagText[tagName]
					if tagLocalizedName == nil then 
						tagLocalizedName = ""
					else
						tagLocalizedName = tagLocalizedName.Value
					end
					local nextText = tagData.GetParam(character, tagLocalizedName, tagData.Param.Value)
					paramText = paramText.."<br>"..nextText
				end
			end
		end
		return paramText
	end
	return ""
end

Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses
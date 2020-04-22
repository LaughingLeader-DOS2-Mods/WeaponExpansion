local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function GetMasteryBonuses(skill, character, isFromItem, param)
	local text = WeaponExpansion.MasteryParamOverrides.SkillData[skill.Name]
	if text ~= nil then
		return "<br>"..text.Value
	end
	return ""
end

WeaponExpansion.Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses
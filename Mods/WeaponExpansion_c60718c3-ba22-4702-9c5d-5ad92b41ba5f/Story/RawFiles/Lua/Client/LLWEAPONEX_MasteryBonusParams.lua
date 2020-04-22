local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function GetMasteryBonuses(skill, character, isFromItem, param)
	local data = WeaponExpansion.MasteryParamOverrides.SkillData[skill.Name]
	if data ~= nil and data.Param ~= nil then
		return "<br>"..data.Param.Value
	end
	return ""
end

WeaponExpansion.Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses
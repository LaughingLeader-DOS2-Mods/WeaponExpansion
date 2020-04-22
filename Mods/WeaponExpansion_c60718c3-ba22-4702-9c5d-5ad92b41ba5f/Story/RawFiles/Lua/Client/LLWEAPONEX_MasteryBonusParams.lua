local TranslatedString = LeaderLib.Classes["TranslatedString"]

local MasteryParamOverrides = {
	SkillData = {
		Projectile_ThrowingKnife = {
			Description = TranslatedString:Create("h5fdfca1dg8dd4g4cc3g9939g7433a38d4658","Throw a knife at your opponent, dealing [1].[2]"),
			Param = TranslatedString:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","<font color='#8F7CFF'>Dagger Mastery I</font><br><font color='#F19824'>The knife thrown has a small chance to be coated in poison or explosive oil, dealing additional damage on hit.</font>")
		}
	}
}

local function GetMasteryBonuses(skill, character, isFromItem, param)
	local data = MasteryParamOverrides.SkillData[skill.Name]
	if data ~= nil and data.Param ~= nil then
		return "<br>"..data.Param.Value
	end
	return ""
end

WeaponExpansion.Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses

return MasteryParamOverrides
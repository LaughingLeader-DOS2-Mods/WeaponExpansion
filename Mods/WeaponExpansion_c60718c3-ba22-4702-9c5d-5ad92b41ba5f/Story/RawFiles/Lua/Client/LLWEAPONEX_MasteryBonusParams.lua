local TranslatedString = LeaderLib.Classes["TranslatedString"]

local MasteryParamOverrides = {
	SkillData = {
		Projectile_ThrowingKnife = {
			Description = TranslatedString:Create("h5fdfca1dg8dd4g4cc3g9939g7433a38d4658","Throw a knife at your opponent, dealing [1].[2]"),
			Param = TranslatedString:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","<font color='#8F7CFF' size='16'>Dagger Mastery I</font><br><font color='#F19824'>The knife thrown has a <font color='#CC33FF'>[1]%</font> to be coated in poison or explosive oil, dealing <font color='#00FFAA'>[2] bonus damage</font> on hit.</font>")
		}
	}
}

local function GetMasteryBonuses(skill, character, isFromItem, param)
	local data = MasteryParamOverrides.SkillData[skill.Name]
	if data ~= nil and data.Param ~= nil then
		local paramText = data.Param.Value:gsub("%[1%]", math.tointeger(math.min(Ext.ExtraData["LLWEAPONEX_ThrowingKnife_MasteryBonusChance"], 100)))
		local damageSkillProps = WeaponExpansion.Skills.PrepareSkillProperties("Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive")
		local damageRange = Game.Math.GetSkillDamageRange(character, damageSkillProps)
		if damageRange ~= nil then
			local damageText = ""
			for damageType,damage in pairs(damageRange) do
				damageText = string.format("%s-%s", math.tointeger(damage[1]), math.tointeger(damage[2]))
				break
			end
			paramText = string.gsub(paramText, "%[2%]", damageText)
		end
		return "<br>"..paramText
	end
	return ""
end

WeaponExpansion.Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses

return MasteryParamOverrides
local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function GetThrowingKnifeBonusParam(character, data)
	local paramText = data.Param.Value:gsub("%[1%]", math.tointeger(math.min(Ext.ExtraData["LLWEAPONEX_ThrowingKnife_MasteryBonusChance"], 100)))
	local damageSkillProps = WeaponExpansion.Skills.PrepareSkillProperties("Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive")
	local damageRange = Game.Math.GetSkillDamageRange(character, damageSkillProps)
	if damageRange ~= nil then
		local damageText = ""
		local totalMin = 0
		local totalMax = 0
		for damageType,damage in pairs(damageRange) do
			totalMin = totalMin + damage[1]
			totalMax = totalMax + damage[2]
		end
		damageText = string.format("%s-%s", math.tointeger(totalMin), math.tointeger(totalMax))
		paramText = string.gsub(paramText, "%[2%]", damageText)
	end
	return paramText
end

local MasteryParamOverrides = {
	SkillData = {
		Projectile_ThrowingKnife = {
			Description = TranslatedString:Create("h5fdfca1dg8dd4g4cc3g9939g7433a38d4658","Throw a knife at your opponent, dealing [1].[2]"),
			Param = TranslatedString:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","<font color='#8F7CFF' size='16'>Dagger Mastery I</font><br><font color='#F19824'>The knife thrown has a <font color='#CC33FF'>[1]%</font> to be coated in poison or explosive oil, dealing <font color='#00FFAA'>[2] bonus damage</font> on hit.</font>"),
			Tag = "LLWEAPONEX_Dagger_Mastery1",
			LockedParam = TranslatedString:Create("h50295d19g3065g4099g9e78g7c6e7b45c579","<font color='#AE9F95' size='16'>Bonus Unlocked at Dagger Mastery I</font>"),
			GetParam = GetThrowingKnifeBonusParam,
		}
	}
}

local function HasMasteryRequirement(character, data)
	if data.Tag == nil then
		return true
	else
		return character.Character:HasTag(data.Tag) == true
	end
end

local function GetMasteryBonuses(skill, character, isFromItem, param)
	local data = MasteryParamOverrides.SkillData[skill.Name]
	if data ~= nil and data.GetParam ~= nil then
		local paramText = ""
		if HasMasteryRequirement(character, data) then
			paramText = data.GetParam(character, data)
			return "<br>"..paramText
		elseif data.LockedParam ~= nil then
			paramText = data.LockedParam.Value
			return "<br>"..paramText
		end
	end
	return ""
end

WeaponExpansion.Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses

return MasteryParamOverrides
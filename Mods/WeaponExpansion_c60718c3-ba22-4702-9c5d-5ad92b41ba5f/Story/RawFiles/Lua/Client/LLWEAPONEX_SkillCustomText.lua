local TranslatedString = LeaderLib.Classes["TranslatedString"]

local skillText = {
	Projectile_ThrowingKnife = TranslatedString:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","<font color='#8F7CFF'>Dagger Mastery I</font><br><font color='#F19824'>The knife thrown has a small chance to be coated in poison or explosive oil, dealing additional damage on hit.</font>")
}

function InitSkillCustomText()
	-- for skill,translatedString in pairs(skillText) do
	-- 	LeaderLib.Print("[LLWEAPONEX_SkillCustomText.lua:AddCustomText] Adding custom desc to ("..skill.."): ("..translatedString.Value..")")
	-- 	Ext.StatAddCustomDescription(skill, "SkillProperties", translatedString.Value)
	-- end
end
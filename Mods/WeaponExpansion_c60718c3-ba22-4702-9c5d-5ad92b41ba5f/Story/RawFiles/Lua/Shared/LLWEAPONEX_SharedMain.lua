if WeaponExpansion == nil then WeaponExpansion = {} end

WeaponExpansion.Main = {}
WeaponExpansion.Debug = {}

local TranslatedString = LeaderLib.Classes["TranslatedString"]
WeaponExpansion.MasteryParamOverrides = {
	SkillData = {
		Projectile_ThrowingKnife = {
			Description = TranslatedString:Create("h5fdfca1dg8dd4g4cc3g9939g7433a38d4658","Throw a knife at your opponent, dealing [1].[2]"),
			Param = TranslatedString:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","<font color='#8F7CFF'>Dagger Mastery I</font><br><font color='#F19824'>The knife thrown has a small chance to be coated in poison or explosive oil, dealing additional damage on hit.</font>")
		}
	}
}

Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "Shared/LLWEAPONEX_SkillDamageFunctions.lua")

--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/LLWEAPONEX_ToolTip.swf")
--Ext.Print("[WeaponExpansion] Enabled tooltip.swf override.")
--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper_kb.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper.swf", "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/serverlist.swf")
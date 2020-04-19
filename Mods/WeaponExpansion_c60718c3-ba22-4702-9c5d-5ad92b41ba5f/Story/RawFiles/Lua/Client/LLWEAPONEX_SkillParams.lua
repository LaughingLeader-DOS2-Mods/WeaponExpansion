local boltRuneBoosts = {
	"_Boost_LLWEAPONEX_Crossbow_Bolt_Normal",
	"_Boost_LLWEAPONEX_Crossbow_Bolt_Air",
	"_Boost_LLWEAPONEX_Crossbow_Bolt_Earth",
	"_Boost_LLWEAPONEX_Crossbow_Bolt_Fire",
	"_Boost_LLWEAPONEX_Crossbow_Bolt_Poison",
	"_Boost_LLWEAPONEX_Crossbow_Bolt_Water",
	"_Boost_LLWEAPONEX_Crossbow_Bolt_Shadow",
	"_Boost_LLWEAPONEX_Crossbow_Bolt_Corrosive",
}

local function GetHandCrossbowBoltEffects(skill, character, isFromItem, param)
	local bolt,boltRuneStat = WeaponExpansion.SkillDamage.GetHandCrossbowBolt(character)
	if boltRuneStat ~= nil then
		return string.format("<font color='#FFBB22'>%s</font>", boltRuneStat)
	end
end

WeaponExpansion.SkillDamage.Params["LLWEAPONEX_HandCrossbow_BoltEffects"] = GetHandCrossbowBoltEffects

local damageScaleLevelText = {Handle="h71b09f9fg285fg4532gab16g1c7640864141", Content="Damage is based on your level and receives bonus from [1]."}
local damageScaleWeaponText = {Handle="ha4cfd852g52f1g4079g8919gd392ac8ade1a", Content="Damage is based on your basic attack and receives a bonus from [1]."}

local function GetHandCrossbowScaling(skill, character, isFromItem, param)
	local att = WeaponExpansion.SkillDamage.GetHighestAttribute(character)
	local text = Ext.GetTranslatedString(damageScaleLevelText.Handle. damageScaleLevelText.Content):gsub("%[1%]", att)
	return "<br><font color='#078FC8'>"..text.."</font>"
end
WeaponExpansion.SkillDamage.Params["LLWEAPONEX_HandCrossbow_Scaling"] = GetHandCrossbowScaling

local defaultPos = {[1] = 0.0, [2] = 0.0, [3] = 0.0,}

local function LLWEAPONEX_SkillGetDescriptionParam(skill, character, isFromItem, param)
	Ext.Print("Looking for skill param ("..tostring(param)..") for: " .. skill.Name)
	Ext.Print("skill("..tostring(skill)..") character("..tostring(character)..") isFromItem("..tostring(isFromItem)..")")
	local param_func = WeaponExpansion.SkillDamage.Params[param]
	if param_func ~= nil then
		local status,val1,val2 = xpcall(param_func, debug.traceback, skill, character, isFromItem, false, defaultPos, defaultPos, -1, 0)
		if status then
			if val1 ~= nil then
				local resultString = ""
				for i,damage in pairs(val1:ToTable()) do
					resultString = resultString .. LeaderLib.Game.GetDamageText(damage.DamageType, damage.Amount)
				end
				return resultString
			end
		else
			Ext.PrintError("Error getting param ("..param..") for skill:\n",val1)
		end
	end
end

Ext.RegisterListener("SkillGetDescriptionParam", LLWEAPONEX_SkillGetDescriptionParam)
local boltRuneBoosts = {
	["_Boost_LLWEAPONEX_Crossbow_Bolt_Normal"] = {},
	["_Boost_LLWEAPONEX_Crossbow_Bolt_Air"] = {Transform="Electrify"},
	["_Boost_LLWEAPONEX_Crossbow_Bolt_Earth"] = {Apply="SLOWED", Transform="Oilify"},
	["_Boost_LLWEAPONEX_Crossbow_Bolt_Fire"] = {Apply="BURNING", Transform="Ignite"},
	["_Boost_LLWEAPONEX_Crossbow_Bolt_Poison"] = {Apply="POISONED", Transform="Contaminate"},
	["_Boost_LLWEAPONEX_Crossbow_Bolt_Water"] = {Apply="CHILLED", Transform="Freeze"},
	["_Boost_LLWEAPONEX_Crossbow_Bolt_Shadow"] = {Apply="CURSED", Transform="Curse"},
	["_Boost_LLWEAPONEX_Crossbow_Bolt_Corrosive"] = {Apply="ACID",Transform="Melt"},
}

local function GetHandCrossbowBoltEffects(skill, character, isFromItem, param)
	local bolt,boltRuneStat = WeaponExpansion.Skills.GetHandCrossbowBolt(character)
	if boltRuneStat ~= nil then
		local boostEffects = boltRuneBoosts[boltRuneStat]
		if boostEffects ~= nil and boostEffects.Transform ~= nil then
			return string.format("<font color='#FFBB22'>%s</font>", boostEffects.Transform)
		end
	end
	return ""
end

WeaponExpansion.Skills.Params["LLWEAPONEX_HandCrossbow_BoltEffects"] = GetHandCrossbowBoltEffects

local TranslatedString = LeaderLib.Classes["TranslatedString"]

local damageScaleLevelText = TranslatedString:Create("h71b09f9fg285fg4532gab16g1c7640864141", "Damage is based on your level and receives bonus from [1].")
local damageScaleWeaponText = TranslatedString:Create("ha4cfd852g52f1g4079g8919gd392ac8ade1a", "Damage is based on your basic attack and receives a bonus from [1].")

local function GetHandCrossbowScaling(skill, character, isFromItem, param)
	local att = WeaponExpansion.Skills.GetHighestAttribute(character)
	local text = string.gsub(damageScaleLevelText.Value, "%[1%]", att)
	return "<br><font color='#078FC8'>"..text.."</font>"
end
WeaponExpansion.Skills.Params["LLWEAPONEX_HandCrossbow_Scaling"] = GetHandCrossbowScaling

local defaultPos = {[1] = 0.0, [2] = 0.0, [3] = 0.0,}

local function LLWEAPONEX_SkillGetDescriptionParam(skill, character, isFromItem, param)
	--Ext.Print("Looking for skill param ("..tostring(param)..") for: " .. skill.Name)
	--Ext.Print("skill("..tostring(skill)..") character("..tostring(character)..") isFromItem("..tostring(isFromItem)..")")
	local param_func = WeaponExpansion.Skills.Damage.Params[param]
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
	param_func = WeaponExpansion.Skills.Params[param]
	if param_func ~= nil then
		local status,txt = xpcall(param_func, debug.traceback, skill, character, isFromItem, false, defaultPos, defaultPos, -1, 0)
		if status then
			if txt ~= nil then
				return txt
			end
		else
			Ext.PrintError("Error getting param ("..param..") for skill:\n",txt)
		end
	end
end

Ext.RegisterListener("SkillGetDescriptionParam", LLWEAPONEX_SkillGetDescriptionParam)
local FORBIDDEN = {
	"ComboCategories",
	"ExtraProperties",
	"SkillProperties",
	"TargetConditions",
	"AoEConditions",
	"CycleConditions",
	"Requirements",
}

local overrides = {
	-- Skills
	Target_SingleHandedAttack = {
		IgnoreSilence = "Yes",
		AIFlags = "StatusIsSecondary",
		UseWeaponDamage = "Yes",
		SkillProperties = "LLWEAPONEX_SUCKER_PUNCH,100,1"
	},
	Target_TentacleLash = {
		UseWeaponDamage = "Yes",
		["Damage Multiplier"] = 90
	},
	Target_CorrosiveTouch = {
		Description = "LLWEAPONEX_Target_CorrosiveTouch_Description",
	},
	Cone_CorrosiveSpray = {
		Description = "LLWEAPONEX_Cone_CorrosiveSpray_Description",
	},
	Projectile_SilverArrow = {
		Description = "LLWEAPONEX_Projectile_SilverArrow_Description",
	},
	Target_DemonicStare = {
		Description = "LLWEAPONEX_Target_DemonicStare_Description",
	},
	-- Potions
	Stats_LLWEAPONEX_UnrelentingRage = {
		RogueLore = 0 -- Crit mult is handled by the extender
	},
	-- Weapons
	NoWeapon = {
		ExtraProperties = "LLWEAPONEX_UNARMED_HIT,100,0"
	},
	_Unarmed = {
		ExtraProperties = "LLWEAPONEX_UNARMED_HIT,100,0"
	}
}

local anim_overrides = {
	Target_SingleHandedAttack = {
		CastAnimation = "skill_cast_ll_suckerpunch_01_cast",
		CastSelfAnimation = "skill_cast_ll_suckerpunch_01_cast"
	}
}
---These are stats that gain new features if the extender is active.
local llweaponex_extender_additions = {
	-- ARM_UNIQUE_LLWEAPONEX_PowerGauntlets_A = {
	-- 	Skills = "Shout_LLWEAPONEX_PowerGauntlets_ToggleGiantStrength"
	-- }
}

local function CanSetProperty(property)
	local i = 1
	while i < #FORBIDDEN do
		if property == FORBIDDEN[i] then return false end
		i = i + 1
	end
	return true
end

local function apply_overrides(stats)
    for statname,props in pairs(stats) do
		for property,value in pairs(props) do
			local next_value = value
			if CanSetProperty(property) then
				Ext.StatSetAttribute(statname, property, next_value)
				Ext.Print("[LLWEAPONEX_StatOverrides.lua] Overriding stat: " .. statname .. " (".. property ..") = \"".. next_value .."\"")
			else
				Ext.Print("[LLWEAPONEX_StatOverrides.lua] Cannot set property: " .. statname .. " (".. property .."). IT IS FORBIDDEN.")
			end
        end
    end
end

--[[ if property == "ExtraProperties" or property == "SkillProperties" then
	local status, err, propertiesOriginal = xpcall(Ext.StatGetAttribute, function(err) return err; end, statname, property)
	if propertiesOriginal ~= nil and propertiesOriginal ~= "" then
		local combined_value = tostring(propertiesOriginal..value)
		Ext.StatSetAttribute(statname, property, combined_value)
		next_value = combined_value
	else
		Ext.StatSetAttribute(statname, property, next_value)
	end
else
	Ext.StatSetAttribute(statname, property, next_value)
end ]]

local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function LLWEAPONEX_StatOverrides_Init()
	Ext.Print("[LLWEAPONEX_StatOverrides.lua] Applying stat overrides.")

	apply_overrides(overrides)
	apply_overrides(llweaponex_extender_additions)

	for statType,entries in pairs(WeaponExpansion.MasteryParamOverrides) do
		local statParamsAttribute = "StatsDescriptionParams"
		if statType == "StatusData" then
			statParamsAttribute = "DescriptionParams"
		end
		for stat,data in pairs(entries) do
			local statParams = Ext.StatGetAttribute(stat, statParamsAttribute)
			if statParams == nil then
				statParams = ""
			else
				statParams = statParams .. ";"
			end
			local nextParams = statParams .. "LLWEAPONEX_MasteryBonuses"
			Ext.StatSetAttribute(stat, statParamsAttribute, nextParams)
			LeaderLib.Print("[LLWEAPONEX_StatOverrides.lua] Set params for ("..stat..") from ("..statParams..") to ("..nextParams..").")
			if data.Description ~= nil then
				Ext.StatSetAttribute(stat, "Description", data.Description.Value)
			end
		end
	end

	if Ext.IsModLoaded("AnimationsPlus_326b8784-edd7-4950-86d8-fcae9f5c457c") then
		apply_overrides(anim_overrides)
	else
		Ext.Print("[LLWEAPONEX_StatOverrides.lua] [*WARNING*] AnimationsPlus is missing! Skipping animation stat overrides.")
	end

	Mods.WeaponExpansion.InitSkillCustomText()
end

Ext.RegisterListener("ModuleLoading", LLWEAPONEX_StatOverrides_Init)
local skill_overrides = {
	Target_SingleHandedAttack = {
		IgnoreSilence = "Yes",
		AIFlags = "StatusIsSecondary",
		UseWeaponDamage = "Yes",
		SkillProperties = "LLWEAPONEX_SUCKER_PUNCH,100,1"
	},
	Target_TentacleLash = {
		UseWeaponDamage = "Yes",
		["Damage Multiplier"] = 90
	}
}

local weapon_overrides = {
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

local function property_ignored(property)
	return false
	-- if property == "ExtraProperties" or property == "SkillProperties" then
	-- 	return true
	-- end
	-- return false
end

local function apply_overrides(stats)
    for statname,overrides in pairs(stats) do
		for property,value in pairs(overrides) do
			if property_ignored(property) then
				Ext.Print("[LLWEAPONEX_StatOverrides.lua] Stat property (".. property ..") is not yet supported!")
			else
				local next_value = value
				if property == "ExtraProperties" or property == "SkillProperties" then
					local propertiesOriginal = Ext.StatGetAttribute(statname, property)
					if propertiesOriginal ~= nil and propertiesOriginal ~= "" then
						local combined_value = tostring(propertiesOriginal..value)
						Ext.StatSetAttribute(statname, property, combined_value)
						next_value = combined_value
					else
						Ext.StatSetAttribute(statname, property, next_value)
					end
				else
					Ext.StatSetAttribute(statname, property, next_value)
				end
				Ext.Print("[LLWEAPONEX_StatOverrides.lua] Overriding stat: " .. statname .. " (".. property ..") = \"".. next_value .."\"")
			end
        end
    end
end

local ModuleLoad = function ()
	Ext.Print("[WeaponExpansion:Bootstrap.lua] Module is loading.")

	apply_overrides(skill_overrides)
	apply_overrides(weapon_overrides)

	if Ext.IsModLoaded("AnimationsPlus_326b8784-edd7-4950-86d8-fcae9f5c457c") then
		apply_overrides(anim_overrides)
	else
		Ext.Print("[LLWEAPONEX_StatOverrides.lua] [*WARNING*] AnimationsPlus is missing! Skipping animation stat overrides.")
	end
end

--v36 and higher
if Ext.RegisterListener ~= nil then
    Ext.RegisterListener("ModuleLoading", ModuleLoad)
else
    Ext.Print("[LLWEAPONEX_StatOverrides.lua] [*WARNING*] Extender version is less than v36! Stat overrides ain't happenin', chief.")
end
local overrides = {
	-- Skills
	Target_SingleHandedAttack = {
		IgnoreSilence = "Yes",
		AIFlags = "StatusIsSecondary",
		UseWeaponDamage = "Yes",
		-- SkillProperties = {{
		-- 	Type = "Status",
		-- 	Action = "LLWEAPONEX_SUCKER_PUNCH",
		-- 	Context = {"Target"},
		-- 	Duration = 6.0,
		-- 	StatusChance = 1.0,
		-- 	Arg3 = "",
		-- 	Arg4 = -1,
		-- 	Arg5 = -1,
		-- 	SurfaceBoost = false
		-- }}
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
	-- Weapons
	NoWeapon = {
		ExtraProperties = {{
			Type = "Status",
			Action = "LLWEAPONEX_UNARMED_NOWEAPON_HIT",
			Context = {"Target"},
			Duration = 0.0,
			StatusChance = 1.0,
			Arg3 = "",
			Arg4 = -1,
			Arg5 = -1,
			SurfaceBoost = false
		}}
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

local function apply_overrides(stats)
    for statname,props in pairs(stats) do
		for property,value in pairs(props) do
			if property == "SkillProperties" or property == "ExtraProperties" then
				local existingTable = Ext.StatGetAttribute(statname, property)
				if existingTable ~= nil then
					for i,v in ipairs(value) do
						table.insert(existingTable, v)
					end
					LeaderLib.PrintDebug("[LLWEAPONEX_StatOverrides.lua] Overriding stat (appended table): ",statname," (".. property ..") = [")
					LeaderLib.PrintDebug(LeaderLib.Common.Dump(existingTable))
					LeaderLib.PrintDebug("]")
					Ext.StatSetAttribute(statname, property, existingTable)
				else
					LeaderLib.PrintDebug("[LLWEAPONEX_StatOverrides.lua] Overriding stat: ",statname," (".. property ..") = [")
					LeaderLib.PrintDebug(LeaderLib.Common.Dump(value))
					LeaderLib.PrintDebug("]")
					Ext.StatSetAttribute(statname, property, value)
				end
			else
				LeaderLib.PrintDebug("[LLWEAPONEX_StatOverrides.lua] Overriding stat: ",statname," (".. property ..") = [",value,"]")
				Ext.StatSetAttribute(statname, property, value)
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

local LLWEAPONEX_PREFIX = "LLWEAPONEX_"

local function OverrideLeaveActionStatuses()
	-- LeaveAction damage is delayed after its first application, for whatever reason.
	-- Instead, for WeaponEx statuses, we'll explode it with the extender, but keep LeaveAction in the status for compatibility,
	-- so other mods can change the projectiles used.
	local total = 0
	for i,stat in pairs(Ext.GetStatEntries("StatusData")) do
		local leaveActionSkill = Ext.StatGetAttribute(stat, "LeaveAction")
		if not LeaderLib.Common.StringIsNullOrEmpty(leaveActionSkill) and stat:sub(1, #LLWEAPONEX_PREFIX) == LLWEAPONEX_PREFIX then
			Ext.StatSetAttribute(stat, "LeaveAction", "")
			LeaveActionData[stat] = leaveActionSkill
			total = total + 1
		end
	end
	LeaderLib.PrintDebug("[WeaponExpansion:OverrideLeaveActionStatuses] Registered ("..tostring(total)..") statuses to the LeaveActionData table.")
	LeaderLib.PrintDebug(LeaderLib.Common.Dump(LeaveActionData))
	LeaderLib.PrintDebug("]")
end

local function AddRequirement(stat, param, inverse, requirementType)
	-- ["Param"] = LLWEAPONEX_Katana_Equipped, ["Not"] = false, ["Requirement"] = Tag
	local requirements = Ext.StatGetAttribute(stat, "Requirements")
	if requirements ~= nil then
		table.insert(requirements, {Param = param, Not = inverse, Requirement = requirementType})
		Ext.StatSetAttribute(stat, "Requirements", requirements)
	else
		Ext.StatSetAttribute(stat, "Requirements", {{Param = param, Not = inverse, Requirement = requirementType}})
	end
end

local function WarfareMeleeWeaponOverride(skill)
	Ext.StatSetAttribute(skill, "Requirement", "None")
	--AddRequirement(skill, "LLWEAPONEX_MeleeWeaponEquipped", false, "Tag")
	AddRequirement(skill, "LLWEAPONEX_NoMeleeWeaponEquipped", true, "Tag")
	--print(LeaderLib.Common.Dump(Ext.StatGetAttribute(skill, "Requirements")))
end

local function StatOverrides_Init()
	Ext.Print("[LLWEAPONEX_StatOverrides.lua] Applying stat overrides.")

	print("[ARM_UNIQUE_LLWEAPONEX_DragonBoneClaws_A] Tags:", Ext.StatGetAttribute("ARM_UNIQUE_LLWEAPONEX_DragonBoneClaws_A", "Tags"))
	print("[ARM_UNIQUE_LLWEAPONEX_DragonBoneClaws_A] Comment:", Ext.StatGetAttribute("ARM_UNIQUE_LLWEAPONEX_DragonBoneClaws_A", "Comment"))

	apply_overrides(overrides)
	apply_overrides(llweaponex_extender_additions)

	for i,skill in pairs(Ext.GetStatEntries("SkillData")) do
		local gameMaster = Ext.StatGetAttribute(skill, "ForGameMaster")
		local requirement = Ext.StatGetAttribute(skill, "Requirement")
		local ability = Ext.StatGetAttribute(skill, "Ability")

		--print(gameMaster, requirement, ability)
	
		if gameMaster == "Yes" and requirement == "MeleeWeapon" and ability == "Warrior" then
			WarfareMeleeWeaponOverride(skill)
		end
	end

	--OverrideLeaveActionStatuses()

	-- for statType,entries in pairs(Mastery.Params) do
	-- 	local statParamsAttribute = "StatsDescriptionParams"
	-- 	if statType == "StatusData" then
	-- 		statParamsAttribute = "DescriptionParams"
	-- 	end
	-- 	for stat,data in pairs(entries) do
	-- 		local statParams = Ext.StatGetAttribute(stat, statParamsAttribute)
	-- 		local canAddMasteryParam = statParams == nil or not string.find(statParams, "LLWEAPONEX_MasteryBonuses")
	-- 		if canAddMasteryParam then
	-- 			if statParams == nil then
	-- 				statParams = ""
	-- 			else
	-- 				statParams = statParams .. ";"
	-- 			end
	-- 			local nextParams = statParams .. "LLWEAPONEX_MasteryBonuses"
	-- 			Ext.StatSetAttribute(stat, statParamsAttribute, nextParams)
	-- 			LeaderLib.PrintDebug("[LLWEAPONEX_StatOverrides.lua] Set params for ("..stat..") from ("..statParams..") to ("..nextParams..").")
	-- 			if data.Description ~= nil then
	-- 				Ext.StatSetAttribute(stat, "Description", data.Description.Value)
	-- 			end
	-- 		end
	-- 	end
	-- end

	if Ext.IsModLoaded("326b8784-edd7-4950-86d8-fcae9f5c457c") then
		apply_overrides(anim_overrides)
	else
		Ext.Print("[LLWEAPONEX_StatOverrides.lua] [*WARNING*] AnimationsPlus is missing! Skipping animation stat overrides.")
	end
end

Ext.RegisterListener("StatsLoaded", StatOverrides_Init)
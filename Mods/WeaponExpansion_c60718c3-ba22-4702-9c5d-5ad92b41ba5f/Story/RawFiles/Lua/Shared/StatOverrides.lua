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
		-- 	StatsId = "",
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
			StatsId = "",
			Arg4 = -1,
			Arg5 = -1,
			SurfaceBoost = false
		}}
	},
}

local function appendProperties(statname, property, value)
	local existingTable = Ext.StatGetAttribute(statname, property)
	if existingTable ~= nil then
		for i,v in ipairs(value) do
			table.insert(existingTable, v)
		end
		Ext.StatSetAttribute(statname, property, existingTable)
	else
		--print("Ext.StatSetAttribute(",statname, property, Common.Dump(value),")")
		Ext.StatSetAttribute(statname, property, value)
	end
end

local function buildTemplateString(curlyBraceType, values)
	local templateString = "{"..curlyBraceType.."}"
	for type,template in pairs(values) do
		templateString = templateString .. "["..type.."]"..template
	end
	return templateString
end

local gunExplosionEffectStatusProperties = {{
	Type = "Status",
	Action = "LLWEAPONEX_FIREARM_SHOOT_EXPLOSION_FX",
	Context = {"Self"},
	Duration = 0.0,
	StatusChance = 1.0,
	StatsId = "",
	Arg4 = -1,
	Arg5 = -1,
	SurfaceBoost = false
}}

local defaultBulletTemplate = "6e597ce1-d8b8-4720-89b9-75f6a71d64ba"
local bulletTemplates = {
	Projectile_ArrowSpray = "7ce736c8-1e02-462d-bee2-36bd86bd8979",
	Projectile_EnemyArrowSpray = "7ce736c8-1e02-462d-bee2-36bd86bd8979",
	Projectile_BallisticShot = "7ce736c8-1e02-462d-bee2-36bd86bd8979",
	Projectile_EnemyBallisticShot = "7ce736c8-1e02-462d-bee2-36bd86bd8979",
	Projectile_Multishot = "deb24a84-006f-4a3a-b4bb-b40fa52a447d",
	Projectile_EnemyMultishot = "deb24a84-006f-4a3a-b4bb-b40fa52a447d",
	Projectile_PiercingShot = "d4eebf4d-4f0c-4409-8fe8-32efeca06453",
	Projectile_EnemyPiercingShot = "d4eebf4d-4f0c-4409-8fe8-32efeca06453",
	Projectile_PinDown = "8814954c-b0d1-4cdf-b075-3313ac71cf20",
	Projectile_EnemyPinDown = "8814954c-b0d1-4cdf-b075-3313ac71cf20",
	Projectile_Ricochet = "22cae5a3-8427-4526-aa7f-4f277d0ff67e",
	Projectile_EnemyRicochet = "22cae5a3-8427-4526-aa7f-4f277d0ff67e",
	Projectile_SkyShot = "e44859b2-d55f-47e2-b509-fd32d7d3c745",
	Projectile_EnemySkyShot = "e44859b2-d55f-47e2-b509-fd32d7d3c745",
	Projectile_Snipe = "fbf17754-e604-4772-813a-3593b4e7bec8",
	Projectile_EnemySnipe = "fbf17754-e604-4772-813a-3593b4e7bec8",
}

local function CreateFirearmDerivativeSkills()
	for skill,bulletTemplate in pairs(bulletTemplates) do
		local defaultTemplate = Ext.StatGetAttribute(skill, "Template")
		local templateString = buildTemplateString("WeaponType", {
			None = defaultTemplate,
			Bow = defaultTemplate,
			Crossbow = defaultTemplate,
			Rifle = bulletTemplate
		})
		Ext.StatSetAttribute(skill, "Template", templateString)
		appendProperties(skill, "SkillProperties", gunExplosionEffectStatusProperties)
	end
end

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
				appendProperties(statname, property, value)
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

local function HasComboCategory(categoryTable, category)
    if categoryTable == nil then return false end
    for i,v in pairs(categoryTable) do
        if v == category then return true end
    end
    return false
end

local function StatOverrides_Init()
	Ext.Print("[LLWEAPONEX_StatOverrides.lua] Applying stat overrides.")

	apply_overrides(overrides)
	apply_overrides(llweaponex_extender_additions)

	CreateFirearmDerivativeSkills()

	for i,skill in pairs(Ext.GetStatEntries("SkillData")) do
		local gameMaster = Ext.StatGetAttribute(skill, "ForGameMaster")
		local requirement = Ext.StatGetAttribute(skill, "Requirement")
		local ability = Ext.StatGetAttribute(skill, "Ability")

		--print(gameMaster, requirement, ability)
	
		if gameMaster == "Yes" and requirement == "MeleeWeapon" and ability == "Warrior" then
			WarfareMeleeWeaponOverride(skill)
		end

		if bulletTemplates[skill] == nil then
			if Ext.StatGetAttribute(skill, "SkillType") == "Projectile" and 
				ability == "Ranger" and 
				requirement == "RangedWeapon" then
					local defaultTemplate = Ext.StatGetAttribute(skill, "Template")
					if not string.find(defaultTemplate, "{") then
						local templateString = buildTemplateString("WeaponType", {
							None = defaultTemplate,
							Bow = defaultTemplate,
							Crossbow = defaultTemplate,
							Rifle = defaultBulletTemplate
						})
						Ext.StatSetAttribute(skill, "Template", templateString)
						--print("[WeaponExpansion] Added rifle template support to skill ", skill)
					end
					appendProperties(skill, "SkillProperties", gunExplosionEffectStatusProperties)
					--print("[WeaponExpansion] Added rifle bullet explosion effect support to skill ", skill)
			end
		end
	end

	-- Add a combo category to unique weapons.
	for i,stat in pairs(Ext.GetStatEntries("Weapon")) do
		if Ext.StatGetAttribute(stat, "Unique") == 1 then
			local combocategory = Ext.StatGetAttribute(stat, "ComboCategory")
			if not HasComboCategory(combocategory, "UniqueWeapon") then
				if combocategory ~= nil and combocategory ~= "" then
					combocategory[#combocategory+1] = "UniqueWeapon"
					Ext.StatSetAttribute(stat, "ComboCategory", combocategory)
				else
					Ext.StatSetAttribute(stat, "ComboCategory", {"UniqueWeapon"})
				end
			end
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
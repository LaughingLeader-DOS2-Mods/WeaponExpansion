local overrides = {
	-- Skills
	Target_SingleHandedAttack = {
		IgnoreSilence = "Yes",
		UseWeaponDamage = "Yes",
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
		for i,v in pairs(value) do
			table.insert(existingTable, v)
		end
		Ext.StatSetAttribute(statname, property, existingTable)
	else
		--print("Ext.StatSetAttribute(",statname, property, Common.Dump(value),")")
		Ext.StatSetAttribute(statname, property, value)
	end
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

local function buildTemplateString(curlyBraceType, values)
	local templateString = "{"..curlyBraceType.."}"
	for type,template in pairs(values) do
		templateString = templateString .. "["..type.."]"..template
	end
	return templateString
end

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

Skills.BulletTemplates = bulletTemplates

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
		--local castEffect = Ext.StatGetAttribute(skill, "CastEffect")
		--castEffect = castEffect .. "{WeaponType}[Rifle]"
		--Ext.StatSetAttribute(skill, "CastEffect", castEffect)
		--appendProperties(skill, "SkillProperties", gunExplosionEffectStatusProperties)
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

local function SwapRequirementWithTag(skill, requirement, tag, inverse)
	Ext.StatSetAttribute(skill, "Requirement", requirement)
	AddRequirement(skill, tag, inverse or false, "Tag")
end

local function HasComboCategory(categoryTable, category)
    if categoryTable == nil then return false end
    for i,v in pairs(categoryTable) do
        if v == category then return true end
    end
    return false
end

local known = {
	Custom = true,
	SurfaceChange = true,
	Summon = true,
	Status = true,
	GameAction = true,
	OsirisTask = true,
	Force = true,
	Sabotage = true,
	SelfOnEquip = true,
}

local AIFLAG_CANNOT_USE = 140689826905584

local function IsEnemySkill(skill)
	local aiflags = Ext.StatGetAttribute(skill, "AIFlags")
	if string.find(skill, "Enemy") and Ext.StatGetAttribute(skill, "IsEnemySkill") == "Yes" and aiflags ~= AIFLAG_CANNOT_USE then
		return true
	end
	return false
end

local player_stats = {
	--["_Base"] = true,
	["_Hero"] = true,
	["HumanFemaleHero"] = true,
	["HumanMaleHero"] = true,
	["DwarfFemaleHero"] = true,
	["DwarfMaleHero"] = true,
	["ElfFemaleHero"] = true,
	["ElfMaleHero"] = true,
	["LizardFemaleHero"] = true,
	["LizardMaleHero"] = true,
	["HumanUndeadFemaleHero"] = true,
	["HumanUndeadMaleHero"] = true,
	["DwarfUndeadFemaleHero"] = true,
	["DwarfUndeadMaleHero"] = true,
	["ElfUndeadFemaleHero"] = true,
	["ElfUndeadMaleHero"] = true,
	["LizardUndeadFemaleHero"] = true,
	["LizardUndeadMaleHero"] = true,
	["_Companions"] = true,
	["Player_Ifan"] = true,
	["Player_Lohse"] = true,
	["Player_RedPrince"] = true,
	["Player_Sebille"] = true,
	["Player_Beast"] = true,
	["Player_Fane"] = true,
	--["Summon_Earth_Ooze_Player"] = true,
}

local CanBackstabPropEntry = {
	Action = "CanBackstab",
	Context =
	{
			"Target",
			"AoE"
	},
	Type = "Custom"
}

local function AddCanBackstab(props)
	if not string.find(Ext.JsonStringify(props), "CanBackstab") then
		table.insert(props, CanBackstabPropEntry)
	end
end

local IgnoreModPrefixes = {
	-- Musketeer
	_MUSK_ = true
}

local function IgnoreRangerSkill(skill)
	for k,b in pairs(IgnoreModPrefixes) do
		if string.find(skill, k) then
			return true
		end
	end
	return false
end

local function StatOverrides_Init()
	Ext.Print("[LLWEAPONEX_StatOverrides.lua] Applying stat overrides.")

	apply_overrides(overrides)
	apply_overrides(llweaponex_extender_additions)

	CreateFirearmDerivativeSkills()

	local props = Ext.StatGetAttribute("Projectile_LLWEAPONEX_BackstabbingFlamingDaggers", "SkillProperties") or {}
	AddCanBackstab(props)

	for i,skill in pairs(Ext.GetStatEntries("SkillData")) do
		local gameMaster = Ext.StatGetAttribute(skill, "ForGameMaster")
		local requirement = Ext.StatGetAttribute(skill, "Requirement")
		local ability = Ext.StatGetAttribute(skill, "Ability")

		-- local props = Ext.StatGetAttribute(skill, "SkillProperties")
		-- if props ~= nil and #props > 0 then
		-- 	local printNewInfo = false
		-- 	for _,v in pairs(props) do
		-- 		if not StringHelpers.IsNullOrEmpty(v.Type) and known[v.Type] ~= true then
		-- 			printNewInfo = true
		-- 		end
		-- 	end
		-- 	if printNewInfo then
		-- 		--print(skill, Ext.JsonStringify(props))
		-- 	end
		-- end

		--print(gameMaster, requirement, ability)
	
		-- UseWeaponDamage is needed so weapons still get unsheathed when not unarmed.
		if gameMaster == "Yes" and not IsEnemySkill(skill) and Ext.StatGetAttribute(skill, "UseWeaponDamage") == "Yes" then
			if requirement == "MeleeWeapon" then
				SwapRequirementWithTag(skill, "None", "LLWEAPONEX_NoMeleeWeaponEquipped", true)
			end
			if requirement == "DaggerWeapon" and ability == "Rogue" then
				SwapRequirementWithTag(skill, "MeleeWeapon", "LLWEAPONEX_CannotUseScoundrelSkills", true)
			end
		end

		if bulletTemplates[skill] == nil then
			if Ext.StatGetAttribute(skill, "SkillType") == "Projectile" 
				and ability == "Ranger"
				and requirement == "RangedWeapon" 
				and not IgnoreRangerSkill(skill)
				then
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
					--appendProperties(skill, "SkillProperties", gunExplosionEffectStatusProperties)
					--print("[WeaponExpansion] Added rifle bullet explosion effect support to skill ", skill)
			end
		end

		if Ext.IsModLoaded(MODID.EE2Core) then
			--EE2 AP cost adjustment
			if string.find(skill, "LLWEAPONEX") then
				local ap = Ext.StatGetAttribute(skill, "ActionPoints")
				local originalAP = ap
				if ap == 1 then
					ap = 2
				elseif ap == 2 then
					ap = 4
				elseif ap == 3 then
					ap = 6
				end
				if ap ~= originalAP then
					Ext.StatSetAttribute(skill, "ActionPoints", ap)
				end
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

	if Ext.IsDeveloperMode() then
		for stat,b in pairs(player_stats) do
			if b and Ext.StatGetAttribute(stat, "Accuracy") == 95 then
				Ext.StatSetAttribute(stat, "Accuracy", 100)
			end
		end
	end

	if Ext.IsModLoaded("326b8784-edd7-4950-86d8-fcae9f5c457c") then
		apply_overrides(anim_overrides)
	else
		Ext.Print("[LLWEAPONEX_StatOverrides.lua] [*WARNING*] AnimationsPlus is missing! Skipping animation stat overrides.")
	end
end

Ext.RegisterListener("StatsLoaded", StatOverrides_Init)
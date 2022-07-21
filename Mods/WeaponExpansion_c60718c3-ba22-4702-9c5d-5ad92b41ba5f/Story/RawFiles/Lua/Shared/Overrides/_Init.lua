---@alias LLWEAPONEX_StatOverrides_GetConditionalAttributeValue<T> fun(statId:string, attributeId:string, value:T):T
---@alias LLWEAPONEX_StatOverrides_Attributes table<string, string|number|LLWEAPONEX_StatOverrides_GetConditionalAttributeValue<any>>

---@type table<string, LLWEAPONEX_StatOverrides_Attributes>
local BaseStats = Ext.Require("Shared/Overrides/BaseStats.lua")

---@type table<GUID, table<string, LLWEAPONEX_StatOverrides_Attributes>>
local ModStats = Ext.Require("Shared/Overrides/ModStats.lua")

local type = type


local function AppendProperties(statName, property, value)
	local existingTable = GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, property)
	if existingTable ~= nil then
		for i,v in pairs(value) do
			table.insert(existingTable, v)
		end
		Ext.StatSetAttribute(statName, property, existingTable)
	else
		--print("Ext.StatSetAttribute(",statName, property, Common.Dump(value),")")
		Ext.StatSetAttribute(statName, property, value)
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
	-- Arrows
	Projectile_FireArrow = defaultBulletTemplate,
	Projectile_ExplosionArrow = defaultBulletTemplate,
	Projectile_FreezingArrow = defaultBulletTemplate,
	Projectile_WaterArrow = defaultBulletTemplate,
	Projectile_CursedFireArrow = defaultBulletTemplate,
	Projectile_BlessedWaterArrow = defaultBulletTemplate,
	Projectile_SlowDownArrow = defaultBulletTemplate,
	Projectile_StunningArrow = defaultBulletTemplate,
	Projectile_SteamCloudArrow = defaultBulletTemplate,
	Projectile_SmokescreenArrow = defaultBulletTemplate,
	Projectile_StaticCloudArrow = defaultBulletTemplate,
	Projectile_SilverArrow = defaultBulletTemplate,
	Projectile_BleedingArrow = defaultBulletTemplate,
	Projectile_KnockedOutArrow = defaultBulletTemplate,
	Projectile_PoisonedCloudArrow = defaultBulletTemplate,
	Projectile_CharmingArrow = defaultBulletTemplate,
	Projectile_PoisonArrow = defaultBulletTemplate,
	Projectile_DebuffAllArrow = defaultBulletTemplate,
}

Skills.BulletTemplates = bulletTemplates

local function CreateFirearmDerivativeSkills()
	for skill,bulletTemplate in pairs(bulletTemplates) do
		local defaultTemplate = skill.Template
		local templateString = buildTemplateString("WeaponType", {
			None = defaultTemplate,
			Bow = defaultTemplate,
			Crossbow = defaultTemplate,
			Rifle = bulletTemplate
		})
		skill.Template = templateString
		--local castEffect = skill.CastEffect
		--castEffect = castEffect .. "{WeaponType}[Rifle]"
		--skill.CastEffect = castEffect
		--AppendProperties(skill, "SkillProperties", gunExplosionEffectStatusProperties)
	end
end

local function HasComboCategory(categoryTable, category)
    if categoryTable == nil then return false end
    for i,v in pairs(categoryTable) do
        if v == category then return true end
    end
    return false
end

---@param stat StatEntrySkillData
---@param param string
---@param inverse boolean
---@param requirementType string
local function AddRequirement(stat, param, inverse, requirementType)
	-- ["Param"] = LLWEAPONEX_Katana_Equipped, ["Not"] = false, ["Requirement"] = Tag
	local requirements = stat.Requirements
	if requirements ~= nil then
		requirements[#requirements+1] = {Param = param, Not = inverse, Requirement = requirementType}
		stat.Requirements = requirements
	else
		stat.Requirements = {{Param = param, Not = inverse, Requirement = requirementType}}
	end
end

---@param skill StatEntrySkillData
---@param requirement string
---@param tag string
---@param inverse boolean
local function SwapRequirementWithTag(skill, requirement, tag, inverse)
	skill.Requirement = requirement
	AddRequirement(skill, tag, inverse or false, "Tag")
end

local CanBackstabPropEntry = {
	Action = "CanBackstab",
	Context = {"Target", "AoE"},
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

---@param id string
---@param attribute string
---@param value string|number|LLWEAPONEX_StatOverrides_GetConditionalAttributeValue<any>
local function ApplyOverride(id, attribute, value)
	local stat = Ext.GetStat(id)
	local t = type(value)
	if t == "function" then
		local v = value(id, attribute, stat[attribute])
		if v ~= nil then
			stat[attribute] = v
		end
	else
		stat[attribute] = value
	end
end

function LoadUniqueRequirementChanges()
	local b,result = xpcall(function()
		local payload = Ext.LoadFile("WeaponExpansion_UniqueRequirementChanges.json")
		if payload ~= nil then
			local data = Ext.JsonParse(payload)
			if data ~= nil then
				for statName,requirements in pairs(data) do
					if GameHelpers.Stats.Exists(statName, "Weapon") then
						Ext.StatSetAttribute(statName, "Requirements", requirements)
					end
				end
			end
		end
	end, debug.traceback)
	if not b then
		Ext.PrintError(result)
	end
end

local function Run()
	CreateFirearmDerivativeSkills()

	--We're appending the CanBackstab property here instead of overriding the stat, in case a mod changed it
	local props = Ext.StatGetAttribute("Projectile_LLWEAPONEX_BackstabbingFlamingDaggers", "SkillProperties") or {}
	AddCanBackstab(props)

	local _EE2 = Ext.IsModLoaded(MODID.EE2Core)

	for skill in GameHelpers.Stats.GetStats("SkillData", true) do
		---@cast skill StatEntrySkillData
		--local gameMaster = skill.ForGameMaster
		local requirement = skill.Requirement
		local ability = skill.Ability
	
		-- UseWeaponDamage is needed so weapons still get unsheathed when not unarmed.
		--gameMaster == "Yes" and not IsEnemySkill(skill)
		if skill.UseWeaponDamage == "Yes" then
			if requirement == "MeleeWeapon" then
				SwapRequirementWithTag(skill, "None", "LLWEAPONEX_NoMeleeWeaponEquipped", true)
			elseif requirement == "DaggerWeapon" and ability == "Rogue" then
				SwapRequirementWithTag(skill, "MeleeWeapon", "LLWEAPONEX_CannotUseScoundrelSkills", true)
			end
		end

		if bulletTemplates[skill] == nil
		and skill.SkillType == "Projectile"
		and ability == "Ranger"
		and requirement == "RangedWeapon"
		and not IgnoreRangerSkill(skill)
		then
			local defaultTemplate = skill.Template
			if not string.find(defaultTemplate, "{") then
				local templateString = buildTemplateString("WeaponType", {
					None = defaultTemplate,
					Bow = defaultTemplate,
					Crossbow = defaultTemplate,
					Rifle = defaultBulletTemplate
				})
				skill.Template = templateString
				--print("[WeaponExpansion] Added rifle template support to skill ", skill)
			end
		end

		if _EE2 then
			--EE2 AP cost adjustment
			if string.find(skill, "LLWEAPONEX") then
				local ap = skill.ActionPoints
				local originalAP = ap
				if ap == 1 then
					ap = 2
				elseif ap == 2 then
					ap = 4
				elseif ap == 3 then
					ap = 6
				end
				if ap ~= originalAP then
					skill.ActionPoints = ap
				end
			end
		end
	end

	-- Add a combo category to unique weapons.
	for stat in GameHelpers.Stats.GetStats("Weapon", true) do
		---@cast stat StatEntryWeapon
		if stat.Unique == 1 then
			local combocategory = stat.ComboCategory
			if not HasComboCategory(combocategory, "UniqueWeapon") then
				if combocategory ~= nil then
					combocategory[#combocategory+1] = "UniqueWeapon"
					stat.ComboCategory = combocategory
				else
					stat.ComboCategory = {"UniqueWeapon"}
				end
			end
			if _EE2 and string.find(stat, "LLWEAPONEX_") then
				--EE2 AP cost adjustment
				local ap = stat.AttackAPCost
				if ap < 4 then
					stat.AttackAPCost = 4
				end
			end
		end
	end

	LoadUniqueRequirementChanges()

	for statId,attributes in pairs(BaseStats) do
		for id,v in pairs(attributes) do
			ApplyOverride(statId, id, v)
		end
	end
	for modGUID,stats in pairs(ModStats) do
		if Ext.Mod.IsModLoaded(modGUID) then
			for statId,attributes in pairs(stats) do
				for id,v in pairs(attributes) do
					ApplyOverride(statId, id, v)
				end
			end
		end
	end
end
Ext.Events.StatsLoaded:Subscribe(function (e)
	Run()
end, {Priority=1})
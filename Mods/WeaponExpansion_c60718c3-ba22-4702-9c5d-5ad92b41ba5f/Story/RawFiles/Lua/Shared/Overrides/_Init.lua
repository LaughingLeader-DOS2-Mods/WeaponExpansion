local type = type

local _ISCLIENT = Ext.IsClient()

---@alias LLWEAPONEX_StatOverrides_GetConditionalAttributeValue<T> fun(statId:string, attributeId:string, value:T):T
---@alias LLWEAPONEX_StatOverrides_Attributes table<string, string|number|LLWEAPONEX_StatOverrides_GetConditionalAttributeValue<any>>

---@type table<string, LLWEAPONEX_StatOverrides_Attributes>
local BaseStats = Ext.Require("Shared/Overrides/BaseStats.lua")

---@type table<Guid, table<string, LLWEAPONEX_StatOverrides_Attributes>>
local ModStats = Ext.Require("Shared/Overrides/ModStats.lua")

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

---@param stat StatEntrySkillData
---@param param string|integer
---@param inverse boolean
---@param requirementType string
local function AddRequirement(stat, param, inverse, requirementType)
	-- ["Param"] = LLWEAPONEX_Katana_Equipped, ["Not"] = false, ["Requirement"] = Tag
	local requirements = stat.Requirements
	if requirements ~= nil then
		for i=1,#requirements do
			local req = requirements[i]
			if req.Param == param and req.Requirement == requirementType and req.Not == inverse then
				return false
			end
		end
		requirements[#requirements+1] = {Param = param, Not = inverse, Requirement = requirementType}
		stat.Requirements = requirements
	else
		stat.Requirements = {{Param = param, Not = inverse, Requirement = requirementType}}
	end
	return true
end

---@param skill StatEntrySkillData
---@param requirement string
---@param tag string
---@param inverse boolean
local function SwapRequirementWithTag(skill, requirement, tag, inverse)
	local changed = false
	if skill.Requirement ~= requirement then
		skill.Requirement = requirement
		changed = true
	end
	if AddRequirement(skill, tag, inverse or false, "Tag") then
		changed = true
	end
	return changed
end

local CanBackstabPropEntry = {
	Action = "CanBackstab",
	Context = {"Target", "AoE"},
	Type = "Custom"
}

local function AddCanBackstab(props)
	for _,v in pairs(props) do
		if v.Type == "Custom" and v.Action == "CanBackstab" then
			return false
		end
	end
	props[#props+1] = CanBackstabPropEntry
	return props
end

local IgnoreModPrefixes = {
	-- Musketeer
	_MUSK_ = true
}

---@param skill string
local function IgnoreRangerSkill(skill)
	for k,b in pairs(IgnoreModPrefixes) do
		if string.find(skill, k) then
			return true
		end
	end
	return false
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
		Ext.Utils.PrintError(result)
	end
end

---@param current string[]
---@vararg string
---@return boolean changed
---@return string[]|nil	categories
local function AppendComboCategory(current, ...)
	local categories = {}
	for i=1,#current do
		categories[current[i]] = true
	end
	local changed = false
	local args = {...}
	for i=1,#args do
		local v = args[i]
		if not categories[v] then
			categories[v] = true
			changed = true
		end
	end
	if not changed then
		return false
	end
	local result = {}
	for v,_ in pairs(categories) do
		result[#result+1] = v
	end
	table.sort(result)
	return true,result
end

---@param id string
---@param attribute string
---@param value string|number|LLWEAPONEX_StatOverrides_GetConditionalAttributeValue<any>
local function ApplyOverride(id, attribute, value)
	local stat = Ext.Stats.Get(id)
	local t = type(value)
	local finalValue = value
	if t == "function" then
		local v = value(id, attribute, stat[attribute])
		if v ~= nil then
			finalValue = v
		end
	end
	if stat[attribute] ~= finalValue then
		stat[attribute] = finalValue
		return true
	end
	return false
end

local function Run(doSync)
	local _EE2 = Ext.IsModLoaded(MODID.EE2Core)

	---@type table<string,boolean>
	local _syncStats = {}

	--We're appending the CanBackstab property here instead of overriding the stat, in case a mod changed it
	local bfd = Ext.Stats.Get("Projectile_LLWEAPONEX_BackstabbingFlamingDaggers")
	if bfd then
		local props = AddCanBackstab(bfd.SkillProperties or {})
		if props then
			bfd.SkillProperties = props
			_syncStats[bfd.Name] = true
		end
	end

	--for _,id in pairs(Ext.Stats.GetStats("SkillData")) do local s = Ext.Stats.Get(id); id.Template = id.Template .. id.Template end

	for _,id in pairs(Ext.Stats.GetStats("SkillData")) do
		local stat = Ext.Stats.Get(id)
		---@cast stat StatEntrySkillData
		--local gameMaster = skill.ForGameMaster
		local requirement = stat.Requirement
		local ability = stat.Ability

		if bulletTemplates[id] then
			local defaultTemplate = stat.Template
			if not string.find(defaultTemplate, "{", 1, true) then
				local templateString = buildTemplateString("WeaponType", {
					None = defaultTemplate,
					Bow = defaultTemplate,
					Crossbow = defaultTemplate,
					Rifle = bulletTemplates[id]
				})
				if stat.Template ~= templateString then
					stat.Template = templateString
					_syncStats[id] = true
				end
			end
		else
			if stat.SkillType == "Projectile"
			and ability == "Ranger"
			and requirement == "RangedWeapon"
			and not IgnoreRangerSkill(stat.Name)
			then
				local defaultTemplate = stat.Template
				if not string.find(defaultTemplate, "{", 1, true) then
					local templateString = buildTemplateString("WeaponType", {
						None = defaultTemplate,
						Bow = defaultTemplate,
						Crossbow = defaultTemplate,
						Rifle = defaultBulletTemplate
					})
					if defaultTemplate ~= templateString then
						stat.Template = templateString
						_syncStats[stat.Name] = true
					end
				end
			end
		end
	
		-- UseWeaponDamage is needed so weapons still get unsheathed when not unarmed.
		--gameMaster == "Yes" and not IsEnemySkill(skill)
		if stat.UseWeaponDamage == "Yes" then
			if requirement == "MeleeWeapon" then
				if SwapRequirementWithTag(stat, "None", "LLWEAPONEX_NoMeleeWeaponEquipped", true) then
					_syncStats[stat.Name] = true
				end
			elseif requirement == "DaggerWeapon" and ability == "Rogue" then
				if SwapRequirementWithTag(stat, "MeleeWeapon", "LLWEAPONEX_CannotUseScoundrelSkills", true) then
					_syncStats[stat.Name] = true
				end
			end
		end

		if _EE2 then
			--EE2 AP cost adjustment
			if string.find(id, "LLWEAPONEX") then
				local ap = stat.ActionPoints
				local originalAP = ap
				if ap == 1 then
					ap = 2
				elseif ap == 2 then
					ap = 4
				elseif ap == 3 then
					ap = 6
				end
				if ap ~= originalAP then
					stat.ActionPoints = ap
					_syncStats[stat.Name] = true
				end
			end
		end
	end

	-- Add a combo category to unique weapons.
	for _,id in pairs(Ext.Stats.GetStats("Weapon")) do
		local stat = Ext.Stats.Get(id)
		---@cast stat StatEntryWeapon
		if stat.Unique == 1 then
			local b,newCategories = AppendComboCategory(stat.ComboCategory, "UniqueWeapon", "Weapon")
			if b then
				---@cast newCategories string[]
				stat.ComboCategory = newCategories
				_syncStats[stat.Name] = true
			end
			if _EE2 and string.find(id, "LLWEAPONEX_") then
				--EE2 AP cost adjustment
				local ap = stat.AttackAPCost
				if ap < 4 then
					stat.AttackAPCost = 4
					_syncStats[stat.Name] = true
				end
			end
		else
			local b,newCategories = AppendComboCategory(stat.ComboCategory, "Weapon")
			if b then
				---@cast newCategories string[]
				stat.ComboCategory = newCategories
				_syncStats[stat.Name] = true
			end
		end
	end

	--LoadUniqueRequirementChanges()

	for statId,attributes in pairs(BaseStats) do
		local changed = false
		for id,v in pairs(attributes) do
			if ApplyOverride(statId, id, v) then
				changed = true
			end
		end
		if changed then
			_syncStats[statId] = true
		end
	end

	for modGUID,stats in pairs(ModStats) do
		if Ext.Mod.IsModLoaded(modGUID) then
			for statId,attributes in pairs(stats) do
				local changed = false
				for id,v in pairs(attributes) do
					if ApplyOverride(statId, id, v) then
						changed = true
					end
				end
				if changed then
					_syncStats[statId] = true
				end
			end
		end
	end

	if doSync then
		for id,b in pairs(_syncStats) do
			Ext.Stats.Sync(id, false)
		end
	end

	Ext.Utils.Print("[WeaponExpansion] Applied stat overrides.")
end

Ext.Events.StatsLoaded:Subscribe(function (e)
	Run()
end, {Priority=1})

-- if not _ISCLIENT then
-- 	Events.LuaReset:Subscribe(function (e)
-- 		if Vars.LeaderDebugMode then
-- 			Run(true)
-- 		end
-- 	end)
-- end
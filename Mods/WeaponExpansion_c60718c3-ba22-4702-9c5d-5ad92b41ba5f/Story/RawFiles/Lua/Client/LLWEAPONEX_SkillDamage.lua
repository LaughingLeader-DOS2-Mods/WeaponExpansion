local function GetScaledPistolDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	local damageList = Ext.NewDamageList()
	damageList:Add("Physical", 10)
	return damageList
end

local skill_damage_functions = {
	Projectile_LLWEAPONEX_Pistol_Damage_Default_Scaled = GetScaledPistolDamage
}

local skillprototype_debug = {
	Id = true,
	Name = true,
	SkillTypeId = true,
	SkillId = true,
	Ability = true,
	Tier = true,
	Requirement = true,
	Level = true,
	MagicCost = true,
	MemoryCost = true,
	ActionPoints = true,
	Cooldown = true,
	CooldownReduction = true,
	ChargeDuration = true,
	DisplayName = true,
	Icon = true,
	AiFlags = true,
	RootSkillPrototype = true,
}

local function LLWEAPONEX_GetSkillDamage(skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	local damageList = nil
	local deathType = 1
	for name,b in pairs(skillprototype_debug) do
		Ext.Print("skill[\""..name.."\"] = ("..tostring(skill[name])..")")
	end

	local skill_func = skill_damage_functions[skill.Name]
	if skill_func ~= nil then
		local success = false
		--Ext.Print("attackerStats("..LeaderLib.Common.Dump(attackerStats)..")")
		success,damageList,deathType = pcall(skill_func, skill, attacker, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization)
	end
	if damageList ~= nil then
		Ext.Print("damageList("..tostring(LeaderLib.Common.Dump(damageList:ToTable()))..")")
	end
	return damageList, deathType
end

Ext.RegisterListener("GetSkillDamage", LLWEAPONEX_GetSkillDamage)

local skill_params = {
	Target_LLWEAPONEX_Pistol_A_Shoot = {
		PistolDamage = GetScaledPistolDamage
	}
}

local function LLWEAPONEX_SkillGetDescriptionParam(skill, character, param)
	Ext.Print("Getting skill param for (" .. tostring(skill.Name) .. ") Param ("..tostring(param)..")")
	local result = ""
	local skill_param_table = skill_params[skill.Name]
	if skill_param_table ~= nil then
		local param_func = skill_param_table[param]
		if param_func ~= nil then
			local damageList = param_func(skill, character)
			for i,damage in pairs(damageList:ToTable()) do
				result = result .. tostring(damage.Amount) .. " " .. damage.DamageType .. " Damage"
			end
		end
	end
	return result
end

--Ext.RegisterListener("SkillGetDescriptionParam", LLWEAPONEX_SkillGetDescriptionParam)
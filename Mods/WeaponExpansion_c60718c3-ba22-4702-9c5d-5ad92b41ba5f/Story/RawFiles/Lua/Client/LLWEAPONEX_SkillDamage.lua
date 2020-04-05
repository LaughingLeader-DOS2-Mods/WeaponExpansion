local function GetScaledPistolDamage(skill, attackerStats, isFromItem, stealthed, attackerPosition, targetPosition, level, noRandomization)
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

local function LLWEAPONEX_GetSkillDamage(skill, attackerStats, isFromItem, stealthed, attackerPosition, targetPosition, level, noRandomization)
	Ext.Print("Getting skill damage for: " .. tostring(skill) .. " isFromItem("..tostring(isFromItem)..") stealthed("..tostring(stealthed)..") attackerPosition("..LeaderLib.Common.Dump(attackerPosition)..") targetPosition("..tostring(targetPosition)..") level("..tostring(level)..") noRandomization("..tostring(noRandomization)..")")
	local damageList = nil

	for name,b in pairs(skillprototype_debug) do
		Ext.Print("skill[\""..name.."\"] = ("..tostring(skill[name])..")")
	end

	local skill_func = skill_damage_functions[skill]
	if skill["Icon"] == "unknown" then
		skill_func = GetScaledPistolDamage
	end
	if skill_func ~= nil then
		Ext.Print("attackerStats("..LeaderLib.Common.Dump(attackerStats)..")")
		damageList = skill_func(skill, attackerStats, isFromItem, stealthed, attackerPosition, targetPosition, level, noRandomization)
	end
	if damageList ~= nil then
		Ext.Print("damageList("..tostring(LeaderLib.Common.Dump(damageList:ToTable()))..")")
	end
	return damageList, 1
end

--Ext.RegisterListener("GetSkillDamage", LLWEAPONEX_GetSkillDamage)

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
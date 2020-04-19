
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

local defaultPos = {[1] = 0.0, [2] = 0.0, [3] = 0.0,}

local function LLWEAPONEX_SkillGetDescriptionParam(skill, character, isFromItem, param)
	Ext.Print("Looking for skill param ("..tostring(param)..") for: " .. skill.Name)
	Ext.Print("skill("..tostring(skill)..") character("..tostring(character)..") isFromItem("..tostring(isFromItem)..")")
	local param_func = WeaponExpansion.SkillDamage.Params[param]
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
end

Ext.RegisterListener("SkillGetDescriptionParam", LLWEAPONEX_SkillGetDescriptionParam)
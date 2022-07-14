if not CustomSkillProperties then
	---@type table<string, CustomSkillProperty>
	CustomSkillProperties = {}
end

local function _NO_DESC() end

---@param id string
--- @param getDesc fun(property:StatsPropertyExtender):string|nil
--- @param onPos fun(property:StatsPropertyExtender, attacker: EsvCharacter|EsvItem, position: vec3, areaRadius: number, isFromItem: boolean, skill: StatEntrySkillData|nil, hit: StatsHitDamageInfo|nil)
--- @param onTarget fun(property:StatsPropertyExtender, attacker: EsvCharacter|EsvItem, target: EsvCharacter|EsvItem, position: vec3, isFromItem: boolean, skill: StatEntrySkillData|nil, hit: StatsHitDamageInfo|nil)
local function CreateSkillProperty(id, getDesc, onPos, onTarget)
	local prop = {
		GetDescription = getDesc or _NO_DESC,
		ExecuteOnPosition = onPos or _NO_DESC,
		ExecuteOnTarget = onTarget or _NO_DESC,
	}
	CustomSkillProperties[id] = prop
	Ext.RegisterSkillProperty(id, prop)
end

---@type CustomSkillProperty
CustomSkillProperties.LLWEAPONEX_ApplyRuneProperties = {
	GetDescription = function(prop)
		-- local chance = prop.Arg1 or 1
		-- if chance >= 1 then
		-- 	return Text.SkillTooltip.ApplySpecialRuneOnHit:ReplacePlaceholders(effectText, "")
		-- else
		-- 	chance = Ext.Round(chance * 100)
		-- 	return Text.SkillTooltip.ApplySpecialRuneOnHit_Chance:ReplacePlaceholders(effectText, chance)
		-- end
	end,
	ExecuteOnPosition = function(prop, attacker, position, areaRadius, isFromItem, skill, hit)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local items = {}
			for _,slot in Data.EquipmentSlots:Get() do
				local uuid = CharacterGetEquippedItem(attacker.MyGuid, slot)
				if not StringHelpers.IsNullOrEmpty(uuid) then
					local item = Ext.GetItem(uuid)
					if item then
						items[#items+1] = items
					end
				end
			end
			for i=1,#items do
				ApplyRuneExtraProperties(attacker, position, items[i], position, areaRadius, skill and skill.Name)
			end
		end
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local items = {}
			for _,slot in Data.EquipmentSlots:Get() do
				local uuid = CharacterGetEquippedItem(attacker.MyGuid, slot)
				if not StringHelpers.IsNullOrEmpty(uuid) then
					local item = Ext.GetItem(uuid)
					if item then
						items[#items+1] = items
					end
				end
			end
			for i=1,#items do
				ApplyRuneExtraProperties(attacker, target, items[i], position, math.max(skill.AreaRadius or 1, skill.ExplodeRadius or 1), skill and skill.Name)
			end
		end
	end
}
Ext.RegisterSkillProperty("LLWEAPONEX_ApplyRuneProperties", CustomSkillProperties.LLWEAPONEX_ApplyRuneProperties)


CreateSkillProperty("LLWEAPONEX_ApplyBulletProperties", nil, function (property, attacker, position, areaRadius, isFromItem, skill, hit)
	local chance = property.Arg1
	if chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
		local radius = math.max(1, math.max(skill.AreaRadius or 0, skill.ExplodeRadius or 0))
		local rune,weaponBoostStat = Skills.GetRuneBoost(attacker.Stats, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
		if weaponBoostStat ~= nil then
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetExtraProperties(weaponBoostStat)
			if props ~= nil and #props > 0 then
				Ext.PropertyList.ExecuteExtraPropertiesOnPosition(weaponBoostStat, "ExtraProperties", attacker, position, radius, "AoE", false, skill.Name)
				Ext.PropertyList.ExecuteExtraPropertiesOnPosition(weaponBoostStat, "ExtraProperties", attacker, attacker, attacker.WorldPos, "Self", false, skill.Name)
			end
		end
	end
end, function (property, attacker, target, position, isFromItem, skill, hit)
	local chance = property.Arg1
	if chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
		local rune,weaponBoostStat = Skills.GetRuneBoost(attacker.Stats, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
		if weaponBoostStat ~= nil then
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetExtraProperties(weaponBoostStat)
			if props ~= nil and #props > 0 then
				Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weaponBoostStat, "ExtraProperties", attacker, target, target.WorldPos, "Target", false, skill.Name)
				Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weaponBoostStat, "ExtraProperties", attacker, attacker, attacker.WorldPos, "Self", false, skill.Name)
			end
		end
	end
end)

CreateSkillProperty("LLWEAPONEX_ApplyBoltProperties", nil, function (property, attacker, position, areaRadius, isFromItem, skill, hit)
	local chance = property.Arg1
	if chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
		local radius = math.max(1, math.max(skill.AreaRadius or 0, skill.ExplodeRadius or 0))
		local rune,weaponBoostStat = Skills.GetRuneBoost(attacker.Stats, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows")
		if weaponBoostStat ~= nil then
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetExtraProperties(weaponBoostStat)
			if props ~= nil and #props > 0 then
				Ext.PropertyList.ExecuteExtraPropertiesOnPosition(weaponBoostStat, "ExtraProperties", attacker, position, radius, "AoE", false, skill.Name)
				Ext.PropertyList.ExecuteExtraPropertiesOnPosition(weaponBoostStat, "ExtraProperties", attacker, attacker, attacker.WorldPos, "Self", false, skill.Name)
			end
		end
	end
end, function (property, attacker, target, position, isFromItem, skill, hit)
	local chance = property.Arg1
	if chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
		local rune,weaponBoostStat = Skills.GetRuneBoost(attacker.Stats, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows")
		if weaponBoostStat ~= nil then
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetExtraProperties(weaponBoostStat)
			if props ~= nil and #props > 0 then
				Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weaponBoostStat, "ExtraProperties", attacker, target, target.WorldPos, "Target", false, skill.Name)
				Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weaponBoostStat, "ExtraProperties", attacker, attacker, attacker.WorldPos, "Self", false, skill.Name)
			end
		end
	end
end)

CustomSkillProperties.LLWEAPONEX_ChaosRuneAbsorbSurface = {
	GetDescription = function(prop)
		local chance = prop.Arg1
		if chance >= 1.0 then
			return Text.SkillTooltip.ChaosRuneAbsorbSurface.Value
		else
			return Text.SkillTooltip.ChaosRuneAbsorbSurface_Chance:ReplacePlaceholders(math.floor(chance * 100))
		end
	end,
	ExecuteOnPosition = function(prop, attacker, position, areaRadius, isFromItem, skill, hit)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local duration = math.max(prop.Arg2 or 6, 6)
			local radius = math.max(areaRadius, math.max(skill.AreaRadius or 1, skill.ExplodeRadius or 1))
			RunebladeManager.AbsorbSurface(attacker, position, radius, duration)
		end
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local duration = math.max(prop.Arg2 or 6, 6)
			local radius = math.max(skill.AreaRadius or 1, skill.ExplodeRadius or 1)
			RunebladeManager.AbsorbSurface(attacker, position, radius, duration)
		end
	end
}
Ext.RegisterSkillProperty("LLWEAPONEX_ChaosRuneAbsorbSurface", CustomSkillProperties.LLWEAPONEX_ChaosRuneAbsorbSurface)
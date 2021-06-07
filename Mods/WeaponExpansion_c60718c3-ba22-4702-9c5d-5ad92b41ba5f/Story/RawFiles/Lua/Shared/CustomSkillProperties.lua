if not CustomSkillProperties then
	CustomSkillProperties = {}
end

CustomSkillProperties.LLWEAPONEX_ApplyHandCrossbowBolt = {
	GetDescription = function(prop)
		return ""
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
			local rune,weaponBoostStat = Skills.GetHandCrossbowRuneBoost(attacker.Stats)
			if weaponBoostStat ~= nil then
				local props = Ext.StatGetAttribute(weaponBoostStat, "ExtraProperties")
				if props then
					GameHelpers.ApplyProperties(attacker, position, props, position, areaRadius)
				end
			end
		end
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local rune,weaponBoostStat = Skills.GetHandCrossbowRuneBoost(attacker.Stats)
			if weaponBoostStat ~= nil then
				local props = Ext.StatGetAttribute(weaponBoostStat, "ExtraProperties")
				if props then
					GameHelpers.ApplyProperties(attacker, position, props, position)
				end
			end
		end
	end
}

CustomSkillProperties.LLWEAPONEX_ApplyPistolBullet = {
	GetDescription = function(prop)
		return ""
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
			local rune,weaponBoostStat = Skills.GetPistolRuneBoost(attacker.Stats)
			if weaponBoostStat ~= nil then
				local props = Ext.StatGetAttribute(weaponBoostStat, "ExtraProperties")
				if props then
					GameHelpers.ApplyProperties(attacker, position, props, position, areaRadius)
				end
			end
		end
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local rune,weaponBoostStat = Skills.GetPistolRuneBoost(attacker.Stats)
			if weaponBoostStat ~= nil then
				local props = Ext.StatGetAttribute(weaponBoostStat, "ExtraProperties")
				if props then
					GameHelpers.ApplyProperties(attacker, position, props, position)
				end
			end
		end
	end
}

for k,v in pairs(CustomSkillProperties) do
	Ext.RegisterSkillProperty(k,v)
end
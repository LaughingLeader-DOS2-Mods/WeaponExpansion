if not CustomSkillProperties then
	CustomSkillProperties = {}
end

CustomSkillProperties.LLWEAPONEX_ApplyRuneProperties = {
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
				ApplyRuneExtraProperties(attacker, position, items[i], position, areaRadius)
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
				ApplyRuneExtraProperties(attacker, target, items[i], position, math.max(skill.AreaRadius or 1, skill.ExplodeRadius or 1))
			end
		end
	end
}
Ext.RegisterSkillProperty("LLWEAPONEX_ApplyRuneProperties", CustomSkillProperties.LLWEAPONEX_ApplyRuneProperties)

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
			local duration = math.max(prop.Arg2 or 1, 1) * 6.0
			local radius = math.max(areaRadius, math.max(skill.AreaRadius or 1, skill.ExplodeRadius or 1))
			RunebladeManager.AbsorbSurface(attacker, position, radius, duration)
		end
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local duration = math.max(prop.Arg2 or 1, 1) * 6.0
			local radius = math.max(skill.AreaRadius or 1, skill.ExplodeRadius or 1)
			RunebladeManager.AbsorbSurface(attacker, position, radius, duration)
		end
	end
}
Ext.RegisterSkillProperty("LLWEAPONEX_ChaosRuneAbsorbSurface", CustomSkillProperties.LLWEAPONEX_ChaosRuneAbsorbSurface)
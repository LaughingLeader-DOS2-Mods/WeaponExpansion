if RunebladeManager == nil then
	RunebladeManager = {}
end

if RunebladeManager.Bonuses == nil then
	RunebladeManager.Bonuses = {}
end

RunebladeManager.ImpactRadius = Ext.ExtraData.LLWEAPONEX_Runeblade_BonusImpactRadius or 0.5

---@param statusName string
---@param callback fun(IsFromSkill:boolean, attacker:EsvCharacter, target:EsvGameObject, damage:integer, data:HitData, bonuses:table, statusMap:table<string,EsvStatus>, targetStatusMap:table<string,EsvStatus>)
function RunebladeManager.RegisterBonus(statusName, callback)
	if RunebladeManager.Bonuses[statusName] == nil then
		RunebladeManager.Bonuses[statusName] = {}
	end
	table.insert(RunebladeManager.Bonuses[statusName], callback)
end

AttackManager.RegisterOnHit(function(bHitObject, source, target, damage, data, bonuses)
	if GameHelpers.CharacterOrEquipmentHasTag(source, "LLWEAPONEX_Runeblade") then
		local statusMap = {}
		for i,v in pairs(source:GetStatusObjects()) do
			statusMap[v.StatusId] = v
		end
		local targetStatusMap = {}
		if bHitObject then
			for i,v in pairs(target:GetStatusObjects()) do
				targetStatusMap[v.StatusId] = v
			end
		end
		for k,v in pairs(RunebladeManager.Bonuses) do
			if statusMap[k] then
				InvokeListenerCallbacks(v, bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
			end
		end
	end
end)

local function CanApplyStatus(target, source)
	if GameHelpers.Character.IsEnemy(target, source) or IsTagged(target, "LeaderLib_FriendlyFireEnabled") == 1 then
		return true
	end
	return false
end

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_FIRE", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	GameHelpers.Status.Apply(target, "BURNING", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_HEATBURST", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	if bHitObject then
		if targetStatusMap.BURNING and not targetStatusMap.LLWEAPONEX_RUNEBLADE_HEATBURST_SPREAD then
			GameHelpers.Status.Apply(target, "LLWEAPONEX_RUNEBLADE_HEATBURST_SPREAD", 6.0, false, source, nil, nil, CanApplyStatus)
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_WATER", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	GameHelpers.Status.Apply(target, "WET", 6.0, false, source, RunebladeManager.ImpactRadius, true)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_POISON", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	GameHelpers.Status.Apply(target, "POISONED", 6.0, false, source, RunebladeManager.ImpactRadius, true)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_SEARING", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	if bHitObject and targetStatusMap.WET then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_EVAPORATE_WATER", 0.0, false, source)
		GameHelpers.Status.Apply(target, "LLWEAPONEX_EVAPORATE_FIRE", 0.0, false, source)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_DEATH", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	if bHitObject and GameHelpers.Character.IsEnemy(source, target) then
		if not targetStatusMap.LLWEAPONEX_REVENANT
		and IsBoss(target.MyGuid) == 0 
		and not targetStatusMap.LLWEAPONEX_DEATH_SENTENCE
		and not targetStatusMap.LLWEAPONEX_DEATH_SENTENCE_BLOCKED
		then
			GameHelpers.Status.Apply(target, "LLWEAPONEX_DEATH_SENTENCE", 6.0, false, source)
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD_PLUS", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	if bHitObject then
		local amount = GetVarInteger(source.MyGuid, "LLWEAPONEX_BloodPlusAttacks") or 0
		amount = amount + 1
		if amount >= 2 then
			local item = GameHelpers.Item.CreateItemByStat("GRN_LLWEAPONEX_Throwing_BloodBall", true)
			if item then
				ItemToInventory(item, source.MyGuid, 1, 1, 0)
			end
			amount = 0
		end
		SetVarInteger(source.MyGuid, "LLWEAPONEX_BloodPlusAttacks", amount)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_CONDUCTION", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	if bHitObject and not statusMap.LLWEAPONEX_PREVENT_DOUBLE_HITS then
		if targetStatusMap.STUNNED or targetStatusMap.SHOCKED then
			GameHelpers.Status.Apply(target, "LLWEAPONEX_RUNEBLADE_CONDUCTION_CHAINLIGHTNING", 0.0, false, source)
		end
		if targetStatusMap.WET then
			if not targetStatusMap.LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE then
				GameHelpers.Status.Apply(target, "SHOCKED", 6.0, false, source)
				GameHelpers.Status.Apply(target, "LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE", 18.0, false, source)
			end
		else
			GameHelpers.Status.Apply(target, "WET", 6.0, false, source)
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_CONTAMINATION", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	if bHitObject then
		if targetStatusMap.POISONED and not targetStatusMap.LLWEAPONEX_RUNEBLADE_CONTAMINATION_SPREAD then
			GameHelpers.Status.Apply(target, "LLWEAPONEX_RUNEBLADE_CONTAMINATION_SPREAD", 6.0, false, source)
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_INFERNO", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	if bHitObject then
		local status = targetStatusMap.BURNING
		if status then
			local nextDuration = status.CurrentLifeTime + 6.0
			status.CurrentLifeTime = math.min(Ext.ExtraData.LLWEAPONEX_Runeblade_Inferno_MaxStacks*6.0, nextDuration)
			status.RequestClientSync = true
		else
			GameHelpers.Status.Apply(target, "BURNING", 6.0, false, source, RunebladeManager.ImpactRadius, true)
		end
	else
		GameHelpers.Status.Apply(target, "BURNING", 6.0, false, source, RunebladeManager.ImpactRadius, true)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_VENOM", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	if bHitObject then
		local status = targetStatusMap.POISONED
		if status then
			local nextDuration = status.CurrentLifeTime + 6.0
			status.CurrentLifeTime = math.min(Ext.ExtraData.LLWEAPONEX_Runeblade_Venom_MaxStacks*6.0, nextDuration)
			status.RequestClientSync = true
		else
			GameHelpers.Status.Apply(target, "POISONED", 6.0, false, source, RunebladeManager.ImpactRadius, true)
		end
	else
		GameHelpers.Status.Apply(target, "POISONED", 6.0, false, source, RunebladeManager.ImpactRadius, true)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD_AIR", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	GameHelpers.Status.Apply(source, "LLWEAPONEX_RUNEBLADE_BLOOD_AIR_REGEN_AURA", 6.0, false, source, RunebladeManager.ImpactRadius, true)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD_FIRE", function(bHitObject, source, target, damage, data, bonuses, statusMap, targetStatusMap)
	GameHelpers.Status.Apply(target, "LLWEAPONEX_SOUL_BURN_PROC", 6.0, false, source, RunebladeManager.ImpactRadius, true)
end)
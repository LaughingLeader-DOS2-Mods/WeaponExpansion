---@param statusName string
---@param callback fun(IsFromSkill:boolean, attacker:EsvCharacter, target:EsvGameObject, damage:integer, data:HitData, bonuses:table, statusMap:table<string,EsvStatus>, targetStatusMap:table<string,EsvStatus>)
function RunebladeManager.RegisterBonus(statusName, callback)
	if RunebladeManager.Bonuses[statusName] == nil then
		RunebladeManager.Bonuses[statusName] = {}
	end
	table.insert(RunebladeManager.Bonuses[statusName], callback)
end

AttackManager.RegisterOnWeaponTypeHit("LLWEAPONEX_Runeblade", function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
	if not isFromSkill then
		local statusMap = {}
		for i,v in pairs(source:GetStatusObjects()) do
			statusMap[v.StatusId] = v
		end
		local targetStatusMap = {}
		if bHitObject then
			for i,v in pairs(target:GetStatusObjects()) do
				targetStatusMap[v.StatusId] = v
			end
			GameHelpers.Status.Apply(target, "LLWEAPONEX_PREVENT_DOUBLE_HITS", 6.0, false, source)
		end
		print(source, target, damage, data, bonuses)
		print("statusMap", Lib.inspect(statusMap))
		print("targetStatusMap", Lib.inspect(targetStatusMap))
		for k,v in pairs(RunebladeManager.Bonuses) do
			if statusMap[k] then
				InvokeListenerCallbacks(v, k, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
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

local function RollForProc(character, chance, skipLogging)
	local roll = Ext.Random(0,999)
	if roll > chance then
		roll = Ext.Random(0,999)
	end

	local chanceTextAmount = Ext.Round((chance/999) * 100)
	if roll <= chance then
		local rollTextAmount = 100
		if not skipLogging then
			CombatLog.AddTextToPlayer(character, "Rolls", string.format("Roll Succeeded: %s%% (%s%% Chance)", rollTextAmount, chanceTextAmount))
		end
		return true
	else
		local rollTextAmount = 100 - Ext.Round((chance/roll) * 100)
		CombatLog.AddTextToPlayer(character, "Rolls", string.format("Roll Failed: %s/100 (%s%% Chance)", rollTextAmount, chanceTextAmount))
		return false
	end
end

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_FIRE", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	GameHelpers.Status.Apply(target, "BURNING", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_HEATBURST", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject then
		if targetStatusMap.BURNING and not targetStatusMap.LLWEAPONEX_RUNEBLADE_HEATBURST_SPREAD then
			GameHelpers.Status.Apply(target, "LLWEAPONEX_RUNEBLADE_HEATBURST_SPREAD", 6.0, false, source)
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_WATER", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	GameHelpers.Status.Apply(target, "WET", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_POISON", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	GameHelpers.Status.Apply(target, "POISONED", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_SEARING", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject and targetStatusMap.WET then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_EVAPORATE_WATER", 0.0, false, source)
		GameHelpers.Status.Apply(target, "LLWEAPONEX_EVAPORATE_FIRE", 0.0, false, source)
	end
	if RollForProc(source, GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Searing_Chance", 401, true)) then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_WATER_BURN", 12.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_DEATH", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
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

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD_PLUS", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject then
		local amount = GetVarInteger(source.MyGuid, "LLWEAPONEX_BloodPlusAttacks") or 0
		amount = amount + 1
		if amount >= 2 then
			local item = GameHelpers.Item.CreateItemByStat("GRN_LLWEAPONEX_Throwing_BloodBall")
			if item then
				ItemToInventory(item, source.MyGuid, 1, 1, 0)
			end
			amount = 0
		end
		SetVarInteger(source.MyGuid, "LLWEAPONEX_BloodPlusAttacks", amount)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_CONDUCTION", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject and targetStatusMap.LLWEAPONEX_PREVENT_DOUBLE_HITS then
		return
	end
	if bHitObject then
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
	else
		GameHelpers.Status.Apply(target, "WET", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_CONTAMINATION", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject and targetStatusMap.POISONED and not targetStatusMap.LLWEAPONEX_RUNEBLADE_CONTAMINATION_SPREAD then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_RUNEBLADE_CONTAMINATION_SPREAD", 6.0, false, source)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_INFERNO", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject and targetStatusMap.LLWEAPONEX_PREVENT_DOUBLE_HITS then
		return
	end
	if bHitObject then
		local status = targetStatusMap.BURNING
		if status then
			local nextDuration = status.CurrentLifeTime + 6.0
			status.CurrentLifeTime = math.min(Ext.ExtraData.LLWEAPONEX_Runeblade_Inferno_MaxStacks*6.0, nextDuration)
			status.RequestClientSync = true
		else
			GameHelpers.Status.Apply(target, "BURNING", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
		end
	else
		GameHelpers.Status.Apply(target, "BURNING", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_VENOM", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject and targetStatusMap.LLWEAPONEX_PREVENT_DOUBLE_HITS then
		return
	end
	if bHitObject then
		local status = targetStatusMap.POISONED
		if status then
			local nextDuration = status.CurrentLifeTime + 6.0
			status.CurrentLifeTime = math.min(Ext.ExtraData.LLWEAPONEX_Runeblade_Venom_MaxStacks*6.0, nextDuration)
			status.RequestClientSync = true
		else
			GameHelpers.Status.Apply(target, "POISONED", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
		end
	else
		GameHelpers.Status.Apply(target, "POISONED", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD_AIR", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject and targetStatusMap.LLWEAPONEX_PREVENT_DOUBLE_HITS then
		return
	end
	GameHelpers.Status.Apply(source, "LLWEAPONEX_RUNEBLADE_BLOOD_AIR_REGEN_AURA", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD_FIRE", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	GameHelpers.Status.Apply(target, "LLWEAPONEX_SOUL_BURN_PROC", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Blood_Chance", 201, true)
	if RollForProc(source, chance) then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_MAGIC_BLEEDING_CHECK", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_LAVA", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Lava_Chance", 601, true)
	if RollForProc(source, chance) then
		GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Runeblade_LavaRune", source)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_AVALANCHE", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Avalanche_Chance", 401, true)
	if RollForProc(source, chance) then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_RUNEBLADE_AVALANCHE_SNOW", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_EARTH", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	print("RunebladeManager", statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Earth_Chance", 201, true)
	if RollForProc(source, chance) then
		GameHelpers.Status.Apply(target, "SLOWED", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_QUAKE", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Quake_Chance", 201, true)
	if RollForProc(source, chance) then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_MAGIC_KNOCKDOWN_CHECK", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_DUST", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if not statusMap.LLWEAPONEX_RUNEBLADE_DUST_COOLDOWN then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Dust_Chance", 301, true)
		if RollForProc(source, chance) then
			GameHelpers.Status.Apply(source, "LLWEAPONEX_RUNEBLADE_DUST_COOLDOWN", 6.0, false, source)
			PlayEffect(source.MyGuid, "LLWEAPONEX_FX_Skills_Runeblade_DustBlast_Cast_01", "")
			---@type EsvZoneAction
			local surf = Ext.CreateSurfaceAction("ZoneAction")
			---@type StatEntrySkillData
			local skill = Ext.GetStat("Cone_LLWEAPONEX_Runeblade_DustBlast")
			surf.SkillId = "Cone_LLWEAPONEX_Runeblade_DustBlast"
			surf.OwnerHandle = source.Handle
			surf.Duration = 6.0
			surf.SurfaceType = skill.SurfaceType
			surf.Position = source.WorldPos
			surf.Target = GameHelpers.Math.ExtendPositionWithForwardDirection(source, 2.0)
			surf.GrowTimer = skill.SurfaceGrowInterval
			surf.GrowStep = skill.SurfaceGrowStep
			surf.Shape = 0 -- 0=Cone, 1=Square
			surf.Radius = skill.Range
			surf.AngleOrBase = skill.Angle
			surf.MaxHeight = 2.4
			Ext.ExecuteSurfaceAction(surf)
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_THUNDERBOLT", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if not statusMap.LLWEAPONEX_RUNEBLADE_THUNDERBOLT_COOLDOWN then
		local success = false
		if bHitObject and targetStatusMap.WET then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Thunderbolt_Chance_Wet", 801, true)
			if RollForProc(source, chance) then
				success = true
			end
		else
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Thunderbolt_Chance", 201, true)
			if RollForProc(source, chance) then
				success = true
			end
		end
		if success then
			--GameHelpers.Skill.Explode(target, "ProjectileStrike_LLWEAPONEX_Runeblade_Thunderbolt", source)
			--GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Runeblade_ChainLightning", source)
			GameHelpers.Skill.CreateProjectileStrike(target, "ProjectileStrike_LLWEAPONEX_Runeblade_Thunderbolt", source, nil, true, true, true)
			GameHelpers.Status.Apply(source, "LLWEAPONEX_RUNEBLADE_THUNDERBOLT_COOLDOWN", 6.0, false, source)
			statusMap.LLWEAPONEX_RUNEBLADE_THUNDERBOLT_COOLDOWN = true
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_EXPLOSIVE", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Explosion_Chance", 401, true)
	if RollForProc(source, chance) then
		GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Runeblade_MiniExplosion", source)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_TAR", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Tar_Chance", 401, true)
	if RollForProc(source, chance) then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_TARRED", 12.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD_POISON", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_BloodDisease_Chance", 401, true)
	if RollForProc(source, chance) then
		GameHelpers.Status.Apply(target, "INFECTIOUS_DISEASED", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_AIR", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if not statusMap.LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE then
		local success = false
		if bHitObject and targetStatusMap.WET then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Air_Chance_Wet", 501, true)
			if RollForProc(source, chance) then
				success = true
			end
		else
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Air_Chance", 101, true)
			if RollForProc(source, chance) then
				success = true
			end
		end
		if success then
			GameHelpers.Status.Apply(target, "SHOCKED", 6.0, false, source)
			GameHelpers.Status.Apply(source, "LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE", 18.0, false, source)
			statusMap.LLWEAPONEX_SHOCKED_RESISTANCE_RUNEBLADE = true
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_GAS", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if not statusMap.LLWEAPONEX_RUNEBLADE_GAS_COOLDOWN then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Gas_Chance", 501, true)
		if RollForProc(source, chance) then
			local pos = GameHelpers.Math.GetPosition(target, false, source.WorldPos)
			local x,y,z = table.unpack(pos)
			local step = 2
			if GameHelpers.Surface.HasSurface(x,z,"Poison", 3.0, true, 1) then
				CharacterStatusText(source.MyGuid, "LLWEAPONEX_StatusText_GasExpansion")
				step = 4
			else
				CharacterStatusText(source.MyGuid, "LLWEAPONEX_StatusText_GasCreation")
			end
			---@type EsvCreatePuddleAction
			local surf = Ext.CreateSurfaceAction("CreatePuddleAction")
			surf.OwnerHandle = source.Handle
			surf.Duration = 18.0
			surf.StatusChance = 1.0
			surf.Position = pos
			surf.SurfaceType = "PoisonCloud"
			surf.GrowTimer = 1
			surf.GrowSpeed = 3
			surf.Step = step
			surf.IgnoreIrreplacableSurfaces = true
			Ext.ExecuteSurfaceAction(surf)
			GameHelpers.Status.Apply(source, "LLWEAPONEX_RUNEBLADE_GAS_COOLDOWN", 6.0, false, source)
			statusMap.LLWEAPONEX_RUNEBLADE_GAS_COOLDOWN = true
			if bHitObject then
				PlayEffect(target.MyGuid, "RS3_FX_Skills_Earth_Cast_Target_Air_Hand_01", "Dummy_BodyFX")
			else
				PlayEffectAtPosition("RS3_FX_Skills_Earth_Cast_Target_Air_Hand_01", x, y, z)
			end
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_ICE", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject and targetStatusMap.LLWEAPONEX_PREVENT_DOUBLE_HITS then
		return
	end
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_Ice_Chance", 201, true)
	if RollForProc(source, chance) then
		if bHitObject and targetStatusMap.CHILLED then
			GameHelpers.Status.Apply(target, "FROZEN", 6.0, false, source)
		else
			GameHelpers.Status.Apply(target, "CHILLED", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
		end
	end
end)

RunebladeManager.RegisterBonus("LLWEAPONEX_ACTIVATE_RUNEBLADE_BLOOD_EARTH", function(statusId, source, target, data, bonuses, statusMap, targetStatusMap, bHitObject)
	if bHitObject and targetStatusMap.LLWEAPONEX_PREVENT_DOUBLE_HITS then
		return
	end
	if bHitObject and GameHelpers.Character.IsUndead(target) then
		GameHelpers.Status.Apply(target, "LLWEAPONEX_UNDEAD_BONUS_DAMAGE", 0.0, false, source)
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_BloodEarth_Chance_Undead", 501, true)
		if RollForProc(source, chance) then
			GameHelpers.Status.Apply(target, "ENTANGLED", 6.0, false, source)
		end
	else
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_Runeblade_BloodEarth_Chance", 101, true)
		if RollForProc(source, chance) then
			GameHelpers.Status.Apply(target, "ENTANGLED", 6.0, false, source, RunebladeManager.ImpactRadius, true, CanApplyStatus)
		end
	end
end)
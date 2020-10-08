if Ext.IsServer() then
	local UnarmedHitMatchProperties = {
		DamageType = 0,
		DamagedMagicArmor = 0,
		Equipment = 0,
		DeathType = 0,
		Bleeding = 0,
		DamagedPhysicalArmor = 0,
		PropagatedFromOwner = 0,
		-- NoWeapon doesn't set HitWithWeapon until after preparation
		HitWithWeapon = 0,
		Surface = 0,
		NoEvents = 0,
		Hit = 0,
		Poisoned = 0,
		--CounterAttack = 0,
		--ProcWindWalker = 1,
		NoDamageOnOwner = 0,
		Burning = 0,
		--DamagedVitality = 0,
		--LifeSteal = 0,
		--ArmorAbsorption = 0,
		--AttackDirection = 0,
		Missed = 0,
		--CriticalHit = 0,
		--Backstab = 0,
		Reflection = 0,
		DoT = 0,
		Dodged = 0,
		--DontCreateBloodSurface = 0,
		FromSetHP = 0,
		FromShacklesOfPain = 0,
		Blocked = 0,
	}

	local function IsUnarmedHit(handle)
		for prop,val in pairs(UnarmedHitMatchProperties) do
			if NRD_HitGetInt(handle, prop) ~= val then
				Ext.PrintError(prop,"does not equal", val)
				return false
			end
		end
		return true
	end

	local lizardHits = {}

	function UnarmedHelpers.ScaleUnarmedHitDamage(attacker, target, damage, handle)
		if damage > 0 then
			--LeaderLib.Debug_TraceHitPrepare(target, attacker, damage, handle)
			if IsUnarmedHit(handle) then
				-- Just why?
				local character = Ext.GetCharacter(attacker)
				local isLizard = character:HasTag("LIZARD")
				local isCombinedHit = isLizard and NRD_HitGetInt(handle, "ProcWindWalker") == 0
				local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character.Stats, true)

				if isCombinedHit then
					lizardHits[attacker] = nil
				elseif isLizard then
					if lizardHits[attacker] == nil then
						lizardHits[attacker] = 0
					end
					lizardHits[attacker] = lizardHits[attacker] + 1
				end

				local isSecondHit = lizardHits[attacker] == 2
				local damageList = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, false, highestAttribute, isLizard, isSecondHit)

				if isCombinedHit then
					local offhandDamage = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, false, highestAttribute, isLizard, true)
					damageList:Merge(offhandDamage)
				end
				NRD_HitClearAllDamage(handle)
				--NRD_HitStatusClearAllDamage(target, handle)
				local damages = damageList:ToTable()
				local totalDamage = 0
				for i,damage in pairs(damages) do
					NRD_HitAddDamage(handle, damage.DamageType, damage.Amount)
					totalDamage = totalDamage + damage.Amount
				end
				Ext.PrintWarning(string.format("[LLWEAPONEX] Unarmed Damage (%s) Boost(%s) IsCombined(%s) IsSecondHit(%s) Attacker(%s) Target(%s)", totalDamage, unarmedMasteryBoost, isCombinedHit, isSecondHit, attacker, target))
				if lizardHits[attacker] == 2 then
					lizardHits[attacker] = nil
				end
			else
				LeaderLib.Debug_TraceHitPrepare(target, attacker, damage, handle)
				Ext.PrintError("Is not an unarmed hit?")
			end
		end
	end
end
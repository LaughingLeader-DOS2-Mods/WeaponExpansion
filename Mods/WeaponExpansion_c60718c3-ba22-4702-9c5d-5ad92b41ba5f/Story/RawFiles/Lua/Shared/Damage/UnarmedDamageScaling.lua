local isClient = Ext.IsClient()

if not isClient then
	local UnarmedHitMatchProperties = {
		DamageType = 0,
		DamagedMagicArmor = 0,
		Equipment = 0,
		--DeathType = 0,
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
				--Ext.PrintError(prop,"does not equal", val)
				return false
			end
		end
		return true
	end

	local lizardHits = {}

	--- @param attacker string
	--- @param target string
	--- @param damage integer
	--- @param handle integer
	--- @param data HitPrepareData
	--- @param force boolean
	function UnarmedHelpers.ScaleUnarmedHitDamage(attacker, target, damage, handle, data, force)
		if force == true or IsUnarmedHit(handle) then
			local character = Ext.GetCharacter(attacker)
			local isLizard = character:HasTag("LIZARD")
			local isCombinedHit = isLizard and not data.ProcWindWalker
			local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character.Stats)

			if isCombinedHit then
				lizardHits[attacker] = nil
			elseif isLizard then
				if lizardHits[attacker] == nil then
					lizardHits[attacker] = 0
				end
				lizardHits[attacker] = lizardHits[attacker] + 1
			end

			--FIX to try and preserve the previous damage type
			-- local previousDamageType = data.DamageType
			-- local lastAmount = 0
			-- for dType,amount in pairs(data.DamageList) do
			-- 	if amount > lastAmount and dType ~= previousDamageType then
			-- 		previousDamageType = dType
			-- 		lastAmount = amount
			-- 	end
			-- end

			local isSecondHit = lizardHits[attacker] == 2
			local damageList = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, false, highestAttribute, isLizard, isSecondHit)

			if isCombinedHit then
				local offhandDamage = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, false, highestAttribute, isLizard, true)
				damageList:Merge(offhandDamage)
			end
			-- if not StringHelpers.IsNullOrEmpty(previousDamageType) then
			-- 	damageList:ConvertDamageType(previousDamageType)
			-- end
			data:ClearAllDamage()
			local damages = damageList:ToTable()
			for i,damage in pairs(damages) do
				data.DamageList[damage.DamageType] = damage.Amount
			end
			data:Recalculate()
			if Vars.DebugMode then
				Ext.PrintWarning(string.format("[LLWEAPONEX] Unarmed Damage Weapon(%s) (%s) Boost(%s) IsCombined(%s) IsSecondHit(%s) Attacker(%s) Target(%s)", weapon and weapon.Name or "nil", data.TotalDamageDone, unarmedMasteryBoost, isCombinedHit, isSecondHit, attacker, target))
			end
			if lizardHits[attacker] == 2 then
				lizardHits[attacker] = nil
			end
		end
	end
end
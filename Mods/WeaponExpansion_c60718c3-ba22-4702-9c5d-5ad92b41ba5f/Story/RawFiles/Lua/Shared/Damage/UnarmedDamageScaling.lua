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
				--Ext.Utils.PrintError(prop,"does not equal", val)
				return false
			end
		end
		return true
	end

	local lizardHits = {}

	--- @param attacker EsvCharacter
	--- @param target EsvCharacter|EsvItem
	--- @param data HitPrepareData
	--- @param force boolean
	function UnarmedHelpers.ScaleUnarmedHitDamage(attacker, target, data, force)
		if force == true or IsUnarmedHit(data.Handle) then
			local isLizard = GameHelpers.Character.GetBaseRace(attacker) == "Lizard"
			local isCombinedHit = isLizard and not data.ProcWindWalker
			local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(attacker.Stats)

			if isCombinedHit then
				lizardHits[attacker.MyGuid] = nil
			elseif isLizard then
				if lizardHits[attacker.MyGuid] == nil then
					lizardHits[attacker.MyGuid] = 0
				end
				lizardHits[attacker.MyGuid] = lizardHits[attacker.MyGuid] + 1
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

			local isSecondHit = lizardHits[attacker.MyGuid] == 2
			local damageList = UnarmedHelpers.CalculateWeaponDamage(attacker.Stats, weapon, false, highestAttribute, isLizard, isSecondHit)

			if isCombinedHit then
				local offhandDamage = UnarmedHelpers.CalculateWeaponDamage(attacker.Stats, weapon, false, highestAttribute, isLizard, true)
				damageList:Merge(offhandDamage)
			end
			-- if not StringHelpers.IsNullOrEmpty(previousDamageType) then
			-- 	damageList:ConvertDamageType(previousDamageType)
			-- end
			data:ClearAllDamage()
			local damages = damageList:ToTable()
			local total = 0
			for i,damage in pairs(damages) do
				data:AddDamage(damage.DamageType, damage.Amount, true)
				total = total + damage.Amount
			end
			data.TotalDamageDone = total
			if Vars.DebugMode then
				Ext.Utils.PrintWarning(string.format("[LLWEAPONEX] Unarmed Damage Weapon(%s) (%s) Boost(%s) IsCombined(%s) IsSecondHit(%s) Attacker(%s) Target(%s)", weapon and weapon.Name or "nil", data.TotalDamageDone, unarmedMasteryBoost, isCombinedHit, isSecondHit, attacker, target))
			end
			if lizardHits[attacker.MyGuid] == 2 then
				lizardHits[attacker.MyGuid] = nil
			end
		end
	end
end
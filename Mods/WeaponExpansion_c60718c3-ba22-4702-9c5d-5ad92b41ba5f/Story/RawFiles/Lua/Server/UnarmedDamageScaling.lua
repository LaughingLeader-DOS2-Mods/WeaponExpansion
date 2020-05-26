
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
	ProcWindWalker = 1,
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

local function IsUnarmedDamage(handle)
	for prop,val in pairs(UnarmedHitMatchProperties) do
		if NRD_HitGetInt(handle, prop) ~= val then
			return false
		end
	end
	return true
end

function ScaleUnarmedDamage(attacker, target, damage, handle)
	if damage > 0 and IsUnarmedDamage(handle) then
		local character = Ext.GetCharacter(attacker)
		local weapon = GetUnarmedWeapon(character.Stats)
		--Ext.Print("Unarmed hit: damage("..tostring(damage)..") unarmedMastery("..tostring(unarmedMastery)..") attacker("..tostring(attacker)..") target("..tostring(target)..") attackerLevel("..tostring(level)..") itemLevel("..tostring(itemLevel)..")")

		local damageList = Game.Math.CalculateWeaponDamage(character.Stats, weapon, false)
		local damages = damageList:ToTable()
		NRD_HitClearAllDamage(handle)
		--NRD_HitStatusClearAllDamage(target, handle)
		for i,damage in pairs(damages) do
			--NRD_HitAddDamage(handle, damage.DamageType, damage.Amount)
			NRD_HitAddDamage(handle, damage.DamageType, damage.Amount)
			--NRD_HitStatusAddDamage(target, handle, damage.DamageType, damage.Amount)
		end
		--Ext.Print("Unarmed damage: ("..LeaderLib.Common.Dump(damages)..")")
	end
end
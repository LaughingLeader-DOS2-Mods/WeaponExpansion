local function SaveBasicAttackTarget(attacker, target)
	if PersistentVars["BasicAttackData"] == nil then
		PersistentVars["BasicAttackData"] = {}
	end
	if PersistentVars["BasicAttackData"][attacker] == nil then
		PersistentVars["BasicAttackData"][attacker] = {}
	end
	PersistentVars["BasicAttackData"][attacker].Target = target
end

local function GetBasicAttackTarget(attacker)
	if PersistentVars["BasicAttackData"] ~= nil and PersistentVars["BasicAttackData"][attacker] ~= nil then
		return PersistentVars["BasicAttackData"][attacker]
	end
	return nil
end

function OnBasicAttackTarget(attacker, target)
	if HasActiveStatus(attacker, "LLWEAPONEX_WAND_MAGIC_MISSILE") == 1 then
		SaveBasicAttackTarget(attacker, target)
		Osi.ProcObjectTimerCancel(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses")
		Osi.ProcObjectTimer(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses", 580)
	end
end

function OnBasicAttackPosition(attacker, xs, ys, zs)
	local x = tonumber(xs)
	local y = tonumber(ys)
	local z = tonumber(zs)

	if HasActiveStatus(attacker, "LLWEAPONEX_WAND_MAGIC_MISSILE") == 1 then
		SaveBasicAttackTarget(attacker, {x,y,z})
		Osi.ProcObjectTimerCancel(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses")
		Osi.ProcObjectTimer(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses", 580)
	end
end

function MagicMissileWeapon_RollForBasicAttackBonuses(attacker)
	local data = GetBasicAttackTarget(attacker)
	if data ~= nil and data.Target ~= nil then
		local chance1 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance1", 45)
		local chance2 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance2", 30)
		local chance3 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance3", 10)
		local sourcePos = GameHelpers.GetForwardPosition(attacker, 4.0)
		if Ext.Random(0,100) <= chance1 then
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus1", 0, sourcePos)
		end
		if Ext.Random(0,100) <= chance2 then
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus2", 0, sourcePos)
		end
		if Ext.Random(0,100) <= chance3 then
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus3", 0, sourcePos)
		end
		PersistentVars["BasicAttackData"][attacker] = nil
	end
end
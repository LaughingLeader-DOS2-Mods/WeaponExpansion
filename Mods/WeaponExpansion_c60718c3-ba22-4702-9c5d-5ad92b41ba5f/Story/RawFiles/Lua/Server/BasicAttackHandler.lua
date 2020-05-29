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
	print("OnBasicAttackTarget", attacker, target)
	if HasActiveStatus(attacker, "LLWEAPONEX_WAND_MAGIC_MISSILE") == 1 then
		SaveBasicAttackTarget(attacker, target)
		Osi.ProcObjectTimerCancel(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses")
		Osi.ProcObjectTimer(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses", 580)
	end
end

function OnBasicAttackPosition(attacker, xs, ys, zs)
	print("OnBasicAttackPosition", attacker, xs,ys,zs, HasActiveStatus(attacker, "LLWEAPONEX_WAND_MAGIC_MISSILE"))
	local x = tonumber(xs)
	local y = tonumber(ys)
	local z = tonumber(zs)

	if HasActiveStatus(attacker, "LLWEAPONEX_WAND_MAGIC_MISSILE") == 1 then
		--local projectileTarget = GameHelpers.ExtendPositionWithForward(attacker, 1.25, x, y, z)
		SaveBasicAttackTarget(attacker, {x,y,z})
		Osi.ProcObjectTimerCancel(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses")
		Osi.ProcObjectTimer(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses", 580)
	end
end

function MagicMissileWeapon_RollForBasicAttackBonuses(attacker)
	local data = GetBasicAttackTarget(attacker)
	if data ~= nil and data.Target ~= nil then
		-- if type(data.Target) == "string" then
		-- 	local x,y,z = GetPosition(data.Target)
		-- 	data.Target = GameHelpers.ExtendPositionWithForward(attacker, 1.25, x,y,z)
		-- end
		print("MagicMissileWeapon_RollForBasicAttackBonuses", Common.Dump(data.Target))
		local chance1 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance1", 45)
		local chance2 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance2", 30)
		local chance3 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance3", 10)
		local sourcePos = GameHelpers.GetForwardPosition(attacker, 4.0)
		sourcePos[2] = sourcePos[2] + 2.0
		if Ext.Random(0,100) <= chance1 then
			print("Shooting Projectile_LLWEAPONEX_Status_MagicMissile_Bonus1")
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus1", 0, sourcePos)
		end
		if Ext.Random(0,100) <= chance2 then
			print("Shooting Projectile_LLWEAPONEX_Status_MagicMissile_Bonus2")
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus2", 0, sourcePos)
		end
		if Ext.Random(0,100) <= chance3 then
			print("Shooting Projectile_LLWEAPONEX_Status_MagicMissile_Bonus3")
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus3", 0, sourcePos)
		end
		PersistentVars["BasicAttackData"][attacker] = nil
	end
end
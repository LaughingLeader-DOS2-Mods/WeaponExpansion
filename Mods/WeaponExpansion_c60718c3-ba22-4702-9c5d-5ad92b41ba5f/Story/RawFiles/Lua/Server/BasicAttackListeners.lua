if BasicAttackManager == nil then
	BasicAttackManager = {}
end

if BasicAttackManager.Listeners == nil then
	BasicAttackManager.Listeners = {
		OnStart = {},
		OnHit = {},
	}
end

function BasicAttackManager.RegisterListener(event, func)
	if BasicAttackManager.Listeners[event] == nil then
		BasicAttackManager.Listeners[event] = {}
	end
	table.insert(BasicAttackManager.Listeners[event], func)
end

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

local function OnBasicAttackTarget(target, owner, attacker)
	if HasActiveStatus(attacker, "LLWEAPONEX_WAND_MAGIC_MISSILE") == 1 then
		SaveBasicAttackTarget(attacker, target)
		Osi.ProcObjectTimerCancel(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses")
		Osi.ProcObjectTimer(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses", 580)
	end
	for i,callback in ipairs(BasicAttackManager.Listeners.OnStart) do
		local b,err = xpcall(callback, debug.traceback, StringHelpers.GetUUID(attacker), StringHelpers.GetUUID(owner), StringHelpers.GetUUID(target))
		if not b then
			Ext.PrintError(err)
		end
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackObject", 3, "after", OnBasicAttackTarget)

local function OnBasicAttackPosition(x, y, z, owner, attacker)
	if HasActiveStatus(attacker, "LLWEAPONEX_WAND_MAGIC_MISSILE") == 1 then
		--local projectileTarget = GameHelpers.Math.ExtendPositionWithForward(attacker, 1.25, x, y, z)
		SaveBasicAttackTarget(attacker, {x,y,z})
		Osi.ProcObjectTimerCancel(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses")
		Osi.ProcObjectTimer(attacker, "Timers_LLWEAPONEX_MagicMissile_RollForBonuses", 580)
	end
	for i,callback in ipairs(BasicAttackManager.Listeners.OnStart) do
		local b,err = xpcall(callback, debug.traceback, StringHelpers.GetUUID(attacker), StringHelpers.GetUUID(owner), {x,y,z})
		if not b then
			Ext.PrintError(err)
		end
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackPosition", 5, "after", OnBasicAttackPosition)

function MagicMissileWeapon_RollForBasicAttackBonuses(attacker)
	local data = GetBasicAttackTarget(attacker)
	if data ~= nil and data.Target ~= nil then
		local chance1 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance1", 45)
		local chance2 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance2", 30)
		local chance3 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance3", 10)
		local sourcePos = GameHelpers.GetForwardPosition(attacker, 4.0)
		sourcePos[2] = sourcePos[2] + 2.0
		if Ext.Random(0,100) <= chance1 then
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus1", 1, sourcePos)
		end
		if Ext.Random(0,100) <= chance2 then
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus2", 1, sourcePos)
		end
		if Ext.Random(0,100) <= chance3 then
			GameHelpers.ShootProjectile(attacker, data.Target, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus3", 1, sourcePos)
		end
		PersistentVars["BasicAttackData"][attacker] = nil
	end
end

--- @param caster EsvGameObject
--- @param position number[]
--- @param damageList DamageList
Ext.RegisterListener("GroundHit", function (caster, position, damageList)
	for i,callback in ipairs(BasicAttackManager.Listeners.OnHit) do
		local b,err = xpcall(callback, debug.traceback, false, caster.MyGuid, position, damageList)
		if not b then
			Ext.PrintError(err)
		end
	end
end)
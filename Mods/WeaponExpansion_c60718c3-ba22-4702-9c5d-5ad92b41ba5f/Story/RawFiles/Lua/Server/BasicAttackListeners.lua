if BasicAttackManager == nil then
	BasicAttackManager = {}
end

if BasicAttackManager.Listeners == nil then
	BasicAttackManager.Listeners = {
		OnStart = {},
		OnHit = {},
	}
end

---@alias BasicAttackEventID OnStart|OnHit

---@alias BasicAttackOnStartCallback fun(attacker:string, target:string|number[]):void
---@alias BasicAttackOnHitTargetCallback fun(bHitObject:boolean, attacker:string, target:string|number[], damage:integer|DamageList, handle:integer|nil):void

---@param event BasicAttackEventID
---@param func BasicAttackOnStartCallback|BasicAttackOnHitTargetCallback
function BasicAttackManager.RegisterListener(event, func)
	if BasicAttackManager.Listeners[event] == nil then
		BasicAttackManager.Listeners[event] = {}
	end
	table.insert(BasicAttackManager.Listeners[event], func)
end

---@param func BasicAttackOnHitTargetCallback|BasicAttackOnHitTargetCallback
function BasicAttackManager.RegisterOnHit(func)
	BasicAttackManager.RegisterListener("OnHit", func)
end

---@param func BasicAttackOnStartCallback
function BasicAttackManager.RegisterOnStart(func)
	BasicAttackManager.RegisterListener("OnStart", func)
end

function BasicAttackManager.RemoveListener(event, func)
	if BasicAttackManager.Listeners[event] ~= nil then
		for i,callback in pairs(BasicAttackManager.Listeners[event]) do
			if callback == func then
				BasicAttackManager.Listeners[event][i] = nil
				break
			end
		end
	end
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
	for i,callback in pairs(BasicAttackManager.Listeners.OnStart) do
		local b,err = xpcall(callback, debug.traceback, StringHelpers.GetUUID(attacker), StringHelpers.GetUUID(target))
		if not b then
			Ext.PrintError(err)
		end
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackObject", 3, "after", OnBasicAttackTarget)

local startedAttackedPosition = {}

local function OnBasicAttackPosition(x, y, z, owner, attacker)
	attacker = StringHelpers.GetUUID(attacker)
	startedAttackedPosition[attacker] = true
	for i,callback in pairs(BasicAttackManager.Listeners.OnStart) do
		local b,err = xpcall(callback, debug.traceback, attacker, {x,y,z})
		if not b then
			Ext.PrintError(err)
		end
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackPosition", 5, "after", OnBasicAttackPosition)

function BasicAttackManager.InvokeOnHit(isFromHit, source, target, damage, handle)
	for i,callback in pairs(BasicAttackManager.Listeners.OnHit) do
		local b,err = xpcall(callback, debug.traceback, isFromHit, source, target, damage, handle)
		if not b then
			Ext.PrintError(err)
		end
	end
end

---@param attacker string
---@param target number[]
---@param hitObject EsvGameObject
function MagicMissileWeapon_RollForBonusMissiles(attacker, target, hitObject)
	local chance1 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance1", 45)
	local chance2 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance2", 30)
	local chance3 = GameHelpers.GetExtraData("LLWEAPONEX_MagicMissile_BonusChance3", 10)
	local sourcePos = GameHelpers.Math.GetForwardPosition(attacker, 4.0)
	sourcePos[2] = sourcePos[2] + 2.0
	--local targetPos = GameHelpers.Math.ExtendPositionWithForwardDirection(attacker, 1.01, target[1], target[2], target[3])
	local targetPos = target
	if Ext.Random(0,100) <= chance1 then
		GameHelpers.ShootProjectile(attacker, targetPos, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus1", true, sourcePos, hitObject.MyGuid)
	end
	if Ext.Random(0,100) <= chance2 then
		GameHelpers.ShootProjectile(attacker, targetPos, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus2", true, sourcePos, hitObject.MyGuid)
	end
	if Ext.Random(0,100) <= chance3 then
		GameHelpers.ShootProjectile(attacker, targetPos, "Projectile_LLWEAPONEX_Status_MagicMissile_Bonus3", true, sourcePos, hitObject.MyGuid)
	end
end

--- @param caster EsvGameObject
--- @param position number[]
--- @param damageList DamageList
Ext.RegisterListener("GroundHit", function (caster, position, damageList)
	--Also fires when a projectile hits the ground (exploding projectiles too!), so we need this table entry
	if caster and startedAttackedPosition[caster.MyGuid] then
		startedAttackedPosition[caster.MyGuid] = nil
		BasicAttackManager.InvokeOnHit(false, caster.MyGuid, position, damageList, nil)
	end
end)

---@param projectile EsvProjectile
---@param hitObject EsvGameObject
---@param position number[]
Ext.RegisterListener("ProjectileHit", function (projectile, hitObject, position)
	-- if projectile.SkillId ~= "" then
	-- 	local skill = LeaderLib.GetSkillEntryName(projectile.SkillId)
	-- end
	--if projectile.RootTemplate == "LLWEAPONEX_Projectile_Wand_MagicMissile_211d6c42-b848-49cd-af76-170c3e2fbd73" then
	if projectile.RootTemplate ~= nil 
		and projectile.RootTemplate.TrailFX == "LLWEAPONEX_FX_Projectiles_Wand_MagicMissile_01" 
		and projectile.SourceHandle ~= nil 
		and projectile.RootTemplate.PathShift == 0.5
	then
		local attacker = Ext.GetCharacter(projectile.SourceHandle)
		if attacker ~= nil and attacker:HasTag("LLWEAPONEX_MagicMissileWand_Equipped") then
			MagicMissileWeapon_RollForBonusMissiles(attacker.MyGuid, position, hitObject)
		end
	end
end)
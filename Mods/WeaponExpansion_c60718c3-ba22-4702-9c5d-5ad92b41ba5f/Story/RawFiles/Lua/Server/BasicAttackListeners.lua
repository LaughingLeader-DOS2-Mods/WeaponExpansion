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
	for i,callback in pairs(BasicAttackManager.Listeners.OnStart) do
		local b,err = xpcall(callback, debug.traceback, StringHelpers.GetUUID(attacker), StringHelpers.GetUUID(owner), StringHelpers.GetUUID(target))
		if not b then
			Ext.PrintError(err)
		end
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackObject", 3, "after", OnBasicAttackTarget)

local function OnBasicAttackPosition(x, y, z, owner, attacker)
	for i,callback in pairs(BasicAttackManager.Listeners.OnStart) do
		local b,err = xpcall(callback, debug.traceback, StringHelpers.GetUUID(attacker), StringHelpers.GetUUID(owner), {x,y,z})
		if not b then
			Ext.PrintError(err)
		end
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackPosition", 5, "after", OnBasicAttackPosition)

---@param attacker string
---@param target number[]
---@param hitObject EsvGameObject
function MagicMissileWeapon_RollForBonusMissiles(attacker, target, hitObject)
	print("MagicMissile rolling")
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
	if caster ~= nil then
		for i,callback in pairs(BasicAttackManager.Listeners.OnHit) do
			local b,err = xpcall(callback, debug.traceback, false, caster.MyGuid, position, damageList)
			if not b then
				Ext.PrintError(err)
			end
		end
	elseif Ext.IsDeveloperMode() then
		Ext.PrintError("[LLWEAPONEX:GroundHit] caster is nil?", Common.Dump(position))
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
		if attacker ~= nil and attacker:GetStatus("LLWEAPONEX_WAND_MAGIC_MISSILE") ~= nil then
			MagicMissileWeapon_RollForBonusMissiles(attacker.MyGuid, position, hitObject)
		end
	end
end)
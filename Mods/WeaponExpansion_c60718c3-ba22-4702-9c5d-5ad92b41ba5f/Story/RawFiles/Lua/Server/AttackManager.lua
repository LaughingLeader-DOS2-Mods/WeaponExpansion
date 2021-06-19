if AttackManager == nil then
	AttackManager = {}
end

if AttackManager.Listeners == nil then
	AttackManager.Listeners = {
		OnStart = {},
		OnHit = {},
		---@type table<string,BasicAttackOnHitTargetCallback>
		OnWeaponTypeHit = {}
	}
end

---@alias BasicAttackEventID OnStart|OnHit

---@alias BasicAttackOnStartCallback fun(attacker:string, target:string|number[]):void
---@alias BasicAttackOnHitTargetCallback fun(bHitObject:boolean, attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], damage:integer|DamageList, data:HitData, bonuses:table|nil):void
---@alias BasicAttackOnWeaponTypeHitTargetCallback fun(IsFromSkill:boolean, attacker:EsvCharacter, target:EsvCharacter|EsvItem, damage:integer, data:HitData, bonuses:table):void
---@alias BasicAttackOnWeaponTypeSkillHitCallback fun(IsFromSkill:boolean, attacker:EsvCharacter, target:EsvCharacter|EsvItem, damage:integer, data:HitData, bonuses:table, skill:StatEntrySkillData):void

---@param event BasicAttackEventID
---@param func BasicAttackOnStartCallback|BasicAttackOnHitTargetCallback
function AttackManager.RegisterListener(event, func)
	if AttackManager.Listeners[event] == nil then
		AttackManager.Listeners[event] = {}
	end
	table.insert(AttackManager.Listeners[event], func)
end

---@param func BasicAttackOnHitTargetCallback|BasicAttackOnHitTargetCallback
function AttackManager.RegisterOnHit(func)
	AttackManager.RegisterListener("OnHit", func)
end

---@param tag string|string[]
---@param func BasicAttackOnWeaponTypeHitTargetCallback|BasicAttackOnWeaponTypeSkillHitCallback
function AttackManager.RegisterOnWeaponTypeHit(tag, func)
	if type(tag) == "table" then
		for i,v in pairs(tag) do
			AttackManager.RegisterOnWeaponTypeHit(v, func)
		end
	else
		if AttackManager.Listeners.OnWeaponTypeHit[tag] == nil then
			AttackManager.Listeners.OnWeaponTypeHit[tag] = {}
		end
		table.insert(AttackManager.Listeners.OnWeaponTypeHit[tag], func)
	end
end

---@param func BasicAttackOnStartCallback
function AttackManager.RegisterOnStart(func)
	AttackManager.RegisterListener("OnStart", func)
end

function AttackManager.RemoveListener(event, func)
	if AttackManager.Listeners[event] ~= nil then
		for i,callback in pairs(AttackManager.Listeners[event]) do
			if callback == func then
				AttackManager.Listeners[event][i] = nil
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
	for i,callback in pairs(AttackManager.Listeners.OnStart) do
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
	for i,callback in pairs(AttackManager.Listeners.OnStart) do
		local b,err = xpcall(callback, debug.traceback, attacker, {x,y,z})
		if not b then
			Ext.PrintError(err)
		end
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackPosition", 5, "after", OnBasicAttackPosition)

----@param isFromHit boolean
--- @param target EsvCharacter|EsvItem
--- @param source EsvCharacter|EsvItem
--- @param data HitData
function AttackManager.InvokeOnHit(isFromHit, target, source, damage, data, bonuses, isFromSkill)
	for i,callback in pairs(AttackManager.Listeners.OnHit) do
		local b,err = xpcall(callback, debug.traceback, isFromHit, source, target, damage, data, bonuses)
		if not b then
			Ext.PrintError(err)
		end
	end
	if source ~= nil and ObjectIsCharacter(source.MyGuid) == 1 then
		if isFromSkill == nil then
			isFromSkill = false
		end
		bonuses = bonuses or MasteryBonusManager.GetMasteryBonuses(source)
		for tag,callbacks in pairs(AttackManager.Listeners.OnWeaponTypeHit) do
			if #callbacks > 0 and GameHelpers.CharacterOrEquipmentHasTag(source, tag) then
				for i,callback in pairs(callbacks) do
					local status,err = xpcall(callback, debug.traceback, isFromSkill, source, target, data, bonuses, tag)
					if not status then
						Ext.PrintError("Error calling function for 'Listeners.OnHit':\n", err)
					end
				end
			end
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
		AttackManager.InvokeOnHit(false, caster, position, damageList)
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
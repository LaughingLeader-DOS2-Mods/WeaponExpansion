HitHandler = {
	---@type table<string,function>
	OnHitCallbacks = {}
}

local function CanGrantMasteryExperience(target,player)
	if IsTagged(target, "LLDUMMY_TrainingDummy") then
		return true,0.1
	else
		local isSummon = CharacterIsSummon(target) == 1
		local isEnemy = CharacterIsEnemy(target,player) == 1
		local ignoreCharacter = Osi.LeaderLib_Helper_QRY_IgnoreCharacter(target) == true
		local combatID = CombatGetIDForCharacter(player)
		if not isSummon and isEnemy and not ignoreCharacter then
			return true,0.5
		end
	end
	return false,0.0
end

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnPrepareHit(target,source,damage,handle)
	if source ~= nil and CharacterGetEquippedWeapon(source) == nil then
		ScaleUnarmedDamage(source,target,damage,handle)
	end
end
Ext.NewCall(OnPrepareHit, "LLWEAPONEX_Ext_OnPrepareHit", "(GUIDSTRING)_Target, (GUIDSTRING)_Instigator, (INTEGER)_Damage, (INTEGER64)_Handle")

local function WeaponIsTagged(char, weapon, tag)
	if tag == "LLWEAPONEX_Unarmed" and CharacterGetEquippedWeapon(char) == nil then
		return true
	end
	if (weapon ~= nil and IsTagged(weapon, weaponType) == 1) then
		return true
	end
	return false
end

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnHit(target,source,damage,handle)
	if source ~= nil then
		--LeaderLib.Debug_TraceOnHit(target,source,damage,handle)
		if LeaderLib.Game.HitWithWeapon(target, handle) then
			local b,expGain = CanGrantMasteryExperience(target,source)
			if b and expGain > 0 then
				AddMasteryExperienceForAllActive(source, expGain)
			end
			if #HitHandler.OnHitCallbacks > 0 then
				local mainhand = CharacterGetEquippedItem(source, "Weapon")
				local offhand = CharacterGetEquippedItem(source, "Shield")
				for tag,callback in pairs(HitHandler.OnHitCallbacks) do
					if WeaponIsTagged(source,mainhand,tag) or WeaponIsTagged(source,offhand,tag) then
						local status,err = xpcall(callback, debug.traceback, target, source, damage, handle)
						if not status then
							Ext.PrintError("Error calling function for 'HitHandler.OnHitCallbacks':\n", err)
						end
					end
				end
			end
		end
	end
end
Ext.NewCall(OnHit, "LLWEAPONEX_Ext_OnHit", "(GUIDSTRING)_Target, (GUIDSTRING)_Instigator, (INTEGER)_Damage, (INTEGER64)_StatusHandle")
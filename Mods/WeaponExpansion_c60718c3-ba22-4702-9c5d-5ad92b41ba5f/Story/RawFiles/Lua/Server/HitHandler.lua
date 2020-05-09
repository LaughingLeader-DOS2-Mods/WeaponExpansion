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
		ScaleUnarmedDamage(target,source,damage,handle)
	end
end
Ext.NewCall(OnPrepareHit, "LLWEAPONEX_Ext_OnPrepareHit", "(GUIDSTRING)_Target, (GUIDSTRING)_Instigator, (INTEGER)_Damage, (INTEGER64)_Handle")

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnHit(target,source,damage,handle)
	LeaderLib.Debug_TraceOnHit(target,source,damage,handle)
	if LeaderLib.Game.HitWithWeapon(target, handle, false) then
		local b,expGain = CanGrantMasteryExperience(target,source)
		if b and expGain > 0 then
			AddMasteryExperienceForAllActive(source, expGain)
		end
	end
end
Ext.NewCall(OnHit, "LLWEAPONEX_Ext_OnHit", "(GUIDSTRING)_Target, (GUIDSTRING)_Instigator, (INTEGER)_Damage, (INTEGER64)_StatusHandle")
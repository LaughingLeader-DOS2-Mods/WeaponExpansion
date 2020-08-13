local warChargeStatuses = {
	"LLWEAPONEX_WARCHARGE_DAMAGEBOOST",
	"LLWEAPONEX_WARCHARGE_BONUS",
	"LLWEAPONEX_WARCHARGE01",
	"LLWEAPONEX_WARCHARGE02",
	"LLWEAPONEX_WARCHARGE03",
	"LLWEAPONEX_WARCHARGE04",
	"LLWEAPONEX_WARCHARGE05",
	"LLWEAPONEX_WARCHARGE06",
	"LLWEAPONEX_WARCHARGE07",
	"LLWEAPONEX_WARCHARGE08",
	"LLWEAPONEX_WARCHARGE09",
	"LLWEAPONEX_WARCHARGE10",
}
local rushSkills = {"Rush_BatteringRam", "Rush_BullRush", "Rush_EnemyBatteringRam", "Rush_EnemyBullRush"}

---@param hitData HitData
MasteryBonusManager.RegisterSkillListener(rushSkills, {"WAR_CHARGE_RUSH"}, function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.CAST then
		local hasStatus = false
		for i,status in pairs(warChargeStatuses) do
			if HasActiveStatus(char, status) == 1 then
				hasStatus = true
				break
			end
		end
		if hasStatus then
			Osi.LeaderLib_Timers_StartObjectTimer(char, 1000, "Timers_LLWEAPONEX_ApplyHasted", "LLWEAPONEX_ApplyHasted")
		end
	elseif state == SKILL_STATE.HIT and hitData.Success then
		local hasStatus = false
		for i,status in pairs(warChargeStatuses) do
			if HasActiveStatus(char, status) == 1 then
				hasStatus = true
				break
			end
		end
		if hasStatus then
			local bonusPercent = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_WarChargeDamageBoost", 25.0)
			if bonusPercent > 0 then
				GameHelpers.IncreaseDamage(hitData.Target, char, hitData.Handle, bonusPercent/100, 0)
			end
		end
	end
end)

---@param target string
---@param status string
---@param source string
---@param bonuses table<string,table<string,boolean>>
MasteryBonusManager.RegisterStatusListener("HARMONY", "BANNER_RALLYINGCRY", function(target, status, source, bonuses)
	if (ObjectIsCharacter(target) == 1 
	and not GameHelpers.Status.IsDisabled(target, true)
	and NRD_ObjectHasStatusType(target, "DISARMED") == 0
	and bonuses.BANNER_RALLYINGCRY[source] == true) then
		local range = 1.0
		local weapon = CharacterGetEquippedWeapon(target)
		if weapon ~= nil then
			range = Ext.GetItem(weapon).Stats.WeaponRange / 100
		end

		local targets = {}

		for i,v in pairs(Ext.GetCharacter(target):GetNearbyCharacters(range)) do
			if CharacterIsEnemy(target, v) == 1 then
				table.insert(targets, v)
			end
		end

		if #targets > 0 then
			local attackTarget = Common.GetRandomTableEntry(targets)
			CharacterAttack(target, attackTarget)
		end
	end
end)

function Banner_OnGuardianAngelApplied(char,source)
	if not StringHelpers.IsNullOrEmpty(source) then
		if Mastery.HasMasteryRequirement(source, Mastery.BonusID.BANNER_GUARDIAN_ANGEL.Tags) then
			SetTag(char, "LLWEAPONEX_Banner_GuardianAngel_Active")
		end
	end
end

Ext.RegisterOsirisListener("CharacterPrecogDying", 1, "after", function(char)
	if HasActiveStatus(char, "GUARDIAN_ANGEL") == 1 and IsTagged(char, "LLWEAPONEX_Banner_GuardianAngel_Active") == 1 then
		local status = Ext.GetCharacter(char):GetStatus("GUARDIAN_ANGEL")
		if status ~= nil and status.StatusSourceHandle ~= nil then
			local sourceCharacter = Ext.GetCharacter(status.StatusSourceHandle)
			if sourceCharacter ~= nil then
				if Mastery.HasMasteryRequirement(sourceCharacter.MyGuid, Mastery.BonusID.BANNER_GUARDIAN_ANGEL.Tags) then
					if PersistentVars.MasteryMechanics.GuardianAngelResurrect == nil then
						PersistentVars.MasteryMechanics.GuardianAngelResurrect = {}
					end
					PersistentVars.MasteryMechanics.GuardianAngelResurrect[char] = sourceCharacter.MyGuid
				end
			end
		end
	end
end)

Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "after", function(char)
	if HasActiveStatus(char, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION") == 1 then
		RemoveStatus(char, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION")
	end
	if PersistentVars.MasteryMechanics.GuardianAngelResurrect ~= nil and #PersistentVars.MasteryMechanics.GuardianAngelResurrect > 0 then
		for deadChar,v in pairs(PersistentVars.MasteryMechanics.GuardianAngelResurrect) do
			if v == GetUUID(char) then
				if CharacterIsDead(deadChar) == 1 then
					CharacterResurrect(deadChar)
				else
					PersistentVars.MasteryMechanics.GuardianAngelResurrect[deadChar] = nil
				end
			end
		end
	end
end)

MasteryBonusManager.RegisterSkillListener({"Shout_Whirlwind", "Shout_EnemyWhirlwind"}, "BANNER_VACUUM", function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		local worldBannerEntry = Osi.DB_LLWEAPONEX_Skills_Temp_RallyBanner:Get(char, nil)
		if worldBannerEntry ~= nil and #worldBannerEntry > 0 then
			local worldBanner = worldBannerEntry[1][2]
			if worldBanner ~= nil and ObjectExists(worldBanner) == 1 then
				local dist = GetDistanceTo(char, worldBanner)
				local skillDist = Ext.StatGetAttribute(skill, "AreaRadius")
				local addWeaponRange = Ext.StatGetAttribute(skill, "AddWeaponRange") == "Yes"
				if addWeaponRange then
					local banners = GameHelpers.Item.FindTaggedEquipment(char, "LLWEAPONEX_Banner")
					if #banners > 0 then
						local banner = Ext.GetItem(banners[1])
						skillDist = skillDist + (banner.Stats.WeaponRange/100)
					end
				end
				if dist <= skillDist + 0.5 then
					--NRD_CreateGameObjectMove([in](GUIDSTRING)_TargetObject, [in](REAL)_X, [in](REAL)_Y, [in](REAL)_Z, [in](STRING)_BeamEffectName, [in](CHARACTERGUID)_CasterCharacter, [out](INTEGER64)_GameActionHandle)
					local dist2 = GetDistanceTo(worldBanner, hitData.Target)
					local x,y,z = GetPosition(worldBanner)
					local tx,ty,tz = GetPosition(hitData.Target)
					local dir = math.sqrt((tx - x)^2 + (tz - z)^2)
					x = x + dir * (dist2 * 0.2)
					z = z + dir * (dist2 * 0.2)
					local fx,fy,fz = FindValidPosition(x,y,z, 4.0, hitData.Target)
					local handle = NRD_CreateGameObjectMove(hitData.Target, fx, fy, fz, "", char)
				end
			end
		end
	end
end)

MasteryBonusManager.RegisterStatusAttemptListener("FLANKING", nil, function(target, status, handle, source)
	local statusSource = nil
	if HasActiveStatus(target, "LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS") == 1 then
		statusSource = Ext.GetStatus("LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS").StatusSourceHandle
	elseif HasActiveStatus(target, "LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS") == 1 then
		statusSource = Ext.GetStatus("LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS").StatusSourceHandle
	end
	if statusSource ~= nil then
		statusSource = Ext.GetCharacter(statusSource)
		if statusSource ~= nil then
			local bonuses = MasteryBonusManager.GetMasteryBonuses(statusSource.MyGuid)
			if bonuses.BANNER_PROTECTION == true then
				NRD_StatusPreventApply(target, handle, 1)
			end
		end
	end
end, true)

LeaderLib.RegisterListener("TurnDelayed", function(uuid)
	local statusSource = nil
	if HasActiveStatus(target, "LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS") == 1 then
		statusSource = Ext.GetStatus("LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS").StatusSourceHandle
	elseif HasActiveStatus(target, "LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS") == 1 then
		statusSource = Ext.GetStatus("LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS").StatusSourceHandle
	end
	if statusSource ~= nil then
		statusSource = Ext.GetCharacter(statusSource)
		if statusSource ~= nil then
			local bonuses = MasteryBonusManager.GetMasteryBonuses(statusSource.MyGuid)
			if bonuses.BANNER_PROTECTION == true then
				ApplyStatus(uuid, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION", 6.0, 0, uuid)
			end
		end
	end
end)
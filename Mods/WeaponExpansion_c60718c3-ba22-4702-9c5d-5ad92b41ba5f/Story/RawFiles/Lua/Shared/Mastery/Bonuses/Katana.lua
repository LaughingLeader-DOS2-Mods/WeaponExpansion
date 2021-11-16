local ComboStatuses = {
	"LLWEAPONEX_KATANA_COMBO1",
	"LLWEAPONEX_KATANA_COMBO2",
	"LLWEAPONEX_KATANA_COMBO3",
	"LLWEAPONEX_KATANA_COMBO4",
	"LLWEAPONEX_KATANA_COMBO5",
	"LLWEAPONEX_KATANA_COMBO6",
	"LLWEAPONEX_KATANA_COMBO7",
	"LLWEAPONEX_KATANA_COMBO8",
	"LLWEAPONEX_KATANA_COMBO9",
}

local Finishers = {
	Default = "LLWEAPONEX_KATANA_FINISHER_APPLY",
	Iaido = "LLWEAPONEX_KATANA_FINISHER_IAIDO_APPLY",
	Vanquisher = "LLWEAPONEX_KATANA_FINISHER_VANQUISHER_APPLY",
}

local function ClearBlademasterComboTag(uuid)
	if IsTagged(uuid, "LLWEAPONEX_Blademaster_Target_Available") == 1 then
		ClearTag(uuid, "LLWEAPONEX_Blademaster_Target_Available")
	end
end

local function SetBlademasterComboTag(uuid)
	if IsTagged(uuid, "LLWEAPONEX_Blademaster_Target_Available") == 0 then
		SetTag(uuid, "LLWEAPONEX_Blademaster_Target_Available")
	end
end

local function ClearBlademasterComboStatuses(uuid)
	if CharacterIsDead(uuid) == 1 then
		return false
	end
	for i,v in pairs(ComboStatuses) do
		if HasActiveStatus(uuid, v) == 1 then
			RemoveStatus(uuid, v)
			return true
		end
	end
	return false
end

---@return boolean,integer
local function HasComboStatus(uuid)
	if CharacterIsDead(uuid) == 1 then
		return false,0
	end
	for i,v in pairs(ComboStatuses) do
		if HasActiveStatus(uuid, v) == 1 then
			return true,i
		end
	end
	return false,0
end

local function CheckActiveCombo(target, isSource)
	if isSource == true then
		local data = PersistentVars.StatusData.KatanaCombo[target]
		if data ~= nil then
			if not Common.TableHasAnyEntry(data) then
				ClearBlademasterComboTag(target)
				PersistentVars.StatusData.KatanaCombo[target] = nil
			end
		else
			ClearBlademasterComboTag(target)
		end
	else
		for source,data in pairs(PersistentVars.StatusData.KatanaCombo) do
			if data[target] == true then
				data[target] = nil
			end
			if not Common.TableHasAnyEntry(data) then
				ClearBlademasterComboTag(source)
				PersistentVars.StatusData.KatanaCombo[source] = nil
			end
		end
	end
end

RegisterSkillListener("Shout_LLWEAPONEX_Katana_VanquishersPath", function(skill, char, state, data)
	if state == SKILL_STATE.CAST then
		local radius = Ext.StatGetAttribute("Shout_LLWEAPONEX_Katana_VanquishersPath", "AreaRadius")
		local caster = Ext.GetCharacter(char)
		PersistentVars.SkillData.VanquishersPath[char] = {}
		local targetData = PersistentVars.SkillData.VanquishersPath[char]
		for i,v in pairs(caster:GetNearbyCharacters(radius)) do
			--local character = Ext.GetCharacter(v)
			local b,count = HasComboStatus(v)
			if b then
				table.insert(targetData, {UUID=v,Count=count,Valid=true})
				ClearBlademasterComboStatuses(v)
			end
		end
		if #targetData > 0 then
			ObjectSetFlag(char, "LLWEAPONEX_Katanas_DisableCombo", 0)
			Timer.Start("LLWEAPONEX_Katana_VanquishersPath_HitNext", 250, char)
		else
			PersistentVars.SkillData.VanquishersPath[char] = nil
			CheckActiveCombo(char, true)
		end
	end
end)

local function GetRandomVanquisherTarget(casterData)
	local tbl = {}
	for i,v in pairs(casterData) do
		if v.Valid then
			table.insert(tbl, v)
		end
	end
	return Common.GetRandomTableEntry(tbl)
end

Timer.RegisterListener("LLWEAPONEX_Katana_VanquishersPath_HitNext", function(timerName, caster)
	if not StringHelpers.IsNullOrEmpty(caster) then
		local casterData = PersistentVars.SkillData.VanquishersPath[caster]
		if casterData ~= nil then
			local targetData = GetRandomVanquisherTarget(casterData)
			if targetData ~= nil then
				targetData.Valid = false
				GameHelpers.ClearActionQueue(caster)
				Osi.LeaderLib_Behavior_TeleportTo(caster, targetData.UUID)
				DeathManager.ListenForDeath("VanquishersPath", targetData.UUID, caster, 1500)
				CharacterUseSkill(caster, "Target_LLWEAPONEX_Katana_VanquishersPath_Hit", targetData.UUID, 1, 1, 1)
			else
				PersistentVars.SkillData.VanquishersPath[caster] = nil
			end
		end
	end
end)

local function GetVanquishersPathTargetData(caster, target)
	caster = GameHelpers.GetUUID(caster)
	target = GameHelpers.GetUUID(target)
	local casterData = PersistentVars.SkillData.VanquishersPath[caster]
	local targetData = nil
	local index = -1
	if casterData ~= nil then
		for i,v in pairs(casterData) do
			if v.UUID == target then
				targetData = v
				index = i
				break
			end
		end
	end
	return targetData,index
end

DeathManager.RegisterListener("VanquishersPath", function(target, attacker, success)
	local targetData,index = GetVanquishersPathTargetData(attacker, target)
	if targetData ~= nil then
		if success then
			local hasTarget = false
			if targetData.Count ~= nil and targetData.Count > 0 then
				local applyComboStatus = ComboStatuses[math.min(#ComboStatuses, targetData.Count)]
				local enemy = Ext.GetCharacter(target)
				if enemy ~= nil then
					for i,v in pairs(enemy:GetNearbyCharacters(6.0)) do
						if CharacterIsDead(v) == 0 and (CharacterIsEnemy(v, attacker) == 1 or IsTagged(v, "LeaderLib_FriendlyFireEnabled") == 1) then
							ApplyStatus(v, applyComboStatus, 6.0, 0, attacker)
							hasTarget = true
						end
					end
				end
			end
			if hasTarget then
				SetBlademasterComboTag(attacker)
			end
		end
		table.remove(PersistentVars.SkillData.VanquishersPath[attacker], index)
	end
end)

RegisterSkillListener("Target_LLWEAPONEX_Katana_VanquishersPath_Hit", function(skill, char, state, data)
	if state == SKILL_STATE.HIT then
		local targetData,index = GetVanquishersPathTargetData(char, data.Target)
		if targetData ~= nil then
			local comboCount = targetData.Count or 0
			if comboCount >= #ComboStatuses then
				NRD_HitClearAllDamage(data.Handle)
				GameHelpers.Damage.ApplySkillDamage(char, data.Target, "Target_LLWEAPONEX_Katana_VanquishersPath_Hit_Max", HitFlagPresets.GuaranteedWeaponHit:Append({CriticalHit=1}))
			end
		end
	elseif state == SKILL_STATE.CAST then
		local targetData = PersistentVars.SkillData.VanquishersPath[char]
		if targetData ~= nil and #targetData > 0 then
			Timer.Start("LLWEAPONEX_Katana_VanquishersPath_HitNext", 2000, char)
		else
			PersistentVars.SkillData.VanquishersPath[char] = nil
		end
	end
end)

local function ApplyDefaultFinisherDamage(i, target, source)
	GameHelpers.Damage.ApplySkillDamage(source, target, "Projectile_LLWEAPONEX_Status_Katana_Finisher_VanquisherDamage", HitFlagPresets.GuaranteedWeaponHit, nil, nil, true)
end

local function ApplyIaidoDamage(i, target, source)
	if i % 2 == 0 then
		GameHelpers.Damage.ApplySkillDamage(source, target, "Projectile_LLWEAPONEX_Status_Katana_Finisher_IaidoDamage", HitFlagPresets.GuaranteedWeaponHit, nil, nil, true)
	else
		ApplyStatus(target, "LLWEAPONEX_RUPTURE", 0.0, 1, source.MyGuid)
	end
end

local function ApplyVanquisherDamage(i, target, source)
	if i % 2 == 0 then
		GameHelpers.Damage.ApplySkillDamage(source, target, "Projectile_LLWEAPONEX_Status_Katana_Finisher_VanquisherDamage", HitFlagPresets.GuaranteedWeaponHit, nil, nil, true)
	else
		ApplyStatus(target, "LLWEAPONEX_RUPTURE", 0.0, 1, source.MyGuid)
	end
end

local function IncrementCombo(target, source, comboMod)
	comboMod = comboMod or 1
	local comboNum = comboMod
	for i,v in pairs(ComboStatuses) do
		if HasActiveStatus(target, v) == 1 then
			comboNum = math.min(#ComboStatuses, i + comboMod)
			break
		end
	end
	local nextStatus = ComboStatuses[comboNum]
	if nextStatus ~= nil then
		if HasActiveStatus(target, nextStatus) == 0 then
			ApplyStatus(target, nextStatus, 6.0, 0, source)
		end
		if ObjectIsCharacter(target) == 1 then
			local status = Ext.GetCharacter(target):GetStatus(nextStatus)
			if status ~= nil then
				status.CurrentLifeTime = 6.0
				status.KeepAlive = true
				status.RequestClientSync = true
			end
		end
	end
end

---@type table<string, fun(i:integer, target:string, source:EsvCharacter)>
local FinisherDamageData = {
	LLWEAPONEX_KATANA_FINISHER_APPLY = ApplyDefaultFinisherDamage,
	LLWEAPONEX_KATANA_FINISHER_IAIDO_APPLY = ApplyIaidoDamage,
	LLWEAPONEX_KATANA_FINISHER_VANQUISHER_APPLY = ApplyVanquisherDamage,
}

RegisterStatusListener(StatusEvent.Applied, {
	"LLWEAPONEX_KATANA_FINISHER_APPLY", 
	"LLWEAPONEX_KATANA_FINISHER_IAIDO_APPLY", 
	--"LLWEAPONEX_KATANA_FINISHER_VANQUISHER_APPLY"
}, 
function(target, status, source)
	if not StringHelpers.IsNullOrEmpty(source) then
		local sourceChar = Ext.GetCharacter(source)
		local hasCombo,total = HasComboStatus(target)
		if total > 0 then
			ObjectSetFlag(source, "LLWEAPONEX_Katanas_DisableCombo", 0)
			local damageCallback = FinisherDamageData[status]
			if damageCallback == nil then 
				damageCallback = FinisherDamageData.LLWEAPONEX_KATANA_FINISHER_APPLY 
			end
			local deadComboAmount = 0
			for i=total,0,-1 do
				if CharacterGetHitpointsPercentage(target) <= 0 then
					deadComboAmount = i
					break
				else
					ClearBlademasterComboStatuses(target)
				end
				local b,result = xpcall(damageCallback, debug.traceback, i, target, sourceChar)
				if not b then
					Ext.PrintError(result)
				end
			end
			local hasTarget = false
			ObjectClearFlag(source, "LLWEAPONEX_Katanas_DisableCombo", 0)
		end
	end
end)

-- Remove combat statuses when the attacker's turn ends, instead of the target.
RegisterStatusListener(StatusEvent.Applied, ComboStatuses, function(target, status, source)
	if PersistentVars.StatusData.KatanaCombo[source] == nil then
		PersistentVars.StatusData.KatanaCombo[source] = {}
	end
	PersistentVars.StatusData.KatanaCombo[source][target] = true
	if IsTagged(source, "LLWEAPONEX_Blademaster_Target_Available") == 0 then
		SetTag(source, "LLWEAPONEX_Blademaster_Target_Available")
	end
	if ObjectIsCharacter(target) == 1 then
		local statusObj = Ext.GetCharacter(target):GetStatus(status)
		if statusObj ~= nil then
			statusObj.KeepAlive = true
		end
	end
end)

RegisterStatusListener(StatusEvent.Removed, ComboStatuses, function(target, status, ...)
	if not HasComboStatus(target) then
		CheckActiveCombo(target)
	end
end)

RegisterMasteryListener("MasteryDeactivated", "LLWEAPONEX_Katana", function(uuid, mastery)
	ClearBlademasterComboTag(uuid)
	PersistentVars.SkillData.VanquishersPath[uuid] = nil
	PersistentVars.StatusData.KatanaCombo[uuid] = nil
end)

---@param data HitData
local function ApplyKatanaCombo(target, source, data, masteryBonuses, tag, skill)
	if ObjectIsCharacter(target) == 1 and CharacterIsEnemy(target, source) == 1 then
		if masteryBonuses.KATANA_COMBO == true and ObjectGetFlag(source, "LLWEAPONEX_Katana_ComboDisabled") == 0 then
			local maxStatus = ComboStatuses[#ComboStatuses]
			if HasActiveStatus(target, maxStatus) == 1 then
				local status = Ext.GetCharacter(target):GetStatus(maxStatus)
				if status ~= nil then
					status.CurrentLifeTime = status.LifeTime
					status.RequestClientSync = true
				end
			else
				if data:HasHitFlag("Backstab", true) or data:HasHitFlag("CriticalHit", true) then
					local comboIncrement = Ext.ExtraData["LLWEAPONEX_MB_Katana_ComboIncrementCritical"] or 2.0
					IncrementCombo(target, source, math.tointeger(comboIncrement))
				else
					local comboIncrement = Ext.ExtraData["LLWEAPONEX_MB_Katana_ComboIncrementDefault"] or 1.0
					IncrementCombo(target, source, math.tointeger(comboIncrement))
				end
			end
		end
	end
end

-- RegisterStatusListener(StatusEvent.Applied, "LLWEAPONEX_HELMSPLITTER", function(target, status, source)
-- 	if not Ext.IsModLoaded(MODID.DivinityUnleashed) and not Ext.IsModLoaded(MODID.ArmorMitigation) then
-- 		--GameHelpers.ExplodeProjectile(source, target, "Projectile_LLWEAPONEX_Status_HelmSplitter_PhysicalArmor")
-- 		--GameHelpers.ExplodeProjectile(source, target, "Projectile_LLWEAPONEX_Status_HelmSplitter_MagicArmor")
--     end
-- end)

MasteryBonusManager.RegisterSkillListener({"MultiStrike_Vault", "MultiStrike_EnemyVault"}, "KATANA_VAULT", function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.HIT then
		ApplyStatus(char, "LLWEAPONEX_MASTERYBONUS_KATANA_VAULTBONUS", 6.0, 0, char)
		StatusManager.SaveTurnEndStatus(char, "LLWEAPONEX_MASTERYBONUS_KATANA_VAULTBONUS", char)
	end
end)

AttackManager.RegisterOnWeaponTagHit("LLWEAPONEX_Katana", function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
	if bHitObject then
		ApplyKatanaCombo(target.MyGuid, source.MyGuid, data, bonuses, "LLWEAPONEX_Katana", data.SkillData)
		if data.Damage > 0 and HasActiveStatus(source.MyGuid, "LLWEAPONEX_MASTERYBONUS_KATANA_VAULTBONUS") == 1 then
			RemoveStatus(source.MyGuid, "LLWEAPONEX_MASTERYBONUS_KATANA_VAULTBONUS")
			local damageBonus = (Ext.ExtraData.LLWEAPONEX_MB_Katana_Backlash_DamageBonus or 50) * 0.01
			if damageBonus > 0 then
				GameHelpers.Damage.IncreaseDamage(target.MyGuid, source.MyGuid, data.Handle, damageBonus)
				CharacterStatusText(source.MyGuid, "LLWEAPONEX_StatusText_Katana_VaultBoost")
				if ObjectIsCharacter(target.MyGuid) == 1 then
					PlayEffect(target.MyGuid, "RS3_FX_Skills_Voodoo_Impact_Attack_Precision_01", "Dummy_BodyFX")
				else
					PlayEffect(source.MyGuid, "RS3_FX_Skills_Voodoo_Impact_Attack_Precision_01", "Dummy_FX_01")
				end
			end
		end
	end
end)
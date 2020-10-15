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

function OnKatanaHit(attacker, target)

end

RegisterSkillListener("Shout_LLWEAPONEX_Katana_VanquishersPath", function(skill, char, state, data)
	if state == SKILL_STATE.CAST then
		local radius = Ext.StatGetAttribute("Shout_LLWEAPONEX_Katana_VanquishersPath", "AreaRadius")
		local caster = Ext.GetCharacter(char)
		PersistentVars.SkillData.VanquishersPath[char] = {}
		local targetData = PersistentVars.SkillData.VanquishersPath[char]
		for i,v in pairs(caster:GetNearbyCharacters(radius)) do
			--local character = Ext.GetCharacter(v)
			if HasComboStatus(v) then
				table.insert(targetData, v)
			end
		end
		if #targetData > 0 then
			StartTimer("LLWEAPONEX_Katana_VanquishersPath_HitNext", 250, char)
		end
	end
end)

OnTimerFinished["LLWEAPONEX_Katana_VanquishersPath_HitNext"] = function(timerData)
	local caster = StringHelpers.GetUUID(timerData[1])
	if not StringHelpers.IsNullOrEmpty(caster) then
		local targetData = PersistentVars.SkillData.VanquishersPath[caster]
		if targetData ~= nil then
			local target = Common.PopRandomTableEntry(targetData)
			if target ~= nil then
				GameHelpers.ClearActionQueue(caster)
				Osi.LeaderLib_Behavior_TeleportTo(caster, target)
				CharacterUseSkill(caster, "Target_LLWEAPONEX_Katana_VanquishersPath_Hit", target, 1, 1, 1)
			end
		end
	end
end

RegisterSkillListener("Target_LLWEAPONEX_Katana_VanquishersPath_Hit", function(skill, char, state, data)
	if state == SKILL_STATE.HIT and CharacterIsDead(char) == 0 then
		local targetData = PersistentVars.SkillData.VanquishersPath[char]
		if targetData ~= nil and #data > 0 then
			StartTimer("LLWEAPONEX_Katana_VanquishersPath_HitNext", 1000, char)
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

---@type table<string, fun(i:integer, target:string, source:EsvCharacter)>
local FinisherDamageData = {
	LLWEAPONEX_KATANA_FINISHER_APPLY = ApplyDefaultFinisherDamage,
	LLWEAPONEX_KATANA_FINISHER_IAIDO_APPLY = ApplyIaidoDamage,
	LLWEAPONEX_KATANA_FINISHER_VANQUISHER_APPLY = ApplyVanquisherDamage,
}

RegisterStatusListener("StatusApplied", {
	"LLWEAPONEX_KATANA_FINISHER_APPLY", 
	"LLWEAPONEX_KATANA_FINISHER_IAIDO_APPLY", 
	"LLWEAPONEX_KATANA_FINISHER_VANQUISHER_APPLY"
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
				if CharacterIsDead(target) == 1 then
					deadComboAmount = i
					break
				end
				local b,result = xpcall(damageCallback, debug.traceback, i, sourceChar, target)
				if not b then
					Ext.PrintError(result)
				end
			end
			local hasTarget = false
			ObjectClearFlag(source, "LLWEAPONEX_Katanas_DisableCombo", 0)
			if deadComboAmount > 0 then
				local applyComboStatus = ComboStatuses[deadComboAmount]
				local enemy = Ext.GetCharacter(target)
				if enemy ~= nil then
					for i,v in pairs(enemy:GetNearbyCharacters(6.0)) do
						if CharacterIsDead(v) == 0 and (CharacterIsEnemy(v, source) == 1 or IsTagged(v, "LeaderLib_FriendlyFireEnabled") == 1) then
							ApplyStatus(v, applyComboStatus, 6.0, 0, source)
							hasTarget = true
						end
					end
				end
			end
			if not hasTarget then
				ClearTag(source, "LLWEAPONEX_Blademaster_Target_Available")
			end
		end
	end
end)

RegisterStatusListener("StatusApplied", ComboStatuses, function(target, status, source)
	StatusManager.SaveTurnEndStatus(target, status, source)
	SetTag(source, "LLWEAPONEX_Blademaster_Target_Available")
end)

RegisterMasteryListener("MasteryDeactivated", "LLWEAPONEX_Katana", function(uuid, mastery)
	StatusManager.RemoveTurnEndStatusesFromSource(uuid, ComboStatuses)
	ClearTag(source, "LLWEAPONEX_Blademaster_Target_Available")
end)

local function ApplyKatanaCombo(target, source, damage, handle, masteryBonuses, tag, skill)
	if masteryBonuses.KATANA_COMBO == true and ObjectIsCharacter(target) == 1 and ObjectGetFlag(source, "LLWEAPONEX_Katana_ComboDisabled") == 0 then
		ApplyStatus(target, "LLWEAPONEX_KATANA_COMBO_PROC", 0.0, 0, source)
	end
end

RegisterHitListener("OnHit", "LLWEAPONEX_Katana", ApplyKatanaCombo)
RegisterHitListener("OnWeaponSkillHit", "LLWEAPONEX_Katana", ApplyKatanaCombo)
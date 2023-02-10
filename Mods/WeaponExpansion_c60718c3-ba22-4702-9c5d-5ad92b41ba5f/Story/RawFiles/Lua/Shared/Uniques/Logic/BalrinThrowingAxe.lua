if not Vars.IsClient then
	---@param char CharacterParam
	---@param refreshSkill boolean|nil
	---@param skipDelete boolean|nil
	local function EquipBalrinAxe(char, refreshSkill, skipDelete)
		local uuid = GameHelpers.GetUUID(char)
		if uuid then
			local axeData = PersistentVars.SkillData.ThrowBalrinAxe[uuid]
			if axeData ~= nil then
				SetOnStage(axeData.Item, 1)
				NRD_CharacterEquipItem(uuid, axeData.Item, axeData.Slot, 0, 0, 1, 1)
				if refreshSkill == true then
					GameHelpers.Skill.SetCooldown(char, axeData.Skill, 0.0)
				end
				if skipDelete ~= true then
					PersistentVars.SkillData.ThrowBalrinAxe[uuid] = nil
				end
				GameHelpers.Status.Remove(char, "LLWEAPONEX_BALRINAXE_DISARMED_INFO")
			end
		end
	end

	Timer.Subscribe("LLWEAPONEX_CheckForAxeMiss", function (e)
		if e.Data.UUID then
			EquipBalrinAxe(e.Data.UUID)
			CharacterStatusText(e.Data.UUID, "LLWEAPONEX_StatusText_BalrinAxeTimedOut")
		end
	end)

	---@param skill string
	---@param char string
	---@param state SKILL_STATE
	---@param data SkillEventData|HitData
	SkillManager.Register.All({"Projectile_LLWEAPONEX_Throw_UniqueAxe_A", "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand"},
	function(e)
		if e.State == SKILL_STATE.USED then
			local slot,item = GameHelpers.Item.GetEquippedTaggedItemSlot(e.Character, "LLWEAPONEX_UniqueThrowingAxeA")
			if slot and item then
				PersistentVars.SkillData.ThrowBalrinAxe[e.Character] = {
					Item = item.MyGuid,
					Slot = slot,
					Skill = e.Skill,
					Target = "",
				}
			end
		elseif e.State == SKILL_STATE.CAST then
			local axeData = PersistentVars.SkillData.ThrowBalrinAxe[e.Character]
			CharacterUnequipItem(e.Character.MyGuid, axeData.Item)
			SetOnStage(axeData.Item, 0)
			Osi.ProcObjectTimer(e.Character, "LLWEAPONEX_Timers_Throwing_BalrinAxeThrowMissed", 1200)
			Timer.StartObjectTimer("LLWEAPONEX_CheckForAxeMiss", e.Character, 1200)
		elseif e.State == SKILL_STATE.HIT then
			GainThrowingMasteryXP(e.Character, e.Data.Target)
			if not e.Data.Success or GameHelpers.Ext.ObjectIsItem(e.Data.Target) then
				EquipBalrinAxe(e.Character)
				CharacterStatusText(e.Character, "LLWEAPONEX_StatusText_BalrinAxeTimedOut")
			else
				local axeData = PersistentVars.SkillData.ThrowBalrinAxe[e.Character]
				if axeData ~= nil then
					axeData.Target = e.Data.Target
					DeathManager.ListenForDeath("ThrowBalrinAxe", e.Data.Target, e.Character, 1000)
				end
			end
			Timer.Cancel("LLWEAPONEX_CheckForAxeMiss", e.Character)
		elseif e.State == SKILL_STATE.PROJECTILEHIT then
			Timer.Cancel("LLWEAPONEX_CheckForAxeMiss", e.Character)
			if StringHelpers.IsNullOrEmpty(e.Data.Target) then
				EquipBalrinAxe(e.Character)
				CharacterStatusText(e.Character, "LLWEAPONEX_StatusText_BalrinAxeTimedOut")
			end
		end
	end)

	DeathManager.OnDeath:Subscribe(function (e)
		if e.Success or GameHelpers.Status.IsActive(e.Target, "LLWEAPONEX_WEAPON_THROW_UNIQUE_AXE1H_A") then
			EquipBalrinAxe(e.Source, true)
		end
	end, {MatchArgs={ID="ThrowBalrinAxe"}})

	EquipmentManager.Events.EquipmentChanged:Subscribe(function(e)
		if e.Equipped then
			local slot = GameHelpers.Item.GetEquippedSlot(e.Character, e.Item)
			if slot == "Weapon" then
				GameHelpers.Skill.Swap(e.Character.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand", "Projectile_LLWEAPONEX_Throw_UniqueAxe_A", true, false)
			else
				GameHelpers.Skill.Swap(e.Character.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A", "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand", true, false)
			end
		else
			if CharacterHasSkill(e.Character.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A") then
				CharacterRemoveSkill(e.Character.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A")
			end
			if CharacterHasSkill(e.Character.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand") then
				CharacterRemoveSkill(e.Character.MyGuid, "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand")
			end
		end
	end, {MatchArgs={Tag = "LLWEAPONEX_UniqueThrowingAxeA"}})

	---@param char CharacterParam
	---@param timedOut boolean|nil
	local function RecoverBalrinAxe(char, timedOut)
		local uuid = GameHelpers.GetUUID(char)
		local data = PersistentVars.SkillData.ThrowBalrinAxe[uuid]
		if data ~= nil then
			EquipBalrinAxe(char, true)
			if timedOut == true then
				CharacterStatusText(uuid, "LLWEAPONEX_StatusText_BalrinAxeTimedOut")
			else
				CharacterStatusText(uuid, "LLWEAPONEX_StatusText_BalrinAxeRetrieved")
			end
			return true
		end
		return false
	end

	StatusManager.Register.Applied("LLWEAPONEX_BALRINAXE_RECOVER_START", function(balrinUser, status, target)
		if RecoverBalrinAxe(balrinUser) then
			GameHelpers.Status.Remove(target, "LLWEAPONEX_WEAPON_THROW_UNIQUE_AXE1H_A")
			GameHelpers.Status.Apply(target, "LLWEAPONEX_BALRINAXE_DEBUFF", 6.0, 1, balrinUser) -- No Aura
			local character = GameHelpers.GetCharacter(balrinUser)
			if ObjectIsCharacter(target) == 1 then
				local targetCharacter = GameHelpers.GetCharacter(target)
				local backStab = Game.Math.CanBackstab(character.Stats, targetCharacter.Stats)
				GameHelpers.Damage.ApplySkillDamage(character, target, "Projectile_LLWEAPONEX_Status_BalrinDebuff_Damage", {
					HitParams=HitFlagPresets.GuaranteedWeaponHit:Append({Backstab = backStab}),
					GetDamageFunction=Skills.Damage.Projectile_LLWEAPONEX_Status_BalrinDebuff_Damage})
			else
				GameHelpers.Damage.ApplySkillDamage(character, target, "Projectile_LLWEAPONEX_Status_BalrinDebuff_Damage", {
					HitParams=HitFlagPresets.GuaranteedWeaponHit,
					GetDamageFunction=Skills.Damage.Projectile_LLWEAPONEX_Status_BalrinDebuff_Damage})
			end
		end
	end)

	StatusManager.Register.Removed("LLWEAPONEX_WEAPON_THROW_UNIQUE_AXE1H_A", function(target, status, source)
		for char,data in pairs(PersistentVars.SkillData.ThrowBalrinAxe) do
			if data.Target == target.MyGuid then
				EquipBalrinAxe(char, true)
				CharacterStatusText(char, "LLWEAPONEX_StatusText_BalrinAxeTimedOut")
				break
			end
		end
	end)

	StatusManager.Register.Removed("LLWEAPONEX_BALRINAXE_DISARMED_INFO", function(target, status)
		RecoverBalrinAxe(target, true)
	end)

	Config.Skill.BalrinAxe = {
		Calls = {
			EquipBalrinAxe = EquipBalrinAxe,
			RecoverBalrinAxe = RecoverBalrinAxe,
		}
	}
end
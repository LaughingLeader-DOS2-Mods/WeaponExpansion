local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Katana, 1, {
	rb:Create("KATANA_VAULT", {
		Skills = {"MultiStrike_Vault", "MultiStrike_EnemyVault"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Katana_VaultBonus", "<font color='#F19966'>After teleporting, your next basic attack or weapon skill will deal +[ExtraData:LLWEAPONEX_MB_Katana_Backlash_DamageBonus]% additional damage.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			GameHelpers.Status.Apply(char, "LLWEAPONEX_MASTERYBONUS_KATANA_VAULTBONUS", 6.0, 0, char)
			StatusTurnHandler.SaveTurnEndStatus(char, "LLWEAPONEX_MASTERYBONUS_KATANA_VAULTBONUS", char)
		end
	end),	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Katana, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Katana, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Katana, 4, {
	
})

--Regular katana mastery skill logic
if not Vars.IsClient then
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

	---@param uuid UUID
	local function ClearBlademasterComboTag(uuid)
		if IsTagged(uuid, "LLWEAPONEX_Blademaster_Target_Available") == 1 then
			ClearTag(uuid, "LLWEAPONEX_Blademaster_Target_Available")
		end
	end

	---@param uuid UUID
	local function SetBlademasterComboTag(uuid)
		if IsTagged(uuid, "LLWEAPONEX_Blademaster_Target_Available") == 0 then
			SetTag(uuid, "LLWEAPONEX_Blademaster_Target_Available")
		end
	end

	---@param char EsvCharacter
	local function ClearBlademasterComboStatuses(char)
		if GameHelpers.Character.IsDeadOrDying(char) then
			return false
		end
		for i,v in pairs(ComboStatuses) do
			if GameHelpers.Status.IsActive(char, v) then
				GameHelpers.Status.Remove(char, v)
				return true
			end
		end
		return false
	end

	---@param char EsvCharacter
	---@return boolean,integer
	local function HasComboStatus(char)
		if GameHelpers.Character.IsDeadOrDying(char) then
			return false,0
		end
		for i,v in pairs(ComboStatuses) do
			if GameHelpers.Status.IsActive(char, v) then
				return true,i
			end
		end
		return false,0
	end

	---@param target EsvCharacter
	---@param isSource boolean|nil
	local function CheckActiveCombo(target, isSource)
		if isSource == true then
			local data = PersistentVars.StatusData.KatanaCombo[target.MyGuid]
			if data ~= nil then
				if not Common.TableHasAnyEntry(data) then
					ClearBlademasterComboTag(target.MyGuid)
					PersistentVars.StatusData.KatanaCombo[target.MyGuid] = nil
				end
			else
				ClearBlademasterComboTag(target.MyGuid)
			end
		else
			for source,data in pairs(PersistentVars.StatusData.KatanaCombo) do
				if data[target.MyGuid] == true then
					data[target.MyGuid] = nil
				end
				if not Common.TableHasAnyEntry(data) then
					ClearBlademasterComboTag(source.MyGuid)
					PersistentVars.StatusData.KatanaCombo[source] = nil
				end
			end
		end
	end

	SkillManager.Register.Cast("Shout_LLWEAPONEX_Katana_VanquishersPath", function(e)
		local radius = Ext.StatGetAttribute("Shout_LLWEAPONEX_Katana_VanquishersPath", "AreaRadius")
		PersistentVars.SkillData.VanquishersPath[e.Character.MyGuid] = {}
		local targetData = PersistentVars.SkillData.VanquishersPath[e.Character.MyGuid]
		for target in GameHelpers.Grid.GetNearbyObjects(e.Character, {Radius=radius, Relation={Enemy=true}}) do
			--local character = Ext.GetCharacter(v)
			local b,count = HasComboStatus(target.MyGuid)
			if b then
				table.insert(targetData, {UUID=target.MyGuid,Count=count,Valid=true})
				ClearBlademasterComboStatuses(target.MyGuid)
			end
		end
		if #targetData > 0 then
			ObjectSetFlag(e.Character.MyGuid, "LLWEAPONEX_Katanas_DisableCombo", 0)
			Timer.StartObjectTimer("LLWEAPONEX_Katana_VanquishersPath_HitNext", e.Character, 250)
		else
			PersistentVars.SkillData.VanquishersPath[e.Character.MyGuid] = nil
			CheckActiveCombo(e.Character, true)
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
						local enemyPos = enemy.WorldPos
						for target in GameHelpers.Grid.GetNearbyObjects(attacker, {Radius=6, Position=enemyPos, Relation={Enemy=true}}) do
							GameHelpers.Status.Apply(target, applyComboStatus, 6.0, false, attacker)
							hasTarget = true
						end
					end
				end
				if hasTarget then
					SetBlademasterComboTag(attacker)
				end
			end
			table.remove(PersistentVars.SkillData.VanquishersPath[attacker], index)
			if #PersistentVars.SkillData.VanquishersPath[attacker] == 0 then
				PersistentVars.SkillData.VanquishersPath[attacker] = nil
			end
		end
	end)

	SkillManager.Register.Hit("Target_LLWEAPONEX_Katana_VanquishersPath_Hit", function(e)
		local targetData,index = GetVanquishersPathTargetData(e.Character, e.Data.Target)
		if targetData ~= nil then
			local comboCount = targetData.Count or 0
			if comboCount >= #ComboStatuses then
				e.Data:ClearAllDamage()

				--Recalculate damage to max amount

				local damageList = Game.Math.GetSkillDamage(e.Data.SkillData, e.Character.Stats, false, false, e.Character.WorldPos, e.Data.TargetObject.WorldPos, e.Character.Stats.Level, true)

				e.Data.DamageList:Merge(damageList)

				local alwaysBackstab = false

				if e.Data.SkillData.SkillProperties then
					for _,v in pairs(e.Data.SkillData.SkillProperties) do
						if v.Action == "AlwaysBackstab" then
							alwaysBackstab = true
						end
					end
				end
			
				if GameHelpers.Ext.ObjectIsCharacter(e.Data.TargetObject) then
					HitOverrides._ComputeCharacterHitFunction(e.Data.TargetObject.Stats, e.Character.Stats, e.Character.Stats.MainWeapon, damageList, e.Data.HitContext.HitType, false, false, e.Data.HitRequest, alwaysBackstab, "EvenGround", "Critical")
				end

				e.Data:ApplyDamageList(true)
			end
		end
	end)

	SkillManager.Register.Cast("Target_LLWEAPONEX_Katana_VanquishersPath_Hit", function(e)
		local targetData = PersistentVars.SkillData.VanquishersPath[e.Character.MyGuid]
		if targetData ~= nil and #targetData > 0 then
			Timer.StartObjectTimer("LLWEAPONEX_Katana_VanquishersPath_HitNext", e.Character, 2000)
		else
			PersistentVars.SkillData.VanquishersPath[e.Character.MyGuid] = nil
		end
	end)

	---@param i integer
	---@param target EsvCharacter
	---@param source EsvCharacter
	local function ApplyDefaultFinisherDamage(i, target, source)
		GameHelpers.Damage.ApplySkillDamage(source, target, "Projectile_LLWEAPONEX_Status_Katana_Finisher_VanquisherDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit, ApplySkillProperties=true})
	end

	---@param i integer
	---@param target EsvCharacter
	---@param source EsvCharacter
	local function ApplyIaidoDamage(i, target, source)
		if i % 2 == 0 then
			GameHelpers.Damage.ApplySkillDamage(source, target, "Projectile_LLWEAPONEX_Status_Katana_Finisher_IaidoDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit, ApplySkillProperties=true})
		else
			GameHelpers.Status.Apply(target, "LLWEAPONEX_RUPTURE", 0.0, true, source)
		end
	end

	---@param i integer
	---@param target EsvCharacter
	---@param source EsvCharacter
	local function ApplyVanquisherDamage(i, target, source)
		if i % 2 == 0 then
			GameHelpers.Damage.ApplySkillDamage(source, target, "Projectile_LLWEAPONEX_Status_Katana_Finisher_VanquisherDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit, ApplySkillProperties=true})
		else
			GameHelpers.Status.Apply(target, "LLWEAPONEX_RUPTURE", 0, true, source)
		end
	end

	---@param target EsvCharacter|EsvItem
	---@param source EsvCharacter
	---@param comboMod integer|nil
	local function IncrementCombo(target, source, comboMod)
		comboMod = comboMod or 1
		local comboNum = comboMod
		for i,v in pairs(ComboStatuses) do
			if GameHelpers.Status.IsActive(target, v) then
				comboNum = math.min(#ComboStatuses, i + comboMod)
				break
			end
		end
		local nextStatus = ComboStatuses[comboNum]
		if nextStatus ~= nil then
			if not GameHelpers.Status.IsActive(target, nextStatus) then
				GameHelpers.Status.Apply(target, nextStatus, 6.0, false, source)
			end
			if GameHelpers.Ext.ObjectIsCharacter(target) then
				local status = target:GetStatus(nextStatus)
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

	StatusManager.Register.Applied({
		"LLWEAPONEX_KATANA_FINISHER_APPLY", 
		"LLWEAPONEX_KATANA_FINISHER_IAIDO_APPLY", 
		--"LLWEAPONEX_KATANA_FINISHER_VANQUISHER_APPLY"
	},
	function(target, status, source, statusType, statusEvent)
		if source then
			local hasCombo,total = HasComboStatus(target)
			if total > 0 then
				ObjectSetFlag(source.MyGuid, "LLWEAPONEX_Katanas_DisableCombo", 0)
				local damageCallback = FinisherDamageData[status.StatusId]
				if damageCallback == nil then 
					damageCallback = FinisherDamageData.LLWEAPONEX_KATANA_FINISHER_APPLY
				end
				local deadComboAmount = 0
				for i=total,0,-1 do
					if GameHelpers.Character.IsDeadOrDying(target) then
						deadComboAmount = i
						break
					else
						ClearBlademasterComboStatuses(target)
					end
					local b,result = xpcall(damageCallback, debug.traceback, i, target, source)
					if not b then
						Ext.PrintError(result)
					end
				end
				local hasTarget = false
				ObjectClearFlag(source.MyGuid, "LLWEAPONEX_Katanas_DisableCombo", 0)
			end
		end
	end)

	-- Remove combat statuses when the attacker's turn ends, instead of the target.
	RegisterStatusListener("Applied", ComboStatuses, function(target, status, source)
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

	StatusManager.Register.Removed(ComboStatuses, function(target, status, ...)
		if not HasComboStatus(target) then
			CheckActiveCombo(target)
		end
	end)

	RegisterMasteryListener("MasteryDeactivated", "LLWEAPONEX_Katana", function(uuid, mastery)
		ClearBlademasterComboTag(uuid)
		PersistentVars.SkillData.VanquishersPath[uuid] = nil
		PersistentVars.StatusData.KatanaCombo[uuid] = nil
	end)

	---@param target EsvCharacter|EsvItem
	---@param source EsvCharacter
	---@param data HitData
	---@param tag string
	---@param skill string
	local function ApplyKatanaCombo(target, source, data, tag, skill)
		if GameHelpers.Ext.ObjectIsCharacter(target) and GameHelpers.Character.CanAttackTarget(target, source, false) then
			if MasteryBonusManager.HasMasteryBonus(source, "KATANA_COMBO") and ObjectGetFlag(source.MyGuid, "LLWEAPONEX_Katana_ComboDisabled") == 0 then
				local maxStatus = ComboStatuses[#ComboStatuses]
				if GameHelpers.Status.IsActive(target, maxStatus) then
					local status = target:GetStatus(maxStatus)
					if status ~= nil then
						status.CurrentLifeTime = status.LifeTime
						status.RequestClientSync = true
					end
				else
					if data:HasHitFlag("Backstab", true) or data:HasHitFlag("CriticalHit", true) then
						local comboIncrement = GameHelpers.GetExtraData("LLWEAPONEX_MB_Katana_ComboIncrementCritical", 2.0)
						IncrementCombo(target, source, math.tointeger(comboIncrement))
					else
						local comboIncrement = GameHelpers.GetExtraData("LLWEAPONEX_MB_Katana_ComboIncrementDefault", 1.0)
						IncrementCombo(target, source, math.tointeger(comboIncrement))
					end
				end
			end
		end
	end

	-- RegisterStatusListener("Applied", "LLWEAPONEX_HELMSPLITTER", function(target, status, source)
	-- 	if not Ext.IsModLoaded(MODID.DivinityUnleashed) and not Ext.IsModLoaded(MODID.ArmorMitigation) then
	-- 		--GameHelpers.ExplodeProjectile(source, target, "Projectile_LLWEAPONEX_Status_HelmSplitter_PhysicalArmor")
	-- 		--GameHelpers.ExplodeProjectile(source, target, "Projectile_LLWEAPONEX_Status_HelmSplitter_MagicArmor")
	--     end
	-- end)

	AttackManager.OnWeaponTagHit.Register("LLWEAPONEX_Katana", function(tag, attacker, target, data, targetIsObject, skill)
		if targetIsObject then
			ApplyKatanaCombo(target, attacker, data, "LLWEAPONEX_Katana", data.SkillData)
			if data.Damage > 0 and GameHelpers.Status.IsActive(attacker, "LLWEAPONEX_MASTERYBONUS_KATANA_VAULTBONUS") then
				GameHelpers.Status.Remove(attacker.MyGuid, "LLWEAPONEX_MASTERYBONUS_KATANA_VAULTBONUS")
				local damageBonus = (GameHelpers.GetExtraData("LLWEAPONEX_MB_Katana_Backlash_DamageBonus", 50) * 0.01)
				if damageBonus > 0 then
					GameHelpers.Damage.IncreaseDamage(target.MyGuid, attacker.MyGuid, data.Handle, damageBonus)
					CharacterStatusText(attacker.MyGuid, "LLWEAPONEX_StatusText_Katana_VaultBoost")
					if ObjectIsCharacter(target.MyGuid) == 1 then
						PlayEffect(target.MyGuid, "RS3_FX_Skills_Voodoo_Impact_Attack_Precision_01", "Dummy_BodyFX")
					else
						PlayEffect(attacker.MyGuid, "RS3_FX_Skills_Voodoo_Impact_Attack_Precision_01", "Dummy_FX_01")
					end
				end
			end
		end
	end)
end
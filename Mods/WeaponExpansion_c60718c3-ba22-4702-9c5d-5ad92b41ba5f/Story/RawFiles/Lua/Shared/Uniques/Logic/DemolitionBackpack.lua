UniqueVars.DemolitionBackpack = {
	RemoteMineSkills = {
		"Projectile_LLWEAPONEX_RemoteMine_Explosive",
		"Projectile_LLWEAPONEX_RemoteMine_Explosive_NoWeapon",
		"Projectile_LLWEAPONEX_RemoteMine_Breach",
		"Projectile_LLWEAPONEX_RemoteMine_Shrapnel",
		"Projectile_LLWEAPONEX_RemoteMine_Shrapnel_NoWeapon",
		"Projectile_LLWEAPONEX_RemoteMine_Tar",
		"Projectile_LLWEAPONEX_RemoteMine_Tar_NoWeapon",
		"Projectile_LLWEAPONEX_RemoteMine_PoisonGas",
		"Projectile_LLWEAPONEX_RemoteMine_PoisonGas_NoWeapon",
		"Projectile_LLWEAPONEX_RemoteMine_Displacement",
	},
	NonDamagingGrenadeSkillToDamageSkill = {
		Projectile_Grenade_Flashbang = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_Flashbang",
		Projectile_Grenade_BlessedIce = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_BlessedIce",
		Projectile_Grenade_WaterBalloon = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_WaterBalloon",
		Projectile_Grenade_WaterBlessedBalloon = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_WaterBlessedBalloon",
		Projectile_Grenade_SmokeBomb = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_SmokeBomb",
		Projectile_Grenade_MustardGas = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_MustardGas",
		Projectile_Grenade_OilFlask = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_OilFlask",
		Projectile_Grenade_BlessedOilFlask = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_BlessedOilFlask",
		Projectile_Grenade_PoisonFlask = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_PoisonFlask",
		Projectile_Grenade_CursedPoisonFlask = "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_CursedPoisonFlask",
	}
}

if not Vars.IsClient then
	--#region Recharging

	---@param character EsvCharacter
	local function _StartRecharge(character)
		if Settings.Global:FlagEquals("LLWEAPONEX_DemolitionBackpackAutoRechargeEnabled", true) then
			local rechargeSpeed = Settings.Global:GetVariable("DemolitionBackpackRechargeSpeed", 24)
			for slot,item in pairs(GameHelpers.Item.FindTaggedEquipment(character, Uniques.DemoBackpack.Tag)) do
				---@cast item EsvItem
				local currentCharges = item.Stats.Charges
				local maxCharges = item.Stats.MaxCharges
				if maxCharges > -1 and currentCharges < maxCharges then
					local diff = maxCharges - currentCharges
					if diff > 0 then
						if rechargeSpeed <= 0 then
							ItemAddCharges(item.MyGuid, diff)
						else
							GameHelpers.Status.Apply(character, "LLWEAPONEX_REMOTEMINE_ADD_RECHARGE", diff * rechargeSpeed, true, character)
						end
					end
				end
			end
		end
	end

	---@param character EsvCharacter
	---@param startRecharge boolean
	local function _AddCharge(character, startRecharge)
		local rechargeSpeed = Settings.Global:GetVariable("DemolitionBackpackRechargeSpeed", 24)
		local rechargeDuration = 12.0
		for slot,item in pairs(GameHelpers.Item.FindTaggedEquipment(character, Uniques.DemoBackpack.Tag)) do
			---@cast item EsvItem
			local currentCharges = item.Stats.Charges
			local maxCharges = item.Stats.MaxCharges
			if maxCharges > -1 and currentCharges < maxCharges then
				ItemAddCharges(item.MyGuid, 1)
				if startRecharge then
					currentCharges = currentCharges + 1
					if currentCharges < maxCharges then
						if rechargeSpeed <= 0 then
							ItemAddCharges(item.MyGuid, maxCharges - currentCharges)
							startRecharge = false
						else
							rechargeDuration = (maxCharges - currentCharges) * rechargeSpeed
						end
					end
				end
			end
		end
		if startRecharge then
			if Settings.Global:FlagEquals("LLWEAPONEX_DemolitionBackpackAutoRechargeEnabled", true) then
				GameHelpers.Status.Apply(character, "LLWEAPONEX_REMOTEMINE_ADD_RECHARGE", rechargeDuration, true, character)
			end
		end
	end

	StatusManager.Subscribe.Removed("LLWEAPONEX_REMOTEMINE_ADD_RECHARGE", function (e)
		if GameHelpers.Ext.ObjectIsCharacter(e.Target) and ObjectGetFlag(e.TargetGUID, "LLWEAPONEX_DemolitionBackpack_SkipNextRecharge") == 0 then
			_AddCharge(e.Target, true)
		end
		ObjectClearFlag(e.TargetGUID, "LLWEAPONEX_DemolitionBackpack_SkipNextRecharge", 0)
	end)

	Settings.Global.Flags.LLWEAPONEX_DemolitionBackpackAutoRechargeEnabled:Subscribe(function (e)
		local enabled = e.Value
		for character in Uniques.DemoBackpack:GetAllCharacterOwners() do
			if enabled then
				_StartRecharge(e.Character)
			else
				ObjectSetFlag(character.MyGuid, "LLWEAPONEX_DemolitionBackpack_SkipNextRecharge", 0)
				GameHelpers.Status.Remove(character, "LLWEAPONEX_REMOTEMINE_ADD_RECHARGE")
			end
		end
	end)

	--#endregion

	UniqueVars.DemolitionBackpack.StartRecharge = _StartRecharge
	UniqueVars.DemolitionBackpack.AddCharge = _AddCharge

	SkillManager.Register.Used("Target_LLWEAPONEX_RemoteMine_Detonate", function (e)
		ObjectSetFlag(e.CharacterGUID, "LLWEAPONEX_RemoteMines_JustDetonated", 0)
		Timer.StartObjectTimer("LLWEAPONEX_RemoteMines_ResetJustDetonated", e.Character, 1500)
	end)

	Ext.Events.SessionLoaded:Subscribe(function (e)
		SkillManager.Register.Hit(UniqueVars.DemolitionBackpack.RemoteMineSkills, function (e)
			if ObjectGetFlag(e.CharacterGUID, "LLWEAPONEX_RemoteMines_JustDetonated") == 1 and GameHelpers.Ext.ObjectIsCharacter(e.Data.TargetObject) then
				local justHit = PersistentVars.SkillData.RemoteMineJustHit[e.CharacterGUID] or {}
				justHit[e.Data.Target] = true
				PersistentVars.SkillData.RemoteMineJustHit[e.CharacterGUID] = justHit
				Timer.RestartObjectTimer("LLWEAPONEX_RemoteMines_ResetJustDetonated", e.Character, 700)
			end
		end)
	end, {Priority=0})

	Ext.Osiris.RegisterListener("CharacterKilledBy", 3, "after", function (targetGUID, attackerOwnerGUID, attackerGUID)
		targetGUID = StringHelpers.GetUUID(targetGUID)
		attackerOwnerGUID = StringHelpers.GetUUID(attackerOwnerGUID)
		attackerGUID = StringHelpers.GetUUID(attackerGUID)
		local justHit = PersistentVars.SkillData.RemoteMineJustHit[attackerGUID]
		if justHit and justHit[targetGUID] then
			_AddCharge(GameHelpers.GetCharacter(attackerGUID), true)
			Timer.RestartObjectTimer("LLWEAPONEX_RemoteMines_ResetJustDetonated", attackerGUID, 500)
		end
		if attackerGUID ~= attackerOwnerGUID then
			local justHit = PersistentVars.SkillData.RemoteMineJustHit[attackerOwnerGUID]
			if justHit and justHit[targetGUID] then
				_AddCharge(GameHelpers.GetCharacter(attackerOwnerGUID), true)
				Timer.RestartObjectTimer("LLWEAPONEX_RemoteMines_ResetJustDetonated", attackerGUID, 500)
			end
		end
	end)

	Timer.Subscribe("LLWEAPONEX_RemoteMines_ResetJustDetonated", function (e)
		if e.Data.UUID then
			ObjectClearFlag(e.Data.UUID, "LLWEAPONEX_RemoteMines_JustDetonated", 0)
			PersistentVars.SkillData.RemoteMineJustHit[e.Data.UUID] = nil
		end
	end)

	--#region Grenade Bonus
	local hitListener,projectileHitListener = nil,nil

	local function _RegisterGrenadeListeners()
		hitListener = SkillManager.Register.Hit("All", function (e)
			if e.SourceItem and (e.SourceItem:HasTag("GRENADES") or GameHelpers.Stats.HasParent(e.SourceItem.StatsId, "_Grenades")) then
				local canAttack = GameHelpers.Character.CanAttackTarget(e.Data.TargetObject, e.Character, false)
				if e.Data.Damage > 0 then
					local min = GameHelpers.GetExtraData("LLWEAPONEX_DemolitionBackpack_GrenadeDamageBonus_Min", 10)
					local max = GameHelpers.GetExtraData("LLWEAPONEX_DemolitionBackpack_GrenadeDamageBonus_Max", 20)
					if max > 0 then
						local damageBoost = Ext.Utils.Round(Ext.Utils.Random(min*100, max*100)/10000)
						e.Data:MultiplyDamage(1+damageBoost)
					end
				else
					local damageSkill = UniqueVars.DemolitionBackpack.NonDamagingGrenadeSkillToDamageSkill[e.Skill]
					if damageSkill then
						GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.TargetObject, damageSkill)
					end
				end
				if e.Skill == "Projectile_Grenade_Holy" then
					--Either heal non-enemies, or harm undead enemies with regen
					local targetIsUndead = GameHelpers.Character.IsUndead(e.Data.TargetObject)
					if (canAttack and targetIsUndead) or (not canAttack and not targetIsUndead) then
						GameHelpers.Status.Apply(e.Data.TargetObject, "REGENERATION", 6.0, false, e.Character)
					end
				else
					if canAttack then
						if e.Skill == "Projectile_Grenade_Love" then
							GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_DEMOLITION_BONUS_CHARMED_DEBUFF", 12, false, e.Character)
						elseif e.Skill == "Projectile_Grenade_MindMaggot" then
							GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_DEMOLITION_BONUS_CHARMED_DEBUFF2", 24, false, e.Character)
						elseif e.Skill == "Projectile_Grenade_Terror" then
							GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_DEMOLITION_BONUS_TERROR_DEBUFF", 6, false, e.Character)
						end
					end
				end
			end
		end)
		
		--Chance to sabotage
		projectileHitListener = SkillManager.Register.ProjectileHit("All", function (e)
			if StringHelpers.IsNullOrEmpty(e.Data.Target) and e.SourceItem and (e.SourceItem:HasTag("GRENADES") or GameHelpers.Stats.HasParent(e.SourceItem.StatsId, "_Grenades")) then
				local sabotageChance = GameHelpers.GetExtraData("LLWEAPONEX_DemolitionBackpack_SabotageChance", 20)
				if sabotageChance > 0 and GameHelpers.Math.Roll(sabotageChance) then
					GameHelpers.Skill.Explode(e.Data.Position, "Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_Sabotage", e.Character)
				end
			end
		end)
	end

	SkillManager.Register.Hit("Projectile_LLWEAPONEX_DemolitionBackpack_Bonus_Sabotage", function (e)
		CharacterStatusText(e.Data.Target, "LLWEAPONEX_Status_Sabotage_Applied")
	end)
	--#endregion
	
	Uniques.DemoBackpack:RegisterEquippedListener(function (e)
		if e.Equipped then
			Timer.Cancel("LLWEAPONEX_DisableDemolitionBackpackListeners")
			if Settings.Global:FlagEquals("LLWEAPONEX_DemolitionBackpackAutoRechargeEnabled", true) then
				_StartRecharge(e.Character)
			end
			if hitListener == nil then
				_RegisterGrenadeListeners()
			end
		else
			GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_REMOTEMINE_ADD_RECHARGE")
			Timer.StartOneshot("LLWEAPONEX_DisableDemolitionBackpackListeners", 1000, function (e)
				if not Uniques.DemoBackpack:IsEquippedByAny() then
					if hitListener then
						Events.OnSkillState:Unsubscribe(hitListener)
						hitListener = nil
					end
					if projectileHitListener then
						Events.OnSkillState:Unsubscribe(projectileHitListener)
						projectileHitListener = nil
					end
				end
			end)
		end
	end)
end
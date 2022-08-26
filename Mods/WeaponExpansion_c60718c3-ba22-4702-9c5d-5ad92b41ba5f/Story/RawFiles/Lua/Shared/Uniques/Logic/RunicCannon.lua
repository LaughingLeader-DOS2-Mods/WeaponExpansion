if not Vars.IsClient then
	---@param specificItem EsvItem|nil
	local function _SyncData(specificItem)
		if specificItem then
			local amount = PersistentVars.SkillData.RunicCannonEnergy[specificItem.MyGuid]
			if amount then
				local owner = GameHelpers.Item.GetOwner(specificItem)
				if owner and GameHelpers.Character.IsPlayer(owner) then
					GameHelpers.Net.PostToUser(owner, "LLWEAPONEX_SyncArmCannonData", {NetID=specificItem.NetID, Amount=amount})
				end
			end
		else
			for itemGUID,amount in pairs(PersistentVars.SkillData.RunicCannonEnergy) do
				local owner = GameHelpers.Item.GetOwner(itemGUID)
				if owner and GameHelpers.Character.IsPlayer(owner) then
					GameHelpers.Net.PostToUser(owner, "LLWEAPONEX_SyncArmCannonData", {NetID=GameHelpers.GetNetID(itemGUID), Amount=amount})
				end
			end
		end
	end

	UniqueVars.SyncRunicCannon = _SyncData

	---@param character EsvCharacter
	---@param glove EsvItem
	---@param doEquip boolean
	local function _EquipArmCannonWeapon(character, glove, doEquip)
		local weapon = GetVarObject(glove.MyGuid, "LLWEAPONEX_ArmCannon_Weapon")
		if not StringHelpers.IsNullOrEmpty(weapon) and ObjectExists(weapon) == 1 then
			if doEquip then
				GameHelpers.Character.EquipItem(character, weapon)
			else
				ItemToInventory(weapon, glove.MyGuid, 1, 0, 1)
			end
		else
			--WPN_UNIQUE_LLWEAPONEX_ArmCannon_A_3b11f892-f6ae-43c8-af73-bcdf5abf64ec
			local weapon = GameHelpers.Item.CreateItemByTemplate("3b11f892-f6ae-43c8-af73-bcdf5abf64ec", {StatsLevel=glove.Stats.Level, IsIdentified=true, HasGeneratedStats=false, GMFolding=false})
			if weapon then
				SetVarObject(glove.MyGuid, "LLWEAPONEX_ArmCannon_Weapon", weapon.MyGuid)
				if doEquip then
					GameHelpers.Character.EquipItem(character, weapon)
				else
					ItemToInventory(weapon.MyGuid, glove.MyGuid, 1, 0, 1)
				end
			end
		end

		if doEquip then
			--Unequip non-shield weapons in the offhand.
			if GetSettings().Global:FlagEquals("LLWEAPONEX_ArmCannonRestrictionsDisabled", false) then
				local shield = GameHelpers.Item.GetItemInSlot(character, "Shield")
				if shield and shield.Stats.ItemType == "Weapon" then
					ItemLockUnEquip(shield.MyGuid, 0)
					ItemToInventory(shield.MyGuid, character.MyGuid, 1, 0, 0)
				end
			end
		end
	end

	---@param character EsvCharacter
	---@return EsvItem|nil
	local function _GetRunicCannon(character)
		local items = GameHelpers.Character.GetTaggedItems(character, "LLWEAPONEX_RunicCannon_Equipped", true)
		if items[1] then
			return items[1]
		end
		return nil
	end

	---@param character EsvCharacter
	---@param item EsvItem
	---@param amount integer|nil
	local function _SetEnergyTags(character, item, amount)
		local current = amount or PersistentVars.SkillData.RunicCannonEnergy[item.MyGuid] or 0
		if current > 0 then
			local maxUpper = GameHelpers.GetExtraData("LLWEAPONEX_RunicCannon_MaxEnergy", 3, true)
			if current >= maxUpper then
				Osi.LeaderLib_Tags_PreserveTag(character.MyGuid, "LLWEAPONEX_ArmCannon_FullyCharged")
				StatusManager.ApplyPermanentStatus(character, "LLWEAPONEX_ARMCANNON_CHARGED", character)
			else
				Osi.LeaderLib_Tags_PreserveTag(character.MyGuid, "LLWEAPONEX_ArmCannon_EnergyAvailable")
			end
			GameHelpers.UI.RefreshSkillBarAfterDelay(character, 500)
		else
			Osi.LeaderLib_Tags_ClearPreservedTag(character.MyGuid, "LLWEAPONEX_ArmCannon_FullyCharged")
			Osi.LeaderLib_Tags_ClearPreservedTag(character.MyGuid, "LLWEAPONEX_ArmCannon_EnergyAvailable")
			StatusManager.RemovePermanentStatus(character, "LLWEAPONEX_ARMCANNON_CHARGED")
			ObjectClearFlag(character.MyGuid, "LLWEAPONEX_ArmCannon_BlockEnergyGain", 0)
			GameHelpers.UI.RefreshSkillBarAfterDelay(character, 500)
		end
	end

	---@param character EsvCharacter
	---@param lastAmount integer
	---@param nextAmount integer
	---@param item EsvItem|nil
	local function _OnEnergyChanged(character, lastAmount, nextAmount, item)
		if nextAmount > 0 and lastAmount ~= nextAmount then
			EffectManager.PlayEffect("RS3_FX_Skills_Soul_Cast_Target_Hand_01_Texkey", character, {Bone="Dummy_R_HandFX"})
			PlaySound(character.MyGuid, "LLWEAPONEX_Whoosh_Slow_Deep_All_02")
			_SyncData(item)
		end
	end

	---@param character EsvCharacter
	---@param amount integer
	---@return EsvItem|nil
	local function _SetEnergy(character, amount)
		local item = _GetRunicCannon(character)
		if item then
			local current = PersistentVars.SkillData.RunicCannonEnergy[item.MyGuid] or 0
			PersistentVars.SkillData.RunicCannonEnergy[item.MyGuid] = amount
			_SetEnergyTags(character, item, amount)
			_OnEnergyChanged(character, current, amount, item)
		end
	end

	---@param character EsvCharacter
	---@param amount integer
	local function _AddEnergy(character, amount)
		local item = _GetRunicCannon(character)
		if item then
			local current = PersistentVars.SkillData.RunicCannonEnergy[item.MyGuid] or 0
			local maxUpper = GameHelpers.GetExtraData("LLWEAPONEX_RunicCannon_MaxEnergy", 3, true)
			local nextAmount = math.min(maxUpper, math.max(0, current + amount))
			PersistentVars.SkillData.RunicCannonEnergy[item.MyGuid] = nextAmount
			_SetEnergyTags(character, item, PersistentVars.SkillData.RunicCannonEnergy[item.MyGuid])
			_OnEnergyChanged(character, current, nextAmount, item)
		end
	end

	Timer.Subscribe("LLWEAPONEX_ArmCannon_ClearEnergyGainBlock", function (e)
		if e.Data.UUID then
			ObjectClearFlag(e.Data.UUID, "LLWEAPONEX_ArmCannon_BlockEnergyGain", 0)
		end
	end)

	---@param character EsvCharacter
	---@param delay integer
	local function _BlockEnergy(character, delay)
		ObjectSetFlag(character.MyGuid, "LLWEAPONEX_ArmCannon_BlockEnergyGain", 0)
		if delay then
			Timer.StartObjectTimer("LLWEAPONEX_ArmCannon_ClearEnergyGainBlock", character, 750)
		end
	end

	Uniques.ArmCannon:RegisterEquippedListener(function (e)
		--TODO Make energy 0 when unequipped? Or make it specific to the item?
		if e.Equipped then
			_SetEnergyTags(e.Character, e.Item)
			local showNotification = GameHelpers.Character.IsPlayer(e.Character) and 1 or 0
			CharacterAddSkill(e.CharacterGUID, "Projectile_LLWEAPONEX_ArmCannon_Shoot", showNotification)
			CharacterAddSkill(e.CharacterGUID, "Zone_LLWEAPONEX_ArmCannon_Disperse", showNotification)
			_EquipArmCannonWeapon(e.Character, e.Item, true)
		else
			_SetEnergyTags(e.Character, e.Item, 0)
			CharacterRemoveSkill(e.CharacterGUID, "Projectile_LLWEAPONEX_ArmCannon_Shoot")
			CharacterRemoveSkill(e.CharacterGUID, "Zone_LLWEAPONEX_ArmCannon_Disperse")
			_EquipArmCannonWeapon(e.Character, e.Item, false)
		end
	end)

	SkillManager.Register.Cast("Target_LLWEAPONEX_ArmCannon_AbsorbSurface", function (e)
		e.Data:ForEach(function (target, targetType, self)
			local x,y,z = table.unpack(GameHelpers.Math.GetPosition(target))
			SetVarFloat3(e.CharacterGUID, "LLWEAPONEX_SurfaceAbsorbPosition", x, y, z)
		end, e.Data.TargetMode.All)
	end)

	SkillManager.Register.Cast("Projectile_LLWEAPONEX_ArmCannon_Shoot", function (e)
		_AddEnergy(e.Character, -1)
	end)

	SkillManager.Register.Cast("Zone_LLWEAPONEX_ArmCannon_Disperse", function (e)
		_BlockEnergy(e.Character, 750)
		_SetEnergy(e.Character, 0)

		local distMult = e.Data.SkillData.Range + 0.5
		local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Character, distMult)
		Timer.StartObjectTimer("LLWEAPONEX_ArmCannon_Disperse", e.Character, 500, {Target=pos})
	end)

	Timer.Subscribe("LLWEAPONEX_ArmCannon_Disperse", function (e)
		if e.Data.UUID and e.Data.Target then
			GameHelpers.Skill.Explode(e.Data.Target, "Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion", e.Data.Object)
			EffectManager.PlayEffectAt("RS3_FX_Skills_Soul_Impact_Soul_Touch_Hand_01", e.Data.Target)
		end
	end)

	Events.OnWeaponTagHit:Subscribe(function (e)
		if e.TargetIsObject and (not e.SkillData or (e.SkillData and not string.find(e.Skill, "LLWEAPONEX_ArmCannon"))) then
			if ObjectGetFlag(e.AttackerGUID, "LLWEAPONEX_ArmCannon_BlockEnergyGain") == 0 
			and (e.Target:HasTag("LLDUMMY_TrainingDummy") or GameHelpers.Character.CanAttackTarget(e.Target, e.Attacker, false)) then
				_BlockEnergy(e.Attacker, 750)
				_AddEnergy(e.Attacker, 1)
			end
		end
	end, {MatchArgs={Tag="LLWEAPONEX_RunicCannonWeapon_Equipped"}})
else
	Ext.RegisterNetListener("LLWEAPONEX_SyncArmCannonData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			ClientVars.RunicCannonEnergy[data.NetID] = data.Amount
		end
	end)
end
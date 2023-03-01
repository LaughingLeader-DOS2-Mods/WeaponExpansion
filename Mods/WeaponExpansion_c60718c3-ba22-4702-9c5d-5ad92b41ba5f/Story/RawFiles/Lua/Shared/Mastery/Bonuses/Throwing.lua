local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 1, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 4, {
	
})

if not Vars.IsClient then
	SkillManager.Register.Hit({"Projectile_LLWEAPONEX_Throw_UniqueAxe_A", "Projectile_LLWEAPONEX_Throw_UniqueAxe_A_Offhand"}, function(e)
		if e.Data.Success then
			GainThrowingMasteryXP(e.Character, e.Data.TargetObject)
		end
	end)

	Events.ObjectEvent:Subscribe(function (e)
		if GameHelpers.Ext.ObjectIsItem(e.Objects[1]) then
			local item = e.Objects[1] --[[@as EsvItem]]
			local owner = GameHelpers.Item.GetOwner(item)
			if owner and PersistentVars.SkillData.ThrowWeapon[owner.MyGuid] then
				local characterGUID = owner.MyGuid
				local movingObjectGUID = e.ObjectGUID1
				Timer.StartOneshot("LLWEAPONEX_MovingObjectWeapon_Setup", 125, function ()
					local transformed = false

					local weapon = nil

					local data = PersistentVars.SkillData.ThrowWeapon[characterGUID]
					if data.Weapon then
						weapon = GameHelpers.GetItem(data.Weapon, "EsvItem")
					elseif data.Shield then
						weapon = GameHelpers.GetItem(data.Shield, "EsvItem")
					end

					if weapon then
						Transform(movingObjectGUID, GameHelpers.GetTemplate(weapon), 0, 1, 0)
						transformed = true

						if not weapon:HasTag("DISABLE_WEAPON_EFFECTS") then
							SetTag(weapon.MyGuid, "DISABLE_WEAPON_EFFECTS")
							ObjectSetFlag(weapon.MyGuid, "LLWEAPONEX_MovingObject_ResetDisableWeaponFXTag", 0)
						end
					end

					if transformed then
						GameHelpers.Status.Apply(characterGUID, "LEADERLIB_HIDE_WEAPON", 30.0, true, characterGUID)
						ItemSetCanPickUp(movingObjectGUID, 0)
						ItemSetOwner(movingObjectGUID, characterGUID)
					end
				end)
			end
		end
	end, {MatchArgs={Event="LLWEAPONEX_MovingObjectWeapon_Init"}})

	Events.ObjectEvent:Subscribe(function (e)
		local character,movingObject = table.unpack(e.Objects)
		if character and movingObject then
			GameHelpers.Status.Remove(character, "LEADERLIB_HIDE_WEAPON")
			
			local weaponData = PersistentVars.SkillData.ThrowWeapon[character.MyGuid]
			if weaponData then
				---@cast character EsvCharacter
				---@cast movingObject EsvItem


				-- local pos = movingObject.WorldPos
				-- local rot = movingObject.Rotation

				if weaponData.Weapon then
					local weapon = GameHelpers.GetItem(weaponData.Weapon)
					if weapon then
						CharacterUnequipItem(character.MyGuid, weapon.MyGuid)
						-- GameHelpers.Utils.SetPosition(weapon, pos)
						-- GameHelpers.Utils.SetRotation(weapon, rot)

						Osi.LeaderLib_Helper_CopyItemTransform(weapon.MyGuid, movingObject.MyGuid)

						if ObjectGetFlag(weapon.MyGuid, "LLWEAPONEX_MovingObject_ResetDisableWeaponFXTag") == 1 then
							ClearTag(weapon.MyGuid, "DISABLE_WEAPON_EFFECTS")
						end
					end
				end

				if weaponData.Shield then
					local weapon = GameHelpers.GetItem(weaponData.Shield)
					if weapon then
						CharacterUnequipItem(character.MyGuid, weapon.MyGuid)
						Osi.LeaderLib_Helper_CopyItemTransform(weapon.MyGuid, movingObject.MyGuid)

						if ObjectGetFlag(weapon.MyGuid, "LLWEAPONEX_MovingObject_ResetDisableWeaponFXTag") == 1 then
							ClearTag(weapon.MyGuid, "DISABLE_WEAPON_EFFECTS")
						end
					end
				end

				PersistentVars.SkillData.ThrowWeapon[character.MyGuid] = nil
			end

			SetOnStage(movingObject.MyGuid, 0)
			ItemDestroy(movingObject.MyGuid)
		end
	end, {MatchArgs={Event="LLWEAPONEX_MovingObjectWeapon_Landed"}})

	local ThrowWeaponSkills = {"Projectile_LLWEAPONEX_ThrowWeapon", "Projectile_LLWEAPONEX_ThrowWeapon_Enemy"}

	SkillManager.Register.Used(ThrowWeaponSkills, function (e)
		local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(e.Character)
		if mainhand or offhand then
			PersistentVars.SkillData.ThrowWeapon[e.CharacterGUID] = {
				Weapon = GameHelpers.GetUUID(mainhand),
				Shield = GameHelpers.GetUUID(offhand)
			}
		end
	end)

	SkillManager.Register.ProjectileHit(ThrowWeaponSkills, function (e)
		local target = e.Data.Target
		if not StringHelpers.IsNullOrEmpty(target) then
			if ObjectIsCharacter(target) == 1 then
				DeathManager.ListenForDeath("ThrowWeapon", target, e.Character, 500)
			end

			local mainhand = nil
			local offhand = nil

			local weaponData = PersistentVars.SkillData.ThrowWeapon[e.CharacterGUID]
			if weaponData ~= nil then
				if not StringHelpers.IsNullOrEmpty(weaponData.Weapon) then
					local mainhandObject = GameHelpers.GetItem(weaponData.Weapon)
					if mainhandObject then
						mainhand = mainhandObject.Stats
					end
				end
				if not StringHelpers.IsNullOrEmpty(weaponData.Shield) then
					local offhandObject = GameHelpers.GetItem(weaponData.Shield)
					if offhandObject and offhandObject.Stats.ItemType == "Weapon" then
						offhand = offhandObject.Stats
					end
				end
			end

			GameHelpers.Damage.ApplySkillDamage(e.Character, target, "Projectile_LLWEAPONEX_ThrowWeapon_ApplyDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit, ApplySkillProperties=true, MainWeapon=mainhand, OffhandWeapon=offhand})
		else
			PersistentVars.SkillData.ThrowWeapon[e.CharacterGUID] = nil
		end
	end)

	DeathManager.OnDeath:Subscribe(function (e)
		local data = PersistentVars.SkillData.ThrowWeapon[e.SourceGUID]
		if data ~= nil then
			if e.Success then
				if not StringHelpers.IsNullOrEmpty(data.Weapon) then
					NRD_CharacterEquipItem(e.SourceGUID, data.Weapon, "Weapon", 0, 0, 1, 1)
				end
				if not StringHelpers.IsNullOrEmpty(data.Shield) then
					NRD_CharacterEquipItem(e.SourceGUID, data.Shield, "Shield", 0, 0, 1, 1)
				end
			end
			PersistentVars.SkillData.ThrowWeapon[e.SourceGUID] = nil
		end
	end, {MatchArgs={ID="ThrowWeapon"}})

	--Throwing Experience
	SkillManager.Register.Cast("All", function (e)
		if e.SourceItem and GameHelpers.ItemHasTag(e.SourceItem, Mastery.Variables.ThrowingMasteryItemTags)
		and MasterySystem.CanGainExperience(e.Character) then
			local primaryTarget = nil
			e.Data:ForEach(function (target, targetType, self)
				---@cast target Guid
				---Prioritize setting a boss as the primary target, since they grant more mastery XP
				if ObjectIsCharacter(target) == 1 and (not primaryTarget or IsBoss(target) == 1) then
					primaryTarget = target
				end
			end, e.Data.TargetMode.Objects)
			if primaryTarget then
				MasterySystem.GrantWeaponSkillExperience(e.Character, primaryTarget, MasteryID.Throwing)
			else
				--Gain xp just from throwing grenades/etc
				AddMasteryExperience(e.Character, MasteryID.Throwing, 0.25)
			end
		end
	end)
end
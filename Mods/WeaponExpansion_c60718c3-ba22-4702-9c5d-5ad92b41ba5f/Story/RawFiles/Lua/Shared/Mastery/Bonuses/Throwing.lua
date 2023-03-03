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
				local transformed = false

				local weapon = nil

				local data = PersistentVars.SkillData.ThrowWeapon[characterGUID]
				if data then
					if data.Weapon then
						weapon = GameHelpers.GetItem(data.Weapon, "EsvItem")
					elseif data.Shield then
						weapon = GameHelpers.GetItem(data.Shield, "EsvItem")
					end
				end

				if weapon then
					Transform(movingObjectGUID, GameHelpers.GetTemplate(weapon), 0, 1, 0)
					transformed = true

					if not weapon:HasTag("DISABLE_WEAPON_EFFECTS") then
						SetTag(weapon.MyGuid, "DISABLE_WEAPON_EFFECTS")
						ObjectSetFlag(weapon.MyGuid, "LLWEAPONEX_MovingObject_ResetDisableWeaponFXTag", 0)
					end

					--Mods.LeaderLib.VisualManager.Client.AttachVisual("497bcc72-d4c5-4219-8308-c0ad04d86664", "48491cef-a2de-4dec-9d65-9c6aea8a769e", nil, {Rotate={0,Ext.Utils.Random(20,270),0}})

					if data.Shield and data.Shield ~= weapon.MyGuid then
						local shield = GameHelpers.GetItem(data.Shield, "EsvItem")
						if shield then
							local ranRot = {0,Ext.Utils.Random(20,270),0}
							local visual = shield.CurrentTemplate.VisualTemplate
							Timer.StartOneshot("", 50, function (e)
								if GameHelpers.ObjectExists(movingObjectGUID) then
									VisualManager.RequestAttachVisual(movingObjectGUID, {Resource=visual, ExtraSettings={Rotate=ranRot}})
								end
							end)
						end
					end
				end

				if transformed then
					GameHelpers.Status.Apply(characterGUID, "LEADERLIB_HIDE_WEAPON", 30.0, true, characterGUID)
					ItemSetCanPickUp(movingObjectGUID, 0)
					ItemSetOwner(movingObjectGUID, characterGUID)
				end
			end
		end
	end, {MatchArgs={Event="LLWEAPONEX_MovingObjectWeapon_Init"}})

	Events.ObjectEvent:Subscribe(function (e)
		local character,movingObject = table.unpack(e.Objects)
		if character and movingObject then

			local weaponData = PersistentVars.SkillData.ThrowWeapon[character.MyGuid]
			if weaponData then
				---@cast character EsvCharacter
				---@cast movingObject EsvItem

				-- local pos = movingObject.WorldPos
				-- local rot = movingObject.Rotation

				if weaponData.Weapon then
					local weapon = GameHelpers.GetItem(weaponData.Weapon)
					if weapon and GameHelpers.Item.ItemIsEquipped(character, weapon) and not weapon.UnEquipLocked then
						CharacterUnequipItem(character.MyGuid, weapon.MyGuid)
						-- GameHelpers.Utils.SetPosition(weapon, pos)
						-- GameHelpers.Utils.SetRotation(weapon, rot)

						Osi.LeaderLib_Helper_CopyItemTransform(weapon.MyGuid, movingObject.MyGuid)

						if ObjectGetFlag(weapon.MyGuid, "LLWEAPONEX_MovingObject_ResetDisableWeaponFXTag") == 1 then
							ClearTag(weapon.MyGuid, "DISABLE_WEAPON_EFFECTS")
						end

						ItemScatterAt(weapon.MyGuid, table.unpack(weapon.WorldPos))
					end
				end

				if weaponData.Shield then
					local weapon = GameHelpers.GetItem(weaponData.Shield)
					if weapon and GameHelpers.Item.ItemIsEquipped(character, weapon) and not weapon.UnEquipLocked then
						CharacterUnequipItem(character.MyGuid, weapon.MyGuid)
						Osi.LeaderLib_Helper_CopyItemTransform(weapon.MyGuid, movingObject.MyGuid)

						if ObjectGetFlag(weapon.MyGuid, "LLWEAPONEX_MovingObject_ResetDisableWeaponFXTag") == 1 then
							ClearTag(weapon.MyGuid, "DISABLE_WEAPON_EFFECTS")
						end

						ItemScatterAt(weapon.MyGuid, table.unpack(weapon.WorldPos))
					end
				end

				SignalTestComplete("LLWEAPONEX_ThrowWeapon_MovingObjectLanded")

				if not DeathManager.IsAttackerListening("ThrowWeapon", character) then
					PersistentVars.SkillData.ThrowWeapon[character.MyGuid] = nil
				end
			end

			GameHelpers.Status.Remove(character, "LEADERLIB_HIDE_WEAPON")
			SetOnStage(movingObject.MyGuid, 0)
			ItemDestroy(movingObject.MyGuid)
		end
	end, {MatchArgs={Event="LLWEAPONEX_MovingObjectWeapon_Landed"}})

	SkillManager.Register.Used(Config.Skill.ThrowWeaponSkills, function (e)
		local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(e.Character)
		if mainhand or offhand then
			PersistentVars.SkillData.ThrowWeapon[e.CharacterGUID] = {
				Weapon = GameHelpers.GetUUID(mainhand),
				Shield = GameHelpers.GetUUID(offhand)
			}
			SignalTestComplete("LLWEAPONEX_ThrowWeapon_UsedSkill")
		end
	end)

	SkillManager.Register.ProjectileHit(Config.Skill.ThrowWeaponSkills, function (e)
		local target = e.Data.Target
		if not StringHelpers.IsNullOrEmpty(target) then
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

			DeathManager.ListenForDeath("ThrowWeapon", target, e.Character, 500)
			GameHelpers.Damage.ApplySkillDamage(e.Character, target, "Projectile_LLWEAPONEX_ThrowWeapon_ApplyDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit, ApplySkillProperties=true, MainWeapon=mainhand, OffhandWeapon=offhand})
			if offhand and offhand.ItemType == "Shield" then
				GameHelpers.Damage.ApplySkillDamage(e.Character, target, "Projectile_LLWEAPONEX_ThrowWeapon_ApplyShieldDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit, ApplySkillProperties=false, MainWeapon=mainhand, OffhandWeapon=offhand})
			end
			SignalTestComplete("LLWEAPONEX_ThrowWeapon_DamageApplied")
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
				SignalTestComplete("LLWEAPONEX_ThrowWeapon_TargetDied")
				EffectManager.PlayEffect("RS3_FX_GP_Status_Deflecting_01", e.Source)
				if e.Target then
					local pos = e.Target.WorldPos
					pos[2] = pos[2] + (e.Target.AI.AIBoundsHeight - 0.2)
					EffectManager.PlayEffectAt("RS3_FX_Skills_Rogue_Impact_01", pos)
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

	if Vars.DebugMode then
		--!test weaponexmisc throwing_throwweapon
		WeaponExTesting.RegisterMiscTest("throwing_throwweapon", function (test)
			local char,dummy,cleanup = Testing.Utils.CreateTestCharacters({CharacterFaction="PVP_1", DummyFaction="PVP_2", EquipmentSet="Class_Fighter_Lizards", TotalCharacters=1, TotalDummies=1})
			---@cast char Guid
			---@cast dummy Guid

			test:Wait(250)
			local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(char)
			if mainhand then
				mainhand = mainhand.MyGuid
			end
			if offhand then
				offhand = offhand.MyGuid
			end
			test.Cleanup = function ()
				PersistentVars.SkillData.ThrowWeapon[char] = nil
				DeathManager.RemoveAllDataForTarget(dummy)
				DeathManager.RemoveAllDataForTarget(char)
				if mainhand then
					ItemRemove(mainhand)
				end
				if offhand then
					ItemRemove(offhand)
				end
				cleanup()
			end

			GameHelpers.Action.UseSkill(char, "Projectile_LLWEAPONEX_ThrowWeapon_Enemy", dummy)
			test:WaitForSignal("LLWEAPONEX_ThrowWeapon_UsedSkill", 5000)
			test:WaitForSignal("LLWEAPONEX_ThrowWeapon_DamageApplied", 2000)
			--Target dummies "die" in the DeathManager in debug mode
			test:WaitForSignal("LLWEAPONEX_ThrowWeapon_TargetDied", 2000)
			
			test:Wait(1000)
			test:AssertEquals(not StringHelpers.IsNullOrEmpty(CharacterGetEquippedWeapon(char)), true, "Failed to re-equip weapons after target dummy 'death'")

			--Test throwing weapons on the ground
			local dir = GameHelpers.Math.GetDirectionalVector(char, dummy)
			local distance = GameHelpers.Math.GetDistance(char, dummy) / 2
			local targetPos = GameHelpers.Math.ExtendPositionWithDirectionalVector(char, dir, distance)
			targetPos[2] = targetPos[2] + 1
			GameHelpers.Action.UseSkill(char, "Projectile_LLWEAPONEX_ThrowWeapon_Enemy", targetPos)
			test:WaitForSignal("LLWEAPONEX_ThrowWeapon_UsedSkill", 5000)
			test:WaitForSignal("LLWEAPONEX_ThrowWeapon_DamageApplied", 2000)
			test:WaitForSignal("LLWEAPONEX_ThrowWeapon_MovingObjectLanded", 2000)

			test:AssertEquals(PersistentVars.SkillData.ThrowWeapon[char] == nil, true, "PersistentVars.SkillData.ThrowWeapon data for test character not cleaned up after the thrown weapon has landed.")
			if mainhand then
				local x,y,z = GameHelpers.Math.GetPosition(mainhand, true)
				test:AssertEquals(x ~= 0 and y ~= 0 and z ~= 0, true, "Thrown mainhand weapon is not in the world.")
			end
			if offhand then
				local x,y,z = GameHelpers.Math.GetPosition(offhand, true)
				test:AssertEquals(x ~= 0 and y ~= 0 and z ~= 0, true, "Thrown offhand weapon is not in the world.")
			end

			test:Wait(10000)

			return true
		end)
	end
else
	---@param character CDivinityStatsCharacter
	TooltipParams.SpecialParamFunctions.LLWEAPONEX_ThrowWeapon_Damage = function (param, character)
		local damage = GameHelpers.Tooltip.GetSkillDamageText("Projectile_LLWEAPONEX_ThrowWeapon_ApplyDamage", character)
		local shield = character:GetItemBySlot("Shield")
		if shield and shield.ItemType == "Shield" then
			local shieldDamage = GameHelpers.Tooltip.GetSkillDamageText("Projectile_LLWEAPONEX_ThrowWeapon_ApplyShieldDamage", character)
			if StringHelpers.IsNullOrWhitespace(shieldDamage) then
				return damage
			end
			return Text.SkillTooltip.ThrowWeaponWithShieldDamage:ReplacePlaceholders(damage, shieldDamage)
		else
			return damage
		end
	end
end
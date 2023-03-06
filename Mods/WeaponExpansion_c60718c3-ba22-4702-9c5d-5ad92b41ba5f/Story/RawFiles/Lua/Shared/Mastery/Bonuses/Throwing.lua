local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData
local _eqSet = "Class_LLWEAPONEX_ThrowingMaster_Preview"

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 1, {
	rb:Create("THROWING_IMPALING_KNIFE", {
		Skills = {"Projectile_ThrowingKnife", "Projectile_EnemyThrowingKnife"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Throwing_ImpalingKnife", "Throw the knife harder, inflicting the target with [Key:LLWEAPONEX_THROW_IMPALED_DisplayName:Impaled] for [ExtraData:LLWEAPONEX_MB_Throwing_ThrowingKnifeInternalDamageTurns:1] turn(s).<br>[Key:LLWEAPONEX_THROW_IMPALED_DisplayName:Impaled] reduces AP Recovery by 1, and deals a small amount of <font color='#CD1F1F'>[Handle:hd05581a1g83a7g4d95gb59fgfa5ef68f5c90:piercing damage]</font>."),
	}).Register.SkillHit(function (self, e, bonuses)
		if e.Data.Success then
			Timer.StartObjectTimer("LLWEAPONEX_Throwing_ApplyImpalingKnife", e.Data.Target, 250, {Source=e.CharacterGUID})
		end
	end).TimerFinished("LLWEAPONEX_Throwing_ApplyImpalingKnife", function (self, e, bonuses)
		if e.Data.Object and e.Data.Source then
			local turns = GameHelpers.GetExtraData("LLWEAPONEX_MB_Throwing_ThrowingKnifeInternalDamageTurns", 1)
			GameHelpers.Status.Apply(e.Data.Object, "LLWEAPONEX_WEAPON_THROW_MB_THROWING_KNIFE", turns * 6.0, false, e.Data.Source)
			SignalTestComplete(self.ID)
		end
	end, "None").Test(function(test, self)
		local characters,_,cleanup = Testing.Utils.CreateTestCharacters({EquipmentSet="Class_Rogue_Dwarves", TotalCharacters=2, TotalDummies=0})
		local char,dummy = table.unpack(characters)
		test.Cleanup = cleanup
		test:Wait(500)
		TeleportToRandomPosition(char, 1.0, ""); TeleportToRandomPosition(dummy, 1.0, "")
		test:Wait(500)
		GameHelpers.Action.UseSkill(char, self.Skills[1], dummy)
		test:WaitForSignal(self.ID, 5000); test:AssertGotSignal(self.ID)
		test:Wait(1000)
		test:AssertEquals(GameHelpers.Status.IsActive(dummy, "LLWEAPONEX_WEAPON_THROW_MB_THROWING_KNIFE"), true, "Failed to apply LLWEAPONEX_THROW_IMPALE")
		return true
	end),
	rb:Create("THROWING_SECOND_IMPACT", {
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Throwing_SecondImpact", "Basic grenades have a <font color='#00FF99'>[ExtraData:LLWEAPONEX_MB_Throwing_GrenadeSecondExplodeChance:25]% chance</font> to explode again."),
		DeferRegistration=true,
	}).Register.Osiris("ItemDestroying", 1, "after", function(itemGUID)
		local item = GameHelpers.GetItem(itemGUID, "EsvItem")
		if item then
			local owner = GameHelpers.Item.GetOwner(item)
			local projectileSkill = StringHelpers.GetSkillEntryName(GetVarFixedString(item.MyGuid, "ProjectileSkill"))
			if owner
			and not StringHelpers.IsNullOrEmpty(projectileSkill)
			and MasteryBonusManager.Vars.ThrowingGrenadeSecondImpactSkills[projectileSkill]
			and MasteryBonusManager.HasMasteryBonus(owner, "THROWING_SECOND_IMPACT", true)
			then
				local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Throwing_GrenadeSecondExplodeChance", 25)
				if owner:HasTag("LLWEAPONEX_MasteryTestCharacter") or (chance > 0 and GameHelpers.Math.Roll(chance)) then
					Timer.StartObjectTimer("LLWEAPONEX_Throwing_SecondImpact_Explode", owner, 800, {Skill=projectileSkill, Position=item.WorldPos})
				end
			end
		end
	end, true).TimerFinished("LLWEAPONEX_Throwing_SecondImpact_Explode", function (self, e, bonuses)
		if e.Data.UUID and e.Data.Skill and e.Data.Position then
			-- local skillData = Ext.Stats.Get(e.Data.Skill, 0, false) --[[@as StatEntrySkillData]]
			-- if skillData then
			-- 	local projectileTemplate = Ext.Template.GetRootTemplate(skillData.Template) --[[@as ProjectileTemplate]]
			-- 	if projectileTemplate and not StringHelpers.IsNullOrEmpty(projectileTemplate.ImpactFX) then
			-- 		EffectManager.PlayEffectAt(projectileTemplate.ImpactFX, e.Data.Position)
			-- 	end
			-- end
			PlaySound(e.Data.UUID, "FX_Surface_SurfaceExplosion_Boom")
			--GameHelpers.Audio.PlaySound("Global", "FX_Surface_SurfaceExplosion_Boom")
			GameHelpers.Skill.Explode(e.Data.Position, e.Data.Skill, e.Data.Object)
			CharacterStatusText(e.Data.UUID, "LLWEAPONEX_StatusText_SecondImpact")
			SignalTestComplete(self.ID)
		end
	end, "None").Test(function(test, self)
		local character,dummy,cleanup = Testing.Utils.CreateTestCharacters({EquipmentSet=_eqSet})
		---@cast character Guid
		---@cast dummy Guid
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(500)
		GameHelpers.Action.UseSkill(character, "Projectile_Grenade_Nailbomb", dummy)
		test:WaitForSignal(self.ID, 5000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 2, {
	rb:Create("THROWING_GLITTER_CHOLORFORM", {
		Skills = {"Projectile_Chloroform", "Projectile_EnemyChloroform", "Projectile_Mark", "Projectile_EnemyMark"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Throwing_GlitterChloroform", "Damage and statuses are now dealt in a [ExtraData:LLWEAPONEX_MB_Throwing_GlitterChloroformRadius:2]m radius."),
	}).Register.SkillProjectileShoot(function (self, e, bonuses)
		local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_Throwing_GlitterChloroformRadius", 2)
		if e.Data.ExplodeRadius0 < radius then
			e.Data.ExplodeRadius0 = radius
		end
		if e.Data.ExplodeRadius1 < radius then
			e.Data.ExplodeRadius1 = radius
		end
		SignalTestComplete(self.ID)
	end).Test(function(test, self)
		local character,dummies,cleanup = Testing.Utils.CreateTestCharacters({EquipmentSet=_eqSet, TotalDummies=2})
		---@cast character Guid
		---@cast dummies Guid[]
		test.Cleanup = cleanup
		test:Wait(500)
		Osi.TeleportTo(dummies[1], dummies[2])
		test:Wait(250)
		GameHelpers.Action.UseSkill(character, "Projectile_Chloroform", dummies[1])
		test:WaitForSignal(self.ID, 5000); test:AssertGotSignal(self.ID)
		test:Wait(250)
		test:AssertEquals(GameHelpers.Status.IsActive(dummies[2], "SLEEPING"), true, "Failed to apply SLEEPING with a modified ExplodeRadius.")
		return true
	end),

	rb:Create("THROWING_EXPLOSIVE_DUST", {
		Skills = {"Projectile_ThrowDust", "Projectile_EnemyThrowDust"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Throwing_ExplosiveDust", "The dust ignites into an explosion cloud, dealing [WeaponDamage:DamageSurface_CloudExplosion] and sabotaging any explosives on the target."),
	}).Register.SkillProjectileHit(function (self, e, bonuses)
		--local radius = math.max(1, GameHelpers.Stats.GetAttribute(e.Skill, "ExplodeRadius", 1))
		--GameHelpers.Surface.CreateSurface(e.Data.Position, "ExplosionCloud", radius, 1, e.Character.Handle, true)
		GameHelpers.Skill.Explode(e.Data.Position, "Projectile_LLWEAPONEX_ThrowingMastery_DustExplosion", e.Character)
		SignalTestComplete(self.ID)
	end).Test(function(test, self)
		local character,dummy,cleanup = Testing.Utils.CreateTestCharacters({EquipmentSet=_eqSet})
		---@cast character Guid
		---@cast dummy Guid
		test.Cleanup = cleanup
		local grenade = CreateItemTemplateAtPosition("5208b121-64fa-4704-8924-c61c576e1ac5", 0, 0, 0)
		ItemToInventory(grenade, dummy, 1, 0, 1)
		test:Wait(250)
		GameHelpers.Action.UseSkill(character, self.Skills[1], dummy)
		test:WaitForSignal(self.ID, 5000); test:AssertGotSignal(self.ID)
		test:Wait(250)
		test:AssertEquals(ObjectExists(grenade) == 0, true, "Grenade failed to explode (no Sabotage?)")
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 3, {
	rb:Create("THROWING_FREE_THROW", {
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Throwing_FreeThrow", "The first throwing item used on your turn is <font color='#00FF99'>free</font>."),
		DeferRegistration=true,
	}).Register.Osiris("ObjectTurnStarted", 1, "after", function(charGUID)
		local object = GameHelpers.TryGetObject(charGUID, "EsvCharacter")
		if object and MasteryBonusManager.HasMasteryBonus(object, "THROWING_FREE_THROW", true) then
			SetTag(charGUID, "LLWEAPONEX_Throwing_FreeThrow")
			SignalTestComplete("THROWING_FREE_THROW_TagSet")
		end
	end, true).TurnEnded(nil, function (self, e, bonuses)
		if e.Object:HasTag("LLWEAPONEX_Throwing_FreeThrow") then
			ClearTag(e.ObjectGUID, "LLWEAPONEX_Throwing_FreeThrow")
			SignalTestComplete("THROWING_FREE_THROW_TagCleared")
		end
	end, true).SkillAPCost(function (self, e, bonuses)
		if (e.Character:HasTag("LLWEAPONEX_Throwing_FreeThrow") or e.Character:HasTag("LLWEAPONEX_MasteryTestCharacter"))
		and (Config.Skill.AllThrowingItemSkills[e.Skill] or Config.Skill.AllGrenadeSkills[e.Skill]) then
			e.Data.AP = 0
			e.Data.ElementalAffinity = false
			e.Data:StopPropagation()
			SignalTestComplete("THROWING_FREE_THROW_APCostSet")
		end
	end).Test(function(test, self)
		local character,dummy,cleanup = Testing.Utils.CreateTestCharacters({EquipmentSet=_eqSet})
		---@cast character Guid
		---@cast dummy Guid
		--local character,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		local grenade = CreateItemTemplateAtPosition("5208b121-64fa-4704-8924-c61c576e1ac5", 0, 0, 0)
		ItemToInventory(grenade, character, 1, 0, 1)
		test:Wait(500)
		Osi.ObjectTurnStarted(character)
		test:WaitForSignal("THROWING_FREE_THROW_TagSet", 500); test:AssertGotSignal("THROWING_FREE_THROW_TagSet")
		--GameHelpers.Action.UseSkill(character, "Projectile_Grenade_Nailbomb", dummy)
		Ext.Events.GetSkillAPCost:Throw({
			AP = 2,
			ElementalAffinity = false,
			ActionPrevented = false,
			AiGrid = Ext.Entity.GetAiGrid(),
			CanPreventAction = true,
			Character = GameHelpers.GetCharacter(character).Stats,
			Position = GameHelpers.Math.GetPosition(dummy),
			Radius = 4.0,
			Skill = {
				Ability = 0,
				ActionPoints = 2,
				SkillId = "Projectile_Grenade_Molotov",
				SkillTypeId = "Projectile",
				StatsObject = GameHelpers.Ext.CreateSkillTable("Projectile_Grenade_Molotov"),
			},
			Name = "GetSkillAPCost",
			Stopped = false,
			PreventAction = function() end,
			StopPropagation = function () end
		})
		--Testing.Utils.UseItemSkillOnTarget(character, dummy, grenade)
		test:WaitForSignal("THROWING_FREE_THROW_APCostSet", 500); test:AssertGotSignal("THROWING_FREE_THROW_APCostSet")
		Osi.ObjectTurnEnded(character)
		test:Wait(250)
		test:WaitForSignal("THROWING_FREE_THROW_TagCleared", 1000); test:AssertGotSignal("THROWING_FREE_THROW_TagCleared")
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Throwing, 4, {
	rb:Create("THROWING_EXPLOSIVES_EXPERT", {
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Throwing_ExplosivesExpert", "Grenades have a <font color='#00FF99'>[ExtraData:LLWEAPONEX_MB_Throwing_GrenadeRadiusIncrease:50]%</font> increased explosion radius."),
		DeferRegistration=true,
	}).Register.SkillProjectileShoot(function (self, e, bonuses)
		local radiusIncrease = GameHelpers.GetExtraData("LLWEAPONEX_MB_Throwing_GrenadeRadiusIncrease", 50)
		if radiusIncrease > 0 then
			radiusIncrease = 1 + (radiusIncrease * 0.01)
			local radius1 = Ext.Utils.Round(e.Data.ExplodeRadius0 * radiusIncrease)
			local radius2 = Ext.Utils.Round(e.Data.ExplodeRadius1 * radiusIncrease)
			e.Data.ExplodeRadius0 = radius1
			e.Data.ExplodeRadius1 = radius2
			SignalTestComplete(self.ID)
		end
	end).SkillProjectileHit(function (self, e, bonuses)
		local radiusIncrease = GameHelpers.GetExtraData("LLWEAPONEX_MB_Throwing_GrenadeRadiusIncrease", 50)
		if radiusIncrease > 0 then
			local skillData = Ext.Stats.Get(e.Skill, 0, false) --[[@as StatEntrySkillData]]
			local increasedSurfaceSize = false
			if skillData and skillData.SkillProperties then
				radiusIncrease = 1 + (radiusIncrease * 0.01)
				for _,v in pairs(skillData.SkillProperties) do
					if (v.Action == "CreateSurface" or v.Action == "TargetCreateSurface") and v.Arg1 > 0 then
						local radius = radiusIncrease * v.Arg1
						local surface = v.Arg3
						local chance = v.Arg4
						if e.Character:HasTag("LLWEAPONEX_MasteryTestCharacter") or chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
							GameHelpers.Surface.CreateSurface(e.Data.Position, surface, radius, 12.0, e.Character.Handle, true, 1.0)
							increasedSurfaceSize = true
						end
					end
				end
			end
			if increasedSurfaceSize then
				SignalTestComplete("THROWING_EXPLOSIVES_EXPERT_SurfaceIncreased")
			end
		end
	end).Test(function(test, self)
		local character,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet)
		test.Cleanup = cleanup
		test:Wait(500)
		GameHelpers.Action.UseSkill(character, "Projectile_Grenade_Molotov", dummy)
		test:WaitForSignal(self.ID, 5000); test:AssertGotSignal(self.ID)
		test:WaitForSignal("THROWING_EXPLOSIVES_EXPERT_SurfaceIncreased", 500); test:AssertGotSignal("THROWING_EXPLOSIVES_EXPERT_SurfaceIncreased")
		return true
	end),
})

Ext.Events.SessionLoaded:Subscribe(function (e)
	for skill in GameHelpers.Stats.GetStats("SkillData", true, "StatEntrySkillData") do
		if Config.Skill.AllGrenadeSkills[skill.Name] ~= false and skill.SkillType == "Projectile" and skill.ProjectileType == "Grenade" then
			Config.Skill.AllGrenadeSkills[skill.Name] = true
		end
	end
	--Only "Starter" Grenades for Second Impact
	for object in GameHelpers.Stats.GetStats("Object", true, "StatEntryObject") do
		if object.ObjectCategory == "GrenadeStarter" then
			local template = Ext.Template.GetRootTemplate(object.RootTemplate) --[[@as ItemTemplate]]
			if template then
				local skills,data = GameHelpers.Item.GetUseActionSkills(template, true)
				if data.CastsSkill then
					for skillid,b in pairs(skills) do
						--_D(Mods.WeaponExpansion.MasteryBonusManager.Vars.ThrowingGrenadeSecondImpactSkills)
						MasteryBonusManager.Vars.ThrowingGrenadeSecondImpactSkills[skillid] = true
					end
				end
			end
		end
	end
	local grenadeSkills = {}
	for skill,b in pairs(Config.Skill.AllGrenadeSkills) do
		if b then
			grenadeSkills[#grenadeSkills+1] = skill
		end
	end
	MasteryBonusManager.GetBonusByID("THROWING_FREE_THROW").Skills = grenadeSkills
	MasteryBonusManager.GetBonusByID("THROWING_EXPLOSIVES_EXPERT").Skills = grenadeSkills

	local secondImpactSkills = {}
	for skill,b in pairs(MasteryBonusManager.Vars.ThrowingGrenadeSecondImpactSkills) do
		if b then
			secondImpactSkills[#secondImpactSkills+1] = skill
		end
	end
	MasteryBonusManager.GetBonusByID("THROWING_SECOND_IMPACT").Skills = secondImpactSkills
end, {Priority=1})

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
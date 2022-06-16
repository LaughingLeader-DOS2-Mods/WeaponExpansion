local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _eqSet = "Class_Cleric_Humans"

MasteryBonusManager.AddRankBonuses(MasteryID.Bludgeon, 1, {
	rb:Create("BLUDGEON_RUSH_DIZZY", {
		Skills = MasteryBonusManager.Vars.RushSkills,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_Rush", "Become a thundering force of will when rushing, <font color='#FFCE58'>knocking enemies aside</font> with a <font color='#F19824'>[ExtraData:LLWEAPONEX_MB_Bludgeon_Rush_DizzyChance]% chance to apply Dizzy for [ExtraData:LLWEAPONEX_MB_Bludgeon_Rush_DizzyTurns] turn(s)</font>."),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local forceDist = Ext.Random(2,4)
			GameHelpers.ForceMoveObject(e.Character, e.Data.Target, forceDist, e.Skill)
			local dizzyChance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_Rush_DizzyChance", 40.0)
			if e.Character:HasTag("LLWEAPONEX_MasteryTestCharacter") or GameHelpers.Math.Roll(dizzyChance) then
				local dizzyDuration = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_Rush_DizzyTurns", 1.0) * 6.0
				GameHelpers.Status.Apply(e.Data.Target, "LLWEAPONEX_DIZZY", dizzyDuration, false, e.Character)
				SignalTestComplete(self.ID)
			end
		end
	end).Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		local dummyPos = GameHelpers.Math.GetPosition(dummy)
		local x,y,z = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(char, 4.0, dummyPos[1], dummyPos[2], dummyPos[3]))
		CharacterUseSkillAtPosition(char, "Rush_EnemyBatteringRam", x, y, z, 1, 1)
		--CharacterUseSkill(char, "Rush_EnemyBatteringRam", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		test:Wait(500)
		test:AssertEquals(HasActiveStatus(dummy, "LLWEAPONEX_DIZZY") == 1, true, "LLWEAPONEX_DIZZY not applied to target")
		return true
	end),
})

if not Vars.IsClient then
	Events.OnHeal:Subscribe(function (e)
		if e.Heal.StatusId == "LLWEAPONEX_MASTERYBONUS_BLUDGEON_ARMOR_DAMAGE" then
			print(Ext.MonotonicTime(), "OnHeal", e.Heal.HealAmount)
		end
	end)
	---@param status EsvStatusHeal
	StatusManager.Register.Applied("LLWEAPONEX_MASTERYBONUS_BLUDGEON_ARMOR_DAMAGE", function (target, status, source)
		print(Ext.MonotonicTime(), "Applied", status.HealAmount)
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Bludgeon, 2, {
	rb:Create("BLUDGEON_SUNDER", {
		Skills = {"Target_CripplingBlow","Target_EnemyCripplingBlow"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_CripplingBlow", "<font color='#F19824'>Sunder targets hit, reducing <font color='#AE9F95'>[Handle:h856999degd5aag435eg895fg50546f5a87f6:Maximum Physical Armour] by [Stats:Stats_LLWEAPONEX_MasteryBonus_Sunder:ArmorBoost]%</font> and <font color='#4197E2'>[Handle:h92acd36agc072g4ec8g9ca2g32fe6f89f375:Maximum Magic Armour] by [Stats:Stats_LLWEAPONEX_MasteryBonus_Sunder:MagicArmorBoost]%</font> for [ExtraData:LLWEAPONEX_MB_Bludgeon_SunderTurns] turn(s).</font>"),
		NamePrefix = "<font color='#F19824'>Sundering</font>"
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local duration = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_SunderTurns", 2) * 6.0
			if GameHelpers.Status.IsActive(e.Data.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER") then
				local status = e.Data.TargetObject:GetStatus("LLWEAPONEX_MASTERYBONUS_SUNDER")
				if status then
					status.CurrentLifeTime = duration
					status.RequestClientSync = true
				end
			else
				GameHelpers.Status.Apply(e.Data.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER", duration, false, e.Character)
			end
			SignalTestComplete(self.ID)
		end
	end).Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		test:Wait(500)
		test:AssertEquals(HasActiveStatus(dummy, "LLWEAPONEX_MASTERYBONUS_SUNDER") == 1, true, "LLWEAPONEX_MASTERYBONUS_SUNDER not applied to target")
		return true
	end),
	rb:Create("BLUDGEON_ARMORBREAKER", {
		Skills = {"ActionAttackGround"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_ArmorBreaker", "<font color='#F19824'>Deal [ExtraData:LLWEAPONEX_MB_Bludgeon_BonusArmorDamage:25]% additional damage to <font color='#A8A8A8'>[Handle:hb677b3f7g5cf6g49c3g84fag2f773ef50dd6:Physical Armour]</font> and <font color='#188EDE'>[Handle:hd82fb3dag025bg4caag856egceaf8ecad162:Magic Armour]</font> with basic attacks.</font>"),
		OnGetTooltip = function (self, skillOrStatus, character, tooltipType, status)
			if ArmorSystemIsDisabled() then
				return GameHelpers.GetStringKeyText("LLWEAPONEX_MB_Bludgeon_ArmorBreaker_NoArmor", "<font color='#F19824'>Deal [ExtraData:LLWEAPONEX_MB_Bludgeon_BonusArmorDamage:25]% additional damage with basic attacks.</font>")
			else
				return self.Tooltip
			end
		end
	}):RegisterOnWeaponTagHit("LLWEAPONEX_Bludgeon", function(tag, attacker, target, data, targetIsObject, skill, self)
		if targetIsObject and not skill and data.Damage > 0 and GameHelpers.Ext.ObjectIsCharacter(target) then
			local armorDamageMult = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_BonusArmorDamage", 25)
			if armorDamageMult > 0 then
				local armor = target.Stats.CurrentArmor or 0
				local magicArmor = target.Stats.CurrentMagicArmor or 0
				if armor > 0 or magicArmor > 0 or attacker:HasTag("LLWEAPONEX_MasteryTestCharacter") then
					local amount = math.floor(data.Damage * (armorDamageMult * 0.01))
					if amount > 0 then
						if not ArmorSystemIsDisabled() then
							data:AddDamage("Magic", amount, true)
							data:AddDamage("Corrosive", amount, true)
							data.DamageList:AggregateSameTypeDamages()
							data:ApplyDamageList(true)
							SetTag(target.MyGuid, "LLWEAPONEX_DisableArmorDamageConversion")
							Timer.StartObjectTimer("LLWEAPONEX_ClearDisableArmorDamageConversion", target, 20)
						else
							--If armor is disabled, then it'll just work as bonus damage
							local bludgeons = GameHelpers.Item.FindTaggedEquipment(attacker, "LLWEAPONEX_Bludgeon", true)
							local weaponDamageType = "Physical"
							if bludgeons[1] then
								weaponDamageType = bludgeons[1]["Damage Type"]
							end
							data:AddDamage(data.HitRequest.DamageType or weaponDamageType, amount)
						end
						SignalTestComplete(self.ID)
					end
					-- local stat = Ext.GetStat("LLWEAPONEX_MASTERYBONUS_BLUDGEON_ARMOR_DAMAGE")
					-- stat.HealValue = Ext.Round(data.Damage * (armorDamageMult * 0.01))
					-- print(Ext.MonotonicTime(), "Sync", stat.HealValue)
					-- Ext.SyncStat("LLWEAPONEX_MASTERYBONUS_BLUDGEON_ARMOR_DAMAGE", false)
					-- GameHelpers.Status.Apply(target, "LLWEAPONEX_MASTERYBONUS_BLUDGEON_ARMOR_DAMAGE", 0, false, attacker)
				end
			end
		end
	end).Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		SetTag(CharacterGetEquippedWeapon(char), "LLWEAPONEX_Bludgeon")
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterAttack(char, dummy)
		test:WaitForSignal(self.ID, 5000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bludgeon, 3, {
	rb:Create("BLUDGEON_GROUNDQUAKE", {
		Skills = {"Cone_GroundSmash","Cone_EnemyGroundSmash"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_GroundSmashQuake", "<font color='#F19824'>A localized quake is created where your weapon contacts the ground, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake] to enemies in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake:ExplodeRadius]m radius.</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
		local weaponRange = 1.5
		local weapons = GameHelpers.Item.FindTaggedEquipment(e.Character, "LLWEAPONEX_Bludgeon")
		if #weapons > 0 then
			for i,v in pairs(weapons) do
				local range = Ext.GetItem(v).Stats.WeaponRange / 100
				if range > weaponRange then
					weaponRange = range + 0.25
				end
			end
		end
		local pos = GameHelpers.Math.GetForwardPosition(e.Character, weaponRange)
		GameHelpers.Skill.Explode(pos, "Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake", e.Character, {EnemiesOnly = true})
		-- TODO: Swap to a different effect
		--local x,y,z = table.unpack(pos)
		--PlayEffectAtPosition("LLWEAPONEX_FX_AnvilMace_Impact_01", x,y,z)
		--PlaySound(e.Character.MyGuid, "Skill_Earth_ReactiveArmor_Impact")
		EffectManager.PlayEffectAt("RS3_FX_Skills_Earth_Cast_Shout_Earthquake_Root_02", pos, {Scale = 0.5})
		SignalTestComplete(self.ID)
	end).Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

if not Vars.IsClient then
	Timer.Subscribe("LLWEAPONEX_MB_Bludgeon_BonusHit", function (e)
		if e.Data.UUID and e.Data.Target then
			if not GameHelpers.Character.IsDeadOrDying(e.Data.Target) and not GameHelpers.Character.IsDeadOrDying(e.Data.UUID) then
				GameHelpers.ClearActionQueue(e.Data.UUID, true)
				CharacterUseSkill(e.Data.UUID, "Target_LLWEAPONEX_MasteryBonus_Bludgeon_FlurryBonus", e.Data.Target, 1, 1, 1)
				-- CharacterUseSkill(e.Data.UUID, "Shout_LeaderLib_ClearQueue", e.Data.UUID, 1, 1, 1)
				-- Timer.StartOneshot("", 250, function ()
				-- 	GameHelpers.ClearActionQueue(e.Data.UUID, true)
				-- 	CharacterUseSkill(e.Data.UUID, "Target_LLWEAPONEX_MasteryBonus_Bludgeon_FlurryBonus", e.Data.Target, 1, 1, 1)
				-- end)
			end
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Bludgeon, 4, {
	rb:Create("BLUDGEON_FLURRY", {
		Skills = {"Target_Flurry","Target_EnemyFlurry"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_Flurry", "<font color='#F19824'>After attacking, leap up into the air and strike the earth, dealing [SkillDamage:Target_LLWEAPONEX_MasteryBonus_Bludgeon_FlurryBonus] and applying [Key:LLWEAPONEX_MASTERYBONUS_SUNDER_DisplayName:Sundered].</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			Timer.Cancel("LLWEAPONEX_MB_Bludgeon_BonusHit", e.Character)
			Timer.StartObjectTimer("LLWEAPONEX_MB_Bludgeon_BonusHit", e.Character, 1250, {Target=e.Data.Target})
			SignalTestComplete("BLUDGEON_FLURRY_InitialSkill")
		end
	end).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			PlaySound(e.Character.MyGuid, "Skill_Earth_DustBlast_Impact")
			EffectManager.PlayEffectAt("RS3_FX_Skills_Earth_Cast_Shout_Earthquake_Root_02", e.Data.TargetObject.WorldPos, {Scale = 0.8})
			SignalTestComplete("BLUDGEON_FLURRY_FinalSkill")
		end
	end, "None", "Target_LLWEAPONEX_MasteryBonus_Bludgeon_FlurryBonus").Register.Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal("BLUDGEON_FLURRY_InitialSkill", 5000)
		test:AssertGotSignal("BLUDGEON_FLURRY_InitialSkill")
		test:WaitForSignal("BLUDGEON_FLURRY_FinalSkill", 20000)
		test:AssertGotSignal("BLUDGEON_FLURRY_FinalSkill")
		test:Wait(1000)
		return true
	end),
})
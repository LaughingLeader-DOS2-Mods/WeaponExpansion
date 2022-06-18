local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _eqSet = "Class_Cleric_Humans"

local _ignoreFormatColors = {
	White = true,
	DarkGray = true,
	Black = true,
}

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

	rb:Create("BLUDGEON_SHELLCRACKING", {
		Skills = {"Target_HeavyAttack","Target_DualWieldingAttack"},
		Statuses = {"FORTIFIED", "MAGIC_SHELL"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_ShellCracking", "<font color='#F19824'>Hitting a target with [FORTIFIED_DisplayName] or [MAGIC_SHELL_DisplayName] reduces the remaining duration by [ExtraData:LLWEAPONEX_MB_Bludgeon_FortifyShellTurnReduction:1] turn(s).<br>If the status is reduced to 0, the magical energy explodes, dealing an additional [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_ShellCrackingBonusDamage] to enemies in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_ShellCrackingBonusDamage:ExplodeRadius]m radius.</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local turnReduction = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_FortifyShellTurnReduction", 1)
			if turnReduction > 0 then
				local durationReduction = turnReduction * 6.0
				local affectedStatus = false
				local createdExplosion = false
				local sourceName = GameHelpers.GetDisplayName(e.Character)
				local targetName = GameHelpers.GetDisplayName(e.Data.TargetObject)
				local effectPos = {GameHelpers.Math.GetPosition(e.Data.Target, true)}
				effectPos[2] = effectPos[2] + 1
				for _,id in pairs(self.Statuses) do
					local status = e.Data.TargetObject:GetStatus(id)
					if status and status.CurrentLifeTime > 0 then -- Ignore permanent statuses
						local statusColor = Ext.StatGetAttribute(id, "FormatColor")
						if StringHelpers.IsNullOrWhitespace(statusColor) or _ignoreFormatColors[statusColor] then
							statusColor = "Green"
						end
						local nextDuration = status.CurrentLifeTime - durationReduction
						if nextDuration <= 0 then
							GameHelpers.Status.Remove(e.Data.TargetObject, id)
							GameHelpers.Skill.Explode(e.Data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_ShellCrackingBonusDamage", e.Character, {EnemiesOnly = true})
							local combatLogText = Text.CombatLog.Bludgeon_ShellCracking_StatusRemoved:ReplacePlaceholders(sourceName, GameHelpers.Stats.GetDisplayName(id), targetName, Data.Colors.FormatStringColor[statusColor] or "#33FF33")
							CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, combatLogText)

							createdExplosion = true

							EffectManager.PlayEffectAt("RS3_FX_GP_Combat_Hit_MagicalArmor_01", effectPos, {Rotation={1,0,0,0,10,10,0,0,0}, Scale=1.5})
						else
							status.CurrentLifeTime = nextDuration
							status.RequestClientSync = true

							local combatLogText = Text.CombatLog.Bludgeon_ShellCracking_StatusTurnsReduced:ReplacePlaceholders(sourceName, targetName, GameHelpers.Stats.GetDisplayName(id), turnReduction, Data.Colors.FormatStringColor[statusColor] or "#33FF33")
							CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, combatLogText)
						end
						affectedStatus = true
					end
				end
				if affectedStatus then
					if createdExplosion then
						PlaySound(e.Data.Target, "Skill_Poly_StripResistance_Impact")
					end
					--PlaySound(e.Data.Target, "Skill_Item_RecoverArmour_Impact")
					SignalTestComplete(self.ID)
				end
			end
		end
	end).Register.Test(function(test, self)
		local char,dummy,cleanup,dummies = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true, 2)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		GameHelpers.Status.Apply(dummy, "FORTIFIED", 6.0, true, dummy)
		GameHelpers.Status.Apply(dummy, "MAGIC_SHELL", 12.0, true, dummy)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		test:Wait(1000)
		local turnReduction = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_FortifyShellTurnReduction", 1)
		if turnReduction > 0 then
			test:AssertEquals(HasActiveStatus(dummy, "FORTIFIED") == 0, true, "FORTIFIED not removed")
			test:AssertEquals(GetStatusTurns(dummy, "MAGIC_SHELL") <= 1, true, "MAGIC_SHELL duration not reduced")
		end
		test:Wait(1000)
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
		Skills = MasteryBonusManager.Vars.BasicAttack,
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
	---@param e {Data:{UUID:string, Target:string|nil}}
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

if Vars.IsClient then
	TooltipParams.SpecialParamFunctions.LLWEAPONEX_BludgeonShatterMultiplier = function(param, statCharacter)
		--1 + (mult * 0.01), so it always is making the hit deal more damage
		local critMult = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_ShatterDamageMultiplier", 200)
		return string.format("%i", Ext.Round(critMult + 100))
	end
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

	rb:Create("BLUDGEON_SHATTER", {
		Skills = MasteryBonusManager.Vars.BasicAttack,
		Statuses = {"PETRIFIED", "FROZEN"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_Shatter", "<font color='#F19824'>Basic attacking a target with [PETRIFIED_DisplayName] or [FROZEN_DisplayName] will shatter the coating, dealing a massive critical hit ([LLWEAPONEX_BludgeonShatterMultiplier]% damage) and cleansing the status.</font><br><font color='#33FF33'>Allies take reduced damage.</font>"),
	}):RegisterOnWeaponTagHit("LLWEAPONEX_Bludgeon", function(tag, attacker, target, data, targetIsObject, skill, self)
		if targetIsObject and not skill and data.Damage > 0 and GameHelpers.Status.IsActive(target, self.Statuses) then
			if GameHelpers.Character.IsAllyOfParty(target) then
				local damageReduction = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_ShatterAllyDamageReduction", 25)
				if damageReduction > 0 then
					--Reduce damage
					data:MultiplyDamage((damageReduction * 0.01), true)
				end
			else
				local critMult = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_ShatterDamageMultiplier", 200)
				if critMult > 0 then
					if data:HasHitFlag("CriticalHit", true) then
						local weaponCritMult = Game.Math.GetCriticalHitMultiplier(attacker.Stats.MainWeapon, attacker.Stats, 1.0)
						critMult = critMult - (weaponCritMult * 100)
					end
					data:SetHitFlag("CriticalHit", true)
					--local critMult = Game.Math.GetCriticalHitMultiplier(attacker.Stats.MainWeapon, attacker.Stats, 1.0)
					data:MultiplyDamage(1 + (critMult * 0.01), true)
				end
			end
			GameHelpers.Status.Remove(target, self.Statuses)
			SignalTestComplete(self.ID)
		end
	end).Register.Test(function(test, self)
		local char1,char2,dummy,cleanup = MasteryTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		SetTag(CharacterGetEquippedWeapon(char1), "LLWEAPONEX_Bludgeon")
		TeleportTo(char1, dummy, "", 0, 1, 1)
		test:Wait(250)
		SetFaction(char1, "Good NPC")
		SetFaction(char2, "Good NPC")
		CharacterSetFightMode(char1, 1, 1)
		TeleportTo(char2, char1, "", 0, 1, 1)
		GameHelpers.Status.Apply(dummy, "FROZEN", -1.0, true, char1)
		GameHelpers.Status.Apply(char2, "PETRIFIED", -1.0, true, dummy)
		test:Wait(1000)
		CharacterAttack(char1, dummy)
		test:WaitForSignal(self.ID, 5000)
		test:AssertGotSignal(self.ID)
		test:Wait(2000)
		CharacterAttack(char1, char2)
		test:WaitForSignal(self.ID, 5000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})
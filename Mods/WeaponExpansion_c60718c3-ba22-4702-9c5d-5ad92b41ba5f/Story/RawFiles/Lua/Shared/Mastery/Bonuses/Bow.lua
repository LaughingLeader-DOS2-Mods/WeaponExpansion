local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _ISCLIENT = Ext.IsClient()

local _eqSet = "Class_Ranger_Humans"

---@param v UUID|number[]
---@param targetType SkillEventDataForEachTargetType
---@param char EsvCharacter
---@param skill string
---@param forwardVector number[]
---@param radius number
local function OnPinDownTarget(v, targetType, char, skill, forwardVector, radius)
	--print("OnPinDownTarget", v, targetType, char, skill, forwardVector, radius)
	local target = nil
	local pos = GameHelpers.Math.GetPosition(v)
	local targets = GameHelpers.Grid.GetNearbyObjects(char, {Position=pos, Radius=radius, Relation={Enemy=true}})
	if targets ~= nil and #targets > 0 then
		target = Common.GetRandomTableEntry(targets)
	end

	if target == nil then
		target = v
	end

	if target ~= nil then
		GameHelpers.Skill.ShootProjectileAt(target, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", char, {CanDeflect = true})
	else
		pos[2] = pos[2] + 1
		GameHelpers.Skill.ShootProjectileAt(pos, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", char, {CanDeflect = true})
	end
	return true
end

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 1, {
	rb:Create("BOW_DOUBLE_SHOT", {
		Skills = {"Projectile_PinDown", "Projectile_EnemyPinDown"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_PinDown", "<font color='#72EE34'>Shoot <font color='#00FFAA'>[ExtraData:LLWEAPONEX_MB_Bow_PinDown_BonusShots]</font> additional arrow(s) at a nearby enemy for [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot].</font><br><font color='#F19824'>If no enemies are nearby, the bonus arrow(s) will fire at the original target.</font>"),
	}).Register.SkillCast(function(self, e, bonuses)
			-- Support for a mod making Pin Down shoot multiple arrows through the use of iterating tables.
			local maxBonusShots = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_PinDown_BonusShots", 1)
			if maxBonusShots > 0 then
				local bonusShots = 0
				local rot = e.Character.Stats.Rotation
				local forwardVector = {
					-rot[7] * 1.25,
					0,
					-rot[9] * 1.25,
				}
				local radius = (Ext.StatGetAttribute(e.Skill, "TargetRadius") or 6.0) / 2
				e.Data:ForEach(function(v, targetType, skillEventData)
					if bonusShots < maxBonusShots then
						local b,result = xpcall(OnPinDownTarget, debug.traceback, v, targetType, e.Character, e.Skill, forwardVector, radius)
						if result then
							bonusShots = bonusShots + 1
						elseif not b then
							Ext.PrintError(result)
						end
					end
				end, e.Data.TargetMode.All)
				if bonusShots > 0 then
					SignalTestComplete(self.ID)
				end
			end
	end).Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 2, {
	rb:Create("BOW_ASSASSINATE_MARKED", {
		Skills = {"Projectile_Snipe", "Projectile_EnemySnipe"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_AssassinateMarked", "<font color='#72EE34'>If the target is <font color='#FF3300'>[Key:MARKED_DisplayName]</font>, deal a <font color='#FF33FF'>guaranteed critical hit</font> and bypass dodging/blocking.</font><br><font color='#F19824'>[Key:MARKED_DisplayName] is cleansed on hit.</font>"),
		Statuses = {"MARKED"},
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_AssassinateMarkedStatus", "<font color='#33FF00'>Character is vulnerable to a critical hit from [Key:Projectile_Snipe_DisplayName].</font>"),
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_Bow_Mastery2", true)
	}).Register.SkillHit(function(self, e, bonuses)
		if GameHelpers.Status.IsActive(e.Data.TargetObject, self.Statuses) then
			if not e.Data:HasHitFlag("CriticalHit", true) then
				local weaponCritMult = Game.Math.GetCriticalHitMultiplier(e.Character.Stats.MainWeapon, e.Character.Stats, 0.0)
				if weaponCritMult < 1 then
					weaponCritMult = weaponCritMult + 1
				end
				e.Data:SetHitFlag("CriticalHit", true)
				e.Data:SetHitFlag("Blocked", false)
				e.Data:SetHitFlag("Dodged", false)
				e.Data:SetHitFlag("Missed", false)
				local critMultReduction = GameHelpers.GetExtraData("LLWEAPONEX_PostHitCriticalMultiplierReduction", 0.1)
				if critMultReduction > 0 then
					weaponCritMult = weaponCritMult - critMultReduction
				end
				e.Data:MultiplyDamage(weaponCritMult)
			end
			GameHelpers.Status.Remove(e.Data.Target, self.Statuses)
			SignalTestComplete(self.ID)
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		ApplyStatus(dummy, "MARKED", -1, 1, char)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end),
	rb:Create("BOW_FOCUSED_ATTACKING", {
		Skills = MasteryBonusManager.Vars.BasicAttack,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_FocusedAttacking", "<font color='#72EE34'>Non-critical basic attacks on the same target have a cumulative chance to critical hit, until a critical hit is achieved, you leave comat, or a different target is attacked.</font><br><font color='#33FF99'>This bonus also works with [Key:LLWEAPONEX_Greatbow:Greatbow] type weapons.</font>"),
	}).Register.WeaponTypeHit("Bow", function(self, e, bonuses)
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_FocusedBasicAttackCriticalChance", 5, true)
		if chance > 0
		and not e.SkillData -- Basic attacks only
		--enable skipWeaponCheck in HasMasteryBonus, so this bonus works as long as it's been unlocked, and the weapon type is a Bow, stats-wise
		and MasteryBonusManager.HasMasteryBonus(e.Attacker, self.ID, true) then
			local GUID = e.Attacker.MyGuid
			if e.Data:HasHitFlag("CriticalHit", true) or not e.TargetIsObject then
				PersistentVars.MasteryMechanics.BowCumulativeCriticalChance[GUID] = nil
			else
				local attackData = PersistentVars.MasteryMechanics.BowCumulativeCriticalChance[GUID]
				if attackData then
					if attackData.Target ~= e.Target.MyGuid then
						attackData.Hits = 1
						attackData.Target = e.Target.MyGuid
					else
						attackData.Hits = attackData.Hits + 1
					end
				else
					attackData = {Hits = 1, Target = e.Target.MyGuid}
					PersistentVars.MasteryMechanics.BowCumulativeCriticalChance[GUID] = attackData
				end
				local totalHits = attackData.Hits
				if totalHits > 1 then
					local bonusRolls = totalHits - 1
					if GameHelpers.Math.Roll(chance, bonusRolls) then
						local attackerName = GameHelpers.Character.GetDisplayName(e.Attacker)
						local targetName = GameHelpers.Character.GetDisplayName(e.Target)
						local combatLogText = Text.CombatLog.Bow.FocusedBasicAttackSuccess:ReplacePlaceholders(attackerName, targetName, totalHits)

						CombatLog.AddCombatText(combatLogText)

						local weaponCritMult = Game.Math.GetCriticalHitMultiplier(e.Attacker.Stats.MainWeapon, e.Attacker.Stats, 0.0)
						if weaponCritMult < 1 then
							weaponCritMult = weaponCritMult + 1
						end
						e.Data:SetHitFlag("CriticalHit", true)
						e.Data:MultiplyDamage(weaponCritMult)
						SignalTestComplete(self.ID)
					end
				end
			end
		end
	end, true).Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		local keepAttacking = true
		local tries = 0
		while keepAttacking and tries <= 30 do
			tries = tries + 1
			CharacterAttack(char, dummy)
			test:WaitForSignal(self.ID, 1000)
			if test.SignalSuccess == self.ID then
				keepAttacking = false
				test.SuccessMessage = string.format("[%s] Took (%s) attacks to finally critical hit (%s%% chance).", self.ID, tries, GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_FocusedBasicAttackCriticalChance", 5))
				Ext.PrintWarning(test.SuccessMessage)
			end
		end
		assert(tries <= 30, "Ran out of basic attack attempts (tries > 30)")
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 3, {
	rb:Create("BOW_EXPLOSIVE_RAIN", {
		Skills = {"ProjectileStrike_RainOfArrows", "ProjectileStrike_EnemyRainOfArrows"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_ExplosiveRain", "<font color='#FFCC33'>[Special:LLWEAPONEX_MB_Bow_ExplosiveRainHitRange]</font><font color='#72EE34'> random arrow(s) have a <font color='#FFCC33'>[ExtraData:LLWEAPONEX_MB_Bow_ExplosiveRain_ExplodeChance]% chance</font> to explode with shrapnel, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Bow_ExplosiveRainDamage] in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Bow_ExplosiveRainDamage:ExplodeRadius]m radius, with a small chance to apply [Key:BLEEDING_DisplayName].</font>"),
	}).Register.SpecialTooltipParam("LLWEAPONEX_MB_Bow_ExplosiveRainHitRange", function (param, character)
		local min = math.max(0, GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_ExplosiveRain_MinArrows", 1, true))
		local max = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_ExplosiveRain_MaxArrows", 5, true)
		if max <= 0 then
			return "0"
		end
		local strikeCount = Ext.StatGetAttribute("ProjectileStrike_RainOfArrows", "StrikeCount")
		if max > strikeCount then
			max = strikeCount
		end
		if min > max then
			min = max
		end
		if min ~= max then
			return string.format("%i-%i", min, max)
		end
		return string.format("%i", min)
	end).SkillUsed(function(self, e, bonuses)
		local strikeCount = Ext.StatGetAttribute(e.Skill, "StrikeCount")
		local max = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_ExplosiveRain_MaxArrows", 5, true)
		if strikeCount > 0 and max > 0 then
			local min = math.max(0, GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_ExplosiveRain_MinArrows", 1, true))
			if min ~= max then
				local ran = Ext.Random(min, max)
				PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid] = {Total = strikeCount, Remaining = ran}
			else
				PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid] = {Total = strikeCount, Remaining = max}
			end
			Timer.StartObjectTimer("LLWEAPONEX_MB_Bow_ExplosiveRain_ClearData", e.Character, 10000)
		end
	end).SkillProjectileHit(function(self, e, bonuses)
		local data = PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid]
		if data then
			if data.Remaining > 0 then
				local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_ExplosiveRain_ExplodeChance", 20, true)
				if GameHelpers.Math.Roll(chance) then
					GameHelpers.Skill.Explode(e.Data.Position, "Projectile_LLWEAPONEX_MasteryBonus_Bow_ExplosiveRainDamage", e.Character, {CanDeflect=false,EnemiesOnly=true})
					local pos = {table.unpack(e.Data.Position)}
					pos[2] = pos[2] - 0.5
					EffectManager.PlayEffectAt("LLWEAPONEX_FX_Projectiles_RemoteMine_Shrapnel_Impact_01", pos, {Scale=0.7})
					data.Remaining = data.Remaining - 1
				end
			end
			if data.Remaining <= 0 then
				PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid] = nil
				SignalTestComplete(self.ID)
			else
				data.Total = data.Total - 1
				Timer.RestartObjectTimer("LLWEAPONEX_MB_Bow_ExplosiveRain_ClearData", e.Character, 1000)
				if data.Total == 0 then
					if data.Remaining > 0 and Vars.DebugMode then
						fprint(LOGLEVEL.WARNING, "[LLWEAPONEX_MB_Bow_ExplosiveRain] (%s) arrow(s) unexploded!", data.Remaining)
					end
					SignalTestComplete(self.ID)
					PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid] = nil
				end
			end
		end
	end).TimerFinished("LLWEAPONEX_MB_Bow_ExplosiveRain_ClearData", function (self, e, bonuses)
		if e.Data.UUID then
			PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Data.UUID] = nil
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(dummy, 10)
		--TeleportTo(char, dummy, "", 0, 1, 1)
		TeleportToPosition(char, pos[1], pos[2], pos[3], "", 0, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		--CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		local x,y,z = GetPosition(dummy)
		CharacterUseSkillAtPosition(char, self.Skills[1], x, y, z, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		test:Wait(3000)
		return true
	end),
})

local OnAttackStarting = nil

if not _ISCLIENT then
	---@param self MasteryBonusData
	---@param e OnBasicAttackStartEventArgs|OnSkillStateSkillEventEventArgs
	---@param bonuses MasteryActiveBonuses
	---@param attacker EsvCharacter
	---@param target EsvCharacter
	OnAttackStarting = function(self, e, bonuses, attacker, target)
		local attackerGUID = attacker.MyGuid
		local targetGUID = target.MyGuid

		local combatid = GameHelpers.Combat.GetID(targetGUID)
		local characters = {}
		if combatid then
			for _,ally in GameHelpers.Combat.GetCharacters(combatid, "Ally", target) do
				local allyGUID = ally.MyGuid
				if allyGUID ~= attackerGUID and allyGUID ~= targetGUID then
					characters[#characters+1] = ally
				end
			end
		else
			for _,v in target:GetNearbyCharacters(32.0) do
				if v ~= targetGUID and v ~= attackerGUID
				and CharacterIsAlly(v, targetGUID) == 1
				then
					characters[#characters+1] = GameHelpers.GetCharacter(v)
				end
			end
		end
		for _,ally in pairs(characters) do
			local allyGUID = ally.MyGuid
			if GameHelpers.Status.IsActive(ally, self.Statuses)
			and MasteryBonusManager.HasMasteryBonus(ally, self.ID)
			and GameHelpers.Character.IsWithinWeaponRange(ally, attacker) then
				local attacks = PersistentVars.MasteryMechanics.BowFarsightAttacks[allyGUID] or 0
				if attacks > 0 then
					CharacterAttack(allyGUID, attackerGUID)
					if attacks > 1 then
						PersistentVars.MasteryMechanics.BowFarsightAttacks[allyGUID] = attacks - 1
						SignalTestComplete("BOW_FARSIGHT_AttacksRemainingReduced")
					else
						PersistentVars.MasteryMechanics.BowFarsightAttacks[allyGUID] = nil
						SignalTestComplete("BOW_FARSIGHT_AttacksRemainingDepleted")
					end
				end
			end
		end
	end
end

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 4, {
	rb:Create("BOW_PIERCING_PROJECTILE", {
		AllSkills = true,
		---@param self MasteryBonusData
		---@param id string
		---@param character EclCharacter
		---@param tooltipType MasteryBonusDataTooltipID
		---@param extraParam EclItem|EclStatus
		---@param tags table<string,boolean>|nil
		GetIsTooltipActive = function(self, id, character, tooltipType, extraParam, tags, itemHasSkill)
			if tooltipType == "skill" and MasteryBonusManager.Vars.BowProjectilePiercingSkills[id] then
				return true
			end
			return false
		end,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_PiercingProjectiles", "<font color='#72EE34'>Non-piercing projectile bow skills will pierce the first target hit.</font>"),
	}).Register.SkillUsed(function (self, e, bonuses)
		--This is to ensure the skill is being cast, so we don't make explosions pierce
		if PersistentVars.MasteryMechanics.PiercingBowSkill[e.Skill] == nil then
			PersistentVars.MasteryMechanics.PiercingBowSkill[e.Skill] = {}
		end
		PersistentVars.MasteryMechanics.PiercingBowSkill[e.Skill][e.Character.MyGuid] = true
	end).SkillProjectileHit(function (self, e, bonuses)
		local pbdata = PersistentVars.MasteryMechanics.PiercingBowSkill[e.Skill]
		if pbdata and pbdata[e.Character.MyGuid] == true then
			pbdata[e.Character.MyGuid] = nil
			if not Common.TableHasAnyEntry(pbdata) then
				PersistentVars.MasteryMechanics.PiercingBowSkill[e.Skill] = nil
			end

			local x,y,z = table.unpack(e.Data.Position)
			local dist = Ext.Round(Ext.GetStat(e.Skill).TargetRadius / 2)
			local dir = GameHelpers.Math.GetDirectionVector(e.Character, e.Data.Position)
			local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Character, dist, x, y, z, dir)
			pos[2] = y

			GameHelpers.Skill.ShootProjectileAt(pos, e.Skill, e.Character, {EnemiesOnly=true})
			SignalTestComplete(self.ID)
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = MasteryTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		local x,y,z = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(dummy, 10.0))
		TeleportToPosition(char, x,y,z, "", 0, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char, "Projectile_EnemyBallisticShot", dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	rb:Create("BOW_FARSIGHT", {
		Skills = {"Target_Farsight", "Target_EnemyFarsight"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_Farsight", "<font color='#72EE34'>While [KEY:FARSIGHT_DisplayName] is active, pre-emptively basic attack the first enemy that attempts to harm an ally, [ExtraData:LLWEAPONEX_MB_Bow_Farsight_AttacksPerTurn:2] time(s) until your turn ends again.</font>"),
		Statuses = {"FARSIGHT"},
	}).Register.SkillCast(function (self, e, bonuses)
		e.Data:ForEach(function (target, targetType, self)
			if target == e.Character.MyGuid then
				TurnCounter.CountUp("LLWEAPONEX_MB_Bow_Farsight", 3, e.Character, {
					CombatOnly = true, Infinite = true, ClearOnDeath = true,
					Target = e.Character.MyGuid})
				SignalTestComplete("BOW_FARSIGHT_FarsightCasted")
			end
		end, e.Data.TargetMode.Objects)
	end).TurnCounter("LLWEAPONEX_MB_Bow_Farsight", function(self, e, bonuses)
		if e.Finished then
			PersistentVars.MasteryMechanics.BowFarsightAttacks[e.Data.Target] = nil
		elseif e.Data.Turns > 0 and e.Data.Target then
			local target = GameHelpers.GetCharacter(e.Data.Target)
			if target then
				if GameHelpers.Status.IsActive(target, self.Statuses) then
					local attacks = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_Farsight_AttacksPerTurn", 2, true)
					if attacks > 0 then
						PersistentVars.MasteryMechanics.BowFarsightAttacks[target.MyGuid] = attacks
						SignalTestComplete("BOW_FARSIGHT_AttacksRemainingSet")
					else
						TurnCounter.ClearTurnCounter("LLWEAPONEX_MB_Bow_Farsight", target)
						SignalTestComplete("BOW_FARSIGHT_AttacksEqualZero")
					end
				else
					TurnCounter.ClearTurnCounter("LLWEAPONEX_MB_Bow_Farsight", target)
					SignalTestComplete("BOW_FARSIGHT_FarsightRemoved")
				end
			end
		end
	end).BasicAttackStart(function(self, e, bonuses)
		if not TurnCounter.IsActive("LLWEAPONEX_MB_Bow_Farsight") then
			return
		end
		if e.TargetIsObject and CharacterIsAlly(e.Attacker.MyGuid, e.Target.MyGuid) == 0 then
			OnAttackStarting(self, e, bonuses, e.Attacker, e.Target)
		end
	end, true, "None").SkillUsed(function (self, e, bonuses)
		if not TurnCounter.IsActive("LLWEAPONEX_MB_Bow_Farsight") or string.find(e.Skill, "Quest") then
			return
		end
		local skillDamageMult = Ext.GetStat(e.Skill)["Damage Multiplier"] or 0
		if skillDamageMult <= 0 then
			return
		end
		if e.Data.TotalTargetObjects > 0 and not MasteryBonusManager.HasMasteryBonus(e.Character, self.ID) then
			local attackerGUID = e.Character.MyGuid
			e.Data:ForEach(function (target, _, _)
				if CharacterIsAlly(attackerGUID, target) == 0 then
					OnAttackStarting(self, e, bonuses, e.Character, GameHelpers.GetCharacter(target))
				end
			end, e.Data.TargetMode.Objects)
		end
	end, "None", "All").Test(function(test, self)
		local char1,char2,dummy,cleanup = MasteryTesting.CreateTwoTemporaryCharactersAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		local x,y,z = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(dummy, 10.0))
		local sword = CreateItemTemplateAtPosition("16600f2c-3817-42e7-be9d-5804f8ac77c8", x, y, z)
		TeleportToPosition(char1, x,y,z, "", 0, 1)
		test:Wait(250)
		CharacterEquipItem(char2, sword)
		CharacterAddSkill(char2, "Target_EnemyCripplingBlow", 0)
		CharacterAddSkill(char2, "Shout_EnemyWhirlwind", 0)
		TeleportTo(char2, dummy, "", 0, 1, 1)
		test:Wait(1000)
		GameHelpers.Status.Apply(char2, "WEB", -1, true, char2)
		SetFaction(char1, "PVP_1")
		SetFaction(dummy, "PVP_1")
		SetFaction(char2, "PVP_2")
		CharacterAddPreferredAiTargetTag(char2, "LLWEAPONEX_Test_Target")
		SetTag(dummy, "LLWEAPONEX_Test_Target")
		test:Wait(1000)
		SetCanJoinCombat(char1, 1)
		SetCanFight(char1, 1)
		SetCanJoinCombat(char2, 1)
		SetCanFight(char2, 1)
		SetCanJoinCombat(dummy, 1)
		SetCanFight(dummy, 1)
		EnterCombat(char1, char2)
		EnterCombat(dummy, char2)
		test:Wait(250)
		CharacterConsume(char2, "QUEST_Tea_Cup_Brand_A")
		JumpToTurn(char1)
		CharacterUseSkill(char1, self.Skills[2], char1, 1, 1, 1)
		test:WaitForSignal("BOW_FARSIGHT_FarsightCasted", 10000)
		test:AssertGotSignal("BOW_FARSIGHT_FarsightCasted")
		EndTurn(char1)
		test:Wait(250)
		JumpToTurn(char2)
		test:WaitForSignal("BOW_FARSIGHT_AttacksRemainingReduced", 3000)
		test:AssertGotSignal("BOW_FARSIGHT_AttacksRemainingReduced")
		test:WaitForSignal("BOW_FARSIGHT_AttacksRemainingDepleted", 30000)
		test:AssertGotSignal("BOW_FARSIGHT_AttacksRemainingDepleted")
		return true
	end),
})
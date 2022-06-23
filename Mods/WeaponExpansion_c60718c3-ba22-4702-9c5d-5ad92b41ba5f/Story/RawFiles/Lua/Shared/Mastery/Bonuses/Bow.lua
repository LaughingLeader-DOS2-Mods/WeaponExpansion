local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

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
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_PinDown", "Shoot <font color='#00FFAA'>[ExtraData:LLWEAPONEX_MB_Bow_PinDown_BonusShots]</font> additional arrow(s) at a nearby enemy for [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot].<br><font color='#F19824'>If no enemies are nearby, the bonus arrow(s) will fire at the original target.</font>"),
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
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_AssassinateMarked", "If the target is <font color='#FF3300'>Marked</font>, deal a <font color='#33FF33'>guaranteed critical hit</font> and bypass dodging/blocking. The mark is cleansed after hit."),
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
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 3, {
	rb:Create("BOW_EXPLOSIVE_RAIN", {
		Skills = {"ProjectileStrike_RainOfArrows", "ProjectileStrike_EnemyRainOfArrows"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_ExplosiveRain", "<font color='#72EE34'>[Special:LLWEAPONEX_MB_Bow_ExplosiveRainHitRange] random arrow(s) have a [ExtraData:LLWEAPONEX_MB_Bow_ExplosiveRain_ExplodeChance]% chance to explode, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Bow_ExplosiveRainDamage] in a [Projectile_LLWEAPONEX_MasteryBonus_Bow_ExplosiveRainDamage:ExplodeRadius]m radius.</font>"),
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
	end).SkillCast(function(self, e, bonuses)
		local strikeCount = Ext.StatGetAttribute("ProjectileStrike_RainOfArrows", "StrikeCount")
		local max = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_ExplosiveRain_MaxArrows", 5, true)
		if strikeCount > 0 and max > 0 then
			local min = math.max(0, GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_ExplosiveRain_MinArrows", 1, true))
			if min ~= max then
				local ran = Ext.Random(min, max)
				PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid] = {Total = strikeCount, Remaining = ran}
			else
				PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid] = {Total = strikeCount, Remaining = max}
			end
			Timer.StartObjectTimer("LLWEAPONEX_MB_Bow_ExplosiveRain_ClearData", e.Character, 3000)
		end
	end).SkillProjectileHit(function(self, e, bonuses)
		local data = PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid]
		if data then
			if data.Remaining > 0 then
				if data.Total > data.Remaining then
					local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_ExplosiveRain_ExplodeChance", 20, true)
					if GameHelpers.Math.Roll(chance, 2) then
						GameHelpers.Skill.Explode(e.Data.Position, "Projectile_LLWEAPONEX_MasteryBonus_Bow_ExplosiveRainDamage", e.Character, {CanDeflect=false,EnemiesOnly=true})
						data.Remaining = data.Remaining - 1
					end
				else
					GameHelpers.Skill.Explode(e.Data.Position, "Projectile_LLWEAPONEX_MasteryBonus_Bow_ExplosiveRainDamage", e.Character, {CanDeflect=false,EnemiesOnly=true})
				end
			end
			if data.Remaining <= 0 then
				PersistentVars.MasteryMechanics.BowExplosiveRainArrowCount[e.Character.MyGuid] = nil
			else
				data.Total = data.Total - 1
				Timer.RestartObjectTimer("LLWEAPONEX_MB_Bow_ExplosiveRain_ClearData", e.Character, 1000)
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
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 4, {
	
})
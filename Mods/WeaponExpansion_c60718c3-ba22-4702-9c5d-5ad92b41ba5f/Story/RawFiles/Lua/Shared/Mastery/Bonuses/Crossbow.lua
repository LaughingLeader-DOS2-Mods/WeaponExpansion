
local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _ISCLIENT = Ext.IsClient()

local _eqSet = "Class_Wayfarer_Lizards"

local function GetStillStanceBonus(character)
	local damageBonus = GameHelpers.GetExtraData("LLWEAPONEX_MB_Crossbow_SkillStanceRankBonus", 5.0)
	if damageBonus > 0 then
		local rank = Mastery.GetMasteryRank(character, MasteryID.Crossbow)
		if Vars.LeaderDebugMode then
			rank = 4
		end
		if rank > 0 then
			return math.ceil(damageBonus * rank)
		end
	end
	return 0
end

MasteryBonusManager.Vars.GetStillStanceBonus = GetStillStanceBonus

---@param skillID string
function MasteryBonusManager.Vars.IsStillStanceSkill(skillID)
	if skillID == "ActionAttackGround" then
		return true
	elseif GameHelpers.Skill.IsAction(skillID) then
		return false
	end
	local skill = Ext.Stats.Get(skillID, nil, false)
	if skill and skill.UseWeaponDamage == "Yes" and (skill.Requirement == "RangedWeapon" or skill.Requirement == "None") then
		return true
	end
	return false
end

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 1, {
	rb:Create("CROSSBOW_RICOCHET", {
		Skills = {"Projectile_Ricochet", "Projectile_EnemyRicochet"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_Ricochet", "<font color='#77FF33'>If each forked projectile hits, [Key:Projectile_Ricochet_DisplayName] is refreshed (once per turn).</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		local GUID = e.Character.MyGuid
		if e.Data.Success and ObjectGetFlag(GUID, "LLWEAPONEX_Crossbow_RicochetRefreshed") == 0 then
			local maxHits = e.Data.SkillData.ForkLevels + 1
			local ricoHits = PersistentVars.MasteryMechanics.CrossbowRicochetHits[GUID] or 0
			ricoHits = ricoHits + 1
			if ricoHits > maxHits then
				PersistentVars.MasteryMechanics.CrossbowRicochetHits[GUID] = nil
				GameHelpers.Skill.Refresh(e.Character, e.Skill)
				ObjectSetFlag(GUID, "LLWEAPONEX_Crossbow_RicochetRefreshed", 0)
			else
				PersistentVars.MasteryMechanics.CrossbowRicochetHits[GUID] = ricoHits
			end
			TurnCounter.ListenForTurnEnding(e.Character, "LLWEAPONEX_Crossbow_RicochetRefreshed")
		end
	end).TurnEnded("LLWEAPONEX_Crossbow_RicochetRefreshed", function(self, e, bonuses)
		ObjectClearFlag(e.Object.MyGuid, "LLWEAPONEX_Crossbow_RicochetRefreshed", 0)
	end, true),
	rb:Create("CROSSBOW_STILL_STANCE", {
		Skills = MasteryBonusManager.Vars.BasicAttack,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_StillStance", "<font color='#77FF33'>If you haven't moved since your last turn, deal [Special:LLWEAPONEX_Crossbow_SkillStanceDamageBonus]% more damage with basic attacks and weapon skills on the first attack.</font><br><font color='#FF6633'>This bonus does not trigger on your first turn in combat.</font>"),
		IsPassive = true,
		GetIsTooltipActive = function(bonus, id, character, tooltipType, status)
			if tooltipType == "skill" then
				if GameHelpers.CharacterOrEquipmentHasTag(character, "LLWEAPONEX_Crossbow_Equipped") then
					if id == "ActionAttackGround" then
						return MasteryBonusManager.Vars.GetStillStanceBonus(character) > 0
					elseif GameHelpers.Skill.IsAction(id) then
						return false
					end
					local skill = Ext.Stats.Get(id, nil, false)
					if skill and skill.UseWeaponDamage == "Yes" and (skill.Requirement == "RangedWeapon" or skill.Requirement == "None") then
						return MasteryBonusManager.Vars.GetStillStanceBonus(character) > 0
					end
				end
			end
			return false
		end
	}).Register.SpecialTooltipParam("LLWEAPONEX_Crossbow_SkillStanceDamageBonus", function (param, character)
		local damageBonus = MasteryBonusManager.Vars.GetStillStanceBonus(character.Character)
		if damageBonus > 0 then
			return string.format("%i", Ext.Utils.Round(damageBonus))
		end
		return "0"
	end).WeaponTagHit(MasteryID.Crossbow, function(self, e, bonuses)
		if e.Data.Success then
			local lastPos = PersistentVars.MasteryMechanics.StillStanceLastPosition[e.Attacker.MyGuid]
			if (lastPos and GameHelpers.Math.GetDistance(e.Attacker.WorldPos, lastPos) <= 0.01)
			or (Vars.LeaderDebugMode and not GameHelpers.Character.IsInCombat(e.Attacker.MyGuid))
			then
				PersistentVars.MasteryMechanics.StillStanceLastPosition[e.Attacker.MyGuid] = nil
				local damageBonus = MasteryBonusManager.Vars.GetStillStanceBonus(e.Attacker)
				if damageBonus > 0 then
					damageBonus = 1 + (damageBonus * 0.01)
					e.Data:MultiplyDamage(damageBonus)
				end
			end
		end
	end).Osiris("ObjectTurnStarted", 1, "after", function(char)
		local character = GameHelpers.GetCharacter(char)
		if character then
			local lastPos = PersistentVars.MasteryMechanics.StillStanceLastPosition[character.MyGuid]
			if (lastPos and GameHelpers.Math.GetDistance(character.WorldPos, lastPos) <= 0.01) then
				local rankName = StringHelpers.StripFont(GameHelpers.GetStringKeyText(Masteries.LLWEAPONEX_Crossbow.RankBonuses[1].Tag, "Crossbow I"))
				CombatLog.AddCombatText(Text.CombatLog.StillStanceEnabled:ReplacePlaceholders(GameHelpers.Character.GetDisplayName(character), rankName))
			end
		end
	end).Osiris("ObjectTurnEnded", 1, "after", function(char)
		local character = GameHelpers.GetCharacter(char)
		if character then
			PersistentVars.MasteryMechanics.StillStanceLastPosition[character.MyGuid] = {table.unpack(character.WorldPos)}
		end
	end).Osiris("ObjectLeftCombat", 1, "after", function(char)
		local character = GameHelpers.GetCharacter(char)
		if character then
			PersistentVars.MasteryMechanics.StillStanceLastPosition[character.MyGuid] = nil
		end
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 2, {
	rb:Create("CROSSBOW_SKYCRIT", {
		Skills = {"Projectile_SkyShot", "Projectile_EnemySkyShot"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_SkyShotCrit", "<font color='#77FF33'>If the target is affected by [Key:KNOCKED_DOWN_DisplayName], deal a critical hit.</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			if GameHelpers.Status.HasStatusType(e.Data.Target, "KNOCKED_DOWN") and not e.Data:HasHitFlag("CriticalHit", true) then
				local attackerStats = e.Character.Stats
				local critMultiplier = Game.Math.GetCriticalHitMultiplier(attackerStats.MainWeapon or attackerStats.OffHandWeapon)
				e.Data:SetHitFlag("CriticalHit", true)
				e.Data:MultiplyDamage(1 + critMultiplier)
			end
		end
	end),

	rb:Create("CROSSBOW_PINFANG", {
		Skills = {"Projectile_PiercingShot", "Projectile_EnemyPiercingShot"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_MarksmansFang", "<font color='#77FF33'>If a target is in front of impassable terrain (like a wall), pin them for 1 turn and deal [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Crossbow_PiercingShotPinDamage].</font>"),
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success and GameHelpers.Ext.ObjectIsCharacter(e.Data.TargetObject) then
			local startPos = e.Data.TargetObject.WorldPos
			local directionalVector = GameHelpers.Math.GetDirectionalVectorBetweenObjects(e.Data.TargetObject, e.Character, false)
			local level = Ext.Entity.GetCurrentLevel()
			local grid = level.AiGrid
			

			local isNextToWall = false

			local y = e.Character.WorldPos[2]

			---@type EsvItem[]
			local objects = {}
			local totalItems = 0

			for _,item in pairs(level.EntityManager.ItemConversionHelpers.RegisteredItems) do
				---@cast item EsvItem
				if not item.WalkOn and not item.OffStage and not item.CanShootThrough and Ext.Math.Distance(item.WorldPos, startPos) <= 3 then
					totalItems = totalItems + 1
					objects[totalItems] = item
				end
			end

			for i=0.5,1.5,0.5 do
				local x = (directionalVector[1] * i) + startPos[1]
				local z = (directionalVector[3] * i) + startPos[3]
				if not GameHelpers.Grid.IsValidPosition(x, z, grid) then
					isNextToWall = true
					break
				elseif totalItems > 0 then
					local checkPos = {x,0,z}
					--Pin if the position overlaps with a blocking object
					for i=1,totalItems do
						local v = objects[i]
						checkPos[2] = v.WorldPos[2]
						if Ext.Math.Distance(v.WorldPos, checkPos) <= (0.1 + v.AI.AIBoundsRadius) then
							isNextToWall = true
							break
						end
					end
				end
			end

			if isNextToWall then
				GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_Crossbow_PiercingShotPinDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
				GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_MB_CROSSOW_PINNED", 6.0, false, e.Character)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 3, {
	rb:Create("CROSSBOW_MARKEDSPRAY", {
		Skills = {"Projectile_ArrowSpray", "Projectile_EnemyArrowSpray"},
		Statuses = {"MARKED"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_MarkedSpray", "<font color='#77FF33'>Each arrow fired will seek your most recent [Key:MARKED_DisplayName:Marked] target with <font color='#FCD203'>uncanny accuracy</font>.<br>After casting, [Key:MARKED_DisplayName:Marked] will be cleansed.</font>"),
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_MarkedSprayStatus", "<font color='#77FF33'>Arrows fired from [Key:Projectile_ArrowSpray_DisplayName:Arrow Spray] will seek this target.</font>"),
		---@param self MasteryBonusData
		---@param id string
		---@param character EclCharacter
		---@param tooltipType MasteryBonusDataTooltipID
		---@param extraParam EclItem|EclStatus
		---@param tags table<string,boolean>|nil
		GetIsTooltipActive = function(self, id, character, tooltipType, extraParam, tags, itemHasSkill)
			if tooltipType == "status" then
				---@cast extraParam EclStatus
				if extraParam and GameHelpers.IsValidHandle(extraParam.StatusSourceHandle) then
					local source = GameHelpers.TryGetObject(extraParam.StatusSourceHandle)
					if GameHelpers.Ext.ObjectIsCharacter(source) then
						---@cast source EclCharacter
						if source and MasteryBonusManager.HasMasteryBonus(source, self.ID, false) then
							for _,skillId in pairs(self.Skills) do
								if source.SkillManager.Skills[skillId] then
									return true
								end
							end
						end
					end
				end
				return false
			end
		end
	}).Register.SkillProjectileBeforeShoot(function(self, e, bonuses)
		local markedTarget = PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID]
		if markedTarget then
			local target = GameHelpers.TryGetObject(markedTarget)
			if target and not GameHelpers.ObjectIsDead(target) then
				local dist = GameHelpers.Math.GetDistance(target, e.Character)
				if GetSettings().Global:FlagEquals("LLWEAPONEX_AllowUnlimitedCrossbowArrowSprayRange", false) then
					local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Crossbow_ArrowSpray_DistanceLimit", 0)
					if maxDistance > 0 and dist > maxDistance then
						return
					end
				end
				e.Data.IgnoreObjects = true
				e.Data.Target = target.Handle
				local pos = {table.unpack(target.WorldPos)}
				pos[2] = pos[2] + (target.AI.AIBoundsHeight / 2)
				e.Data.EndPosition = pos

				local angle = GameHelpers.Math.GetRelativeAngle(e.Character, target)
				local forceHit = dist >= 30 or ((angle >= 120 and angle <= 210) or CharacterCanSee(e.CharacterGUID, target.MyGuid) == 0)
				--Target is behind the caster or can't see them
				if e.Data.HitObject and forceHit then
					e.Data.HitObject.Target = target.Handle
					e.Data.HitObject.Position = pos
					local spos = e.Data.StartPosition
					spos[2] = spos[2] + 20
					e.Data.StartPosition = spos
					--e.Data.HitObject.HitInterpolation = 30
				end
			else
				PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID] = nil
			end
			if Vars.DebugMode then
				Timer.Cancel("CROSSBOW_MARKEDSPRAY_SignalComplete")
				Timer.StartOneshot("CROSSBOW_MARKEDSPRAY_SignalComplete", 250, function (e)
					SignalTestComplete("CROSSBOW_MARKEDSPRAY")
				end)
			else
				SignalTestComplete(self.ID)
			end
		end
	end).SkillProjectileShoot(function (self, e, bonuses)
		local markedTarget = PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID]
		if markedTarget then
			e.Data.IgnoreRoof = true
			e.Data.ForceTarget = true

			local followCameraCharacter = nil
			if Vars.DebugMode and e.Character:HasTag("LLWEAPONEX_MasteryTestCharacter") then
				followCameraCharacter = GameHelpers.Character.GetHost()
			elseif GameHelpers.Character.IsPlayer(e.Character) and GameHelpers.Math.GetDistance(e.Character, markedTarget) >= 25 then
				followCameraCharacter = e.Character
			end
			if followCameraCharacter then
				local user = GameHelpers.GetUserID(followCameraCharacter)
				local projectile = e.Data.NetID
				Ext.OnNextTick(function (e)
					GameHelpers.Net.PostToUser(user, "LLWEAPONEX_Crossbow_MarkedSpray_FollowProjectile", tostring(projectile))
				end)
			end
		end
	end).SkillCast(function (self, e, bonuses)
		local markedTarget = PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID]
		if markedTarget then
			CharacterSetForceSynch(markedTarget, 1)
			Timer.StartObjectTimer("LLWEAPONEX_MarkedSpray_Cleanse", e.Character, 2000, {Target=markedTarget})
		end
	end).TimerFinished("LLWEAPONEX_MarkedSpray_Cleanse", function(self, e, bonuses)
		local markedTarget = PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.Data.UUID]
		if markedTarget == e.Data.Target then
			PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.Data.UUID] = nil
			if GameHelpers.ObjectExists(markedTarget) then
				GameHelpers.Status.Remove(markedTarget, "MARKED")
				CharacterSetForceSynch(markedTarget, 0)
			end
		end
	end, "None").StatusApplied(function (self, e, bonuses)
		PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.SourceGUID] = e.TargetGUID
	end, "Source").StatusRemoved(function (self, e, bonuses)
		for source,target in pairs(PersistentVars.MasteryMechanics.CrossbowMarkedTarget) do
			if target == e.TargetGUID then
				PersistentVars.MasteryMechanics.CrossbowMarkedTarget[source] = nil
			end
		end
	end, "None").Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = function()
			cleanup()
			PersistentVars.MasteryMechanics.CrossbowMarkedTarget[char] = nil
		end
		test:Wait(250)
		if SharedData.RegionData.Current == "FJ_FortJoy_Main" then
			GameHelpers.Utils.SetPosition(dummy, {217.97674560546875,-1.75,195.25508117675781})
			GameHelpers.Utils.SetPosition(char, {166.34489440917969,4.75,203.94488525390625})
		else
			--local dist = Ext.Stats.Get(self.Skills[1]).TargetRadius - 0.5)
			local x,y,z = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(dummy, 50))
			TeleportToPosition(char, x,y,z, "", 0, 1)
		end

		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		ApplyStatus(dummy, "MARKED", -1, 1, char)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		test:Wait(1000)
		return true
	end),
	rb:Create("CROSSBOW_SHATTERINGSNIPE", {
		Skills = {"Projectile_Snipe", "Projectile_EnemySnipe"},
		_ArmorSystemTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_ShatteringSnipe", "<font color='#77FF33'>If attacking a target with no armor, or if the hit would result in no armor, the bolt rupture's the target's insides, deal an additional [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Crossbow_RuptureDamage] and applying or extending <font color='#FF0000'>[Key:BLEEDING_DisplayName] for 1 turn</font>.</font>"),
		_NoArmorSystemTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_ShatteringSnipe_NoArmor", "<font color='#77FF33'>If dealing over [ExtraData:LLWEAPONEX_MB_Crossbow_NoArmorSystem_DamageThreshold:25]% of the target's [Handle:h068a4744gf811g42b4ga8b1g29a9c62c13fc:Maximum Vitality], deal an additional [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Crossbow_RuptureDamage] and applying or extending <font color='#FF0000'>[Key:BLEEDING_DisplayName] for 1 turn.</font>"),
		OnGetTooltip = function (self, id, character, tooltipType, ...)
			if not ArmorSystemIsDisabled() then
				return self._ArmorSystemTooltip
			else
				return self._NoArmorSystemTooltip
			end
		end,
	}).Register.SkillHit(function(self, e, bonuses)
		local target = e.Data.TargetObject
		if not ArmorSystemIsDisabled() then
			local ma = target.Stats.MaxMagicArmor
			local pa = target.Stats.MaxArmor

			local totalArmorDamage = 0
			local totalMagicArmorDamage = 0

			for _,v in pairs(e.Data.DamageList:ToTable()) do
				if v.Amount > 0 then
					local damageArmorType = Data.DamageTypeToArmorType[v.DamageType]
					if damageArmorType == "CurrentArmor" then
						totalArmorDamage = totalArmorDamage + v.Amount
					elseif damageArmorType == "CurrentMagicArmor" then
						totalMagicArmorDamage = totalMagicArmorDamage + v.Amount
					elseif v.DamageType == "Chaos" then
						--Count it for both, with a reduced amount, since it could really end up as anything
						totalArmorDamage = totalArmorDamage + math.floor(v.Amount * 0.5)
						totalMagicArmorDamage = totalMagicArmorDamage + math.floor(v.Amount * 0.5)
					elseif v.DamageType == "Sulfuric" then
						if target.Stats.MagicalSulfur then
							totalMagicArmorDamage = totalMagicArmorDamage + v.Amount
						else
							totalArmorDamage = totalArmorDamage + v.Amount
						end
					end
				end
			end

			if totalArmorDamage >= pa or totalMagicArmorDamage >= ma then
				GameHelpers.Damage.ApplySkillDamage(e.Character, target, "Projectile_LLWEAPONEX_MasteryBonus_Crossbow_RuptureDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
				GameHelpers.Status.ExtendTurns(target, "BLEEDING", 1, true, true)
			end
		else
			local threshold = GameHelpers.GetExtraData("LLWEAPONEX_MB_Crossbow_NoArmorSystem_DamageThreshold", 25)
			if threshold > 0 then
				local vitAmount = math.ceil(target.Stats.MaxVitality * (threshold * 0.01))
				if e.Data.Damage > vitAmount then
					GameHelpers.Damage.ApplySkillDamage(e.Character, target, "Projectile_LLWEAPONEX_MasteryBonus_Crossbow_RuptureDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
					GameHelpers.Status.ExtendTurns(target, "BLEEDING", 1, true, true)
				end
			end
		end
		SignalTestComplete(self.ID)
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		ApplyStatus(dummy, "MARKED", -1, 1, char)
		test:Wait(1000)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		test:Wait(1000)
		return true
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 4, {
	rb:Create("CROSSBOW_PIERCING_PROJECTILE", {
		AllSkills = true,
		---@param self MasteryBonusData
		---@param id string
		---@param character EclCharacter
		---@param tooltipType MasteryBonusDataTooltipID
		---@param extraParam EclItem|EclStatus
		---@param tags table<string,boolean>|nil
		GetIsTooltipActive = function(self, id, character, tooltipType, extraParam, tags, itemHasSkill)
			if tooltipType == "skill" and MasteryBonusManager.Vars.CrossbowProjectilePiercingSkills[id] then
				return true
			end
			return false
		end,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_PiercingProjectiles", "<font color='#77FF33'>Non-piercing [Handle:h87b42cabg950ag4e52g802dg9fc6aa755f5e:Ranged Weapon] skills will pierce the first target hit.</font>"),
		IsPassive = true,
	}).Register.SkillCast(function (self, e, bonuses)
		if MasteryBonusManager.Vars.CrossbowProjectilePiercingSkills[e.Skill] then
			--This is to ensure the skill is being cast, so we don't make explosions pierce
			if PersistentVars.MasteryMechanics.CrossbowCastingPiercingSkill[e.Skill] == nil then
				PersistentVars.MasteryMechanics.CrossbowCastingPiercingSkill[e.Skill] = {}
			end
			PersistentVars.MasteryMechanics.CrossbowCastingPiercingSkill[e.Skill][e.Character.MyGuid] = {table.unpack(e.Character.WorldPos)}
		end
	end).SkillProjectileHit(function (self, e, bonuses)
		local pbdata = PersistentVars.MasteryMechanics.CrossbowCastingPiercingSkill[e.Skill]
		if pbdata and pbdata[e.Character.MyGuid] then
			--local originalPos = {table.unpack(pbdata[e.Character.MyGuid])}
			pbdata[e.Character.MyGuid] = nil
			if not Common.TableHasAnyEntry(pbdata) then
				PersistentVars.MasteryMechanics.CrossbowCastingPiercingSkill[e.Skill] = nil
			end

			local originalPos = e.Data.Projectile.SourcePosition
			local skillData = Ext.Stats.Get(e.Skill, nil, false)
			local x,y,z = table.unpack(e.Data.Position)
			local dist = math.max(1, math.ceil(skillData.TargetRadius / 2))
			local dir = GameHelpers.Math.GetDirectionalVector(originalPos, e.Data.Position)
			local castPos = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Character, 1.2, x, y, z, dir)
			local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Character, dist, x, y, z, dir)
			pos[2] = y
			castPos[2] = y + 1

			--Make the piercing projectile prioritize hitting an enemy within a small radius of the end position
			local nearbyEnemies = GameHelpers.Grid.GetNearbyObjects(e.Character, {Radius=2.5, Position=pos, Relation={Enemy=true}, AsTable=true, Type="Character", Sort="Distance"})

			---@cast nearbyEnemies EsvCharacter[]
			if nearbyEnemies[1] then
				local obj = nearbyEnemies[1] 
				pos = GameHelpers.Math.GetPosition(obj)
				pos[2] = pos[2] + (obj.RootTemplate.AIBoundsHeight * 0.6)
			end

			GameHelpers.Skill.ShootProjectileAt(pos, e.Skill, e.Character, {
				EnemiesOnly=true,
				Caster=e.Character,
				Target="nil",
				Source="nil",
				SourcePosition=castPos,
			})
			SignalTestComplete(self.ID)
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
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
	rb:Create("CROSSBOW_REACTIVE_TRAPPER", {
		Skills = {"Target_ReactionShot", "Target_EnemyReactionShot"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_ReactiveShot", "<font color='#77FF33'>After casting, automatically apply [Key:INVISIBLE_DisplayName:Invisible] for [ExtraData:LLWEAPONEX_MB_Crossbow_ReactiveShot_InvisibleTurns:1] turn(s), and throw a <font color='#CE7964'>[Handle:hc8d093e1g6201g4b5dgb199gca172eaedb7d:Tar Trap]</font> at the target location.<br>When exploded, the <font color='#CE7964'>[Handle:hc8d093e1g6201g4b5dgb199gca172eaedb7d:Tar Trap]</font> slows movement in a [Stats:Projectile_LLWEAPONEX_Crossbow_ReactiveShotTrap:ExplodeRadius]m radius, dealing [SkillDamage:Projectile_LLWEAPONEX_Crossbow_ReactiveShotTrap_Damage]."),
	}).Register.SkillCast(function(self, e, bonuses)
		local pos = GameHelpers.Grid.GetValidPositionTableInRadius(e.Data:GetSkillTargetPosition(), 10.0)
		--Make Source "nil" so it doesn't rotate to the player's facing direction, which can mess with the projectile path
		GameHelpers.Skill.ShootProjectileAt(pos, "Projectile_LLWEAPONEX_Crossbow_ReactiveShotTrap", e.Character, {SourceOffset={0,2,0}, Source="nil"})
		local turns = GameHelpers.GetExtraData("LLWEAPONEX_MB_Crossbow_ReactiveShot_InvisibleTurns", 1, true)
		if turns > 0 then
			GameHelpers.Status.Apply(e.Character, "INVISIBLE", turns * 6, false, e.Character)
		end
		SignalTestComplete(self.ID)
	end).Test(function(test, self)
		local summonChangedEventIndex = nil
		local trap = nil
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = function()
			cleanup()
			if summonChangedEventIndex ~= nil then
				Events.SummonChanged:Unsubscribe(summonChangedEventIndex)
			end
			if trap ~= nil and ObjectExists(trap) == 1 then
				ItemRemove(trap)
			end
		end
		test:Wait(250)
		local x,y,z = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(dummy, 10.0))
		TeleportToPosition(char, x,y,z, "", 0, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		summonChangedEventIndex = Events.SummonChanged:Subscribe(function (e)
			if e.IsItem and e.Owner.MyGuid == char then
				trap = e.Summon.MyGuid
			end
		end)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		local turns = GameHelpers.GetExtraData("LLWEAPONEX_MB_Crossbow_ReactiveShot_InvisibleTurns", 1, true)
		if turns > 0 then
			test:Wait(500)
			test:AssertEquals(HasActiveStatus(char, "INVISIBLE") == 1, true, "INVISIBLE not applied to caster")
		end
		test:Wait(500)
		test:AssertEquals(trap ~= nil, true, "Tar Trap was not created.")
		test:Wait(5000)
		return true
	end),
})

if not _ISCLIENT then
	Mastery.Events.MasteryChanged:Subscribe(function (e)
		if not e.Enabled then
			PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID] = nil
		end
	end, {MatchArgs={ID=MasteryID.Crossbow}})
else
	---@type ComponentHandle|nil
	local _trackingProjectileHandle = nil
	local _tickListenerIndex = nil

	local function _GetProjectile()
		local projectile = Ext.Entity.GetProjectile(_trackingProjectileHandle)
		if projectile then
			return projectile
		end
		local level = Ext.ClientEntity.GetCurrentLevel()
		for id,v in pairs(level.EntityManager.ProjectileConversionHelpers.RegisteredProjectiles[level.LevelDesc.LevelName]) do
			if v.Handle == _trackingProjectileHandle then
				return v
			end
		end
		return nil
	end

	---@param e LuaTickEvent
	local function _FollowProjectile(e)
		if Ext.Client.GetGameState() ~= "Running" then
			return
		end
		local projectile = _GetProjectile()
		if projectile then
			GameHelpers.Utils.SetPlayerCameraPosition(Client:GetCharacter(), {CurrentLookAt=projectile.Translate, TargetLookAt=projectile.Translate})
		else
			Ext.Events.Tick:Unsubscribe(_tickListenerIndex)
			_trackingProjectileHandle = nil
			Timer.StartOneshot("", 3000, function (_)
				_tickListenerIndex = nil
			end)
		end
	end

	--local level = Ext.ClientEntity.GetCurrentLevel(); Ext.IO.SaveFile("Dumps/Projectiles_Client.json", Ext.DumpExport(level.EntityManager.ProjectileConversionHelpers.RegisteredProjectiles[level.LevelDesc.LevelName]))

	Ext.RegisterNetListener("LLWEAPONEX_Crossbow_MarkedSpray_FollowProjectile", function (channel, payload, user)
		if _tickListenerIndex == nil then
			local netid = tonumber(payload)
			local projectile = Ext.Entity.GetProjectile(netid)
			if not projectile then
				Ext.Utils.PrintError("Failed to get projectile for NetID", netid)
				local level = Ext.ClientEntity.GetCurrentLevel()
				for id,v in pairs(level.EntityManager.ProjectileConversionHelpers.RegisteredProjectiles[level.LevelDesc.LevelName]) do
					if v.NetID == netid then
						projectile = v
						break
					end
				end
			end
			if projectile then
				Ext.Utils.Print("Found projectile", projectile.NetID)
				_trackingProjectileHandle = projectile.Handle
				_tickListenerIndex = Ext.Events.Tick:Subscribe(_FollowProjectile)
			end
		end
	end)
end

--Ext.IO.SaveFile("Dumps/Projectiles_Client.json", Ext.DumpExport(level.EntityManager.ProjectileConversionHelpers.RegisteredProjectiles[level.LevelDesc.LevelName]))
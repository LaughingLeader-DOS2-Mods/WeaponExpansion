
local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local _ISCLIENT = Ext.IsClient()

local _eqSet = "Class_Ranger_Humans"

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
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_StillStance", "<font color='#77FF33'>If you haven't moved, deal [Special:LLWEAPONEX_Crossbow_SkillStanceDamageBonus]% more damage with basic attacks or weapon skills.</font>"),
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
			PersistentVars.MasteryMechanics.StillStanceLastPosition[character.MyGuid] = {table.unpack(character.WorldPos)}
			local rankName = StringHelpers.StripFont(GameHelpers.GetStringKeyText(Masteries.LLWEAPONEX_Crossbow.RankBonuses[1].Tag, "Crossbow I"))
			CombatLog.AddCombatText(Text.CombatLog.StillStanceEnabled:ReplacePlaceholders(GameHelpers.Character.GetDisplayName(character), rankName))
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
		if e.Data.Success and ObjectIsCharacter(e.Data.Target) == 1 then
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
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_MarkedSpray", "<font color='#77FF33'>Each bolt fired will seek your [Key:MARKED_DisplayName] target.<br>If no targets have been [Key:MARKED_DisplayName] by you, the cooldown of [Key:Projectile_Mark_DisplayName:Glitter Dust] is reduced by 1 turn.</font>"),
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_MarkedSprayStatus", "<font color='#77FF33'>Arrows fired from [Key:Projectile_ArrowSpray_DisplayName:Arrow Spray] will seek to this target.</font>"),
		---@param self MasteryBonusData
		---@param id string
		---@param character EclCharacter
		---@param tooltipType MasteryBonusDataTooltipID
		---@param extraParam EclItem|EclStatus
		---@param tags table<string,boolean>|nil
		GetIsTooltipActive = function(self, id, character, tooltipType, extraParam, tags, itemHasSkill)
			if tooltipType == "status" then
				---@cast extraParam EclStatus
				if GameHelpers.IsValidHandle(extraParam.StatusSourceHandle) then
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
	}).Register.SkillProjectileShoot(function(self, e, bonuses)
		local markedTarget = PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID]
		if markedTarget then
			local target = GameHelpers.TryGetObject(markedTarget)
			if target and not GameHelpers.ObjectIsDead(target) then
				e.Data.TargetObjectHandle = target.Handle
				e.Data.TargetPosition = target.WorldPos
				e.Data.ForceTarget = true
				--e.Data.HitObjectHandle = target.Handle
			else
				PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID] = nil
			end
		end
	end).SkillCast(function (self, e, bonuses)
		if PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID] == nil then
			for _,id in pairs(self.Skills) do
				local skillData = e.Character.SkillManager.Skills[id]
				if skillData and skillData.ActiveCooldown > 0 and skillData.ActiveCooldown < 60 then
					local cd = math.max(0, skillData.ActiveCooldown - 6.0)
					skillData.ActiveCooldown = cd
				end
			end
		end
	end).StatusApplied(function (self, e, bonuses)
		PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.SourceGUID] = e.TargetGUID
	end, "Source").StatusRemoved(function (self, e, bonuses)
		for source,target in pairs(PersistentVars.MasteryMechanics.CrossbowMarkedTarget) do
			if target == e.TargetGUID then
				PersistentVars.MasteryMechanics.CrossbowMarkedTarget[source] = nil
			end
		end
	end, "None").Test(function(test, self)
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
					if damageArmorType == "Armor" then
						totalArmorDamage = totalArmorDamage + v.Amount
					elseif damageArmorType == "MagicArmor" then
						totalMagicArmorDamage = totalMagicArmorDamage + v.Amount
					elseif v.DamageType == "Chaos" then
						--Count it for both, with a reduced amount, since it could really end up as anything
						totalArmorDamage = totalArmorDamage + math.floor(v.Amount * 0.5)
						totalMagicArmorDamage = totalMagicArmorDamage + math.floor(v.Amount * 0.5)
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
	end).SkillCast(function (self, e, bonuses)
		if PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID] == nil then
			for _,id in pairs(self.Skills) do
				local skillData = e.Character.SkillManager.Skills[id]
				if skillData and skillData.ActiveCooldown > 0 and skillData.ActiveCooldown < 60 then
					local cd = math.max(0, skillData.ActiveCooldown - 6.0)
					skillData.ActiveCooldown = cd
				end
			end
		end
	end).StatusApplied(function (self, e, bonuses)
		PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.SourceGUID] = e.TargetGUID
	end, "Source").StatusRemoved(function (self, e, bonuses)
		for source,target in pairs(PersistentVars.MasteryMechanics.CrossbowMarkedTarget) do
			if target == e.TargetGUID then
				PersistentVars.MasteryMechanics.CrossbowMarkedTarget[source] = nil
			end
		end
	end, "None").Test(function(test, self)
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
	
})

if not _ISCLIENT then
	Mastery.Events.MasteryChanged:Subscribe(function (e)
		if not e.Enabled then
			PersistentVars.MasteryMechanics.CrossbowMarkedTarget[e.CharacterGUID] = nil
		end
	end, {MatchArgs={ID=MasteryID.Crossbow}})
end
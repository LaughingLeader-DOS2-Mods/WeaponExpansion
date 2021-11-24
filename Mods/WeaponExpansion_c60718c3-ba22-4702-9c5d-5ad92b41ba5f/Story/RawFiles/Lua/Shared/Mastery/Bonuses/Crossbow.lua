
local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

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

Mastery.Variables.Bonuses.GetStillStanceBonus = GetStillStanceBonus

local function IsStillStanceSkill(skill)
	if skill == "ActionAttackGround" then
		return true
	elseif LeaderLib.Data.ActionSkills[skill] then
		return false
	end
	local skill = Ext.GetStat(skill)
	if skill and skill.UseWeaponDamage == "Yes" and (skill.Requirement == "RangedWeapon" or skill.Requirement == "None") then
		return true
	end
	return false
end

Mastery.Variables.Bonuses.IsStillStanceSkill = IsStillStanceSkill

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 1, {
	rb:Create("CROSSBOW_RICOCHET", {
		Skills = {"Projectile_Ricochet", "Projectile_EnemyRicochet"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_Ricochet", "<font color='#77FF33'>If each forked projectile hits, [Key:Projectile_Ricochet_DisplayName] is refreshed (once per turn).</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success and ObjectGetFlag(char, "LLWEAPONEX_Crossbow_RicochetRefreshed") == 0 then
			local maxHits = Ext.StatGetAttribute(skill, "ForkLevels") + 1
			if not PersistentVars.MasteryMechanics.CrossbowRicochetHits[char] then
				PersistentVars.MasteryMechanics.CrossbowRicochetHits[char] = 0
			end
			PersistentVars.MasteryMechanics.CrossbowRicochetHits[char] = PersistentVars.MasteryMechanics.CrossbowRicochetHits[char] + 1
			if PersistentVars.MasteryMechanics.CrossbowRicochetHits[char] > maxHits then
				PersistentVars.MasteryMechanics.CrossbowRicochetHits[char] = nil
				GameHelpers.Skill.Refresh(char, skill)
				ObjectSetFlag(char, "LLWEAPONEX_Crossbow_RicochetRefreshed", 0)
			end
			TurnCounter.ListenForTurnEnding(char, "LLWEAPONEX_Crossbow_RicochetRefreshed")
		end
	end):RegisterTurnEndedListener("LLWEAPONEX_Crossbow_RicochetRefreshed", function(char, id)
		ObjectClearFlag(char, "LLWEAPONEX_Crossbow_RicochetRefreshed", 0)
	end, true),
	rb:Create("CROSSBOW_STILL_STANCE", {
		AllSkills = true,
		--[[ Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_StillStance", "<font color='#77FF33'>If you haven't moved, deal [Special:LLWEAPONEX_Crossbow_SkillStanceDamageBonus]% more damage.</font>"),
		GetIsTooltipActive = function(bonus, id, character, tooltipType, status)
			if tooltipType == "skill" then
				if GameHelpers.CharacterOrEquipmentHasTag(character.MyGuid, "LLWEAPONEX_Crossbow_Equipped") then
					if id == "ActionAttackGround" then
						return GetStillStanceBonus(character.MyGuid) > 0
					elseif LeaderLib.Data.ActionSkills[id] then
						return false
					end
					local skill = Ext.GetStat(id)
					if skill and skill.UseWeaponDamage == "Yes" and (skill.Requirement == "RangedWeapon" or skill.Requirement == "None") then
						return GetStillStanceBonus(character.MyGuid) > 0
					end
				end
			end
			return false
		end ]]
	}):RegisterOnWeaponTagHit(MasteryID.Crossbow, function(tag, source, target, data, bonuses, isFromHit, isFromSkill)
		if data.Success then
			local lastPos = PersistentVars.MasteryMechanics.StillStanceLastPosition[source.MyGuid]
			if (lastPos and GameHelpers.Math.GetDistance(source.WorldPos, lastPos) <= 0.01)
			or (Vars.LeaderDebugMode and CharacterIsInCombat(source.MyGuid) == 0)
			then
				local damageBonus = GetStillStanceBonus(source)
				if damageBonus > 0 then
					damageBonus = 1 + (damageBonus * 0.01)
					data:MultiplyDamage(damageBonus)
					local rankName = StringHelpers.StripFont(GameHelpers.GetStringKeyText(Masteries.LLWEAPONEX_Crossbow.RankBonuses[1].Tag, "Crossbow I"))
					CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, Text.CombatLog.StillStanceEnabled:ReplacePlaceholders(source.DisplayName, rankName))
				end
			end
		end
	end):RegisterOsirisListener("ObjectTurnStarted", 1, "after", function(char)
		local character = GameHelpers.GetCharacter(char)
		if character then
			PersistentVars.MasteryMechanics.StillStanceLastPosition[character.MyGuid] = TableHelpers.Clone(character.WorldPos)
			local rankName = StringHelpers.StripFont(GameHelpers.GetStringKeyText(Masteries.LLWEAPONEX_Crossbow.RankBonuses[1].Tag, "Crossbow I"))
			CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, Text.CombatLog.StillStanceEnabled:ReplacePlaceholders(character.DisplayName, rankName))
		end
	end)
})

if Vars.IsClient then
	TooltipHandler.SpecialParamFunctions.LLWEAPONEX_Crossbow_SkillStanceDamageBonus = function(param, statCharacter)
		local damageBonus = GetStillStanceBonus(statCharacter.MyGuid)
		if damageBonus > 0 then
			return tostring(damageBonus)
		end
		return "0"
	end
end

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 2, {
	rb:Create("CROSSBOW_SKYCRIT", {
		Skills = {"Projectile_SkyShot", "Projectile_EnemySkyShot"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_SkyShotCrit", "<font color='#77FF33'>If the target is affected by [Key:KNOCKED_DOWN_DisplayName], deal a critical hit.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			if GameHelpers.Status.HasStatusType(data.Target, "KNOCKED_DOWN") and not data:HasHitFlag("CriticalHit", true) then
				local attackerStats = GameHelpers.GetCharacter(char).Stats
				local critMultiplier = Game.Math.GetCriticalHitMultiplier(attackerStats.MainWeapon or attackerStats.OffHandWeapon)
				data:SetHitFlag("CriticalHit", true)
				data:MultiplyDamage(1 + critMultiplier)
			end
		end
	end),

	rb:Create("CROSSBOW_PINFANG", {
		Skills = {"Projectile_PiercingShot", "Projectile_EnemyPiercingShot"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Crossbow_MarksmansFang", "<font color='#77FF33'>If a target is in front of impassable terrain (like a wall), pin them for 1 turn and deal [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Crossbow_PiercingShotPinDamage].</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success and ObjectIsCharacter(data.Target) == 1 then
			local attacker = Ext.GetCharacter(char)
			local startPos = data.TargetObject.WorldPos
			local directionalVector = GameHelpers.Math.GetDirectionalVectorBetweenObjects(data.TargetObject, attacker, false)
			local grid = Ext.GetAiGrid()

			local isNextToWall = false

			local y = attacker.WorldPos[2]

			---@type EsvItem[]
			local objects = {}

			for i,v in pairs(Ext.GetAllItems()) do
				if GetDistanceToPosition(v, startPos[1], startPos[2], startPos[3]) <= 3 then
					objects[#objects+1] = Ext.GetItem(v)
				end
			end

			for i=1,2.5,0.5 do
				local x = (directionalVector[1] * i) + startPos[1]
				local z = (directionalVector[3] * i) + startPos[3]
				if not GameHelpers.Grid.IsValidPosition(x, z, grid) then
					isNextToWall = true
					break
				else
					--Pin if the position overlaps with a blocking object
					for i,v in pairs(objects) do
						if GetDistanceToPosition(v.MyGuid, x, v.WorldPos[2], z) <= (0.1 + v.RootTemplate.AIBoundsRadius) then
							if not v.WalkOn then
								isNextToWall = true
								break
							end
						end
					end
				end
			end

			if isNextToWall then
				GameHelpers.Damage.ApplySkillDamage(attacker, data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_Crossbow_PiercingShotPinDamage", HitFlagPresets.GuaranteedWeaponHit)
				GameHelpers.Status.Apply(data.TargetObject, "LLWEAPONEX_MB_CROSSOW_PINNED", 6.0, 0, attacker)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 4, {
	
})
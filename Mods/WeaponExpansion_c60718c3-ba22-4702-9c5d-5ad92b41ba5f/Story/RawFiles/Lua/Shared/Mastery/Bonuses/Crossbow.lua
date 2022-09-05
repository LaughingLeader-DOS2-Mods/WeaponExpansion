
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
					local skill = Ext.GetStat(id)
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
			return string.format("%i", Ext.Round(damageBonus))
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
			local GUID = character.MyGuid
			PersistentVars.MasteryMechanics.StillStanceLastPosition[GUID] = {table.unpack(character.WorldPos)}
			local rankName = StringHelpers.StripFont(GameHelpers.GetStringKeyText(Masteries.LLWEAPONEX_Crossbow.RankBonuses[1].Tag, "Crossbow I"))
			CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, Text.CombatLog.StillStanceEnabled:ReplacePlaceholders(GameHelpers.Character.GetDisplayName(character), rankName))
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
			local grid = Ext.GetAiGrid()

			local isNextToWall = false

			local y = e.Character.WorldPos[2]

			---@type EsvItem[]
			local objects = {}

			for i,v in pairs(Ext.GetAllItems()) do
				if GetDistanceToPosition(v, startPos[1], startPos[2], startPos[3]) <= 3 then
					objects[#objects+1] = Ext.GetItem(v)
				end
			end

			for i=0.5,1.5,0.5 do
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
				GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_Crossbow_PiercingShotPinDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
				GameHelpers.Status.Apply(e.Data.TargetObject, "LLWEAPONEX_MB_CROSSOW_PINNED", 6.0, false, e.Character)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Crossbow, 4, {
	
})
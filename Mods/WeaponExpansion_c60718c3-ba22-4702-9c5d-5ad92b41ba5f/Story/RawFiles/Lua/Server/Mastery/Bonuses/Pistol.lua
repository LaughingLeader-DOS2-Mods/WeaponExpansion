MasteryBonusManager.RegisterSkillListener({"Shout_Adrenaline", "Shout_EnemyAdrenaline"}, "PISTOL_ADRENALINE", function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.CAST then
		SetTag(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
		CharacterStatusText(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
	end
end)

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
MasteryBonusManager.RegisterSkillListener(Mastery.Bonuses.LLWEAPONEX_Pistol_Mastery1.PISTOL_CLOAKEDJUMP.Skills, "PISTOL_CLOAKEDJUMP", function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		if CharacterHasSkill(char, "Shout_LLWEAPONEX_Pistol_Reload") == 1 then
			LeaderLib.SwapSkill(char, "Shout_LLWEAPONEX_Pistol_Reload", "Projectile_LLWEAPONEX_Pistol_Shoot")
		end
		if CharacterIsInCombat(char) == 1 then
			LeaderLib.StartTimer("LLWEAPONEX_MasteryBonus_CloakAndDagger_Pistol_MarkEnemy", 1000, char)
		end
	end
end)

local function CloakAndDagger_Pistol_MarkEnemy(timerData)
	local char = timerData[1]
	if char ~= nil and CharacterIsInCombat(char) == 1 then
		local data = Osi.DB_CombatCharacters:Get(nil, CombatGetIDForCharacter(char))
		if data ~= nil then
			local totalEnemies = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_CloakAndDagger_MaxMarkedTargets", 1)
			local maxDistance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_CloakAndDagger_MarkingRadius", 6.0)
			local combatEnemies = LeaderLib.Common.ShuffleTable(data)
			local lastDist = 999
			local targets = {}
			for i,v in pairs(combatEnemies) do
				local enemy = v[1]
				if enemy ~= char 
				and CharacterIsEnemy(char, enemy) == 1 
				and CharacterIsDead(enemy) == 0 
				and not GameHelpers.Status.IsSneakingOrInvisible(enemy) 
				and HasActiveStatus(enemy, "MARKED") == 0
				then
					local dist = GetDistanceTo(char,enemy)
					if dist <= maxDistance then
						if totalEnemies == 1 then
							if dist < lastDist then
								targets[1] = enemy
							end
						else
							table.insert(targets, {Dist = dist, UUID = enemy})
						end
						lastDist = dist
					end
				end
			end
			if #targets > 1 then
				table.sort(targets, function(a,b)
					return a.Dist < b.Dist
				end)
				for i,v in pairs(targets) do
					local target = v.UUID
					ApplyStatus(target, "MARKED", 6.0, 0, char)
					SetTag(target, "LLWEAPONEX_Pistol_MarkedForCrit")
					Osi.LLWEAPONEX_Statuses_ListenForTurnEnding(char, target, "MARKED", "")
					totalEnemies = totalEnemies - 1
					if totalEnemies <= 0 then
						break
					end
				end
			elseif targets[1] ~= nil then
				local target = targets[1]
				ApplyStatus(target, "MARKED", 6.0, 0, char)
				SetTag(target, "LLWEAPONEX_Pistol_MarkedForCrit")
				Osi.LLWEAPONEX_Statuses_ListenForTurnEnding(char, target, "MARKED", "")
			end
		end
	else
		printd("CloakAndDagger_Pistol_MarkEnemy params: "..LeaderLib.Common.Dump(skillData))
	end
end

OnTimerFinished["LLWEAPONEX_MasteryBonus_CloakAndDagger_Pistol_MarkEnemy"] = CloakAndDagger_Pistol_MarkEnemy

---@param target string
---@param weaponBoostStat string
---@param source EsvCharacter
function Pistol_ApplyRuneProperties(target, source)
	local rune,weaponBoostStat = Skills.GetRuneBoost(source.Stats, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
	if weaponBoostStat ~= nil then
		---@type StatProperty[]
		local props = Ext.StatGetAttribute(weaponBoostStat, "ExtraProperties")
		if props ~= nil then
			GameHelpers.ApplyProperties(target, source.MyGuid, props)
		end
	end
end

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function PistolShootBonuses(skill, char, state, skillData)
	if state == SKILL_STATE.HIT and skillData.Success then
		local target = skillData.Target
		local damageAmount = skillData.Damage
		if target ~= nil and damageAmount > 0 then
			local caster = Ext.GetCharacter(char)
			local handle = skillData.Handle
			if IsTagged(target, "LLWEAPONEX_Pistol_MarkedForCrit") == 1 then
				local critMult = Ext.Round(CharacterGetAbility(char,"RogueLore") * Ext.ExtraData.SkillAbilityCritMultiplierPerPoint) * 0.01
				GameHelpers.IncreaseDamage(target, char, handle, critMult)
				NRD_StatusSetInt(target, handle, "CriticalHit", 1)
				NRD_StatusSetInt(target, handle, "Hit", 1)
				NRD_StatusSetInt(target, handle, "Dodged", 0)
				NRD_StatusSetInt(target, handle, "Missed", 0)
				NRD_StatusSetInt(target, handle, "Blocked", 0)
				ClearTag(target, "LLWEAPONEX_Pistol_MarkedForCrit")
				--CharacterStatusText(target, string.format("<font color='#FF337F'>%s</font>", Ext.GetTranslatedString("h11065363gf07eg4764ga834g9eeab569ceec", "Critical Hit!")))
				CharacterStatusText(target, "LLWEAPONEX_StatusText_Pistol_MarkedCrit")
			end
			if IsTagged(char, "LLWEAPONEX_Pistol_Adrenaline_Active") == 1 then
				ClearTag(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
				local damageBoost = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_Adrenaline_PistolDamageBoost", 50.0) * 0.01
				if damageBoost > 0 then
					GameHelpers.IncreaseDamage(target, char, handle, damageBoost)
					CharacterStatusText(char, "LLWEAPONEX_StatusText_Pistol_AdrenalineBoost")
				end
			end
			local rune,weaponBoostStat = Skills.GetRuneBoost(caster.Stats, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
			if weaponBoostStat ~= nil then
				---@type StatProperty[]
				local props = Ext.StatGetAttribute(weaponBoostStat, "ExtraProperties")
				if props ~= nil then
					GameHelpers.ApplyProperties(target, char, props)
				end
			end
		end
	end
end
RegisterSkillListener("Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand", PistolShootBonuses)
RegisterSkillListener("Projectile_LLWEAPONEX_Pistol_Shoot_RightHand", PistolShootBonuses)
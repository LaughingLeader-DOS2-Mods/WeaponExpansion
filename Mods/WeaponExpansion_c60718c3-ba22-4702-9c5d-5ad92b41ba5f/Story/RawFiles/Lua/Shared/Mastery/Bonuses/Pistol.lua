local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Pistol, 1, {
	rb:Create("PISTOL_ADRENALINE", {
		Skills = {"Shout_Adrenaline", "Shout_EnemyAdrenaline"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Pistol_Adrenaline", "Gain hyper-focus, increasing the <font color='#33FF00'>damage of the next shot of your pistol by [ExtraData:LLWEAPONEX_MB_Pistol_Adrenaline_DamageBoost]%</font>."),
		Statuses = {"ADRENALINE"},
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Pistol_AdrenalineStatus", "<font color='#33FF00'>Your next pistol shot will deal [ExtraData:LLWEAPONEX_MB_Pistol_Adrenaline_DamageBoost]% more damage.</font>"),
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_Pistol_Adrenaline_Active", false)
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			SetTag(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
			CharacterStatusText(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
		end
	end),

	rb:Create("PISTOL_CLOAKEDJUMP", {
		Skills = {"Jump_CloakAndDagger", "Jump_EnemyCloakAndDagger"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Pistol_CloakAndDagger", "Automatically reload your pistol when jumping.<br>When landing, apply [Key:MARKED_DisplayName] to the closest enemy within [ExtraData:LLWEAPONEX_MB_Pistol_CloakAndDagger_MarkingRadius]m ([ExtraData:LLWEAPONEX_MB_Pistol_CloakAndDagger_MaxTargets] target(s) max).<br>Shooting targets [Key:MARKED_DisplayName] this way, with your pistol, guarantees one critical hit until you end your turn."),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			if CharacterHasSkill(char, "Shout_LLWEAPONEX_Pistol_Reload") == 1 then
				GameHelpers.Skill.Swap(char, "Shout_LLWEAPONEX_Pistol_Reload", "Projectile_LLWEAPONEX_Pistol_Shoot")
			end
			if CharacterIsInCombat(char) == 1 then
				Timer.StartObjectTimer("LLWEAPONEX_MasteryBonus_CloakAndDagger_Pistol_MarkEnemy", char, 1000)
			end
		end
	end),
})

if not Vars.IsClient then
	Timer.Subscribe("LLWEAPONEX_MasteryBonus_CloakAndDagger_Pistol_MarkEnemy", function(e)
		if e.Data.UUID ~= nil and CharacterIsInCombat(e.Data.UUID) == 1 then
			local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_Pistol_CloakAndDagger_MarkingRadius", 6)
			local maxTargets = GameHelpers.GetExtraData("LLWEAPONEX_MB_Pistol_CloakAndDagger_MaxTargets", 1)
			if radius > 0 and maxTargets > 0 then
				---@type MasteryBonusManagerClosestEnemyData[]
				local enemies = Common.ShuffleTable(MasteryBonusManager.GetClosestEnemiesToObject(e.Data.UUID, e.Data.UUID, radius, true, maxTargets))
				for i,v in pairs(enemies) do
					if CharacterIsDead(v.UUID) == 0 
					and not GameHelpers.Status.IsSneakingOrInvisible(v.UUID) 
					and HasActiveStatus(v.UUID, "MARKED") == 0
					then
						GameHelpers.Status.Apply(v.UUID, "MARKED", 6.0, 0, e.Data.UUID)
						SetTag(v.UUID, "LLWEAPONEX_Pistol_MarkedForCrit")
						Osi.LLWEAPONEX_Statuses_ListenForTurnEnding(e.Data.UUID, v.UUID, "MARKED", "")
					end
				end
			end
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Pistol, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Pistol, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Pistol, 4, {
	
})

if not Vars.IsClient then
	---@param target string
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
	---@param data HitData
	local function PistolShootBonuses(skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local target = data.Target
			local damageAmount = data.Damage
			if target ~= nil and damageAmount > 0 then
				local caster = Ext.GetCharacter(char)
				local handle = data.Handle
				if IsTagged(target, "LLWEAPONEX_Pistol_MarkedForCrit") == 1 then
					if not data:HasHitFlag("CriticalHit", true) then
						local attackerStats = GameHelpers.GetCharacter(char).Stats
						local critMult = (attackerStats.RogueLore * Ext.ExtraData.SkillAbilityCritMultiplierPerPoint) * 0.01
						data:SetHitFlag("CriticalHit", true)
						data:SetHitFlag("Hit", true)
						data:SetHitFlag("Dodged", false)
						data:SetHitFlag("Missed", false)
						data:SetHitFlag("Blocked", false)
						data:MultiplyDamage(1 + critMult)
					end
					ClearTag(target, "LLWEAPONEX_Pistol_MarkedForCrit")
					CharacterStatusText(target, "LLWEAPONEX_StatusText_Pistol_MarkedCrit")
				end
				if IsTagged(char, "LLWEAPONEX_Pistol_Adrenaline_Active") == 1 then
					ClearTag(char, "LLWEAPONEX_Pistol_Adrenaline_Active")
					local damageBoost = GameHelpers.GetExtraData("LLWEAPONEX_MB_Pistol_Adrenaline_DamageBoost", 50.0) * 0.01
					if damageBoost > 0 then
						data:MultiplyDamage(1 + damageBoost)
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
	RegisterSkillListener({"Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand", "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand"}, PistolShootBonuses)
end
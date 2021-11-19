local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

---@type SkillEventDataForEachCallback
local function OnPinDownTarget(v, targetType, char, skill, forwardVector, radius)
	--print("OnPinDownTarget", v, targetType, char, skill, forwardVector, radius)
	local target = nil
	if targetType == "string" then
		local targets = nil
		
		targets = MasteryBonusManager.GetClosestEnemiesToObject(char, v, radius, true, 3, v)
		
		if targets ~= nil and #targets > 0 then
			target = Common.GetRandomTableEntry(targets)
		end

		if target == nil then
			target = v
		end

		if target ~= nil then
			GameHelpers.Skill.ShootProjectileAt(target.UUID, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", char, {CanDeflect = true})
		else
			local x,y,z = GetPosition(v)
			y = y + 1.0
			GameHelpers.Skill.ShootProjectileAt({x,y,z}, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", char, {CanDeflect = true})
		end
		return true
	elseif targetType == "table" then
		local x,y,z = table.unpack(v)
		local targets = MasteryBonusManager.GetClosestCombatEnemies(v, radius, true, 3, v)
		if #targets > 0 then
			target = Common.GetRandomTableEntry(targets)
		end

		if target ~= nil then
			GameHelpers.Skill.ShootProjectileAt(target.UUID, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", char, {CanDeflect = true})
		else
			x = x + forwardVector[1]
			z = z + forwardVector[3]
			GameHelpers.Skill.ShootProjectileAt({x,y,z}, "Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot", char, {CanDeflect = true})
		end
		return true
	end
	return false
end

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 1, {
	rb:Create("BOW_DOUBLE_SHOT", {
		Skills = {"Projectile_PinDown", "Projectile_EnemyPinDown"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_PinDown", "Shoot <font color='#00FFAA'>[ExtraData:LLWEAPONEX_MB_Bow_PinDown_BonusShots]</font> additional arrow(s) at a nearby enemy for [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot].<br><font color='#F19824'>If no enemies are nearby, the bonus arrow(s) will fire at the original target.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			-- Support for a mod making Pin Down shoot multiple arrows through the use of iterating tables.
			local maxBonusShots = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bow_PinDown_BonusShots", 1)
			if maxBonusShots > 0 then
				local bonusShots = 0
				local character = Ext.GetCharacter(char)
				local rot = character.Stats.Rotation
				local forwardVector = {
					-rot[7] * 1.25,
					0,
					-rot[9] * 1.25,
				}
				local radius = (Ext.StatGetAttribute(skill, "TargetRadius") or 6.0) / 2
				data:ForEach(function(v, targetType, skillEventData)
					if bonusShots < maxBonusShots then
						local success,b = xpcall(OnPinDownTarget, debug.traceback, v, targetType, char, skill, forwardVector, radius)
						if b == true then
							bonusShots = bonusShots + 1
						elseif not success then
							Ext.PrintError(b)
						end
					end
				end)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 2, {
	rb:Create("BOW_ASSASSINATE_MARKED", {
		Skills = {"Projectile_Snipe", "Projectile_EnemySnipe"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_AssassinateMarked", "If the target is <font color='#FF3300'>Marked</font>, deal a <font color='#33FF33'>guaranteed critical hit</font> and bypass dodging/blocking. The mark is cleansed after hit."),
		Statuses = {"MARKED"},
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bow_AssassinateMarkedStatus", "<font color='#33FF00'>Character is vulnerable to a critical hit from [Key:Projectile_Snipe_DisplayName].</font>"),
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_Bow_Mastery2", true)
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and HasActiveStatus(data.Target, "MARKED") == 1 then
			if not data:HasHitFlag("CriticalHit", true) then
				local attackerStats = GameHelpers.GetCharacter(char).Stats
				local critMultiplier = Game.Math.GetCriticalHitMultiplier(attackerStats.MainWeapon or attackerStats.OffHandWeapon)
				data:SetHitFlag("CriticalHit", true)
				data:MultiplyDamage(1 + critMultiplier)
			end
			RemoveStatus(data.Target, "MARKED")
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bow, 4, {
	
})
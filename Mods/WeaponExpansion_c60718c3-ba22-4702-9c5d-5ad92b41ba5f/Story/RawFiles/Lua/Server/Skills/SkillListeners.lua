SkillConfiguration.AimedShot = {
	BonusStatuses = {"LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY"},
	CriticalRequrementStatuses = {"MARKED"},
}

RegisterSkillListener("Projectile_LLWEAPONEX_Rifle_AimedShot", function(skill, char, state, data)
	if state == SKILL_STATE.USED then
		GameHelpers.Status.Apply(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", 6.0, false, char)
		local shouldCriticalHit = false
		data:ForEach(function(target)
			if GameHelpers.Status.IsActive(target, SkillConfiguration.AimedShot.CriticalRequrementStatuses) then
				shouldCriticalHit = true
			end
		end, data.TargetMode.Objects)
		if shouldCriticalHit then
			GameHelpers.Status.Apply(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", 6.0, true, char)
		end
	elseif state == SKILL_STATE.CAST then
		Timer.StartObjectTimer("LLWEAPONEX_Rifle_AimedShot_ClearBonuses", char, 1500)
	elseif state == SKILL_STATE.HIT then
		Timer.Cancel("LLWEAPONEX_Rifle_AimedShot_ClearBonuses", char)
		GameHelpers.Status.Remove(char, SkillConfiguration.AimedShot.BonusStatuses)
	end
end)

Timer.RegisterListener("LLWEAPONEX_Rifle_AimedShot_ClearBonuses", function(timerName, uuid)
	GameHelpers.Status.Remove(uuid, SkillConfiguration.AimedShot.BonusStatuses)
end)

RegisterSkillListener({"Projectile_LLWEAPONEX_Greatbow_PiercingShot", "Projectile_LLWEAPONEX_Greatbow_PiercingShot_Enemy"}, function(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		if IsTagged(data.Target, "DRAGON") == 1 then
			ApplyStatus(data.Target, "LLWEAPONEX_DRAGONS_BANE", 6.0, 0, char)
		end
	end
end)

-- Placeholder until we can check a character's Treasures array
local STEAL_DEFAULT_TREASURE = "ST_LLWEAPONEX_RandomEnemyTreasure"

---@param data HitData
RegisterSkillListener("Target_LLWEAPONEX_Steal", function(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		local canStealFrom = IsTagged(data.Target, "LLDUMMY_TrainingDummy") == 0 or Vars.DebugMode == true
		if canStealFrom then
			local attacker = Ext.GetCharacter(char)
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_Steal_BaseChance", 50.0)
			if attacker:HasTag("LLWEAPONEX_PirateGloves_Equipped") then
				local glovesBonusChance = GameHelpers.GetExtraData("LLWEAPONEX_Steal_GlovesBonusChance", 30.0)
				chance = math.tointeger(chance + glovesBonusChance)
			end
			
			local stolenSuccess = GetVarInteger(data.Target, "LLWEAPONEX_Steal_TotalStolen") or 0
			if stolenSuccess > 0 then
				local stealReduction = GameHelpers.GetExtraData("LLWEAPONEX_Steal_SuccessChanceReduction", 30.0)
				chance = math.tointeger(math.max(chance - (stolenSuccess * stealReduction), 0))
			end

			local enemy = Ext.GetCharacter(data.Target)
			local name = attacker.DisplayName
			
			if chance > 0 then
				local roll = Ext.Random(0,100)
				if roll <= chance then
					stolenSuccess = stolenSuccess + 1
					SetVarInteger(data.Target, "LLWEAPONEX_Steal_TotalStolen", stolenSuccess)

					local treasure = STEAL_DEFAULT_TREASURE
					local level = CharacterGetLevel(char)
					local targetOwner = data.Target
					local itemName = ""

					-- local enemyTreasure = enemy.Treasures
					-- if enemyTreasure ~= nil then
					-- 	table.insert(treasure, Common.GetRandomTableEntry(enemyTreasure))
					-- end
					if enemy.Stats.Level > level then
						level = enemy.Stats.Level
					end
					-- if #treasure == 0 then
					-- 	table.insert(treasure, STEAL_DEFAULT_TREASURE)
					-- end
		
					local items = {}
					local x,y,z = GetPosition(char)
					--LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830
					local container = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
					-- for i,treasure in pairs(treasure) do
					-- 	GenerateTreasure(container, treasure, level, char)
					-- end
					GenerateTreasure(container, treasure, level, char)
					local treasureItems = Ext.GetItem(container):GetInventoryItems()
					if #treasureItems > 0 then
						local ranItem = Common.GetRandomTableEntry(treasureItems)
						itemName = Ext.GetItem(ranItem).DisplayName or Ext.GetTranslatedString("h6f1e6e58g9918g4f9bga5f1gae66ef1915d4", "an item")
						ItemSetOriginalOwner(ranItem, targetOwner) -- So it shows up as stolen
						ItemToInventory(ranItem, char, ItemGetAmount(ranItem), 1, 0)
					else
						itemName = Ext.GetTranslatedString("h55e5ec72g331dg4dc9g9532g4a68ba0bc2a3", "Gold")
						GenerateTreasure(container, "ST_LLWEAPONEX_JustGold", level, char)
						MoveAllItemsTo(container, char, 0, 0, 0)
					end
					ItemRemove(container)

					GameHelpers.UI.CombatLog(Text.CombatLog.StealSuccess:ReplacePlaceholders(name, itemName, enemy.DisplayName), 0)
				else
					GameHelpers.UI.CombatLog(Text.CombatLog.StealFailed:ReplacePlaceholders(name, enemy.DisplayName), 0)
				end
			else
				GameHelpers.UI.CombatLog(Text.CombatLog.StealLimitReached:ReplacePlaceholders(name, enemy.DisplayName), 0)
			end
		end
	end
end)

---@param reverse boolean
---@param skill string
---@param instant boolean
---@param char string
---@param state SkillState
---@param data SkillEventData
local function SwapSkills(nextSkill, instant, skill, char, state, data)
	if state == SKILL_STATE.CAST then
		if CharacterIsInCombat(char) == 1 or instant then
			if instant ~= true then
				Timer.StartOneshot("LLWEAPONEX_Pistol_SwapSkills_"..skill..char, 500, function()
					GameHelpers.Skill.Swap(char, skill, nextSkill, true)
				end)
			else
				GameHelpers.Skill.Swap(char, skill, nextSkill, true)
			end
		else
			NRD_SkillSetCooldown(char, skill, 0.0)
			GameHelpers.UI.RefreshSkillBarSkillCooldown(char, skill)
		end
	end
end

RegisterSkillListener("Projectile_LLWEAPONEX_HandCrossbow_Shoot", function(...) SwapSkills("Shout_LLWEAPONEX_HandCrossbow_Reload", false, ...) end)
RegisterSkillListener("Shout_LLWEAPONEX_HandCrossbow_Reload", function(...) SwapSkills("Projectile_LLWEAPONEX_HandCrossbow_Shoot", true, ...) end)
RegisterSkillListener("Projectile_LLWEAPONEX_Pistol_Shoot", function(...) SwapSkills("Shout_LLWEAPONEX_Pistol_Reload", false, ...) end)
RegisterSkillListener("Shout_LLWEAPONEX_Pistol_Reload", function(...) SwapSkills("Projectile_LLWEAPONEX_Pistol_Shoot", true, ...) end)
--RegisterSkillListener("Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy", function(...) SwapHandCrossbowSkills(false, ...) end)

SkillManager.Register.Cast("Projectile_LLWEAPONEX_DarkFireball",
function(skill, char, state, data)
	local radius = math.max(1.0, Ext.StatGetAttribute("Projectile_LLWEAPONEX_DarkFireball", "ExplodeRadius") - 1.0)
	if radius > 0 then
		data:ForEach(function (target, targetType, skillData)
			local pos = GameHelpers.Math.GetPosition(target)
			GameHelpers.Surface.CreateSurface(pos, "FireCursed", radius, 6.0, char.Handle, false)
			GameHelpers.Surface.CreateSurface(pos, "FireCloudCursed", radius, 6.0, char.Handle, false)
		end, data.TargetMode.All)
	end
end)

SkillManager.Register.Hit({"Projectile_LLWEAPONEX_HandCrossbow_Shoot", "Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"},
function(skill, char, state, data)
	-- Silver bolts / Bullets do bonus damage to undead/voidwoken
	if data.Success and TagHelpers.IsUndeadOrVoidwoken(data.Target) then
		if Skills.HasTaggedRuneBoost(char.Stats, "LLWEAPONEX_SilverAmmo", "_LLWEAPONEX_HandCrossbows") then
			local bonus = GameHelpers.GetExtraData("LLWEAPONEX_HandCrossbow_SilverBonusDamage", 1.5)
			if bonus > 0 then
				data:MultiplyDamage(bonus, true)
			end
		end
	end
end)

SkillManager.Register.Hit({"Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand", "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand"},
function(skill, char, state, data, dataType)
	-- Silver bullets do bonus damage to undead/voidwoken
	if data.Success and TagHelpers.IsUndeadOrVoidwoken(data.Target) then
		if Skills.HasTaggedRuneBoost(char.Stats, "LLWEAPONEX_SilverAmmo", "_LLWEAPONEX_Pistols") then
			local bonus = GameHelpers.GetExtraData("LLWEAPONEX_Pistol_SilverBonusDamage", 1.5)
			if bonus > 0 then
				data:MultiplyDamage(bonus, true)
			end
		end
	end
end)

SkillManager.Register.Cast({"Target_LLWEAPONEX_Greatbow_FutureBarrage", "Target_LLWEAPONEX_Greatbow_FutureBarrage_Enemy"},
function(skill, char, state, data, dataType)
	local combat = CombatGetIDForCharacter(char.MyGuid)
	data:ForEach(function(target, targetType, d)
		local pos = GameHelpers.Math.GetPosition(target)
		local delay = math.floor(GameHelpers.GetExtraData("LLWEAPONEX_FutureBarrage_TurnDelay", 3))
		if Vars.DebugMode then
			delay = 1
		end
		if delay > 0 then
			if PersistentVars.SkillData.FutureBarrage[char.MyGuid] == nil then
				PersistentVars.SkillData.FutureBarrage[char.MyGuid] = {}
			end
			table.insert(PersistentVars.SkillData.FutureBarrage[char.MyGuid], pos)
			TurnCounter.CountDown("LLWEAPONEX_Greatbow_FutureBarrageFire", delay, combat or nil, {Position = pos})
		end
		EffectManager.PlayEffectAt("LLWEAPONEX_FX_AreaRadiusDecal_Circle_1m_Green_01", pos, {Scale=8.0})
	end, data.TargetMode.All)
end)

--Make hits against disabled/immobile enemies critical hits
SkillManager.Register.Hit("ProjectileStrike_Greatbow_FutureBarrage_RainOfArrows",
function(skill, char, state, data, dataType)
	if data.Success and GameHelpers.Ext.ObjectIsCharacter(data.TargetObject) and not data:HasHitFlag("CriticalHit", true) then
		if GameHelpers.Status.IsDisabled(data.TargetObject)
		or data.TargetObject.Stats.Movement <= 0
		or GameHelpers.Status.IsActive(data.TargetObject, "WEB") then
			data:SetHitFlag("CriticalHit", true)
			local mult = Game.Math.GetCriticalHitMultiplier(char.Stats.MainWeapon, char.Stats, 0.0)
			data:MultiplyDamage(mult)
		end
	end
end)

TurnCounter.RegisterListener("LLWEAPONEX_Greatbow_FutureBarrageFire", function (id, turns, lastTurns, finished, data)
	if finished then
		EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_Greatbow_FutureBarrage_Decal_AttackImminent_01", data.Position)
		Timer.Start("LLWEAPONEX_FutureBarrage_FireSkill", 250, data.Position)
	else
		if turns == 1 then
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_AreaRadiusDecal_Circle_1m_01", data.Position, {
				Scale = 8.0
			})
		end
	end
end)

Timer.RegisterListener("LLWEAPONEX_FutureBarrage_FireSkill", function (timerName, targetPosition)
	for uuid,positions in pairs(PersistentVars.SkillData.FutureBarrage) do
		for i,pos in pairs(positions) do
			if targetPosition[1] == pos[1]
			and targetPosition[2] == pos[2]
			and targetPosition[3] == pos[3]
			then
				GameHelpers.Skill.CreateProjectileStrike(targetPosition, "ProjectileStrike_Greatbow_FutureBarrage_RainOfArrows", uuid, {
					PlayCastEffects=true,
					PlayTargetEffects=true
				})
				table.remove(positions, i)
			end
		end
		if #positions == 0 then
			PersistentVars.SkillData.FutureBarrage[uuid] = nil
		end
	end
end)
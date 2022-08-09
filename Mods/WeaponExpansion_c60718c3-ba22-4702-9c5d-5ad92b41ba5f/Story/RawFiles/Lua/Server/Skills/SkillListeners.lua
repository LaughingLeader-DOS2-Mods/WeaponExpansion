SkillConfiguration.AimedShot = {
	BonusStatuses = {"LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY"},
	CriticalRequirementStatuses = {"MARKED"},
}

SkillManager.Register.All("Projectile_LLWEAPONEX_Rifle_AimedShot", function(e)
	if e.State == SKILL_STATE.USED then
		GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", 6.0, false, e.Character)
		local shouldCriticalHit = false
		e.Data:ForEach(function(target)
			if GameHelpers.Status.IsActive(target, SkillConfiguration.AimedShot.CriticalRequirementStatuses) then
				shouldCriticalHit = true
			end
		end, e.Data.TargetMode.Objects)
		if shouldCriticalHit then
			GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", 6.0, true, e.Character)
		end
	elseif e.State == SKILL_STATE.CAST then
		Timer.StartObjectTimer("LLWEAPONEX_Rifle_AimedShot_ClearBonuses", e.Character, 1500)
	elseif e.State == SKILL_STATE.HIT or e.State == SKILL_STATE.UNMEMORIZED then
		Timer.Cancel("LLWEAPONEX_Rifle_AimedShot_ClearBonuses", e.Character)
		GameHelpers.Status.Remove(e.Character, SkillConfiguration.AimedShot.BonusStatuses)
	end
end)

Timer.Subscribe("LLWEAPONEX_Rifle_AimedShot_ClearBonuses", function(e)
	if e.Data.Object then
		GameHelpers.Status.Remove(e.Data.Object, SkillConfiguration.AimedShot.BonusStatuses)
	end
end)

SkillManager.Register.Hit({"Projectile_LLWEAPONEX_Greatbow_PiercingShot", "Projectile_LLWEAPONEX_Greatbow_PiercingShot_Enemy"},
function(e)
	if e.Data.Success and e.Data.TargetObject:HasTag("DRAGON") then
		GameHelpers.Status.Apply(e.Data.Target, "LLWEAPONEX_DRAGONS_BANE", 6.0, 0, e.Character)
	end
end)

-- Placeholder until we can check a character's Treasures array
local STEAL_DEFAULT_TREASURE = "ST_LLWEAPONEX_RandomEnemyTreasure"

SkillManager.Register.Hit("Target_LLWEAPONEX_Steal", function(e)
	if e.Data.Success then
		local canStealFrom = e.Data.TargetObject:HasTag("LLDUMMY_TrainingDummy") or Vars.DebugMode == true
		if canStealFrom then
			local chance = GameHelpers.GetExtraData("LLWEAPONEX_Steal_BaseChance", 50.0)
			if e.Character:HasTag("LLWEAPONEX_PirateGloves_Equipped") then
				local glovesBonusChance = GameHelpers.GetExtraData("LLWEAPONEX_Steal_GlovesBonusChance", 30.0)
				chance = math.tointeger(chance + glovesBonusChance)
			end
			
			local stolenSuccess = GetVarInteger(e.Data.Target, "LLWEAPONEX_Steal_TotalStolen") or 0
			if stolenSuccess > 0 then
				local stealReduction = GameHelpers.GetExtraData("LLWEAPONEX_Steal_SuccessChanceReduction", 30.0)
				chance = math.tointeger(math.max(chance - (stolenSuccess * stealReduction), 0))
			end

			local enemy = Ext.GetCharacter(e.Data.Target)
			local name = e.Character.DisplayName
			
			if chance > 0 then
				local roll = Ext.Random(0,100)
				if roll <= chance then
					stolenSuccess = stolenSuccess + 1
					SetVarInteger(e.Data.Target, "LLWEAPONEX_Steal_TotalStolen", stolenSuccess)

					local treasure = STEAL_DEFAULT_TREASURE
					local level = CharacterGetLevel(e.Character)
					local targetOwner = e.Data.Target
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
					local x,y,z = table.unpack(e.Character.WorldPos)
					--LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830
					local container = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
					-- for i,treasure in pairs(treasure) do
					-- 	GenerateTreasure(container, treasure, level, char)
					-- end
					GenerateTreasure(container, treasure, level, e.Character.MyGuid)
					local treasureItems = Ext.GetItem(container):GetInventoryItems()
					if #treasureItems > 0 then
						local ranItem = Common.GetRandomTableEntry(treasureItems)
						itemName = Ext.GetItem(ranItem).DisplayName or Ext.GetTranslatedString("h6f1e6e58g9918g4f9bga5f1gae66ef1915d4", "an item")
						ItemSetOriginalOwner(ranItem, targetOwner) -- So it shows up as stolen
						ItemToInventory(ranItem, e.Character.MyGuid, ItemGetAmount(ranItem), 1, 0)
					else
						itemName = Ext.GetTranslatedString("h55e5ec72g331dg4dc9g9532g4a68ba0bc2a3", "Gold")
						GenerateTreasure(container, "ST_LLWEAPONEX_JustGold", level, e.Character.MyGuid)
						MoveAllItemsTo(container, e.Character.MyGuid, 0, 0, 0)
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

---@param nextSkill string
---@param instant boolean
---@param e OnSkillStateSkillEventEventArgs
local function SwapSkills(nextSkill, instant, e)
	if instant or GameHelpers.Character.IsInCombat(e.Character) then
		if instant ~= true then
			Timer.StartOneshot(string.format("LLWEAPONEX_Pistol_SwapSkills_%s%s", e.Skill, e.Character.MyGuid), 500, function()
				GameHelpers.Skill.Swap(e.Character, e.Skill, nextSkill, true)
			end)
		else
			GameHelpers.Skill.Swap(e.Character, e.Skill, nextSkill, true)
		end
	else
		NRD_SkillSetCooldown(e.Character.MyGuid, e.Skill, 0.0)
		GameHelpers.UI.RefreshSkillBarSkillCooldown(e.Character, e.Skill)
	end
end

SkillManager.Register.Cast("Projectile_LLWEAPONEX_HandCrossbow_Shoot", function(e) SwapSkills("Shout_LLWEAPONEX_HandCrossbow_Reload", false, e) end)
SkillManager.Register.Cast("Shout_LLWEAPONEX_HandCrossbow_Reload", function(e) SwapSkills("Projectile_LLWEAPONEX_HandCrossbow_Shoot", true, e) end)
SkillManager.Register.Cast("Projectile_LLWEAPONEX_Pistol_Shoot", function(e) SwapSkills("Shout_LLWEAPONEX_Pistol_Reload", false, e) end)
SkillManager.Register.Cast("Shout_LLWEAPONEX_Pistol_Reload", function(e) SwapSkills("Projectile_LLWEAPONEX_Pistol_Shoot", true, e) end)

SkillManager.Register.Cast("Projectile_LLWEAPONEX_DarkFireball",
function(e)
	local radius = math.max(1.0, Ext.StatGetAttribute(e.Skill, "ExplodeRadius") - 1.0)
	if radius > 0 then
		e.Data:ForEach(function (target, targetType, skillData)
			local pos = GameHelpers.Math.GetPosition(target)
			GameHelpers.Surface.CreateSurface(pos, "FireCursed", radius, 6.0, e.Character.Handle, false)
			GameHelpers.Surface.CreateSurface(pos, "FireCloudCursed", radius, 6.0, e.Character.Handle, false)
		end, e.Data.TargetMode.All)
	end
end)

SkillConfiguration.HandCrossbows = {
	AllShootSkills = {"Projectile_LLWEAPONEX_HandCrossbow_Shoot", "Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"}
}

Ext.Events.SessionLoaded:Subscribe(function()
	SkillManager.Register.Hit(SkillConfiguration.HandCrossbows.AllShootSkills, function(e)
		-- Silver bolts / Bullets do bonus damage to undead/voidwoken
		if e.Data.Success and TagHelpers.IsUndeadOrVoidwoken(e.Data.Target) then
			if Skills.HasTaggedRuneBoost(e.Character.Stats, "LLWEAPONEX_SilverAmmo", "_LLWEAPONEX_HandCrossbows") then
				local bonus = GameHelpers.GetExtraData("LLWEAPONEX_HandCrossbow_SilverBonusDamage", 1.5)
				if bonus > 0 then
					e.Data:MultiplyDamage(bonus, true)
				end
			end
		end
	end)

	SkillManager.Register.MemorizationChanged(SkillConfiguration.HandCrossbows.AllShootSkills, function (e)
		if e.Data == false then
			CharacterRemoveSkill(e.CharacterGUID, "Shout_LLWEAPONEX_HandCrossbow_Reload")
		end
	end)
end, {Priority=0})

SkillManager.Register.Cast({"Target_LLWEAPONEX_Greatbow_FutureBarrage", "Target_LLWEAPONEX_Greatbow_FutureBarrage_Enemy"},
function(e)
	local combat = CombatGetIDForCharacter(e.Character.MyGuid)
	e.Data:ForEach(function(target)
		local pos = GameHelpers.Math.GetPosition(target)
		local delay = math.floor(GameHelpers.GetExtraData("LLWEAPONEX_FutureBarrage_TurnDelay", 3))
		if Vars.DebugMode then
			delay = 1
		end
		if delay > 0 then
			if PersistentVars.SkillData.FutureBarrage[e.Character.MyGuid] == nil then
				PersistentVars.SkillData.FutureBarrage[e.Character.MyGuid] = {}
			end
			table.insert(PersistentVars.SkillData.FutureBarrage[e.Character.MyGuid], pos)
			TurnCounter.CountDown("LLWEAPONEX_Greatbow_FutureBarrageFire", delay, combat or nil, {Position = pos})
		end
		EffectManager.PlayEffectAt("LLWEAPONEX_FX_AreaRadiusDecal_Circle_1m_Green_01", pos, {Scale=8.0})
	end, e.Data.TargetMode.All)
end)

--Make hits against disabled/immobile enemies critical hits
SkillManager.Register.Hit("ProjectileStrike_Greatbow_FutureBarrage_RainOfArrows",
function(e)
	if e.Data.Success and GameHelpers.Ext.ObjectIsCharacter(e.Data.TargetObject) and not e.Data:HasHitFlag("CriticalHit", true) then
		if GameHelpers.Status.IsDisabled(e.Data.TargetObject, false, true)
		or GameHelpers.Status.IsActive(e.Data.TargetObject, "WEB") then
			e.Data:SetHitFlag("CriticalHit", true)
			local mult = Game.Math.GetCriticalHitMultiplier(e.Character.Stats.MainWeapon, e.Character.Stats, 0.0)
			e.Data:MultiplyDamage(mult)
		end
	end
end)

TurnCounter.Subscribe("LLWEAPONEX_Greatbow_FutureBarrageFire", function (e)
	if e.Finished then
		EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_Greatbow_FutureBarrage_Decal_AttackImminent_01", e.Data.Position)
		Timer.Start("LLWEAPONEX_FutureBarrage_FireSkill", 250, {Position=e.Data.Position})
	else
		if e.Turn == 1 then
			EffectManager.PlayEffectAt("LLWEAPONEX_FX_AreaRadiusDecal_Circle_1m_01", e.Data.Position, {
				Scale = 8.0
			})
		end
	end
end)

Timer.Subscribe("LLWEAPONEX_FutureBarrage_FireSkill", function (e)
	local targetPosition = e.Data.Position
	if targetPosition then
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
	else
		fprint(LOGLEVEL.ERROR, "[LLWEAPONEX_FutureBarrage_FireSkill] No position set in the timer data:")
		e:Dump()
	end
end)
Config.Skill.AimedShot = {
	BonusStatuses = {"LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY"},
	CriticalRequirementStatuses = {"MARKED"},
}

SkillManager.Register.All("Projectile_LLWEAPONEX_Rifle_AimedShot", function(e)
	if e.State == SKILL_STATE.USED then
		GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", 6.0, false, e.Character)
		local shouldCriticalHit = false
		e.Data:ForEach(function(target)
			if GameHelpers.Status.IsActive(target, Config.Skill.AimedShot.CriticalRequirementStatuses) then
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
		GameHelpers.Status.Remove(e.Character, Config.Skill.AimedShot.BonusStatuses)
	end
end)

Timer.Subscribe("LLWEAPONEX_Rifle_AimedShot_ClearBonuses", function(e)
	if e.Data.Object then
		GameHelpers.Status.Remove(e.Data.Object, Config.Skill.AimedShot.BonusStatuses)
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

			local enemy = GameHelpers.GetCharacter(e.Data.Target)
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
					local treasureItems = GameHelpers.GetItem(container):GetInventoryItems()
					if #treasureItems > 0 then
						local ranItem = Common.GetRandomTableEntry(treasureItems)
						itemName = GameHelpers.GetItem(ranItem).DisplayName or Ext.GetTranslatedString("h6f1e6e58g9918g4f9bga5f1gae66ef1915d4", "an item")
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
	if instant or (GameHelpers.Character.IsInCombat(e.Character) or Mods.LeaderLib.Vars.LeaderDebugMode) then
		if instant ~= true then
			local characterGUID = e.CharacterGUID
			local skill = e.Skill
			Timer.StartOneshot(string.format("LLWEAPONEX_SwapSkills_%s%s", skill, e.CharacterGUID), 500, function()
				GameHelpers.Skill.Swap(characterGUID, skill, nextSkill, true)
			end)
		else
			GameHelpers.Skill.Swap(e.Character, e.Skill, nextSkill, true)
		end
	else
		local skillData = e.Character:GetSkillInfo(e.Skill)
		if skillData then
			skillData.ActiveCooldown = 0
		end
		GameHelpers.UI.RefreshSkillBarSkillCooldown(e.Character, e.Skill)
	end
end

SkillManager.Register.Cast("Projectile_LLWEAPONEX_HandCrossbow_Shoot", function(e) SwapSkills("Shout_LLWEAPONEX_HandCrossbow_Reload", false, e) end)
SkillManager.Register.Cast("Shout_LLWEAPONEX_HandCrossbow_Reload", function(e) SwapSkills("Projectile_LLWEAPONEX_HandCrossbow_Shoot", true, e) end)
SkillManager.Register.Cast("Projectile_LLWEAPONEX_Pistol_Shoot", function(e) SwapSkills("Shout_LLWEAPONEX_Pistol_Reload", false, e) end)
SkillManager.Register.Cast("Shout_LLWEAPONEX_Pistol_Reload", function(e) SwapSkills("Projectile_LLWEAPONEX_Pistol_Shoot", true, e) end)

SkillManager.Register.Cast("Projectile_LLWEAPONEX_DarkFireball",
function(e)
	local radius = math.max(1.0, GameHelpers.Stats.GetAttribute(e.Skill, "ExplodeRadius", 1) - 1.0)
	if radius > 0 then
		e.Data:ForEach(function (target, targetType, skillData)
			local pos = GameHelpers.Math.GetPosition(target)
			GameHelpers.Surface.CreateSurface(pos, "FireCursed", radius, 6.0, e.Character.Handle, false)
			GameHelpers.Surface.CreateSurface(pos, "FireCloudCursed", radius, 6.0, e.Character.Handle, false)
		end, e.Data.TargetMode.All)
	end
end)

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

--#region Chaos Skills

--[[ SkillManager.Register.Used({"Projectile_LLWEAPONEX_ChaosSlash", "Projectile_LLWEAPONEX_EnemyChaosSlash"}, function (e)

end) ]]

SkillManager.Register.Used("Rush_LLWEAPONEX_EnemyChaosCharge", function (e)
	local lastAction = PersistentVars.SkillData.ChaosChargePathAction[e.CharacterGUID]
	if lastAction then
		StopDrawSurfaceOnPath(lastAction.Handle)
	end
	local surface = Common.GetRandomTableEntry(Config.Status.ChaosPowerSurfaces)
	local radius = GameHelpers.GetExtraData("LLWEAPONEX_ChaosCharge_SurfaceRadius", 0.5)
	local duration = GameHelpers.GetExtraData("LLWEAPONEX_ChaosCharge_SurfaceDuration", 12.0)
	local handle = DrawSurfaceOnPath(e.CharacterGUID, e.CharacterGUID, surface, radius, duration)
	PersistentVars.SkillData.ChaosChargePathAction[e.CharacterGUID] = {
		Handle = handle,
		Surface = surface
	}
end)

SkillManager.Register.Cast("Rush_LLWEAPONEX_EnemyChaosCharge", function (e)
	Timer.StartObjectTimer("LLWEAPONEX_Timers_StopChaosChargeDrawing", e.Character, 800)
end)

Timer.Subscribe("LLWEAPONEX_Timers_StopChaosChargeDrawing", function (e)
	local data = PersistentVars.SkillData.ChaosChargePathAction[e.Data.UUID]
	if data then
		StopDrawSurfaceOnPath(data.Handle)
		PersistentVars.SkillData.ChaosChargePathAction[e.Data.UUID] = nil
		local character = e.Data.Object --[[@as EsvCharacter]]
		if character then
			local radius = GameHelpers.GetExtraData("LLWEAPONEX_ChaosCharge_SurfaceRadius", 0.5) * 2
			local duration = GameHelpers.GetExtraData("LLWEAPONEX_ChaosCharge_SurfaceDuration", 12.0)
			GameHelpers.Surface.CreateSurface(character.WorldPos, data.Surface, radius, duration, character.Handle, true)
		end
	end
end)

Events.ObjectEvent:Subscribe(function (e)
	local item = e.Objects[1] --[[@as EsvItem]]
	local radius = GetVarFloat(item.MyGuid, "LLWEAPONEX_Radius") or 1.0
	local lifetime = GetVarFloat(item.MyGuid, "LLWEAPONEX_Lifetime") or 6.0
	local owner = GameHelpers.Item.GetOwner(item) --[[@as EsvCharacter]]
	fprint(LOGLEVEL.ERROR, "[LLWEAPONEX_Commands_StartDrawingChaosSurface] MovingObject(%s) Owner(%s)", item.CurrentTemplate.Name, GameHelpers.GetDisplayName(owner))

	local surface = Common.GetRandomTableEntry(Config.Status.ChaosPowerSurfaces)
	--local action = Ext.Action.CreateGameAction("PathAction", "", owner.Handle) --[[@as EsvPathAction]]
	-- local action = Ext.Surface.Action.Create("EsvChangeSurfaceOnPathAction") --[[@as EsvChangeSurfaceOnPathAction]]
	-- action.CheckExistingSurfaces = false
	-- action.Duration = lifetime
	-- action.FollowObject = item.Handle
	-- action.IgnoreIrreplacableSurfaces = true
	-- action.OwnerHandle = owner.Handle
	-- action.Radius = radius
	-- action.StatusChance = 1.0
	-- action.SurfaceType = surface
	-- Ext.Surface.Action.Execute(action)
	-- PersistentVars.SkillData.ChaosSlashPathAction[item.MyGuid] = Ext.Utils.HandleToInteger(action.MyHandle)
	local handle = DrawSurfaceOnPath(owner.MyGuid, item.MyGuid, surface, radius, lifetime)
	PersistentVars.SkillData.ChaosSlashPathAction[item.MyGuid] = {
		Handle = handle,
		Surface = surface,
		Owner = owner.MyGuid
	}

end, {MatchArgs={Event="LLWEAPONEX_Commands_StartDrawingChaosSurface"}})

Events.ObjectEvent:Subscribe(function (e)
	local owner,item = table.unpack(e.Objects)
	---@cast owner EsvCharacter
	---@cast item EsvItem

	local data = PersistentVars.SkillData.ChaosSlashPathAction[e.ObjectGUID2]
	if data then
		StopDrawSurfaceOnPath(data.Handle)
		PersistentVars.SkillData.ChaosSlashPathAction[e.ObjectGUID2] = nil
		local radius = GetVarFloat(item.MyGuid, "LLWEAPONEX_Radius") or 1.0
		local lifetime = GetVarFloat(item.MyGuid, "LLWEAPONEX_Lifetime") or 6.0
		GameHelpers.Surface.CreateSurface(item.WorldPos, data.Surface, radius, lifetime, owner.Handle, true)
	end
	ItemDestroy(e.ObjectGUID2)
end, {MatchArgs={Event="LLWEAPONEX_Commands_StopDrawingChaosSurface"}})

--#endregion

---@param target EsvCharacter
---@param fromPosition vec3
---@param skill string
local function _ShootReturnSkill(target, fromPosition, skill)
	GameHelpers.Skill.ShootProjectileAt(target, skill, fromPosition, {CanDeflect=false, IgnoreObjects=true})
end

--#region Kevin

Timer.Subscribe("LLWEAPONEX_ShootKevinReturnEffect", function (e)
	if e.Data.Object and e.Data.Position then
		_ShootReturnSkill(e.Data.Object, e.Data.Position, "Projectile_LLWEAPONEX_Throw_Rock_Kevin_Effect")
	end
end)

SkillManager.Register.ProjectileHit("Projectile_LLWEAPONEX_Throw_Rock_Kevin_Effect", function (e)
	if e.Character and ObjectGetFlag(e.CharacterGUID, "LLWEAPONEX_Kevin_IgnoreEnergy") == 0 then
		for _,kevin in pairs(GameHelpers.Item.FindTaggedItems(e.Character, "LLWEAPONEX_KevinThePetRock")) do
			local current = GetVarInteger(kevin, "LLWEAPONEX_Kevin_CurrentEnergy")
			local max = GetVarInteger(kevin, "LLWEAPONEX_Kevin_MaxEnergy") or 4
			if current > 0 then
				current = current - 1
				SetVarInteger(kevin, "LLWEAPONEX_Kevin_CurrentEnergy", current)
			end
			local rechargeTurnAmount = GameHelpers.GetExtraData("LLWEAPONEX_Kevin_RechargeTurn", 1)
			if current <= 0 then
				local duration = rechargeTurnAmount * max
				GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_KEVIN_EXAUSTED_INFO", duration, false, e.Character)
				GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_KEVIN_RECHARGE")
				--GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_KEVIN_RECHARGE", duration, false, e.Character)
				local template = GameHelpers.GetTemplate(kevin)
				--THR_UNIQUE_LLWEAPONEX_Rock_Kevin_Disabled_9b6ea03d-801b-438d-a7c7-a6b9575c1043
				Transform(kevin, "9b6ea03d-801b-438d-a7c7-a6b9575c1043", 0, 0, 1)
				SetVarFixedString(kevin, "LLWEAPONEX_Kevin_OriginalTemplate", template)
			elseif not e.Character:GetStatus("LLWEAPONEX_KEVIN_RECHARGE") then
				GameHelpers.Status.Apply(e.Character, "LLWEAPONEX_KEVIN_RECHARGE", rechargeTurnAmount * 6.0, false, e.Character)
			end
		end
	end
end)

StatusManager.Subscribe.Removed("LLWEAPONEX_KEVIN_RECHARGE", function (e)
	if not GameHelpers.Status.IsActive(e.Target, "LLWEAPONEX_KEVIN_EXAUSTED_INFO") then
		for _,kevin in pairs(GameHelpers.Item.FindTaggedItems(e.Character, "LLWEAPONEX_KevinThePetRock")) do
			local current = GetVarInteger(kevin, "LLWEAPONEX_Kevin_CurrentEnergy") or 4
			local max = GetVarInteger(kevin, "LLWEAPONEX_Kevin_MaxEnergy") or 4
			if current < max then
				current = current + 1
				SetVarInteger(kevin, "LLWEAPONEX_Kevin_CurrentEnergy", current)
			end
			if current < max then
				local rechargeTurnAmount = GameHelpers.GetExtraData("LLWEAPONEX_Kevin_RechargeTurn", 1)
				GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_KEVIN_RECHARGE", rechargeTurnAmount * 6.0, false, e.Source)
			end
		end
	end
end)

StatusManager.Subscribe.Removed("LLWEAPONEX_KEVIN_EXAUSTED_INFO", function (e)
	for _,kevin in pairs(GameHelpers.Item.FindTaggedItems(e.Character, "LLWEAPONEX_KevinThePetRock")) do
		local max = GetVarInteger(kevin, "LLWEAPONEX_Kevin_MaxEnergy") or 4
		SetVarInteger(kevin, "LLWEAPONEX_Kevin_CurrentEnergy", max)
		local template = GetVarFixedString(kevin, "LLWEAPONEX_Kevin_OriginalTemplate")
		if not StringHelpers.IsNullOrEmpty(template) and GameHelpers.GetTemplate(kevin) ~= template then
			Transform(kevin, template, 0, 0, 1)
		end
	end
end)

--#endregion

--#region Shield Toss

--Same thing as the Kevin mechanic, where we try and guess the total fork targets, so we can return the shield immediately

SkillManager.Register.Cast("Projectile_LLWEAPONEX_ShieldToss", function (e)
	local pos = e.Data:GetSkillTargetPosition()
	Timer.StartObjectTimer("LLWEAPONEX_ShootShieldTossReturnEffect", e.Character, 1000, {Position=pos})
	
	local maxHits = e.Data.SkillData.ForkLevels + 1
	if maxHits > 1 then
		--Guess how many times Kevin is going to fork, so we can shoot the return projectile immediately
		local estimatedHits = 0
		local radius = e.Data.SkillData.AreaRadius
		for enemy in GameHelpers.Grid.GetNearbyObjects(e.Character, {Type="Character", Relation={Enemy=true}, Radius=radius, Position=pos}) do
			estimatedHits = estimatedHits + 1
			if estimatedHits >= maxHits then
				estimatedHits = maxHits
				break
			end
		end
		if estimatedHits > 0 then
			PersistentVars.SkillData.ShieldTossHitsRemaining[e.CharacterGUID] = estimatedHits
		end
	end
end)

SkillManager.Register.Hit("Projectile_LLWEAPONEX_ShieldToss", function (e)
	local remainingHits = PersistentVars.SkillData.ShieldTossHitsRemaining[e.CharacterGUID] or 0
	remainingHits = remainingHits - 1
	if remainingHits <= 0 then
		Timer.Cancel("LLWEAPONEX_ShootShieldTossReturnEffect", e.Character)
		PersistentVars.SkillData.ShieldTossHitsRemaining[e.CharacterGUID] = nil
		_ShootReturnSkill(e.Character, e.Data.TargetObject.WorldPos, "Projectile_LLWEAPONEX_ShieldToss_Returned")
		EffectManager.PlayEffect("RS3_FX_GP_Status_Harmony_Impact_01", e.Character)
		GameHelpers.Skill.Explode(e.Character.WorldPos, "Projectile_LLWEAPONEX_ApplyShieldTossBonus", e.Character)
	else
		PersistentVars.SkillData.ShieldTossHitsRemaining[e.CharacterGUID] = remainingHits
		Timer.StartObjectTimer("LLWEAPONEX_ShootShieldTossReturnEffect", e.Character, 300, {Position=e.Data.TargetObject.WorldPos})
	end
end)

Timer.Subscribe("LLWEAPONEX_ShootShieldTossReturnEffect", function (e)
	if e.Data.Object and e.Data.Position then
		_ShootReturnSkill(e.Data.Object, e.Data.Position, "Projectile_LLWEAPONEX_ShieldToss_Returned")
	end
end)

--#endregion

--These are registered last during SessionLoaded, in case a mod modifies the associatd config tables

Ext.Events.SessionLoaded:Subscribe(function (e)
	SkillManager.Register.Hit(Config.Skill.HandCrossbowsShootSkills, function(e)
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

	SkillManager.Register.MemorizationChanged(Config.Skill.HandCrossbowsShootSkills, function (e)
		if e.Data == false then
			CharacterRemoveSkill(e.CharacterGUID, "Shout_LLWEAPONEX_HandCrossbow_Reload")
		end
	end)

	SkillManager.Register.Cast(Config.Skill.KevinSkills, function (e)
		local pos = e.Data:GetSkillTargetPosition()
		Timer.StartObjectTimer("LLWEAPONEX_ShootKevinReturnEffect", e.Character, 1000, {Position=pos})
		
		local maxHits = e.Data.SkillData.ForkLevels + 1
		if maxHits > 1 then
			--Guess how many times Kevin is going to fork, so we can shoot the return projectile immediately
			local estimatedHits = 0
			local radius = e.Data.SkillData.AreaRadius
			for enemy in GameHelpers.Grid.GetNearbyObjects(e.Character, {Type="Character", Relation={Enemy=true}, Radius=radius, Position=pos}) do
				estimatedHits = estimatedHits + 1
				if estimatedHits >= maxHits then
					estimatedHits = maxHits
					break
				end
			end
			if estimatedHits > 0 then
				PersistentVars.SkillData.KevinHitsRemaining[e.CharacterGUID] = estimatedHits
			end
		end
	end)

	SkillManager.Register.Hit(Config.Skill.KevinSkills, function (e)
		local remainingHits = PersistentVars.SkillData.KevinHitsRemaining[e.CharacterGUID] or 0
		remainingHits = remainingHits - 1
		if remainingHits <= 0 then
			Timer.Cancel("LLWEAPONEX_ShootKevinReturnEffect", e.Character)
			PersistentVars.SkillData.KevinHitsRemaining[e.CharacterGUID] = nil
			_ShootReturnSkill(e.Character, e.Data.TargetObject.WorldPos, "Projectile_LLWEAPONEX_Throw_Rock_Kevin_Effect")
		else
			PersistentVars.SkillData.KevinHitsRemaining[e.CharacterGUID] = remainingHits
			Timer.StartObjectTimer("LLWEAPONEX_ShootKevinReturnEffect", e.Character, 300, {Position=e.Data.TargetObject.WorldPos})
		end
	end)
end, {Priority=0})
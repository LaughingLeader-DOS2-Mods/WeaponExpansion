RegisterSkillListener("Projectile_LLWEAPONEX_Rifle_AimedShot", function(skill, char, state, data)
	if state == SKILL_STATE.PREPARE then
		--ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", -1.0, 0, char)
		--Mods.Timer.Start("Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus", 1000, char)
	elseif state == SKILL_STATE.USED then
		if HasActiveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY") == 0 then
			ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", 12.0, 1, char)
		end
		data:ForEach(function(target)
			if HasActiveStatus(target, "MARKED") == 1 and HasActiveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL") == 0 then
				ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", 12.0, 1, char)
			end
		end)
	elseif state == SKILL_STATE.CAST then
		Osi.LeaderLib_Timers_StartObjectTimer(char, 1500, "Timers_LLWEAPONEX_Rifle_AimedShot_ClearBonuses", "LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
	elseif state == SKILL_STATE.HIT then
		Osi.LeaderLib_Timers_CancelObjectObjectTimer(char, "Timers_LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
		SetStoryEvent(char, "LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
	end
end)

RegisterSkillListener({"Projectile_LLWEAPONEX_Greatbow_PiercingShot", "Projectile_LLWEAPONEX_Greatbow_PiercingShot_Enemy"}, function(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		if IsTagged(data.Target, "DRAGON") == 1 then
			ApplyStatus(data.Target, "LLWEAPONEX_DRAGONS_BANE", 6.0, 0, char)
		end
	end
end)

RegisterSkillListener({"Projectile_SkyShot", "Projectile_EnemySkyShot"}, function(skill, char, state, data)
	if IsTagged(char, "LLWEAPONEX_Omnibolt_Equipped") == 1 then
		if state == SKILL_STATE.HIT and data.Success and ObjectGetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus") == 0 then
			GameHelpers.ExplodeProjectile(char, data.Target, "Projectile_LLWEAPONEX_Greatbow_LightningStrike")
		elseif state == SKILL_STATE.USED then
			if data.TotalTargetObjects > 0 then
				ObjectClearFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus", 0)
			elseif data.TotalTargetPositions > 0 then
				ObjectSetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus", 0)
				local x,y,z = table.unpack(data.TargetPositions[1])
				SetVarFloat3(char, "LLWEAPONEX_Omnibolt_SkyShotWorldPosition", x, y, z)
			end
		elseif state == SKILL_STATE.CAST then
			Timer.Start("Timers_LLWEAPONEX_ProcGreatbowLightningStrike", 750, char)
		end
	end
end)

Timer.RegisterListener("Timers_LLWEAPONEX_ProcGreatbowLightningStrike", function(timerName, char)
	if char and ObjectGetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus") == 1 then
		local x,y,z = GetVarFloat3(char, "LLWEAPONEX_Omnibolt_SkyShotWorldPosition")
		GameHelpers.Skill.Explode({x,y,z}, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", char)
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
			local chance = Ext.ExtraData["LLWEAPONEX_Steal_BaseChance"] or 50.0
			if attacker:HasTag("LLWEAPONEX_ThiefGloves_Equipped") then
				local glovesBonusChance = Ext.ExtraData["LLWEAPONEX_Steal_GlovesBonusChance"] or 30.0
				chance = math.tointeger(chance + glovesBonusChance)
			end
			
			local stolenSuccess = GetVarInteger(data.Target, "LLWEAPONEX_Steal_TotalStolen") or 0
			if stolenSuccess > 0 then
				local stealReduction = Ext.ExtraData["LLWEAPONEX_Steal_SuccessChanceReduction"] or 30.0
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
				StartOneshotTimer("LLWEAPONEX_Pistol_SwapSkills_"..skill..char, 500, function()
					GameHelpers.Skill.Swap(char, skill, nextSkill, true)
				end)
			else
				GameHelpers.Skill.Swap(char, skill, nextSkill, true)
			end
		else
			NRD_SkillSetCooldown(char, skill, 0.0)
		end
	end
end

RegisterSkillListener("Projectile_LLWEAPONEX_HandCrossbow_Shoot", function(...) SwapSkills("Shout_LLWEAPONEX_HandCrossbow_Reload", false, ...) end)
RegisterSkillListener("Shout_LLWEAPONEX_HandCrossbow_Reload", function(...) SwapSkills("Projectile_LLWEAPONEX_HandCrossbow_Shoot", true, ...) end)
RegisterSkillListener("Projectile_LLWEAPONEX_Pistol_Shoot", function(...) SwapSkills("Shout_LLWEAPONEX_Pistol_Reload", false, ...) end)
RegisterSkillListener("Shout_LLWEAPONEX_Pistol_Reload", function(...) SwapSkills("Projectile_LLWEAPONEX_Pistol_Shoot", true, ...) end)
--RegisterSkillListener("Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy", function(...) SwapHandCrossbowSkills(false, ...) end)

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData
RegisterSkillListener("Projectile_LLWEAPONEX_DarkFireball", function(skill, char, state, data)
	if state == SKILL_STATE.CAST then
		local radius = math.max(1.0, Ext.StatGetAttribute("Projectile_LLWEAPONEX_DarkFireball", "ExplodeRadius") - 1.0)
		if data.TotalTargetObjects > 0 then
			for i,v in pairs(data.TargetObjects) do
				local x,y,z = GetPosition(v)
				--SurfaceSmokeCloudCursed
				Osi.LeaderLib_Helper_CreateSurfaceWithOwnerAtPosition(char, x, y, z, "SurfaceFireCursed", radius, 1)
				Osi.LeaderLib_Helper_CreateSurfaceWithOwnerAtPosition(char, x, y, z, "SurfaceFireCloudCursed", radius, 1)
			end
		elseif data.TotalTargetPositions > 0 then
			local x,y,z = table.unpack(data.TargetPositions[1])
			Osi.LeaderLib_Helper_CreateSurfaceWithOwnerAtPosition(char, x, y, z, "SurfaceFireCursed", radius, 1)
			Osi.LeaderLib_Helper_CreateSurfaceWithOwnerAtPosition(char, x, y, z, "SurfaceFireCloudCursed", radius, 1)
		end
	end
end)

RegisterSkillListener({"Projectile_LLWEAPONEX_HandCrossbow_Shoot", "Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"}, function(skill, char, state, data)
	if state == SKILL_STATE.HIT then
		-- Silver bolts / Bullets do bonus damage to undead/voidwoken
		if data.Success and TagHelpers.IsUndeadOrVoidwoken(data.Target) then
			local character = Ext.GetCharacter(char)
			if Skills.HasTaggedRuneBoost(character.Stats, "LLWEAPONEX_SilverAmmo", "_LLWEAPONEX_HandCrossbows") then
				local bonus = Ext.ExtraData.LLWEAPONEX_HandCrossbow_SilverBonusDamage or 1.5
				GameHelpers.Damage.IncreaseDamage(data.Target, char, data.Handle, bonus, false)
			end
		end
	end
end)

RegisterSkillListener({"Projectile_LLWEAPONEX_Pistol_Shoot_LeftHand", "Projectile_LLWEAPONEX_Pistol_Shoot_RightHand"}, function(skill, char, state, data)
	if state == SKILL_STATE.HIT then
		-- Silver bullets do bonus damage to undead/voidwoken
		if data.Success and TagHelpers.IsUndeadOrVoidwoken(data.Target) then
			local character = Ext.GetCharacter(char)
			if Skills.HasTaggedRuneBoost(character.Stats, "LLWEAPONEX_SilverAmmo", "_LLWEAPONEX_Pistols") then
				local bonus = Ext.ExtraData.LLWEAPONEX_Pistol_SilverBonusDamage or 1.5
				GameHelpers.Damage.IncreaseDamage(data.Target, char, data.Handle, bonus, false)
			end
		end
	end
end)

RegisterSkillListener({"Target_LLWEAPONEX_Greatbow_FutureBarrage", "Target_LLWEAPONEX_Greatbow_FutureBarrage_Enemy"}, function(skill, char, state, data)
	if state == SKILL_STATE.CAST then
		data:ForEach(function(target, targetType, d)
			local x,y,z = 0,0,0
			if targetType == "table" then
				x,y,z = table.unpack(target)
			else
				x,y,z = GetPosition(target)
			end
			local delay = math.floor(Ext.ExtraData.LLWEAPONEX_FutureBarrage_TurnDelay or 3)
			if Vars.DebugMode then
				delay = 1
			end
			Osi.LeaderLib_Turns_TrackPositionWithObject(char, x, y, z, "LLWEAPONEX_Greatbow_FutureBarrageFire", delay)
			local handle = PlayScaledLoopEffectAtPosition("LLWEAPONEX_FX_AreaRadiusDecal_Circle_1m_Green_01", 8.0, x, y, z)-- == 4m
			Osi.DB_LLWEAPONEX_Greatbows_Temp_FutureBarrage_LoopFX(char, x, y, z, handle)
			--Osi.DB_LLWEAPONEX_Greatbows_Temp_FutureBarrage_NextEffectPos:Delete(char, x, y, z)
		end, data.TargetMode.All)
	end
end)

Timer.RegisterListener("Timers_LLWEAPON_FutureBarrageDummyCast", function(timerName, caster, dummy)
	if caster and dummy then
		local x,y,z = GetVarFloat3(dummy, "LLWEAPONEX_FutureBarrageTarget")
		--CharacterUseSkill(dummy, "ProjectileStrike_Greatbow_FutureBarrage_RainOfArrows_DummySkill", dummy, 0, 1, 1)
		CharacterUseSkillAtPosition(dummy, "ProjectileStrike_Greatbow_FutureBarrage_RainOfArrows_DummySkill", x, y, z, 0, 1)
		CharacterCharacterSetEvent(caster, dummy, "LLWEAPONEX_Greatbow_FutureBarrage_DummySkillUsed")
	end
end)

local function SetupDummy(dummy, owner)
	CharacterTransformFromCharacter(dummy, owner, 0, 1, 1, 0, 0, 0, 0)
	--SetVisible(dummy, 0)
	CharacterSetDetached(dummy, 1)

	ObjectSetFlag(dummy, "LEADERLIB_IGNORE", 0)
	SetCanJoinCombat(dummy, 0)
	SetCanFight(dummy, 0)
	SetTag(dummy, "LeaderLib_Dummy")
	SetTag(dummy, "SUMMON") -- For Crime/etc to ignore the dummy
	SetVarObject(dummy, "LeaderLib_Dummy_Owner", owner)
	Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_DummyCrimesEnabled", "LeaderLib")

	CharacterMakeStoryNpc(dummy, 1)
	
	SetFaction(dummy, GetFaction(owner))
	CharacterAddAttitudeTowardsPlayer(dummy, owner, 100)
	SetTag(dummy, "LeaderLib_TemporaryCharacter")
	ObjectSetFlag(dummy, "LeaderLib_IsSkillDummy", 0)
end

function FutureBarrage_FireDummySkill(caster, x, y, z)
	x = tonumber(x)
	y = tonumber(y)
	z = tonumber(z)
	local dummy = TemporaryCharacterCreateAtPosition(x, y, z, "LeaderLib_SkillDummy_94668062-11ea-4ecf-807c-4cc225cbb236", 0)
	SetVarFloat3(dummy, "LLWEAPONEX_FutureBarrageTarget", x, y, z)
	SetupDummy(dummy, caster)

	CharacterAddSkill(dummy, "ProjectileStrike_Greatbow_FutureBarrage_RainOfArrows_DummySkill", 0)
	local dummyBow = GameHelpers.Item.CreateItemByStat("WPN_LLWEAPONEX_Greatbow", true, {ItemType = "Common"})
	if dummyBow then
		NRD_CharacterEquipItem(dummy, dummyBow, "Weapon", 0, 0, 0, 1)
	else
		print("Failed to make dummy Greatbow")
	end
	Osi.LeaderLib_Behavior_TeleportTo(dummy, caster)
	Timer.Start("Timers_LLWEAPON_FutureBarrageDummyCast", 250, caster, dummy)
	-- StartOneshotTimer(string.format("Timers_LLWEAPON_FutureBarrageDummyCast_%s", dummy), 250, function()
	-- 	Osi.LeaderLib_Behavior_TeleportTo(dummy, caster)
	-- 	--CharacterUseSkill(dummy, "ProjectileStrike_Greatbow_FutureBarrage_RainOfArrows_DummySkill", dummy, 0, 1, 1)
	-- end)
end
function FutureBarrage_ApplyDamage(caster, target, isBonus)
	if isBonus ~= nil then
		GameHelpers.Damage.ApplySkillDamage(caster, target, "Projectile_LLWEAPONEX_Status_Greatbow_FutureBarrage_Damage", HitFlagPresets.FutureBarrage)
	else
		GameHelpers.Damage.ApplySkillDamage(caster, target, "Projectile_LLWEAPONEX_Status_Greatbow_FutureBarrage_BonusDamage", HitFlagPresets.FutureBarrage)
	end
end
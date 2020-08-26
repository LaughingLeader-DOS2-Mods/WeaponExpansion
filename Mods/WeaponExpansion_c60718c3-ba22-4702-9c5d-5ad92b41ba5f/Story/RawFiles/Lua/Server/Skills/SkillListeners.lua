SKILL_STATE = LeaderLib.SKILL_STATE

local SkillListeners = {
	SkillType = {},
	Element = {},
	Any = {}
}

if SkillManager == nil then
	SkillManager = {}
end

function SkillManager.RegisterTypeListener(skilltype, func)
	skilltype = string.lower(skilltype)
	if SkillListeners.SkillType[skilltype] == nil then
		SkillListeners.SkillType[skilltype] = {}
	end
	table.insert(SkillListeners.SkillType[skilltype], func)
end

function SkillManager.RegisterElementListener(element, func)
	skilltype = string.lower(element)
	if SkillListeners.Element[element] == nil then
		SkillListeners.Element[element] = {}
	end
	table.insert(SkillListeners.Element[element], func)
end

function SkillManager.RegisterAnySkillListener(func)
	table.insert(SkillListeners.Any, func)
end

function OnSkillEvent(uuid, state, skill, skilltype, element)
	for i,callback in ipairs(SkillListeners.SkillType[skilltype]) do
		local b,err = xpcall(callback, debug.traceback, uuid, state, skill, skilltype, element)
		if not b then
			Ext.PrintError(err)
		end
	end
	skilltype = string.lower(skilltype)
	if SkillListeners.SkillType[skilltype] ~= nil then
		for i,callback in ipairs(SkillListeners.SkillType[skilltype]) do
			local b,err = xpcall(callback, debug.traceback, uuid, state, skill, skilltype, element)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData|HitData
local function AimedShotBonuses(skill, char, state, data)
	if state == SKILL_STATE.PREPARE then
		--ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", -1.0, 0, char)
		--Mods.LeaderLib.StartTimer("Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus", 1000, char)
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
end
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Rifle_AimedShot", AimedShotBonuses)

---@param skill string
---@param char string
---@param state SkillState
---@param data HitData
local function Greatbow_PiercingShot_DragonBonus(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		if IsTagged(data.Target, "DRAGON") == 1 then
			ApplyStatus(data.Target, "LLWEAPONEX_DRAGONS_BANE", 6.0, 0, char)
		end
	end
end
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Greatbow_PiercingShot", Greatbow_PiercingShot_DragonBonus)

-- local function CheckAimedShotBonus(data)
-- 	local char = data[1]
-- 	if char ~= nil and HasActiveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY") == 1 then
-- 		local removeStatus = false
-- 		local action = NRD_CharacterGetCurrentAction(char)
-- 		if action ~= "PrepareSkill" and action ~= "UseSkill" then
-- 			removeStatus = true
-- 		else
-- 			local skillprototype = NRD_ActionStateGetString(char, "SkillId")
-- 			if skillprototype ~= "" and skillprototype ~= nil then
-- 				local skill = string.gsub(skillprototype, "_%-?%d+$", "")
-- 				if skill ~= "Projectile_LLWEAPONEX_Rifle_AimedShot" then
-- 					removeStatus = true
-- 				end
-- 			end
-- 		end
-- 		if removeStatus then
-- 			RemoveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY")
-- 		else
-- 			Mods.LeaderLib.StartTimer("Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus", 1000, char)
-- 		end
-- 	end
-- end

-- OnTimerFinished["Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus"] = CheckAimedShotBonus

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData|HitData
local function SkyShot(skill, char, state, data)
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
			LeaderLib.StartTimer("Timers_LLWEAPONEX_ProcGreatbowLightningStrike", 750, char)
		end
	end
end

LeaderLib.RegisterSkillListener("Projectile_SkyShot", SkyShot)
LeaderLib.RegisterSkillListener("Projectile_EnemySkyShot", SkyShot)

local function ProcGreatbowLightningStrike(data)
	local char = data[1]
	if char ~= nil and ObjectGetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus") == 1 then
		local x,y,z = GetVarFloat3(char, "LLWEAPONEX_Omnibolt_SkyShotWorldPosition")
		GameHelpers.ExplodeProjectile(char, {x,y,z}, "Projectile_LLWEAPONEX_Greatbow_LightningStrike")
	end
end

OnTimerFinished["Timers_LLWEAPONEX_ProcGreatbowLightningStrike"] = ProcGreatbowLightningStrike

-- Placeholder until we can check a character's Treasures array
local STEAL_DEFAULT_TREASURE = "ST_LLWEAPONEX_RandomEnemyTreasure"

---@param skill string
---@param char string
---@param state SkillState
---@param data HitData
LeaderLib.RegisterSkillListener("Target_LLWEAPONEX_Steal", function(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		local canStealFrom = IsTagged(data.Target, "LLDUMMY_TrainingDummy") == 0 or Ext.IsDeveloperMode()
		if canStealFrom then
			
			local chance = Ext.ExtraData["LLWEAPONEX_Steal_BaseChance"] or 50.0
			if IsTagged(char, "LLWEAPONEX_ThiefGloves_Equipped") == 1 then
				local glovesBonusChance = Ext.ExtraData["LLWEAPONEX_Steal_GlovesBonusChance"] or 30.0
				chance = math.tointeger(chance + glovesBonusChance)
			end
			
			local stolenSuccess = GetVarInteger(data.Target, "LLWEAPONEX_Steal_TotalStolen") or 0
			if stolenSuccess > 0 then
				local stealReduction = Ext.ExtraData["LLWEAPONEX_Steal_SuccessChanceReduction"] or 30.0
				chance = math.tointeger(math.max(chance - (stolenSuccess * stealReduction), 0))
			end

			local enemy = Ext.GetCharacter(data.Target)
			local name = Ext.GetCharacter(char).DisplayName
			
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
						itemName = Ext.GetItem(ranItem).DisplayName or "an item"
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

--Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy

---@param reverse boolean
---@param skill string
---@param instant boolean
---@param char string
---@param state SkillState
---@param data HitData
local function SwapSkills(nextSkill, instant, skill, char, state, data)
	if state == SKILL_STATE.CAST then
		if CharacterIsInCombat(char) == 1 or instant then
			if instant ~= true then
				LeaderLib.StartOneshotTimer("LLWEAPONEX_Pistol_SwapSkills_"..skill..char, 500, function()
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

LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_HandCrossbow_Shoot", function(...) SwapSkills("Shout_LLWEAPONEX_HandCrossbow_Reload", false, ...) end)
LeaderLib.RegisterSkillListener("Shout_LLWEAPONEX_HandCrossbow_Reload", function(...) SwapSkills("Projectile_LLWEAPONEX_HandCrossbow_Shoot", true, ...) end)
LeaderLib.RegisterSkillListener("Target_LLWEAPONEX_Pistol_Shoot", function(...) SwapSkills("Shout_LLWEAPONEX_Pistol_Reload", false, ...) end)
LeaderLib.RegisterSkillListener("Shout_LLWEAPONEX_Pistol_Reload", function(...) SwapSkills("Target_LLWEAPONEX_Pistol_Shoot", true, ...) end)
--LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy", function(...) SwapHandCrossbowSkills(false, ...) end)

---@param skill string
---@param char string
---@param state SkillState
---@param data SkillEventData
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_DarkFireball", function(skill, char, state, data)
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
local function IgnoreCharacter(uuid)
	return Osi.LeaderLib_Helper_QRY_IgnoreCharacter(uuid) == true or CharacterIsSummon(uuid) == 1 or CharacterIsPartyFollower(uuid) == 1
end

local currentLevel = ""
Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, editorMode)
	currentLevel = region
	Vars.isInCharacterCreation = IsCharacterCreationLevel(region) == 1
	if Vars.isInCharacterCreation then
		Ext.BroadcastMessage("LLWEAPONEX_OnCharacterCreationStarted", "", nil)
	end
end)

Ext.RegisterOsirisListener("RegionEnded", 1, "after", function(region)
	if IsCharacterCreationLevel(region) == 1 then
		Ext.BroadcastMessage("LLWEAPONEX_OnCharacterCreationFinished", "", nil)
		Vars.isInCharacterCreation = false
		GameHelpers.SetScale(Origin.Korvash, 1.1, true)
	end
end)

Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, name, profileId)
	local character = GetCurrentCharacter(id)
	if character ~= nil then
		if Vars.isInCharacterCreation then
			Ext.PostMessageToUser(id, "LLWEAPONEX_OnCharacterCreationStarted", "")
		end
	end
end)

local function IncreaseKillCount(char, fromTargetDying)
	if CharacterHasSkill(char, "Projectile_LLWEAPONEX_DarkFireball") == 1 then
		local character = Ext.GetCharacter(char)
		local maxCount = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_MaxKillCount", 10)
		local current = PersistentVars.SkillData.DarkFireballCount[character.MyGuid] or 0
		if current < maxCount then
			PersistentVars.SkillData.DarkFireballCount[character.MyGuid] = current + 1
			if PersistentVars.SkillData.DarkFireballCount[character.MyGuid] >= 1 then
				UpdateDarkFireballSkill(char)
			end
			SyncDataToClient(CharacterGetReservedUserID(char))
			if Vars.DebugMode then
				print("IncreaseKillCount", char, PersistentVars.SkillData.DarkFireballCount[character.MyGuid], maxCount)
			end
		end
	end
end

if Vars.DebugMode then
	Ext.RegisterConsoleCommand("llweaponex_killcount", function(cmd)
		local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
		IncreaseKillCount(host)
	end)
end

local function SkipDeathXP(uuid, region)
	-- Ignore Windigo Source Blast
	if region == "TUT_Tutorial_A" then
		local killedDB = Osi.DB_TUT_WindegoKilledNPC:Get(nil)
		for i,v in pairs(killedDB) do
			if StringHelpers.GetUUID(v[1]) == uuid then
				return true
			end
		end
	end
	return false
end

function OnCharacterDied(uuid, force)
	PersistentVars.MasteryMechanics.BowCumulativeCriticalChance[uuid] = nil
	if force == true or not SkipDeathXP(uuid, GetRegion(uuid)) then
		local id = CombatGetIDForCharacter(uuid)
		--print("OnCharacterDied", uuid, id)
		if id ~= nil then
			for i,entry in pairs(Osi.DB_CombatCharacters:Get(nil, id)) do
				local v = StringHelpers.GetUUID(entry[1])
				if not GameHelpers.Character.IsPlayer(v) and not GameHelpers.Character.IsEnemy(uuid, v) then
					SetTag(v, "LLWEAPONEX_EnemyDiedInCombat")
					IncreaseKillCount(v, uuid)
				end
			end
		else
			local x,y,z = GetPosition(uuid)
			for i,v in pairs(Ext.GetCharactersAroundPosition(x, y, z, 20.0)) do
				if not GameHelpers.Character.IsPlayer(v) and GameHelpers.Character.IsEnemy(uuid, v) then
					SetTag(v, "LLWEAPONEX_EnemyDiedInCombat")
					IncreaseKillCount(v, uuid)
				end
			end
		end
	end
end

RegisterProtectedOsirisListener("CharacterPrecogDying", 1, "after", function(char)
	if ObjectExists(char) == 1 and not StringHelpers.IsNullOrEmpty(char) and not IgnoreCharacter(char) then
		OnCharacterDied(StringHelpers.GetUUID(char))
	end
end)

local function ReloadAmmoSkills(uuid)
	if CharacterHasSkill(uuid, "Shout_LLWEAPONEX_HandCrossbow_Reload") == 1 then
		GameHelpers.Skill.Swap(uuid, "Shout_LLWEAPONEX_HandCrossbow_Reload", "Projectile_LLWEAPONEX_HandCrossbow_Shoot", true, true)
	end
	if CharacterHasSkill(uuid, "Shout_LLWEAPONEX_Pistol_Reload") == 1 then
		GameHelpers.Skill.Swap(uuid, "Shout_LLWEAPONEX_Pistol_Reload", "Projectile_LLWEAPONEX_Pistol_Shoot", true, true)
	end
end

-- Ext.RegisterOsirisListener("ObjectWasTagged", 2, "after", function(object, tag)


-- end)

Ext.RegisterOsirisListener("ObjectLostTag", 2, "after", function(object, tag)
	if ObjectExists(object) == 0 then
		return
	end
	if tag == "LLWEAPONEX_Unarmed" then
		EquipmentManager:CheckWeaponRequirementTags(Ext.GetCharacter(object))
	end
end)

local LoneWolfBannerLifeStealScale = {
	[0] = 5,
	[8] = 10,
	[12] = 25,
	[16] = 30,
}

Ext.RegisterOsirisListener("CharacterLeveledUp", 1, "after", function(uuid)
	uuid = StringHelpers.GetUUID(uuid)
	local character = Ext.GetCharacter(uuid)
	if character and GameHelpers.Character.IsPlayer(character) then
		local loneWolfBanner = Uniques.LoneWolfBanner:GetUUID(uuid)
		if loneWolfBanner then
			local level = CharacterGetLevel(uuid)
			if level > 1 then
				local stat = Ext.GetStat("Stats_LLWEAPONEX_Banner_Rally_Dwarves_AuraBonus")
				if stat ~= nil then
					local newLifeSteal = (math.ceil((5 - 1) / 100.0 * (Ext.ExtraData.AttributeLevelGrowth + Ext.ExtraData.AttributeBoostGrowth) * level) * Ext.ExtraData.AttributeGrowthDamp) + 5
					PrintDebug("Stats_LLWEAPONEX_Banner_Rally_Dwarves_AuraBonus", level, newLifeSteal)
				end
			end
		end
		--for _,slotName in Data.VisibleEquipmentSlots:Get() do
		for i,v in pairs(character:GetInventoryItems()) do
			local item = Ext.GetItem(v)
			if item ~= nil and item.Stats ~= nil then
				UniqueManager.LevelUpUnique(character, item)
			end
		end
	end
end)

function OnRest(target, source)
	ReloadAmmoSkills(target)
	if IsTagged(target, "LLWEAPONEX_Quiver_Equipped") then
		local quiver = Ext.GetCharacter(target).Stats:GetItemBySlot("Belt")
		if quiver ~= nil then
			ItemResetChargesToMax(quiver.MyGuid)
		end
	end
end

-- Why is this happening?
-- RegisterProtectedOsirisListener("SkillAdded", 3, "after", function(char, skill, learned)
-- 	if IsTagged(char, "TOTEM") == 1 and skill == "Target_SingleHandedAttack" then
-- 		CharacterRemoveSkill(char, skill)
-- 	end
-- end)

--- @param request EsvShootProjectileRequest
-- Ext.RegisterListener("BeforeShootProjectile", function (request)
--     print(string.format("(%s) BeforeShootProjectile(%s)", Ext.MonotonicTime(), request.Target))
-- end)

-- ---@param projectile EsvProjectile
-- Ext.RegisterListener("ShootProjectile", function(projectile)
-- 	print(string.format("(%s) ShootProjectile(%s)", Ext.MonotonicTime(), projectile.RootTemplate))
-- end)

-- ---@param projectile EsvProjectile
-- ---@param hitObject EsvGameObject
-- ---@param position number[]
-- Ext.RegisterListener("ProjectileHit", function (projectile, hitObject, position)
-- 	local char = Ext.GetCharacter(projectile.SourceHandle)
-- 	local item = Ext.GetItem(CharacterGetEquippedWeapon(char.MyGuid))
-- 	print(string.format("ProjectileHit(%s) RootTemplate(%s) Weapon.Stats.Projectile(%s)", Ext.MonotonicTime(), projectile.RootTemplate.Name, item.Stats.Projectile))
-- 	if item:HasTag("LLWEAPONEX_Firearm") then
-- 		for i,v in pairs(item.Stats.DynamicStats) do
-- 			if not StringHelpers.IsNullOrEmpty(v.BoostName) and not StringHelpers.IsNullOrEmpty(v.Projectile) and v.Projectile ~= item.Stats.Projectile then
-- 				print(i, v.BoostName, v.Projectile)
-- 			end
-- 		end
-- 	end
-- end)

Events.Initialized:Subscribe(function(e)
	local region = e.Region
	if not StringHelpers.IsNullOrEmpty(region) then
		if IsGameLevel(region) == 1 then
			Timer.Start("LLWEAPONEX_InitUniques", 500)
		end
		if IsCharacterCreationLevel(region) == 1 then
			Ext.BroadcastMessage("LLWEAPONEX_OnCharacterCreationStarted", "", nil)
		end
	end
	if PersistentVars.AttributeRequirementChanges then
		local existingChanges = {}
		for itemGUID,attribute in pairs(PersistentVars.AttributeRequirementChanges) do
			if ObjectExists(itemGUID) == 1 then
				existingChanges[itemGUID] = attribute
				local item = GameHelpers.GetItem(itemGUID)
				if item then
					local doSync = false
					for _,req in pairs(item.Stats.Requirements) do
						if req.Requirement ~= attribute and Data.AttributeEnum[req.Requirement] then
							req.Requirement = attribute
							doSync = true
						end
					end
					if doSync then
						GameHelpers.Net.Broadcast("LLWEAPONEX_ChangeAttributeRequirement", {Item=item.NetID, Attribute=attribute})
					end
				end
			end
		end
		PersistentVars.AttributeRequirementChanges = existingChanges
	end
end)

TurnEndRemoveTags = {
	LLWEAPONEX_EnemyDiedInCombat = true,
	LLWEAPONEX_BattleBook_ScrollBonusAP = true,
}

local function RemoveTagsOnTurnEnd(uuid)
	for tag,b in pairs(TurnEndRemoveTags) do
		if b then
			ClearTag(uuid, tag)
		end
	end
end

---@param uuid UUID
---@param id integer
local function OnLeftCombat(uuid, id)
	ReloadAmmoSkills(uuid)
	StatusTurnHandler.RemoveAllTurnEndStatuses(uuid)
	RemoveTagsOnTurnEnd(uuid)
	PersistentVars.MasteryMechanics.BowCumulativeCriticalChance[uuid] = nil
end

Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "after", function(obj)
	if ObjectExists(obj) == 1 and ObjectIsCharacter(obj) == 1 then
		obj = StringHelpers.GetUUID(obj)
		StatusTurnHandler.RemoveAllTurnEndStatuses(obj)
		RemoveTagsOnTurnEnd(obj)
	end
end)

RegisterProtectedOsirisListener("ObjectLeftCombat", 2, "after", function(obj,id)
	if ObjectExists(obj) == 1 and ObjectIsCharacter(obj) == 1 then
		obj = StringHelpers.GetUUID(obj)
		OnLeftCombat(obj, id)
	end
end)

--- @param char string
--- @param skill string
--- @param skillType string
--- @param skillElement string
local function OnSkillCast(char, skill, skillType, skillElement)
	char = StringHelpers.GetUUID(char)
	if GameHelpers.Character.IsPlayer(char) then
		if skill == "Shout_LLWEAPONEX_OpenMenu" then
			OpenMasteryMenu(GameHelpers.GetCharacter(char))
		end
	end
	if Skills.BulletTemplates[skill] and IsTagged(char, "LLWEAPONEX_Firearm_Equipped") == 1 then
		GameHelpers.Status.Apply(char, "LLWEAPONEX_FIREARM_SHOOT_EXPLOSION_FX", 0.0, 0, char)
	end
	-- if ObjectGetFlag(char, "LLWEAPONEX_BasilusDagger_ListenForAction") == 1 then
	-- 	Basilus_OnTargetActionTaken(char)
	-- end
end
Ext.RegisterOsirisListener("SkillCast", 4, "after", OnSkillCast)
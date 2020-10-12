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
		Ext.GetCharacter(Origin.Korvash):SetScale(1.1)
	end
end)

Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, name, profileId)
	local character = GetCurrentCharacter(id)
	if character ~= nil then
		if Vars.isInCharacterCreation then
			Ext.PostMessageToUser(id, "LLWEAPONEX_OnCharacterCreationStarted", "")
		else
			Ext.PostMessageToUser(id, "LLWEAPONEX_InitializeMasteryMenu", "")
		end
	end
end)

local function IncreaseKillCount(char, fromTargetDying)
	if CharacterHasSkill(char, "Projectile_LLWEAPONEX_DarkFireball") == 1 then
		local character = Ext.GetCharacter(char)
		local maxCount = Ext.ExtraData["LLWEAPONEX_DarkFireball_MaxKillCount"] or 10
		local current = PersistentVars.SkillData.DarkFireballCount[character.NetID] or 0
		if current < maxCount then
			PersistentVars.SkillData.DarkFireballCount[character.NetID] = current + 1
			if PersistentVars.SkillData.DarkFireballCount[character.NetID] >= 1 then
				UpdateDarkFireballSkill(char)
			end
			--print("IncreaseKillCount", char, current, maxCount)
		end
	end
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
	if force == true or not SkipDeathXP(uuid, GetRegion(uuid)) then
		local id = CombatGetIDForCharacter(uuid)
		--print("OnCharacterDied", uuid, id)
		if id ~= nil then
			for i,entry in pairs(Osi.DB_CombatCharacters:Get(nil, id)) do
				local v = StringHelpers.GetUUID(entry[1])
				if IsPlayer(v) and CharacterIsEnemy(uuid, v) == 1 then
					SetTag(v, "LLWEAPONEX_EnemyDiedInCombat")
					IncreaseKillCount(v, uuid)
				end
			end
		else
			local x,y,z = GetPosition(uuid)
			for i,v in pairs(Ext.GetCharactersAroundPosition(x, y, z, 20.0)) do
				if IsPlayer(v) and CharacterIsEnemy(uuid, v) == 1 then
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
		GameHelpers.Skill.Swap(uuid, "Shout_LLWEAPONEX_Pistol_Reload", "Target_LLWEAPONEX_Pistol_Shoot", true, true)
	end
end

local function OnLeftCombat(uuid, id)
	ClearTag(uuid, "LLWEAPONEX_EnemyDiedInCombat")
	ReloadAmmoSkills(uuid)
end

RegisterProtectedOsirisListener("ObjectLeftCombat", 2, "after", function(object,id)
	if ObjectIsCharacter(object) == 1 then
		OnLeftCombat(StringHelpers.GetUUID(object), id)
	end
end)

-- Ext.RegisterOsirisListener("ObjectWasTagged", 2, "after", function(object, tag)


-- end)

Ext.RegisterOsirisListener("ObjectLostTag", 2, "after", function(object, tag)
	if tag == "LLWEAPONEX_Unarmed" then
		Equipment.CheckWeaponRequirementTags(StringHelpers.GetUUID(object))
	end
end)

local LoneWolfBannerLifeStealScale = {
	[0] = 5,
	[8] = 10,
	[12] = 25,
	[16] = 30,
}

Ext.RegisterOsirisListener("CharacterLeveledUp", 1, "after", function(character)
	character = StringHelpers.GetUUID(character)
	if IsPlayer(character) then
		if Uniques.LoneWolfBanner.Owner == GetUUID(character) then
			local level = CharacterGetLevel(character)
			if level > 1 then
				local stat = Ext.GetStat("Stats_LLWEAPONEX_Banner_Rally_Dwarves_AuraBonus")
				if stat ~= nil then
					local newLifeSteal = (math.ceil((5 - 1) / 100.0 * (Ext.ExtraData.AttributeLevelGrowth + Ext.ExtraData.AttributeBoostGrowth) * level) * Ext.ExtraData.AttributeGrowthDamp) + 5
					printd("Stats_LLWEAPONEX_Banner_Rally_Dwarves_AuraBonus", level, newLifeSteal)
				end
			end
		end
		for id,unique in pairs(Uniques) do
			if unique.Owner == character then
				unique:ApplyProgression()
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
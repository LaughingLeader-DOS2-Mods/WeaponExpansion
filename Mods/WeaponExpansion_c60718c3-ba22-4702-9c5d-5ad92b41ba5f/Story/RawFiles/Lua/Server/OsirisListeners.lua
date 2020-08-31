local currentLevel = ""
Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, editorMode)
	currentLevel = region
	Vars.isInCharacterCreation = IsCharacterCreationLevel(region) == 1
	if Vars.isInCharacterCreation then
		Ext.BroadcastMessage("LLWEAPONEX_OnCharacterCreationStarted", "", nil)
	else
		for id,unique in pairs (Uniques) do
			unique:OnLevelChange(region)
		end
	end
end)

Ext.RegisterOsirisListener("RegionEnded", 1, "after", function(region)
	if IsCharacterCreationLevel(region) == 1 then
		Ext.BroadcastMessage("LLWEAPONEX_OnCharacterCreationFinished", "", nil)
		Vars.isInCharacterCreation = false
		Ext.GetCharacter(Mercs.Korvash):SetScale(1.1)
	end
end)

Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, name, profileId)
	local character = GetCurrentCharacter(id)
	if character ~= nil then
		if Vars.isInCharacterCreation then
			Ext.PostMessageToClient(character, "LLWEAPONEX_OnCharacterCreationStarted", "")
		end
		Ext.PostMessageToUser(id, "LLWEAPONEX_SetActiveCharacter", GetUUID(character))
	end
end)

---@param target string
---@param source string
---@param item EsvItem
local function ApplyRuneExtraProperties(target, source, item)
	local runes = ExtenderHelpers.GetRuneBoosts(item.Stats)
	if #runes > 0 then
		print(Ext.JsonStringify(runes))
		for i,runeEntry in pairs(runes) do
			for attribute,boost in pairs(runeEntry.Boosts) do
				if boost ~= nil and boost ~= "" then
					---@type StatProperty[]
					local extraProperties = Ext.StatGetAttribute(boost, "ExtraProperties")
					if extraProperties ~= nil then
						print(Ext.JsonStringify(extraProperties))
						for i,v in pairs(extraProperties) do
							if v.Type == "Status" then
								if v.StatusChance < 1.0 then
									local statusObject = {
										StatusId = v.Action,
										StatusType = Ext.StatGetAttribute(v.Action, "StatusType"),
										ForceStatus = false,
										StatusSourceHandle = source,
										TargetHandle = target,
										CanEnterChance = math.tointeger(v.StatusChance * 100)
									}
									local chance = Game.Math.StatusGetEnterChance(statusObject, true)
									local roll = Ext.Random(0,100)
									print(v.Action, chance, roll)
									if roll <= chance then
										ApplyStatus(target, v.Action, v.Duration, 0, source)
									end
								else
									ApplyStatus(target, v.Action, v.Duration, 0, source)
								end
							elseif v.Type == "SurfaceTransform" then
								local x,y,z = GetPosition(target)
								TransformSurfaceAtPosition(x, y, z, v.Action, "Ground", 1.0, 6.0, source)
							end
						end
					end
				end
			end
		end
	end
end

local function OnStatusApplied(target, status, source)
	if source ~= nil and ObjectIsCharacter(source) == 1 then
		if status == "LLWEAPONEX_PISTOL_SHOOT_HIT" then
			local items = GameHelpers.Item.FindTaggedEquipment(source, "LLWEAPONEX_Pistol")
			if items ~= nil then
				for slot,v in pairs(items) do
					ApplyRuneExtraProperties(target, source, Ext.GetItem(v))
				end
			end
		elseif status == "LLWEAPONEX_HANDCROSSBOW_HIT" then
			local items = GameHelpers.Item.FindTaggedEquipment(source, "LLWEAPONEX_HandCrossbow")
			if items ~= nil then
				for slot,v in pairs(items) do
					ApplyRuneExtraProperties(target, source, Ext.GetItem(v))
				end
			end
		end
	end
	local callbacks = Listeners.Status[status]
	if callbacks ~= nil then
		for i,callback in pairs(callbacks) do
			local b,err = xpcall(callback, debug.traceback, target, status, source)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end
Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "after", OnStatusApplied)
Ext.RegisterOsirisListener("ItemStatusChange", 3, "after", OnStatusApplied)

Ext.RegisterOsirisListener("NRD_OnStatusAttempt", 4, "after", function(target, status, handle, source)
	if #Listeners.StatusAttempt	> 0 then
		local callbacks = Listeners.StatusAttempt[status]
		if callbacks ~= nil then
			for i,callback in pairs(callbacks) do
				local s,err = xpcall(callback, debug.traceback, target, status, handle, source)
				if not s then
					Ext.PrintError(err)
				end
			end
		end
	end
end)

local function IncreaseKillCount(char, fromTargetDying)
	if CharacterHasSkill(char, "Projectile_LLWEAPONEX_DarkFireball") == 1 then
		local maxCount = Ext.ExtraData["LLWEAPONEX_DarkFireball_MaxKillCount"] or 10
		local current = PersistentVars.SkillData.DarkFireballCount[char] or 0
		if current < maxCount then
			PersistentVars.SkillData.DarkFireballCount[char] = current + 1
			SyncVars()
			if PersistentVars.SkillData.DarkFireballCount[char] >= 1 then
				UpdateDarkFireballSkill(char)
			end
		end
	end
end

local function OnCharacterDied(char)
	local id = CombatGetIDForCharacter(char)
	if id ~= nil then
		for i,entry in pairs(Osi.DB_CombatCharacters:Get(nil, id)) do
			local v = GetUUID(entry[1])
			if IsPlayer(v) and CharacterIsEnemy(char, v) == 1 then
				SetTag(v, "LLWEAPONEX_EnemyDiedInCombat")
				IncreaseKillCount(v, char)
			end
		end
	else
		local x,y,z = GetPosition(char)
		for i,v in pairs(Ext.GetCharactersAroundPosition(x, y, z, 20.0)) do
			if IsPlayer(v) and CharacterIsEnemy(char, v) == 1 then
				SetTag(v, "LLWEAPONEX_EnemyDiedInCombat")
				IncreaseKillCount(v, char)
			end
		end
	end
end

Ext.RegisterOsirisListener("CharacterDied", 1, "after", OnCharacterDied)

local function OnLeftCombat(char, id)
	ClearTag(char, "LLWEAPONEX_EnemyDiedInCombat")
end

Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", OnLeftCombat)

Ext.RegisterOsirisListener("ObjectWasTagged", 2, "after", function(object, tag)


end)

Ext.RegisterOsirisListener("ObjectLostTag", 2, "after", function(object, tag)
	if tag == "LLWEAPONEX_Unarmed" then
		Equipment.CheckWeaponRequirementTags(GetUUID(object))
	end
end)

local LoneWolfBannerLifeStealScale = {
	[0] = 5,
	[8] = 10,
	[12] = 25,
	[16] = 30,
}

Ext.RegisterOsirisListener("CharacterLeveledUp", 1, "after", function(character)
	if IsPlayer(character) and Uniques.LoneWolfBanner.Owner == GetUUID(character) then
		local level = CharacterGetLevel(character)
		if level > 1 then
			local stat = Ext.GetStat("Stats_LLWEAPONEX_Banner_Rally_Dwarves_AuraBonus")
			if stat ~= nil then
				local newLifeSteal = (math.ceil((5 - 1) / 100.0 * (Ext.ExtraData.AttributeLevelGrowth + Ext.ExtraData.AttributeBoostGrowth) * level) * Ext.ExtraData.AttributeGrowthDamp) + 5
				print("Stats_LLWEAPONEX_Banner_Rally_Dwarves_AuraBonus", level, newLifeSteal)
			end
		end
	end
	
end)

local levelTest = 1
Ext.RegisterConsoleCommand("scaletest", function(cmd, levelstr)
	local level = tonumber(levelstr) or levelTest + 1
	local newLifeSteal = (math.ceil(((5*(level*.7)) - 1) / 100.0 * (Ext.ExtraData.AttributeLevelGrowth + Ext.ExtraData.AttributeBoostGrowth) * level) * Ext.ExtraData.AttributeGrowthDamp) + 5
	print("Stats_LLWEAPONEX_Banner_Rally_Dwarves_AuraBonus|LifeSteal", level, newLifeSteal)
	levelTest = level
end)
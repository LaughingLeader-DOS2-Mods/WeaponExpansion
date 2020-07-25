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
	if Vars.isInCharacterCreation then
		Ext.PostMessageToClient(character, "LLWEAPONEX_OnCharacterCreationStarted", "")
	end
	Ext.PostMessageToClient(character, "LLWEAPONEX_SetActiveCharacter", GetUUID(character))
end)

Ext.RegisterOsirisListener("ItemLockUnEquip", 2, "after", function(item, locked)
	print("ItemLockUnEquip", item, locked)
	if locked == 1 then
		ObjectSetFlag(item, "LLWEAPONEX_ItemIsLocked", 0)
	else
		ObjectClearFlag(item, "LLWEAPONEX_ItemIsLocked", 0)
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
			local items = GameHelpers.FindTaggedEquipment(source, "LLWEAPONEX_Pistol")
			if items ~= nil then
				print(Ext.JsonStringify(items))
				for slot,v in pairs(items) do
					ApplyRuneExtraProperties(target, source, Ext.GetItem(v))
				end
			end
		elseif status == "LLWEAPONEX_HANDCROSSBOW_HIT" then
			local items = GameHelpers.FindTaggedEquipment(source, "LLWEAPONEX_HandCrossbow")
			if items ~= nil then
				for slot,v in pairs(items) do
					ApplyRuneExtraProperties(target, source, Ext.GetItem(v))
				end
			end
		end
	end
end
Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "after", OnStatusApplied)
Ext.RegisterOsirisListener("ItemStatusChange", 3, "after", OnStatusApplied)

local function OnCharacterDied(char)
	local id = CombatGetIDForCharacter(char)
	if id ~= nil then
		for i,entry in pairs(Osi.DB_CombatCharacters:Get(nil, id)) do
			if CharacterIsEnemy(char, entry[1]) == 1 then
				SetTag(entry[1], "LLWEAPONEX_EnemyDiedInCombat")
			end
		end
	else
		local x,y,z = GetPosition(char)
		for i,v in pairs(Ext.GetCharactersAroundPosition(x, y, z, 20.0)) do
			if CharacterIsEnemy(char, v) == 1 and CharacterIsInCombat(v) == 1 then
				SetTag(entry[1], "LLWEAPONEX_EnemyDiedInCombat")
			end
		end
	end

	if CharacterIsPlayer(Mercs.Korvash) == 1 and CharacterCanSee(Mercs.Korvash, char) == 1 and CharacterIsEnemy(Mercs.Korvash, char) == 1 then
		PersistentVars.SkillData.DarkFireballCount = math.max(PersistentVars.SkillData.DarkFireballCount + 1, 10)
		--Ext.PostMessageToClient(Mercs.Korvash, "LLWEAPONEX_SyncVars", Ext.JsonStringify(PersistentVars))
		SyncVars()
		if PersistentVars.SkillData.DarkFireballCount >= 1 then
			UpdateDarkFireballSkill()
		end
	end
end

Ext.RegisterOsirisListener("CharacterDied", 1, "after", OnCharacterDied)

local function OnLeftCombat(char, id)
	ClearTag(char, "LLWEAPONEX_EnemyDiedInCombat")
end

Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", OnLeftCombat)
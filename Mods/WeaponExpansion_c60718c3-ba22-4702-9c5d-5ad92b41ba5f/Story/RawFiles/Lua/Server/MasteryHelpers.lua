

local function HasMinimumMasteryLevel(uuid,mastery,minLevel)
	--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
	local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
	if dbEntry ~= nil then
		local masteryLevel = dbEntry[1][3]
		if masteryLevel ~= nil and masteryLevel >= minLevel then
			return masteryLevel
		end
	end
end

Ext.NewQuery(HasMinimumMasteryLevel, "LLWEAPONEX_Ext_QRY_HasMinimumMasteryLevel", "[in](CHARACTERGUID)_Character, [in](STRING)_Mastery, [in](INTEGER)_MinLevel, [out](INTEGER)_Level")

function TagMasteryRanks(uuid,mastery,level)
	if level > 0 then
		for i=1,level,1 do
			local tag = mastery.."_Mastery"..tostring(i)
			SetTag(uuid, tag)
			--LeaderLib.PrintDebug("[WeaponExpansion:TagMasteryRanks] Setting tag ["..tag.."] on ["..uuid.."]")
		end
	end
end

--- Callback for when a character's mastery levels up.
--- @param uuid string
--- @param mastery string
--- @param last integer
--- @param next integer
local function MasteryLeveledUp(uuid,mastery,last,next)
	local masteryData = Masteries[mastery]
	local masteryName = string.format("<font color='%s'>%s %s</font>", masteryData.Color, masteryData.Name.Value, Text.Mastery.Value)
	local text = string.gsub(Text.MasteryLeveledUp.Value, "%[1%]", masteryName):gsub("%[2%]", next)
	CharacterStatusText(uuid, text)
	-- if CharacterIsPlayer(uuid) == 1 and CharacterIsControlled(uuid) == 1 then
	-- 	ShowNotification(uuid, text)
	-- else
	-- 	CharacterStatusText(uuid, text)
	-- end
	TagMasteryRanks(uuid,mastery,next)

	-- Set the special rank 1+ unarmed tags.
	if mastery == "LLWEAPONEX_Unarmed" and next == 1 then
		EquipmentManager.CheckWeaponRequirementTags(uuid)
	end

	LeaderLib.PrintDebug(string.format("[WeaponExpansion] Mastery [%s] leveled up (%i => %i) on [%s]", mastery, last, next, uuid))
	local name = Ext.GetCharacter(uuid).DisplayName
	local text = Text.CombatLog.MasteryRankUp:ReplacePlaceholders(name, masteryName, next)
	GameHelpers.UI.CombatLog(text)
end

--- Adds mastery experience a specific masteries.
--- @param uuid string
--- @param mastery string
--- @param expGain number
--- @param skipFlagCheck boolean
function AddMasteryExperience(uuid,mastery,expGain,skipFlagCheck)
	if skipFlagCheck == true or ObjectGetFlag(uuid, "LLWEAPONEX_DisableWeaponMasteryExperience") == 0 then
		expGain = expGain or 0.25
		local currentLevel = 0
		local currentExp = 0
		--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
		local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
		if dbEntry ~= nil then
			local playerEntry = dbEntry[1]
			if playerEntry ~= nil then
				currentLevel = playerEntry[3]
				currentExp = playerEntry[4]

				if currentExp == nil then currentExp = 0 end
			end
		end

		if currentLevel < 4 then
			local expAmountData = Mastery.Variables.RankVariables[currentLevel]
			local maxAddExp = expAmountData.Amount
			local nextLevelExp = Mastery.Variables.RankVariables[currentLevel+1].Required
			local nextLevel = currentLevel

			local nextExp = Ext.Round(currentExp + (maxAddExp * expGain))
			if nextExp >= nextLevelExp then
				nextLevel = currentLevel + 1
				if nextLevel >= Mastery.Variables.MaxRank then
					nextExp = nextLevelExp
				end
			end

			if Ext.IsDeveloperMode() then
				if currentExp == nil then currentExp = 0 end
				if nextExp == nil then nextExp = 0 end
				Ext.PrintWarning("Mastery XP:",uuid, mastery, currentExp, "=>", nextExp)
			end

			Osi.LLWEAPONEX_WeaponMastery_Internal_StoreExperience(uuid, mastery, nextLevel, nextExp)

			if nextLevel > currentLevel then
				MasteryLeveledUp(uuid, mastery, currentLevel, nextLevel)
			end
		end
	end
end

Ext.NewCall(AddMasteryExperience, "LLWEAPONEX_Ext_AddMasteryExperience", "(CHARACTERGUID)_Character, (STRING)_Mastery, (REAL)_ExperienceGain")

local function ItemIsTagged(item, tag)
	if item == nil then
		return false
	end
	return IsTagged(item, tag) == 1
end

--- Adds mastery experience for all active masteries on equipped weapons.
--- @param uuid string
--- @param expGain number
function AddMasteryExperienceForAllActive(uuid,expGain)
	if ObjectGetFlag(uuid, "LLWEAPONEX_DisableWeaponMasteryExperience") == 0 then
		--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
		--local offhand = CharacterGetEquippedItem(uuid, "Shield")
		for mastery,masterData in pairs(Masteries) do
			-- if ItemIsTagged(mainhand) or ItemIsTagged(offhand) then
			-- 	AddMasteryExperience(uuid,mastery,expGain)
			-- end
			if IsTagged(uuid,mastery) == 1 then
				AddMasteryExperience(uuid,mastery,expGain,true)
			end
		end
	end
end

Ext.NewCall(AddMasteryExperienceForAllActive, "LLWEAPONEX_Ext_AddMasteryExperienceForAllActive", "(CHARACTERGUID)_Character, (REAL)_ExperienceGain")

local function HasRequirement(val, matchAny)
	if matchAny == nil then
		return val ~= nil and val ~= "None" and val ~= ""
	else
		if val ~= nil and val ~= "None" and val ~= "" then
			for i,v in pairs(matchAny) do
				if val == v then
					return true
				end
			end
		end
		return false
	end
end

function IsWeaponSkill(skill)
	if skill == nil or skill == "" then
		return false
	end
	local stat = Ext.GetStat(skill)
	if stat ~= nil then
		if (stat.UseWeaponDamage == "Yes" 
		or stat.UseWeaponProperties == "Yes")
		or (HasRequirement(stat.Requirement) and stat["Damage Multiplier"] > 0) then
			return true
		end
	end
	return false
end

function IsMeleeWeaponSkill(skill)
	if skill == nil or skill == "" then
		return false
	end
	local stat = Ext.GetStat(skill)
	if stat ~= nil then
		if (stat.UseWeaponDamage == "Yes" 
		or stat.UseWeaponProperties == "Yes")
		or (HasRequirement(stat.Requirement, {"MeleeWeapon", "DaggerWeapon", "StaffWeapon", "ShieldWeapon"}) and stat["Damage Multiplier"] > 0) then
			return true
		end
	end
	return false
end

--- @param uuid string
--- @param mastery string
function OnMasteryDeactivated(uuid,mastery)
	ClearTag(uuid,mastery)
	LeaderLib.PrintDebug("[WeaponExpansion] Cleared mastery tag ["..mastery.."] on ["..uuid.."].")
	local callbacks = Listeners.MasteryDeactivated[mastery]
	if callbacks ~= nil then
		for i,callback in pairs(callbacks) do
			local b,err = xpcall(callback, debug.traceback, uuid, mastery)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

--- @param uuid string
--- @param mastery string
--- @param minLevel integer
function HasMasteryLevel(uuid,mastery,minLevel)
	local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
	if dbEntry ~= nil then
		local playerEntry = dbEntry[1]
		if playerEntry ~= nil then
			local currentLevel = playerEntry[3]
			--currentExp = playerEntry[4]
			return currentLevel >= minLevel
		end
	end
	return false
end

function HasMasteryRequirement_QRY(call, uuid, tag)
	return Mastery.HasMasteryRequirement(Ext.GetCharacter(uuid), tag)
end


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
	local masteryName = Masteries[mastery].Name.Value:gsub("</font>", Text.Mastery.Value .. " </font>")
	local text = string.gsub(Text.MasteryLeveledUp.Value, "%[1%]", masteryName):gsub("%[2%]", next)
	if CharacterIsPlayer(uuid) == 1 and CharacterIsControlled(uuid) then
		ShowNotification(uuid, text)
	else
		CharacterStatusText(uuid, text)
	end
	TagMasteryRanks(uuid,mastery,next)

	LeaderLib.PrintDebug("[WeaponExpansion] Mastery ["..mastery.."] leveled up ("..tostring(last).." => "..tostring(last)..") on ["..uuid.."]")
end

--- Adds mastery experience a specific masteries.
--- @param uuid string
--- @param mastery string
--- @param expGain number
--- @param skipFlagCheck boolean
function AddMasteryExperience(uuid,mastery,expGain)
	if skipFlagCheck == true or ObjectGetFlag(uuid, "LLWEAPONEX_DisableWeaponMasteryExperience") == 0 then
		local currentLevel = 0
		local currentExp = 0
		--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
		local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
		LeaderLib.PrintDebug("[MasteryHelpers:AddMasteryExperience] dbEntry")
		LeaderLib.PrintDebug(LeaderLib.Common.Dump(dbEntry))
		if dbEntry ~= nil then
			local playerEntry = dbEntry[1]
			if playerEntry ~= nil then
				currentLevel = playerEntry[3]
				currentExp = playerEntry[4]
			end
		end

		if currentLevel < 4 then
			local expAmountData = Mastery.Variables.RankVariables[currentLevel]
			local maxAddExp = expAmountData.Amount
			local nextLevelExp = expAmountData.NextLevel
			local nextLevel = currentLevel

			currentExp = currentExp + (maxAddExp * expGain)
			if currentExp >= nextLevelExp then
				nextLevel = currentLevel + 1
			end

			Osi.LLWEAPONEX_WeaponMastery_Internal_StoreExperience(uuid, mastery, nextLevel, currentExp)

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

--- @param uuid string
--- @param mastery string
function OnMasteryDeactivated(uuid,mastery)
	ClearTag(uuid,mastery)
	LeaderLib.PrintDebug("[WeaponExpansion] Cleared mastery tag ["..mastery.."] on ["..uuid.."].")
end
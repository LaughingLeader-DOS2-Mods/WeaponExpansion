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

local function AddMasteryExperience(uuid,mastery,expGain)
	local currentLevel = 0
	local currentExp = 0
	--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
	local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
	if dbEntry ~= nil then
		currentLevel = dbEntry[1][3]
		currentExp = dbEntry[1][4]
	end

	if currentLevel < 4 then
		local expAmountData = experienceAmounts[currentLevel]
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

Ext.NewCall(AddMasteryExperience, "LLWEAPONEX_Ext_AddMasteryExperience", "(CHARACTERGUID)_Character, (STRING)_Mastery, (REAL)_ExperienceGain")

local function AddMasteryExperienceForAllActive(uuid,expGain)
	for mastery,masterData in pairs(WeaponExpansion.Masteries) do

	end
end

Ext.NewCall(AddMasteryExperience, "LLWEAPONEX_Ext_AddMasteryExperience", "(CHARACTERGUID)_Character, (STRING)_Mastery, (REAL)_ExperienceGain")
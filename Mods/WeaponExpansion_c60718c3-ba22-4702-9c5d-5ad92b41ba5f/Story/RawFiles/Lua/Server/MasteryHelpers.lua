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

local leveledUpText = LeaderLib.Classes.TranslatedString:Create("hd88b4801g3ec4g4b1eg8272ge2f6dce46f0c", "<font color='#F7BA14'>[1] increased to rank <font color='#00FF00'>[2]</font></font>")

function TagMasteryRanks(uuid,mastery,level)
	if level > 0 then
		for i=1,level,1 do
			local tag = mastery.."_Mastery"..tostring(i)
			SetTag(uuid, tag)
			LeaderLib.Print("[WeaponExpansion] Setting tag ["..tag.."] on ["..uuid.."]")
		end
	end
end

--- Callback for when a character's mastery levels up.
--- @param uuid string
--- @param mastery string
--- @param last integer
--- @param next integer
local function MasteryLeveledUp(uuid,mastery,last,next)
	local masteryName = WeaponExpansion.Masteries[mastery].Name.Value
	local text = string.gsub(leveledUpText.Value, "%[1%]", masteryName):gsub("%[2%]", next)
	if CharacterIsPlayer(uuid) == 1 and CharacterIsControlled(uuid) then
		ShowNotification(uuid, text)
	else
		CharacterStatusText(uuid, text)
	end
	TagMasteryRanks(uuid,mastery,next)

	LeaderLib.Print("[WeaponExpansion] Mastery ["..mastery.."] leveled up ("..tostring(last).." => "..tostring(last)..") on ["..uuid.."]")
end

--- Adds mastery experience a specific masteries.
--- @param uuid string
--- @param mastery string
--- @param expGain number
--- @param skipFlagCheck boolean
local function AddMasteryExperience(uuid,mastery,expGain)
	if skipFlagCheck == true or ObjectGetFlag(uuid, "LLWEAPONEX_DisableWeaponMasteryExperience") == 0 then
		local currentLevel = 0
		local currentExp = 0
		--DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience(_Player, _WeaponType, _Level, _Experience)
		local dbEntry = Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Get(uuid, mastery, nil, nil)
		if dbEntry ~= nil then
			currentLevel = dbEntry[1][3]
			currentExp = dbEntry[1][4]
		end

		if currentLevel < 4 then
			local expAmountData = WeaponExpansion.MasteryVariables.RankVariables[currentLevel]
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
local function AddMasteryExperienceForAllActive(uuid,expGain)
	if ObjectGetFlag(uuid, "LLWEAPONEX_DisableWeaponMasteryExperience") == 0 then
		--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
		--local offhand = CharacterGetEquippedItem(uuid, "Shield")
		for mastery,masterData in pairs(WeaponExpansion.Masteries) do
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
--- @param item string
function OnItemEquipped(uuid,item,template)
	--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
	--local offhand = CharacterGetEquippedItem(uuid, "Shield")
	
	local stat = NRD_ItemGetStatsId(item)
	local statType = NRD_StatGetType(stat)
	if NRD_StatGetType(stat) == "Weapon" then
		SetTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
		Osi.LLWEAPONEX_OnWeaponEquipped(uuid,item,template)
	end

	local isPlayer = CharacterIsPlayer(uuid) == 1 or CharacterGameMaster(uuid) == 1

	for mastery,masterData in pairs(WeaponExpansion.Masteries) do
		-- if ItemIsTagged(mainhand) or ItemIsTagged(offhand) then
		-- 	AddMasteryExperience(uuid,mastery,expGain)
		-- end
		if IsTagged(item,mastery) == 1 then
			Osi.LLWEAPONEX_WeaponMastery_TrackItem(uuid, item)
			if IsTagged(uuid, mastery) == 0 then
				SetTag(uuid,mastery)
				Osi.LLWEAPONEX_WeaponMastery_OnMasteryActivated(uuid,mastery)
				Osi.LLWEAPONEX_OnWeaponTypeEquipped(uuid, item, mastery, isPlayer)
			end
		end
	end
end

function OnItemUnequipped(uuid,item,template)
	if ObjectGetFlag(item, "LLWEAPONEX_HasWeaponType") == 1 then
		local isPlayer = CharacterIsPlayer(uuid) == 1 or CharacterGameMaster(uuid) == 1
		for mastery,masterData in pairs(WeaponExpansion.Masteries) do
			if IsTagged(item,mastery) == 1 then
				Osi.LLWEAPONEX_OnWeaponTypeUnEquipped(uuid, item, mastery, isPlayer)
			end
		end
	end
end

--- @param uuid string
--- @param mastery string
function OnMasteryDeactivated(uuid,mastery)
	ClearTag(uuid,mastery)
end
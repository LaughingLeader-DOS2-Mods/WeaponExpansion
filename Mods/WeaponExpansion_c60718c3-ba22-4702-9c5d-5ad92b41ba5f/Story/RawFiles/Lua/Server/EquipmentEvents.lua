--- @param uuid string
--- @param item string
local function OnItemEquipped(uuid,item)
	--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
	--local offhand = CharacterGetEquippedItem(uuid, "Shield")
	
	local stat = NRD_ItemGetStatsId(item)
	local statType = NRD_StatGetType(stat)
	if NRD_StatGetType(stat) == "Weapon" then
		SetTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
		Osi.LLWEAPONEX_OnWeaponEquipped(uuid,item,GetTemplate(item))
	end

	local isPlayer = 0
	if CharacterIsPlayer(uuid) == 1 or CharacterGameMaster(uuid) == 1 then
		isPlayer = 1
	end

	for mastery,masterData in pairs(Masteries) do
		-- if ItemIsTagged(mainhand) or ItemIsTagged(offhand) then
		-- 	AddMasteryExperience(uuid,mastery,expGain)
		-- end
		LeaderLib.PrintDebug("[WeaponExpansion] Checking item for tag ["..mastery.."] on ["..uuid.."]")
		if IsTagged(item,mastery) == 1 then
			local equippedTag = Tags.WeaponTypes[mastery]
			if equippedTag ~= nil then
				SetTag(uuid, equippedTag)
				LeaderLib.PrintDebug("[WeaponExpansion] Setting tag ["..equippedTag.."] on ["..uuid.."]")
			end
			Osi.LLWEAPONEX_WeaponMastery_TrackItem(uuid, item, mastery)
			ObjectSetFlag(item, "LLWEAPONEX_HasWeaponType", 0)
			if IsTagged(uuid, mastery) == 0 then
				SetTag(uuid, mastery)
				LeaderLib.PrintDebug("[WeaponExpansion] Setting tag ["..mastery.."] on ["..uuid.."]")
				Osi.LLWEAPONEX_WeaponMastery_OnMasteryActivated(uuid, mastery)
				print(uuid, item, mastery, isPlayer, Osi.LLWEAPONEX_OnWeaponTypeEquipped)
				Osi.LLWEAPONEX_OnWeaponTypeEquipped(uuid, item, mastery, isPlayer)
			end
		end
	end
end
Ext.NewCall(OnItemEquipped, "LLWEAPONEX_Ext_OnItemEquipped", "(CHARACTERGUID)_Character, (ITEMGUID)_Item, (STRING)_Template")

local function OnItemUnequipped(uuid,item)
	local template = GetTemplate(item)
	if ObjectGetFlag(item, "LLWEAPONEX_HasWeaponType") == 1 then
		local isPlayer = 0
		if CharacterIsPlayer(uuid) == 1 or CharacterGameMaster(uuid) == 1 then
			isPlayer = 1
		end
		for mastery,masterData in pairs(Masteries) do
			if IsTagged(item,mastery) == 1 then
				local equippedTag = Tags.WeaponTypes[mastery]
				if equippedTag ~= nil then
					ClearTag(uuid, equippedTag)
					LeaderLib.PrintDebug("[WeaponExpansion] Clearing tag ["..equippedTag.."] on ["..uuid.."]")
				end
				Osi.LLWEAPONEX_OnWeaponTypeUnEquipped(uuid, item, mastery, isPlayer)
				ClearTag(uuid,mastery)
				LeaderLib.PrintDebug("[WeaponExpansion] Weapon with mastery tag ["..mastery.."] on ["..uuid.."] was removed.")
			end
		end
	end
	Osi.LLWEAPONEX_OnItemUnEquipped(uuid,item,template)
end
Ext.NewCall(OnItemUnequipped, "LLWEAPONEX_Ext_OnItemUnequipped", "(CHARACTERGUID)_Character, (ITEMGUID)_Item, (STRING)_Template")
local function OnWeaponTypeEquipped(uuid, item, weapontype, stat, statType)
	if weapontype == "Rapier" or weapontype == "Katana" then
		local twohanded = Ext.StatGetAttribute(stat, "IsTwoHanded") == "Yes"
		if (twohanded and weapontype == "Katana") or (not twohanded and weapontype == "Rapier") then
			Osi.LLWEAPONEX_AnimationSetOverride_Set(uuid, "LLWEAPONEX_Override1", weapontype)
		end
	end
end

local rangedWeaponTypes = {
	None = false,
	Sword = false,
	Club = false,
	Axe = false,
	Staff = false,
	Bow = true,
	Crossbow = true,
	Spear = false,
	Knife = false,
	Wand = true,
	Arrow = true,
	--Custom = false,
}

--- @param uuid string
--- @param item string
function OnItemEquipped(uuid,item)
	--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
	--local offhand = CharacterGetEquippedItem(uuid, "Shield")
	if not StringHelpers.IsNullOrEmpty(item) then
		local stat = NRD_ItemGetStatsId(item)
		if stat == nil then
			return
		end
		local statType = NRD_StatGetType(stat)

		if IsTagged(item, "LLWEAPONEX_TaggedWeaponType") == 0 and statType == "Weapon" or statType == "Shield" then
			TagWeapon(item, statType, stat)
		end
		
		local isPlayer = IsPlayerQRY(uuid)
		
		if statType == "Weapon" and isPlayer == 1 then
			SetTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
			local weapontype = Ext.StatGetAttribute(stat, "WeaponType")
			if rangedWeaponTypes[weapontype] ~= true then
				SetTag(uuid, "LLWEAPONEX_MeleeWeaponEquipped")
			else
				ClearTag(uuid, "LLWEAPONEX_MeleeWeaponEquipped")
				SetTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
			end
			local isUnarmed = Ext.StatGetAttribute(stat, "AnimType") == "Unarmed" or IsUnarmed(uuid)
			if not isUnarmed then
				Osi.LLWEAPONEX_WeaponMastery_Internal_CheckRemovedMasteries(uuid, "LLWEAPONEX_Unarmed")
			end
		end
		
		for tag,data in pairs(Masteries) do
			--LeaderLib.PrintDebug("[WeaponExpansion] Checking item for tag ["..tag.."] on ["..uuid.."]")
			if IsTagged(item,tag) == 1 then
				if isPlayer == 1 then
					local equippedTag = Tags.WeaponTypes[tag]
					if equippedTag ~= nil then
						LeaderLib.PrintDebug("[WeaponExpansion:OnItemEquipped] Setting equipped tag ["..equippedTag.."] on ["..uuid.."]")
						Osi.LLWEAPONEX_Equipment_TrackItem(uuid,item,tag,equippedTag,isPlayer)
					end
					Osi.LLWEAPONEX_WeaponMastery_TrackMastery(uuid, item, tag)
					if IsTagged(uuid, tag) == 0 then
						SetTag(uuid, tag)
						LeaderLib.PrintDebug("[WeaponExpansion:OnItemEquipped] Setting mastery tag ["..tag.."] on ["..uuid.."]")
					end
				end
				local template = GetTemplate(item)
				Osi.LLWEAPONEX_OnItemTemplateEquipped(uuid,item,template)
				Osi.LLWEAPONEX_Equipment_OnTaggedItemEquipped(uuid,item,tag,isPlayer)
				OnWeaponTypeEquipped(uuid, item, tag, stat, statType)
			end
		end
	end
end

function OnItemTemplateUnEquipped(uuid, item, template)
	SetIsUnarmed(uuid)
end

function SetIsUnarmed(uuid, hasMasteryRank1)
	local weapon = CharacterGetEquippedWeapon(uuid)
	if weapon == nil then
		if hasMasteryRank1 == true or HasMasteryLevel(uuid, "LLWEAPONEX_Unarmed", 1) then
			--SetTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
			SetTag(uuid, "LLWEAPONEX_MeleeWeaponEquipped")
			ClearTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
			Osi.LLWEAPONEX_Equipment_TrackUnarmed(uuid);
			Osi.LLWEAPONEX_WeaponMastery_OnMasteryActivated(uuid, "LLWEAPONEX_Unarmed")
		else
			ClearTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
			ClearTag(uuid, "LLWEAPONEX_MeleeWeaponEquipped")
			SetTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
		end
	end
end

local rodSkills = {
	Air = {"Projectile_LLWEAPONEX_ShootRod_Air", "Projectile_LLWEAPONEX_ShootRod_Air_Offhand"},
	Chaos = {"Projectile_LLWEAPONEX_ShootRod_Chaos", "Projectile_LLWEAPONEX_ShootRod_Chaos_Offhand"},
	Earth = {"Projectile_LLWEAPONEX_ShootRod_Earth", "Projectile_LLWEAPONEX_ShootRod_Earth_Offhand"},
	Fire = {"Projectile_LLWEAPONEX_ShootRod_Fire", "Projectile_LLWEAPONEX_ShootRod_Fire_Offhand"},
	Poison = {"Projectile_LLWEAPONEX_ShootRod_Poison", "Projectile_LLWEAPONEX_ShootRod_Poison_Offhand"},
	Water = {"Projectile_LLWEAPONEX_ShootRod_Water", "Projectile_LLWEAPONEX_ShootRod_Water_Offhand"},
	Magic = {"Projectile_LLWEAPONEX_ShootRod_MagicMissile", "Projectile_LLWEAPONEX_ShootRod_MagicMissile_Offhand"},
}

local uniqueRodSkills = {
	WPN_UNIQUE_LLWEAPONEX_Rod_1H_MagicMissile_A = { "Projectile_LLWEAPONEX_ShootRod_MagicMissile", "Projectile_LLWEAPONEX_ShootRod_MagicMissile_Offhand" },
}

function AddRodSkill(char, item)
	local stat = NRD_ItemGetStatsId(item)
	if Ext.StatGetAttribute(stat, "WeaponType") ~= "Wand" then
		local mainhandSkill, offhandSkill = nil, nil
		local skills = uniqueRodSkills[stat]
		if skills == nil then
			local damageType = Ext.StatGetAttribute(stat, "Damage Type")
			skills = rodSkills[damageType]
			if skills ~= nil then
				mainhandSkill,offhandSkill = table.unpack(skills)
			end
		else
			mainhandSkill,offhandSkill = table.unpack(skills)
		end

		if mainhandSkill ~= nil and offhandSkill ~= nil then
			local slot = GameHelpers.GetEquippedSlot(char,item)
			if slot == "Weapon" then
				CharacterAddSkill(char, mainhandSkill, 0)
				SetVarFixedString(item, "LLWEAPONEX_Rod_ShootSkill", mainhandSkill)
			elseif slot == "Shield" then
				CharacterAddSkill(char, offhandSkill, 0)
				SetVarFixedString(item, "LLWEAPONEX_Rod_ShootSkill", offhandSkill)
			else
				CharacterRemoveSkill(char, mainhandSkill)
				CharacterRemoveSkill(char, offhandSkill)
			end
		end
	end
end

local function WeaponHasRodSkill(weapon, skill)
	if weapon ~= nil and GetVarFixedString(weapon, "LLWEAPONEX_Rod_ShootSkill") == skill then
		return true
	end
	return false
end

function RemoveRodSkill(char, item)
	local skill = GetVarFixedString(item, "LLWEAPONEX_Rod_ShootSkill")
	if not LeaderLib.StringHelpers.IsNullOrEmpty(skill) then
		local mainhand = CharacterGetEquippedItem(char, "Weapon")
		local offhand = CharacterGetEquippedItem(char, "Shield")
		if not WeaponHasRodSkill(mainhand, skill) and not WeaponHasRodSkill(offhand, skill) then
			CharacterRemoveSkill(char, skill)
		end
	end
end

local function GetRodTypeQRY(item)
	local stat = NRD_ItemGetStatsId(item)
	local skills = uniqueRodSkills[stat]
	if skills == nil then
		local damageType = Ext.StatGetAttribute(stat, "Damage Type")
		skills = rodSkills[damageType]
		if skills ~= nil then
			return skills[1], skills[2]
		end
	else
		return skills[1], skills[2]
	end
end

Ext.NewQuery(GetRodTypeQRY, "LLWEAPONEX_Ext_QRY_GetRodSkills", "[in](ITEMGUID)_Rod, [out](STRING)_MainhandSkill, [out](STRING)_OffhandSkill")

local deltamodSwap = {
	{Tag="LLWEAPONEX_Greatbow", Find="FinesseBoost", Replace="StrengthBoost"},
	{Tag="LLWEAPONEX_Quarterstaff", Find="FinesseBoost", Replace="StrengthBoost"},
	{Tag="LLWEAPONEX_Rod", Find="StrengthBoost", Replace="IntelligenceBoost"},
	{Tag="LLWEAPONEX_Runeblade", Find="FinesseBoost", Replace="IntelligenceBoost"},
	{Tag="LLWEAPONEX_Runeblade", Find="StrengthBoost", Replace="IntelligenceBoost"},
}

function SwapDeltaMods(item)
	local swapBoosts = {}
	local hasSwapBoosts = false
	for i,entry in pairs(deltamodSwap) do
		if IsTagged(item, entry.Tag) == 1  then
			swapBoosts[entry.Find] = entry.Replace
			hasSwapBoosts = true
		end
	end

	if hasSwapBoosts then
		LeaderLib.PrintDebug("[WeaponExpansion:SwapDeltaMods] Checking for boosts on item ("..item..")")
		NRD_ItemCloneBegin(item)
		local cloned = NRD_ItemClone()
		for boostName,addBoost in pairs(swapBoosts) do
			local boostValue = NRD_ItemGetPermanentBoostInt(item, boostName)
			if boostValue > 0 then
				LeaderLib.PrintDebug("[WeaponExpansion:SwapDeltaMods] Swapping item boost ["..boostName.."]("..tostring(boostValue)..") for ["..addBoost.."]")
				NRD_ItemSetPermanentBoostInt(cloned, boostName, 0)
				NRD_ItemSetPermanentBoostInt(cloned, addBoost, boostValue)
			else
				LeaderLib.PrintDebug("[WeaponExpansion:SwapDeltaMods] NRD_ItemGetPermanentBoostInt["..boostName.."]("..tostring(boostValue)..")")
			end
		end
		ItemRemove(item)
		ObjectSetFlag(cloned, "LLWEAPONEX_BoostConversionApplied", 0)
		return cloned
	end
end

Ext.NewQuery(SwapDeltaMods, "LLWEAPONEX_Ext_QRY_SwapDeltaMods", "[in](ITEMGUID)_Item, [out](ITEMGUID)_NewItem")

function MagicMissileWeapon_Swap(char, wand, rod)
	local equippedItem = nil
	local targetItem = nil
	local slot = GameHelpers.GetEquippedSlot(char,wand)
	if slot == nil then
		slot = GameHelpers.GetEquippedSlot(char,rod)
		equippedItem = rod
		targetItem = wand
	else
		equippedItem = wand
		targetItem = rod
	end
	if equippedItem ~= nil and targetItem ~= nil then
		CharacterUnequipItem(char, equippedItem)
		--ItemToInventory(equippedItem, targetItem, 1, 0, 0)
		NRD_CharacterEquipItem(char, targetItem, slot, 0, 0, 1, 1)
		Osi.LeaderLib_Timers_StartObjectObjectTimer(equippedItem, targetItem, 50, "Timers_LLWEAPONEX_MoveMagicMissileWeapon", "LeaderLib_Commands_ItemToInventory")
	end
end
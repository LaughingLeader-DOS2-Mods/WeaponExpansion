local function OnWeaponTypeEquipped(uuid, item, weapontype, stat, statType, isPlayer)
	if weapontype == "Rapier" or weapontype == "Katana" then
		local twohanded = Ext.StatGetAttribute(stat, "IsTwoHanded") == "Yes"
		if (twohanded and weapontype == "Katana") or (not twohanded and weapontype == "Rapier") then
			Osi.LLWEAPONEX_AnimationSetOverride_Set(uuid, "LLWEAPONEX_Override1", weapontype)
		end
	end
end

--- @param uuid string
--- @param item string
function OnItemEquipped(uuid,item)
	--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
	--local offhand = CharacterGetEquippedItem(uuid, "Shield")
	
	local stat = NRD_ItemGetStatsId(item)
	local statType = NRD_StatGetType(stat)

	if IsTagged(item, "LLWEAPONEX_TaggedWeaponType") == 0 and statType == "Weapon" or statType == "Shield" then
		TagWeapon(item, statType, stat)
	end

	local isPlayer = IsPlayerQRY(uuid)

	for tag,data in pairs(Masteries) do
		--LeaderLib.PrintDebug("[WeaponExpansion] Checking item for tag ["..tag.."] on ["..uuid.."]")
		if IsTagged(item,tag) == 1 then
			if isPlayer == 1 then
				local equippedTag = Tags.WeaponTypes[tag]
				if equippedTag ~= nil then
					LeaderLib.PrintDebug("[WeaponExpansion:OnItemEquipped] Setting equipped tag ["..equippedTag.."] on ["..uuid.."]")
					Osi.LLWEAPONEX_Equipment_TrackItem(uuid,item,equippedTag,isPlayer)
				end
				Osi.LLWEAPONEX_WeaponMastery_TrackMastery(uuid, item, tag)
				if IsTagged(uuid, tag) == 0 then
					SetTag(uuid, tag)
					LeaderLib.PrintDebug("[WeaponExpansion:OnItemEquipped] Setting mastery tag ["..tag.."] on ["..uuid.."]")
				end
			end
			OnWeaponTypeEquipped(uuid, item, tag, stat, statType, isPlayer == 1)
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
}

local uniqueRodSkills = {
	WPN_UNIQUE_LLWEAPONEX_Rod_1H_MagicMissile_A = { "Projectile_LLWEAPONEX_ShootRod_MagicMissile", "Projectile_LLWEAPONEX_ShootRod_MagicMissile_Offhand" },
}
local function GetRodTypeQRY(item)
	local stat = NRD_ItemGetStatsId(item)
	local skills = uniqueRodSkills[stat]
	if skills == nil then
		local damageType = Ext.StatGetAttribute(stat, "Damage Type")
		skills = rodSkills[damageType]
		if skills == nil then
			skills = rodSkills["Chaos"]
		end
		return skills[1], skills[2]
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
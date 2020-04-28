--- @param uuid string
--- @param item string
local function OnItemEquipped(uuid,item)
	--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
	--local offhand = CharacterGetEquippedItem(uuid, "Shield")
	
	local stat = NRD_ItemGetStatsId(item)
	local statType = NRD_StatGetType(stat)
	if statType == "Weapon" then
		SetTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
		Osi.LLWEAPONEX_OnWeaponEquipped(uuid,item,GetTemplate(item))
	end

	if statType == "Weapon" or statType == "Shield" and ObjectGetFlag(item, "LLWEAPONEX_TaggedWeaponType") == 0 then
		TagWeapon(item, statType, stat)
	end

	local isPlayer = 0
	if CharacterIsPlayer(uuid) == 1 or CharacterGameMaster(uuid) == 1 then
		isPlayer = 1
	end

	for tag,data in pairs(Masteries) do
		--LeaderLib.PrintDebug("[WeaponExpansion] Checking item for tag ["..tag.."] on ["..uuid.."]")
		if IsTagged(item,tag) == 1 then
			local equippedTag = Tags.WeaponTypes[tag]
			if equippedTag ~= nil then
				LeaderLib.PrintDebug("[WeaponExpansion] Setting tag ["..equippedTag.."] on ["..uuid.."]")
				Osi.LLWEAPONEX_Equipment_TrackItem(uuid,item,equippedTag)
			end
			Osi.LLWEAPONEX_WeaponMastery_TrackMastery(uuid, item, tag)
			ObjectSetFlag(item, "LLWEAPONEX_HasWeaponType", 0)
			if IsTagged(uuid, tag) == 0 then
				SetTag(uuid, tag)
				LeaderLib.PrintDebug("[WeaponExpansion] Setting tag ["..tag.."] on ["..uuid.."]")
				Osi.LLWEAPONEX_WeaponMastery_OnMasteryActivated(uuid, tag)
				print(uuid, item, tag, isPlayer)
				OnWeaponTypeEquipped(uuid, item, tag, stat, statType, isPlayer == 1)
			end
		end
	end
end
Ext.NewCall(OnItemEquipped, "LLWEAPONEX_Ext_OnItemEquipped", "(CHARACTERGUID)_Character, (ITEMGUID)_Item, (STRING)_Template")

local function OnWeaponTypeEquipped(uuid, item, weapontype, stat, statType, isPlayer)
	if weapontype == "Rapier" or weapontype == "Katana" then
		local twohanded = Ext.StatGetAttribute(stat, "IsTwoHanded") == "Yes"
		if (twohanded and weapontype == "Katana") or (not twohanded and weapontype == "Rapier") then
			Osi.LLWEAPONEX_AnimationSetOverride_Set(uuid, "LLWEAPONEX_Override1", weapontype)
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
	LLWEAPONEX_Greatbow = {Find="FinesseBoost", Replace="StrengthBoost"},
	LLWEAPONEX_Quarterstaff = {Find="FinesseBoost", Replace="StrengthBoost"},
	LLWEAPONEX_Rod = {Find="StrengthBoost", Replace="IntelligenceBoost"},
	LLWEAPONEX_Runeblade = {Find="FinesseBoost", Replace="IntelligenceBoost"},
	LLWEAPONEX_Runeblade = {Find="StrengthBoost", Replace="IntelligenceBoost"},
}
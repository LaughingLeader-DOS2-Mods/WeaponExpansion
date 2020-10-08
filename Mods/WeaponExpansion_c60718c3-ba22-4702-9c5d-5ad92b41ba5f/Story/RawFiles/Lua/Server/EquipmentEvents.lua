Equipment = {}

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

---@param uuid string
---@param item EsvItem
local function UpdatedUnarmedTagsFromWeapon(uuid, item)
	SetTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
	if rangedWeaponTypes[item.Stats.WeaponType] ~= true then
		ClearTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
	else
		SetTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
	end
	if IsPlayer(uuid) then
		if item.Stats.AnimType ~= "Unarmed" or not UnarmedHelpers.HasUnarmedWeaponStats(uuid) then
			Osi.LLWEAPONEX_WeaponMastery_Internal_CheckRemovedMasteries(uuid, "LLWEAPONEX_Unarmed")
		end
	end
end

---@param uuid string
---@param item StatItem
local function CheckScoundrelTags(uuid, itemUUID)
	if itemUUID ~= nil and ObjectExists(itemUUID) == 1 then
		local item = Ext.GetItem(itemUUID)
		if item.Stats.WeaponType == "Knife" or item:HasTag("LLWEAPONEX_Katana") or (Mastery.HasMasteryRequirement(uuid, "LLWEAPONEX_Axe_Mastery4") and (item.Stats.WeaponType == "Axe" or item:HasTag("LLWEAPONEX_Axe"))) then
			return true
		end
	end
	return false
end

---@param uuid string
function Equipment.CheckWeaponRequirementTags(uuid)
	local character = Ext.GetCharacter(uuid)
	local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
	local offhand = CharacterGetEquippedItem(uuid, "Shield")
	local weapon = mainhand or offhand
	if StringHelpers.IsNullOrEmpty(weapon) and StringHelpers.IsNullOrEmpty(offhand) then
		Osi.LLWEAPONEX_Equipment_TrackUnarmed(uuid)
	end
	if weapon ~= nil and ObjectExists(weapon) == 1 then
		local item = Ext.GetItem(weapon)
		SetTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
		if rangedWeaponTypes[item.Stats.WeaponType] ~= true then
			ClearTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
			if CheckScoundrelTags(uuid, mainhand) or CheckScoundrelTags(uuid, offhand) then
				if character:HasTag("LLWEAPONEX_CannotUseScoundrelSkills") then
					ClearTag(uuid, "LLWEAPONEX_CannotUseScoundrelSkills")
					print("ClearTag LLWEAPONEX_CannotUseScoundrelSkills", uuid)
				end
			else
				if not character:HasTag("LLWEAPONEX_CannotUseScoundrelSkills") then
					SetTag(uuid, "LLWEAPONEX_CannotUseScoundrelSkills")
					print("SetTag LLWEAPONEX_CannotUseScoundrelSkills", uuid)
				end
			end
		else
			SetTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
		end
		LeaderLib.RefreshSkillBar(uuid)
	elseif Mastery.HasMasteryRequirement(character, "LLWEAPONEX_Unarmed_Mastery1") then
		ClearTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
		SetTag(uuid, "LLWEAPONEX_CannotUseScoundrelSkills")
		LeaderLib.RefreshSkillBar(uuid)
	else
		ClearTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
		SetTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
		SetTag(uuid, "LLWEAPONEX_CannotUseScoundrelSkills")
		LeaderLib.RefreshSkillBar(uuid)
	end

	--[[ if IsPlayer(uuid) then
		local hasWarfareTag = character:HasTag("LLWEAPONEX_NoMeleeWeaponEquipped")
		local hasScoundrelTag = character:HasTag("LLWEAPONEX_CannotUseScoundrelSkills")
		for skill,b in pairs(Skills.WarfareMeleeSkills) do
			GameHelpers.UI.SetSkillEnabled(uuid, skill, not hasWarfareTag)
		end
		for skill,b in pairs(Skills.ScoundrelMeleeSkills) do
			GameHelpers.UI.SetSkillEnabled(uuid, skill, not hasScoundrelTag)
		end
	end ]]
end

--- @param uuid string
--- @param item string
function OnItemEquipped(uuid,itemUUID)
	--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
	--local offhand = CharacterGetEquippedItem(uuid, "Shield")
	if not StringHelpers.IsNullOrEmpty(itemUUID) and ObjectExists(itemUUID) == 1 then
		local item = Ext.GetItem(itemUUID)
		if item == nil then
			return
		end
		local stat = item.StatsId
		local statType = item.Stats.ItemType

		if not item:HasTag("LLWEAPONEX_TaggedWeaponType") and statType == "Weapon" or statType == "Shield" then
			TagWeapon(itemUUID, statType, stat)
		end
		
		local isPlayer = IsPlayerQRY(uuid)
		
		if isPlayer == 1 and statType == "Weapon" then
			Equipment.CheckWeaponRequirementTags(uuid)
		end
		
		for tag,data in pairs(Masteries) do
			--LeaderLib.PrintDebug("[WeaponExpansion] Checking item for tag ["..tag.."] on ["..uuid.."]")
			if item:HasTag(tag) then
				if isPlayer == 1 then
					local equippedTag = Tags.WeaponTypes[tag]
					if equippedTag ~= nil then
						if Ext.IsDeveloperMode() then
							if IsTagged(uuid, equippedTag) == 0 then
								LeaderLib.PrintDebug("[WeaponExpansion:OnItemEquipped] Setting equipped tag ["..equippedTag.."] on ["..uuid.."]")
							end
						end
						Osi.LLWEAPONEX_Equipment_TrackItem(uuid,itemUUID,tag,equippedTag,isPlayer)
					end
					Osi.LLWEAPONEX_WeaponMastery_TrackMastery(uuid, itemUUID, tag)
					if IsTagged(uuid, tag) == 0 then
						SetTag(uuid, tag)
						LeaderLib.PrintDebug("[WeaponExpansion:OnItemEquipped] Setting mastery tag ["..tag.."] on ["..uuid.."]")
					end
				end
				local template = GetTemplate(itemUUID)
				Osi.LLWEAPONEX_OnItemTemplateEquipped(uuid,itemUUID,template)
				Osi.LLWEAPONEX_Equipment_OnTaggedItemEquipped(uuid,itemUUID,tag,isPlayer)
				OnWeaponTypeEquipped(uuid, itemUUID, tag, stat, statType)
			end
		end
	end
end

function OnItemTemplateUnEquipped(uuid, item, template)
	if IsPlayer(uuid) then
		Equipment.CheckWeaponRequirementTags(uuid)
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
			local slot = GameHelpers.Item.GetEquippedSlot(char,item)
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

function MagicMissileWeapon_Swap(char, wand, rod)
	local equippedItem = nil
	local targetItem = nil
	local slot = GameHelpers.Item.GetEquippedSlot(char,wand)
	if slot == nil then
		slot = GameHelpers.Item.GetEquippedSlot(char,rod)
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
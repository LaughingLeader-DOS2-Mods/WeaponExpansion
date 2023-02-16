if EquipmentManager == nil then
	EquipmentManager = {}
end

---@param uuid string
---@param item EsvItem
local function CheckWeaponAnimation(uuid, item)
	local isTwoHanded = item.Stats.IsTwoHanded
	if item:HasTag("LLWEAPONEX_Rapier") and not isTwoHanded then
		Osi.LLWEAPONEX_AnimationSetOverride_Set(uuid, "LLWEAPONEX_Override1", "LLWEAPONEX_Rapier")
	elseif item:HasTag("LLWEAPONEX_Katana") and isTwoHanded then
		Osi.LLWEAPONEX_AnimationSetOverride_Set(uuid, "LLWEAPONEX_Override1", "LLWEAPONEX_Katana")
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

local function AxeScoundrelEnabled(uuid, item)
	return Mastery.HasMasteryRequirement(uuid, "LLWEAPONEX_Axe_Mastery4")
	and (item.Stats.WeaponType == "Axe" or item:HasTag("LLWEAPONEX_Axe"))
end

---@param uuid string
---@param item StatItem
local function CheckScoundrelTags(uuid, itemUUID)
	if itemUUID ~= nil and ObjectExists(itemUUID) == 1 then
		local item = Ext.GetItem(itemUUID)
		if item.Stats.WeaponType == "Knife" 
		or item:HasTag("LLWEAPONEX_Katana") 
		or AxeScoundrelEnabled(uuid, item)
		then
			return true
		end
	end
	return false
end

---@param uuid string
function EquipmentManager.CheckWeaponRequirementTags(uuid)
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
					printd("ClearTag LLWEAPONEX_CannotUseScoundrelSkills", uuid)
				end
			else
				if not character:HasTag("LLWEAPONEX_CannotUseScoundrelSkills") then
					SetTag(uuid, "LLWEAPONEX_CannotUseScoundrelSkills")
					printd("SetTag LLWEAPONEX_CannotUseScoundrelSkills", uuid)
				end
			end
		else
			SetTag(uuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
		end
		LeaderLib.RefreshSkillBar(uuid)
	elseif Mastery.HasMasteryRequirement(character, "LLWEAPONEX_Unarmed_Mastery1") then
		ClearTag(uuid, "LLWEAPONEX_AnyWeaponEquipped")
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

---@param character EsvCharacter
---@param isPlayer boolean
---@param newlyEquipped EsvItem
local function CheckForUnarmed(character, isPlayer, newlyEquipped)
	local hasEmptyHands = HasEmptyHand(character, false)
	if newlyEquipped ~= nil and newlyEquipped.Stats ~= nil and newlyEquipped.Stats.IsTwoHanded then
		hasEmptyHands = false
	end
	if hasEmptyHands and CharacterHasSkill(character.MyGuid, "Target_LLWEAPONEX_SinglehandedAttack") == 1 then
		GameHelpers.Skill.Swap(character.MyGuid, "Target_LLWEAPONEX_SinglehandedAttack", "Target_SingleHandedAttack", true, false)
	else
		local hasSkill = CharacterHasSkill(character.MyGuid, "Target_LLWEAPONEX_SinglehandedAttack") == 1
		if UnarmedHelpers.IsUnarmed(character) then
			if not hasSkill then
				GameHelpers.Skill.Swap(character.MyGuid, "Target_SingleHandedAttack", "Target_LLWEAPONEX_SinglehandedAttack", true, false)
			end
		elseif hasSkill then
			CharacterRemoveSkill(character.MyGuid, "Target_LLWEAPONEX_SinglehandedAttack")
		end
	end
end

--- @param uuid string
--- @param item string
function OnItemEquipped(uuid,itemUUID)
	if uuid == NPC.VendingMachine then
		return false
	end
	--local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
	--local offhand = CharacterGetEquippedItem(uuid, "Shield")
	if not StringHelpers.IsNullOrEmpty(itemUUID) and ObjectExists(itemUUID) == 1 then
		local item = Ext.GetItem(itemUUID)
		if item == nil then
			Ext.PrintError("[WeaponExpansion:OnItemEquipped] Failed to get item from:", itemUUID)
			return false
		end

		local character = Ext.GetCharacter(uuid)

		local stat = item.StatsId
		local statType = item.Stats.ItemType

		-- LLWEAPONEX_Blunt was an old tag name that became LLWEAPONEX_Bludgeon
		if item:HasTag("LLWEAPONEX_Blunt") or (not item:HasTag("LLWEAPONEX_TaggedWeaponType") and (statType == "Weapon" or statType == "Shield")) then
			TagWeapon(itemUUID, statType, stat)
		end
		
		local isPlayer = character.IsPlayer or character.IsGameMaster
		
		if isPlayer and statType == "Weapon" then
			EquipmentManager.CheckWeaponRequirementTags(uuid)
			CheckForUnarmed(character, isPlayer, item)
		end

		local template = GetTemplate(itemUUID)
		Osi.LLWEAPONEX_OnItemTemplateEquipped(uuid,itemUUID,template)

		if not item:HasTag("LLWEAPONEX_NoTracking") then
			for tag,data in pairs(Masteries) do
				--printd("[WeaponExpansion] Checking item for tag ["..tag.."] on ["..uuid.."]")
				if item:HasTag(tag) then
					if isPlayer then
						local equippedTag = Tags.WeaponTypes[tag]
						if equippedTag ~= nil then
							if Vars.DebugMode then
								if IsTagged(uuid, equippedTag) == 0 then
									printd("[WeaponExpansion:OnItemEquipped] Setting equipped tag ["..equippedTag.."] on ["..uuid.."]")
								end
							end
							Osi.LLWEAPONEX_Equipment_TrackItem(uuid,itemUUID,tag,equippedTag,isPlayer and 1 or 0)
						end
						Osi.LLWEAPONEX_WeaponMastery_TrackMastery(uuid, itemUUID, tag)
						if IsTagged(uuid, tag) == 0 then
							SetTag(uuid, tag)
							printd("[WeaponExpansion:OnItemEquipped] Setting mastery tag ["..tag.."] on ["..uuid.."]")
						end
					end
					Osi.LLWEAPONEX_Equipment_OnTaggedItemEquipped(uuid,itemUUID,tag,isPlayer and 1 or 0)
				end
			end
		end

		CheckWeaponAnimation(uuid, item)

		if isPlayer then
			if item.Stats.Unique == 1 then
				UniqueManager.LevelUpUnique(character, item)
				for i,tag in pairs(item:GetTags()) do
					local unique = UniqueManager.GetDataByTag(tag)
					if unique ~= nil then
						if unique.UUID ~= item.MyGuid then
							unique:AddCopy(item.MyGuid, uuid)
							unique:ApplyProgression(nil, nil, item, true)
						end
						if not unique:IsReleasedFromOwner(item.MyGuid) then
							unique:ReleaseFromOwner(false, item.MyGuid)
						end
						unique:SetOwner(item.MyGuid, uuid)
						break
					end
				end
			end

			EquipmentManager.CheckFirearmProjectile(character, item)
		end

		template = StringHelpers.GetUUID(template)
		local callbacks = Listeners.EquipmentChanged.Template[template]
		if callbacks ~= nil then
			if Vars.DebugMode then
				Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Template] Template(%s) Stat(%s) Character(%s) Equipped(true)", template, item.StatsId, character.MyGuid))
			end
			for i,callback in pairs(callbacks) do
				local b,err = xpcall(callback, debug.traceback, character, item, template, true)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
		for tag,callbacks in pairs(Listeners.EquipmentChanged.Tag) do
			if item:HasTag(tag) then
				if Vars.DebugMode then
					Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Tag] Tag(%s) Stat(%s) Character(%s) Equipped(true)", tag, item.StatsId, character.MyGuid))
				end
				for i,callback in pairs(callbacks) do
					local b,err = xpcall(callback, debug.traceback, character, item, tag, true)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
		end
	end
end

function OnItemTemplateUnEquipped(uuid, itemUUID, template)
	if uuid == NPC.VendingMachine then
		return false
	end
	local isPlayer = IsPlayer(uuid)

	if isPlayer then
		EquipmentManager.CheckWeaponRequirementTags(uuid)
	end
	
	local character = Ext.GetCharacter(uuid)
	CheckForUnarmed(character, isPlayer)
	template = StringHelpers.GetUUID(template)

	if ObjectExists(itemUUID) == 1 then
		local item = Ext.GetItem(itemUUID)
		local callbacks = Listeners.EquipmentChanged.Template[template]
		if callbacks ~= nil then
			if Vars.DebugMode then
				Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Template] Template(%s) Stat(%s) Character(%s) Equipped(false)", template, item.StatsId, character.MyGuid))
			end
			for i,callback in pairs(callbacks) do
				local b,err = xpcall(callback, debug.traceback, character, item, template, false)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
		for tag,callbacks in pairs(Listeners.EquipmentChanged.Tag) do
			if item:HasTag(tag) then
				if Vars.DebugMode then
					Ext.Print(string.format("[WeaponExpansion:EquipmentChanged.Tag] Tag(%s) Stat(%s) Character(%s) Equipped(false)", tag, item.StatsId, character.MyGuid))
				end
				for i,callback in pairs(callbacks) do
					local b,err = xpcall(callback, debug.traceback, character, item, tag, false)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
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

---@param character EsvCharacter
function HasEmptyHand(character, ignoreShields)
	local uuid = ""
	if type(character) == "string" then
		uuid = character
		character = Ext.GetCharacter(character)
	end
	if type(ignoreShields) == "string" then
		ignoreShields = string.lower(ignoreShields) == "true"
	end
	if character ~= nil and character.Stats ~= nil then
		if character.Stats.MainWeapon ~= nil then
			if character.Stats.MainWeapon.IsTwoHanded then
				return false
			end
			if character.Stats.OffHandWeapon ~= nil and (ignoreShields or character.Stats.OffHandWeapon.ItemType == "Shield") then
				return false
			end
		end
		return true
	else
		local mainhand = CharacterGetEquippedItem(uuid, "Weapon")
		local offhand = CharacterGetEquippedItem(uuid, "Shield")
		if not StringHelpers.IsNullOrEmpty(mainhand) then
			local item = Ext.GetItem(mainhand)
			if item ~= nil and item.Stats.IsTwoHanded then
				return false
			end
			if not StringHelpers.IsNullOrEmpty(offhand) then
				if ignoreShields == true then
					item = Ext.GetItem(offhand)
					if item ~= nil and item.ItemType == "Shield" then
						return true
					end
				end
			end
		end
		return true
	end
	return false
end

RegisterProtectedOsirisListener("ItemAddedToCharacter", 2, "after", function(item, char)
	if IsPlayer(char) then
		local unique = AllUniques[StringHelpers.GetUUID(item)]
		if unique ~= nil and not unique:IsReleasedFromOwner() then
			unique:ReleaseFromOwner()
		end
	end
end)

Ext.RegisterOsirisListener("CharacterItemEvent", 3, "after", function(char, item, event)
	if event == "LeaderLib_Events_ItemLeveledUp" then
		char = StringHelpers.GetUUID(char)
		item = StringHelpers.GetUUID(item)
		local itemData = Ext.GetItem(item)
		if itemData ~= nil and itemData.Stats ~= nil and itemData.Stats.Unique == 1 then
			local data = UniqueManager.GetDataByItem(itemData)
			if data ~= nil then
				data:OnItemLeveledUp(item)
			end
		end
	end
end)

local blockTagCombinations = {
	ARROWS = {
		LLWEAPONEX_Firearm_Equipped = "LLWEAPONEX_Notifications_BlockedArrowOnGun"
	},
	LLWEAPONEX_HandCrossbow = {
		LLWEAPONEX_HandCrossbow_Equipped = "LLWEAPONEX_Notifications_BlockedHandCrossbow"
	}
}

---@param item EsvItem
---@param char EsvCharacter
local function ShouldBlockItem(item, char)
	for itemTag,characterTags in pairs(blockTagCombinations) do
		if item:HasTag(itemTag) then
			for tag,blockText in pairs(characterTags) do
				if char:HasTag(tag) then
					if blockText ~= "" and CharacterIsControlled(char.MyGuid) == 1 and (char.IsPlayer or char.IsGameMaster) then
						ShowNotification(char.MyGuid, blockText)
					end
					return true
				end
			end
		end
	end
	return false
end

RegisterProtectedOsirisListener("CanUseItem", 3, "before", function(charUUID, itemUUID, request)
	charUUID = StringHelpers.GetUUID(charUUID)
	itemUUID = StringHelpers.GetUUID(itemUUID)
	if ObjectExists(itemUUID) == 0 or ObjectExists(charUUID) == 0 then
		return
	end
	local item = Ext.GetItem(itemUUID)
	local char = Ext.GetCharacter(charUUID)

	if item ~= nil and char ~= nil then
		local db = Osi.DB_CurrentGameMode:Get("GameMaster")
		local isGameMaster = db ~= nil and #db > 0
		if ShouldBlockItem(item, char) then
			if not isGameMaster then
				Osi.DB_CustomUseItemResponse(charUUID, itemUUID, 0)
			else
				RequestProcessed(charUUID, request, 0)
			end
		end
	end
end)

local bulletTemplates = {
	["0f0dea4a-4e3b-48b0-92c7-6f33bdc3f2df"] = true,
	["0a1fa669-d8fb-4767-a129-e14fbd91b195"] = true,
	["d1b28a79-ccd2-481b-b035-13e15346cefb"] = true,
	["bc37a903-547a-4010-a845-7ef244e6b2cb"] = true,
	["92862716-b0db-46b4-9356-9858f9e743f0"] = true,
	["932fb7ba-2634-4b8a-b40a-936077a08008"] = true,
	["6e569546-bd74-4856-819b-d40b08b026ba"] = true,
	["e1125176-cd00-4f7a-8298-ac862d12cf15"] = true,
	["6572eec4-eeb3-4b9d-9cdd-15952a9a8ca6"] = true,
	["6e597ce1-d8b8-4720-89b9-75f6a71d64ba"] = true,
	["b059c11d-458a-4f89-8f18-15b48a402008"] = true,
	["a38aa4e6-ee75-4bb4-8c98-b9f358a23c25"] = true,
	["7ce736c8-1e02-462d-bee2-36bd86bd8979"] = true,
	["7c31f878-1f04-47bb-b8b1-05e605dc0b60"] = true,
	["deb24a84-006f-4a3a-b4bb-b40fa52a447d"] = true,
	["d4eebf4d-4f0c-4409-8fe8-32efeca06453"] = true,
	["8814954c-b0d1-4cdf-b075-3313ac71cf20"] = true,
	["22cae5a3-8427-4526-aa7f-4f277d0ff67e"] = true,
	["e44859b2-d55f-47e2-b509-fd32d7d3c745"] = true,
	["fbf17754-e604-4772-813a-3593b4e7bec8"] = true,
}

---@param item EsvItem
function EquipmentManager.ItemIsNearPlayers(item)
	local target = item.MyGuid
	local parentInventory = GetInventoryOwner(item.MyGuid)
	if not StringHelpers.IsNullOrEmpty(parentInventory) then
		if IsPlayer(parentInventory) then
			return true
		end
		target = parentInventory
	end
	for i,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
		local uuid = db[1]
		local dist = GetDistanceTo(uuid, target)
		if dist ~= nil and dist <= 30 then
			return true
		end
	end
	return false
end

---@param item EsvItem
---@param stats table
function EquipmentManager.SyncItemStatChanges(item, changes, dynamicIndex)
	if changes.Boosts ~= nil and changes.Boosts["Damage Type"] ~= nil then
		changes.Boosts["DamageType"] = changes.Boosts["Damage Type"]
		changes.Boosts["Damage Type"] = nil
	end
	local slot = nil
	local owner = nil
	if item.Slot < 14 and item.OwnerHandle ~= nil then
		local char = Ext.GetCharacter(item.OwnerHandle)
		if char ~= nil then
			slot = GameHelpers.Item.GetEquippedSlot(char.MyGuid, item.MyGuid)
			owner = char.NetID
		end
	end
	if item ~= nil and item.NetID ~= nil then
		local data = {
			UUID = item.MyGuid,
			NetID = item.NetID,
			Slot = slot,
			Owner = owner,
			Changes = changes
		}
		if EquipmentManager.ItemIsNearPlayers(item) then
			Ext.BroadcastMessage("LLWEAPONEX_SetItemStats", Ext.JsonStringify(data), nil)
		else
			Ext.PrintWarning(string.format("[WeaponExpansion:EquipmentManager.SyncItemStatChanges] Item[%s] NetID(%s) UUID(%s) is not near any players, and cannot be retrieved by clients.", item.StatsId, item.NetID, item.MyGuid))
		end
	end
end

---@param char EsvCharacter
---@param item EsvItem
function EquipmentManager.CheckFirearmProjectile(char, item)
	if item:HasTag("LLWEAPONEX_Firearm")
	and not item:HasTag("Musk_Rifle") -- Musketeer has its own rune projectile tweaks
	and item.Stats ~= nil and string.find(item.StatsId, "LLWEAPONEX")
	then
		local changedProjectile = false
		local statChanges = {
			DynamicStats = {}
		}
		for i,v in pairs(item.Stats.DynamicStats) do
			if not StringHelpers.IsNullOrEmpty(v.BoostName) 
			and not StringHelpers.IsNullOrEmpty(v.Projectile) 
			and v.Projectile ~= item.Stats.Projectile
			and bulletTemplates[v.Projectile] ~= true then
				v.Projectile = item.Stats.Projectile
				changedProjectile = true
				statChanges.DynamicStats[i] = {
					Projectile = v.Projectile
				}
			end
		end
		if changedProjectile then
			item.Stats.ShouldSyncStats = true
			EquipmentManager.SyncItemStatChanges(item, statChanges)
		end
	end
end

RegisterProtectedOsirisListener("RuneInserted", 4, "after", function(charUUID, itemUUID, runeTemplate, slot)
	local char = Ext.GetCharacter(charUUID)
	local item = Ext.GetItem(itemUUID)
	EquipmentManager.CheckFirearmProjectile(char, item)
end)

RegisterProtectedOsirisListener("RuneRemoved", 4, "after", function(charUUID, itemUUID, runeUUID, slot)
	local char = Ext.GetCharacter(charUUID)
	local item = Ext.GetItem(itemUUID)
	EquipmentManager.CheckFirearmProjectile(char, item)
end)
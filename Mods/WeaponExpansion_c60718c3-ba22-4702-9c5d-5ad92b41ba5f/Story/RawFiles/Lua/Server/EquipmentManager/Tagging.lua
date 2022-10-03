local self = EquipmentManager

local rangedWeaponTypes = {
	--None = false,
	Sword = false,
	Club = false,
	Axe = false,
	Staff = false,
	Spear = false,
	Knife = false,
	Bow = true,
	Crossbow = true,
	Rifle = true,
	Wand = true,
	Arrow = true,
}

local function TagFromStats(uuid, stat)
	local tagged = false
	for statWord,tag in pairs(Tags.StatWordToTag) do
		if string.find(stat, statWord) then
			SetTag(uuid, tag)
			--PrintDebug("[WeaponExpansion:TagFromStats] Tagged ("..uuid..")["..stat.."] with ("..tag..").")
			tagged = true
		end
	end
	return tagged
end

---@param item EsvItem
---@param statType string|nil The item's stat type. Optional.
---@param statID string|nil The item's stat. Optional.
---@param itemTags table<string,boolean>|nil
function EquipmentManager:TagWeapon(item, statType, statID, itemTags)
	local item = GameHelpers.GetItem(item)
	if item == nil then
		return false
	end
	local tagged = false
	if not item:HasTag("LLWEAPONEX_TaggedWeaponType") then
		SetTag(item.MyGuid, "LLWEAPONEX_TaggedWeaponType")
	end
	-- Has mastery tag but is missing LLWEAPONEX_TaggedWeaponType
	if itemTags then
		for tag,data in pairs(Masteries) do
			if itemTags[tag] or GameHelpers.ItemHasTag(item, tag) then
				return true
			end
		end
	end

	local template = GameHelpers.GetTemplate(item.MyGuid)
	local templateTag = Tags.TemplateToTag[template]
	if Vars.DebugMode then
		fprint(LOGLEVEL.WARNING, "[WeaponExpansion:TagWeapon] (%s) Type(%s) Stat(%s) Template(%s) TemplateTag(%s)", item.MyGuid, statType, statID, template, templateTag or "")
	end
	if templateTag ~= nil then
		if type(templateTag) == "table" then
			for i,tag in pairs(templateTag) do
				SetTag(item.MyGuid, tag)
			end
		else
			SetTag(item.MyGuid, templateTag)
		end
		tagged = true
	else
		if StringHelpers.IsNullOrEmpty(statType) or StringHelpers.IsNullOrEmpty(statID) then
			statID = item.Stats.Name
			statType = GameHelpers.Stats.GetStatType(statID)
		end
		if not StringHelpers.IsNullOrEmpty(statID) then
			if not TagFromStats(item.MyGuid, statID) then
				if statType == "Weapon" then
					local tag = Tags.WeaponTypeToTag[item.Stats.WeaponType]
					if tag ~= nil then
						SetTag(item.MyGuid, tag)
						tagged = true
					end
				elseif statType == "Shield" then
					SetTag(item.MyGuid, "LLWEAPONEX_Shield")
					tagged = true
				end
			else
				tagged = true
			end
		end
	end
	return tagged
end

---@param item EsvItem
local function IsRangedWeapon(item)
	local isRanged = rangedWeaponTypes[item.Stats.WeaponType]
	if isRanged ~= nil then
		return isRanged
	end
	--Type is None or some unknown value, so check the weapon range
	local range = item.Stats.WeaponRange or 0
	if range >= 1000 and not StringHelpers.IsNullOrWhitespace(item.Stats.Projectile) then
		return true
	end
	return false
end

---@param item EsvItem
local function CheckRequirementTags(character, item, otherHand)
	if item.Stats.ItemType ~= "Shield" then
		SetTag(character.MyGuid, "LLWEAPONEX_AnyWeaponEquipped")
		if not IsRangedWeapon(item) then
			ClearTag(character.MyGuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
			if self:CheckScoundrelTags(character, item) or (otherHand and self:CheckScoundrelTags(character, otherHand)) then
				if character:HasTag("LLWEAPONEX_CannotUseScoundrelSkills") then
					ClearTag(character.MyGuid, "LLWEAPONEX_CannotUseScoundrelSkills")
					PrintDebug("ClearTag LLWEAPONEX_CannotUseScoundrelSkills", character.MyGuid)
					return true
				end
			else
				if not character:HasTag("LLWEAPONEX_CannotUseScoundrelSkills") then
					SetTag(character.MyGuid, "LLWEAPONEX_CannotUseScoundrelSkills")
					PrintDebug("SetTag LLWEAPONEX_CannotUseScoundrelSkills", character.MyGuid)
					return true
				end
			end
		else
			SetTag(character.MyGuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
			return true
		end
	else
		SetTag(character.MyGuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
		return true
	end
	return false
end

---@param character EsvCharacter
function EquipmentManager:CheckWeaponRequirementTags(character)
	if not character then
		return
	end
	local refreshRequired = false
	local mainhand = CharacterGetEquippedItem(character.MyGuid, "Weapon")
	local offhand = CharacterGetEquippedItem(character.MyGuid, "Shield")
	if StringHelpers.IsNullOrEmpty(mainhand) and StringHelpers.IsNullOrEmpty(offhand) then
		Osi.LLWEAPONEX_Equipment_TrackUnarmed(character.MyGuid)

		if Mastery.HasMasteryRequirement(character, "LLWEAPONEX_Unarmed_Mastery1") then
			ClearTag(character.MyGuid, "LLWEAPONEX_AnyWeaponEquipped")
			ClearTag(character.MyGuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
			SetTag(character.MyGuid, "LLWEAPONEX_CannotUseScoundrelSkills")
		else
			ClearTag(character.MyGuid, "LLWEAPONEX_AnyWeaponEquipped")
			SetTag(character.MyGuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
			SetTag(character.MyGuid, "LLWEAPONEX_CannotUseScoundrelSkills")
		end

		refreshRequired = true
	else
		if not StringHelpers.IsNullOrEmpty(mainhand) then
			mainhand = GameHelpers.GetItem(mainhand)
		end
		if not StringHelpers.IsNullOrEmpty(offhand) then
			offhand = GameHelpers.GetItem(offhand)
		end
	end

	if mainhand then
		refreshRequired = CheckRequirementTags(character, mainhand, offhand)
	elseif offhand then
		refreshRequired = CheckRequirementTags(character, offhand)
	end

	if refreshRequired and CharacterIsControlled(character.MyGuid) == 1 then
		GameHelpers.UI.RefreshSkillBar(character.MyGuid)
	end

	--[[ if IsPlayer(character.MyGuid) then
		local hasWarfareTag = character:HasTag("LLWEAPONEX_NoMeleeWeaponEquipped")
		local hasScoundrelTag = character:HasTag("LLWEAPONEX_CannotUseScoundrelSkills")
		for skill,b in pairs(Skills.WarfareMeleeSkills) do
			GameHelpers.UI.SetSkillEnabled(character.MyGuid, skill, not hasWarfareTag)
		end
		for skill,b in pairs(Skills.ScoundrelMeleeSkills) do
			GameHelpers.UI.SetSkillEnabled(character.MyGuid, skill, not hasScoundrelTag)
		end
	end ]]
end

---@param character EsvCharacter
---@param isPlayer boolean
---@param newlyEquipped EsvItem
function EquipmentManager:CheckForUnarmed(character, isPlayer, newlyEquipped)
	local hasEmptyHands = HasEmptyHand(character, false)
	if newlyEquipped ~= nil and newlyEquipped.Stats ~= nil and newlyEquipped.Stats.IsTwoHanded then
		hasEmptyHands = false
	end
	if hasEmptyHands and CharacterHasSkill(character.MyGuid, "Target_LLWEAPONEX_SinglehandedAttack") == 1 then
		GameHelpers.Skill.Swap(character.MyGuid, "Target_LLWEAPONEX_SinglehandedAttack", "Target_SingleHandedAttack", true, false)
	else
		local hasSkill = CharacterHasSkill(character.MyGuid, "Target_LLWEAPONEX_SinglehandedAttack") == 1
		if UnarmedHelpers.HasEmptyHands(character) then
			if not hasSkill then
				GameHelpers.Skill.Swap(character.MyGuid, "Target_SingleHandedAttack", "Target_LLWEAPONEX_SinglehandedAttack", true, false)
			end
		elseif hasSkill then
			CharacterRemoveSkill(character.MyGuid, "Target_LLWEAPONEX_SinglehandedAttack")
		end
	end
end

---@param character EsvCharacter
---@param item EsvItem
local function UpdatedUnarmedTagsFromWeapon(character, item)
	SetTag(character.MyGuid, "LLWEAPONEX_AnyWeaponEquipped")
	if rangedWeaponTypes[item.Stats.WeaponType] ~= true then
		ClearTag(character.MyGuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
	else
		SetTag(character.MyGuid, "LLWEAPONEX_NoMeleeWeaponEquipped")
	end
	if GameHelpers.Character.IsPlayer(character) then
		if item.Stats.AnimType ~= "Unarmed" or not UnarmedHelpers.HasUnarmedWeaponStats(character.MyGuid) then
			Osi.LLWEAPONEX_WeaponMastery_Internal_CheckRemovedMasteries(character.MyGuid, "LLWEAPONEX_Unarmed")
		end
	end
end

---@param character EsvCharacter
---@param item EsvItem
local function AxeScoundrelEnabled(character, item, itemTags)
	return Mastery.HasMasteryRequirement(character.MyGuid, "LLWEAPONEX_Axe_Mastery4")
	and (item.Stats.WeaponType == "Axe" or (itemTags.LLWEAPONEX_Axe or item:HasTag("LLWEAPONEX_Axe")))
end

---@param character EsvCharacter
---@param item EsvItem
function EquipmentManager:CheckScoundrelTags(character, item, itemTags)
	itemTags = itemTags or {}
	if item.Stats.WeaponType == "Knife" 
	or (itemTags.LLWEAPONEX_Katana or item:HasTag("LLWEAPONEX_Katana"))
	or AxeScoundrelEnabled(character, item, itemTags)
	then
		return true
	end
	return false
end

---@param character EsvCharacter
---@return boolean
function HasEmptyHand(character, ignoreShields)
	local character = GameHelpers.GetCharacter(character)
	if not character then
		return false
	end
	local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(character)
	if type(ignoreShields) == "string" then
		ignoreShields = string.lower(ignoreShields) == "true"
	else
		ignoreShields = ignoreShields == true
	end
	if mainhand and mainhand.Stats.IsTwoHanded then
		return false
	end
	if offhand and (not ignoreShields or offhand.Stats.ItemType ~= "Shield") then
		return false
	end
	return true
end
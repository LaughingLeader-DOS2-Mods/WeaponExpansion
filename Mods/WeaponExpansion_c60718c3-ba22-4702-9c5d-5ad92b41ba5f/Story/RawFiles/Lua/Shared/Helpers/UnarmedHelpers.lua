if UnarmedHelpers == nil then
	UnarmedHelpers = {}
end

local isClient = Ext.IsClient()

local unarmedAttributes = {
	"Strength",
	"Finesse",
	"Constitution"
}

function UnarmedHelpers.GetMasteryBoost(unarmedMastery)
	if unarmedMastery == 1 then
		return GameHelpers.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost1", 30)
	elseif unarmedMastery == 2 then
		return GameHelpers.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost2", 40)
	elseif unarmedMastery == 3 then
		return GameHelpers.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost3", 60)
	elseif unarmedMastery >= 4 then
		return GameHelpers.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost4", 70)
	end
	return 0
end

local _SLOTS = {
	Gloves = true,
	Boots = true
}

local _UNARMEDTAGS = {"LLWEAPONEX_Unarmed", "LLWEAPONEX_UnarmedWeaponEquipped"}

UnarmedHelpers.Tags = _UNARMEDTAGS
UnarmedHelpers.ValidWeaponSlots = _SLOTS

---@param character EsvCharacter|EclCharacter
---@return boolean
function UnarmedHelpers.IsLizard(character)
	if character:HasTag("LIZARD") then
		return true
	end
	if GameHelpers.Character.IsPlayer(character) and character.PlayerCustomData ~= nil then
		if string.find(character.PlayerCustomData.Race, "Lizard") then
			return true
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter
---@return EsvItem|EclItem
local function GetEquippedUnarmedArmor(character)
	local foundItems = {}
	if isClient then
		for slot,b in pairs(_SLOTS) do
			local item = character:GetItemBySlot(slot)
			if item and GameHelpers.ItemHasTag(item, _UNARMEDTAGS) then
				foundItems[#foundItems+1] = item
			end
		end
	else
		if not Ext.OsirisIsCallable() then
			for slot,b in pairs(_SLOTS) do
				local statItem = character.Stats:GetItemBySlot(slot)
				if statItem and GameHelpers.StatItemHasTag(statItem, _UNARMEDTAGS) then
					foundItems[#foundItems+1] = statItem
				end
			end
		else
			local items = character:GetInventoryItems()
			for i=1,math.min(#items, 14) do
				if items[i] then
					local item = Ext.GetItem(items[i])
					if item and not GameHelpers.Item.IsObject(item) and GameHelpers.ItemHasTag(item, _UNARMEDTAGS) then
						if isClient then
							if _SLOTS[item.Stats.ItemSlot] == true  then
								foundItems[#foundItems+1] = item
							end
						else
							if _SLOTS[Data.EquipmentSlotNames[item.Slot]] == true then
								foundItems[#foundItems+1] = item
							end
						end
					end
				end
			end
		end
	end
	return foundItems
end

---@param character EsvCharacter|EclCharacter
---@return integer
function UnarmedHelpers.GetUnarmedMasteryRank(character)
	local unarmedMasteryRank = 0
	local characterTags = GameHelpers.GetAllTags(character.Character, true, true)
	for i=1,Mastery.Variables.MaxRank,1 do
		local tag = "LLWEAPONEX_Unarmed_Mastery" .. i
		if characterTags[tag] then
			unarmedMasteryRank = i
		end
	end
	return unarmedMasteryRank
end

---@param character StatCharacter
---@param skipItemCheck boolean|nil
---@param statItem StatItem|nil
---@return StatItem,number,integer,string,boolean
function UnarmedHelpers.GetUnarmedWeapon(character, skipItemCheck, statItem)
	local hasUnarmedWeapon = false
	local weaponStat = "NoWeapon"
	local level = character.Level
	if skipItemCheck ~= true and statItem == nil then
		for item in pairs(GetEquippedUnarmedArmor(character.Character)) do
			local unarmedWeaponStat = nil
			if GameHelpers.Ext.ObjectIsItem(item) then
				unarmedWeaponStat = UnarmedWeaponStats[item.StatsId]
			elseif GameHelpers.Ext.ObjectIsStatItem(item) then
				unarmedWeaponStat = UnarmedWeaponStats[item.Name]
			end
			if unarmedWeaponStat ~= nil then
				weaponStat = unarmedWeaponStat
				hasUnarmedWeapon = true
				level = item.Level
				break
			end
		end
	end
	if statItem ~= nil then
		local unarmedWeaponStat = UnarmedWeaponStats[statItem.Name]
		if unarmedWeaponStat ~= nil then
			weaponStat = unarmedWeaponStat
			hasUnarmedWeapon = true
			level = statItem.Level
		end
	end
	local highestAttribute = Skills.GetHighestAttribute(character, unarmedAttributes)
	local unarmedMasteryRank = UnarmedHelpers.GetUnarmedMasteryRank(character.Character)
	local unarmedMasteryBoost = UnarmedHelpers.GetMasteryBoost(unarmedMasteryRank)
	---@type StatItem
	local weapon = ExtenderHelpers.CreateWeaponTable(weaponStat, level, highestAttribute, "Club", unarmedMasteryBoost)
	--print("Unarmed weapon:", Common.Dump(weapon), getmetatable(character.Character))
	--print(getmetatable(character), type(getmetatable(character)))
	return weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon
end

---@param character StatCharacter
---@param statItem StatItem
---@return StatItem Weapon table
---@return integer Highest attribute
function UnarmedHelpers.CreateUnarmedWeaponTable(character, statItem)
	local hasUnarmedWeapon = false
	local weaponStat = "NoWeapon"
	local level = character.Level
	if statItem ~= nil then
		local unarmedWeaponStat = UnarmedWeaponStats[statItem.Name]
		if unarmedWeaponStat ~= nil then
			weaponStat = unarmedWeaponStat
			hasUnarmedWeapon = true
			level = statItem.Level
		end
	end
	local highestAttribute = Skills.GetHighestAttribute(character, unarmedAttributes)
	local unarmedMasteryRank = UnarmedHelpers.GetUnarmedMasteryRank(character.Character)
	local unarmedMasteryBoost = UnarmedHelpers.GetMasteryBoost(unarmedMasteryRank)
	local weapon = ExtenderHelpers.CreateWeaponTable(weaponStat, level, highestAttribute, "Club", unarmedMasteryBoost)
	return weapon,highestAttribute
end

---@param character EclCharacter
function UnarmedHelpers.GetUnarmedBaseAndTotalDamage(character)
	local isLizard = UnarmedHelpers.IsLizard(character)
	local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character.Stats, true)
	local damageList,baseMin,baseMax,totalMin,totalMax = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, true, highestAttribute, isLizard, false)
	if isLizard then
		local damageList2,baseMin2,baseMax2,totalMin2,totalMax2 = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, true, highestAttribute, isLizard, true)
		baseMin = baseMin + baseMin2
		baseMax = baseMax + baseMax2
		totalMin = totalMin + totalMin2
		totalMax = totalMax + totalMax2
	end
	return baseMin,baseMax,totalMin,totalMax,unarmedMasteryBoost
end

---@param character StatCharacter
---@param skipDualWielding boolean|nil Skip calculating dual-wielding damage (Lizards) if true.
---@return table<string,number[]>,string
function UnarmedHelpers.GetBaseUnarmedDamageRange(character, skipDualWielding)
	local noWeapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character, true)
	local damageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, noWeapon)
	if skipDualWielding ~= true and UnarmedHelpers.IsLizard(character.Character) then
		local offHandDamageRange = Common.CopyTable(damageRange, true)
		local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
		for damageType, range in pairs(offHandDamageRange) do
			local min = math.ceil(range.Min * dualWieldPenalty)
			local max = math.ceil(range.Max * dualWieldPenalty)
			local range = damageRange[damageType]
			if damageRange[damageType] ~= nil then
				range.Min = range.Min + min
				range.Max = range.Max + max
			else
				damageRange[damageType] = {Min = min, Max = max}
			end
		end
	end
	return damageRange,highestAttribute
end


---@param character StatCharacter
---@param item EclItem|EsvItem|StatItem
---@param skipDualWielding boolean|nil Skip calculating dual-wielding damage (Lizards) if true.
---@return table<string,number[]>,string
function UnarmedHelpers.GetUnarmedWeaponDamageRange(character, item, skipDualWielding)
	local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character, true, item)
	local damageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, weapon)
	if skipDualWielding ~= true and UnarmedHelpers.IsLizard(character.Character) then
		local offHandDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, weapon)
		local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
		for damageType, range in pairs(offHandDamageRange) do
			local min = math.ceil(range.Min * dualWieldPenalty)
			local max = math.ceil(range.Max * dualWieldPenalty)
			local range = damageRange[damageType]
			if damageRange[damageType] ~= nil then
				range.Min = range.Min + min
				range.Max = range.Max + max
			else
				damageRange[damageType] = {Min = min, Max = max}
			end
		end
	end
	return damageRange,highestAttribute
end

---@param stat StatEntryWeapon
function UnarmedHelpers.IsUnarmedWeaponStat(stat)
	if stat == nil then
		return true
	else
		if stat.Name == "NoWeapon" or UnarmedWeaponStats[stat.Name] then
			return true
		end
		if not StringHelpers.IsNullOrWhitespace(stat.Tags) and 
		Common.TableHasValue(StringHelpers.Split(stat.Tags, ";"), "LLWEAPONEX_Unarmed") then
			return true
		end
		for _,v in pairs(stat.DynamicStats) do
			if not StringHelpers.IsNullOrWhitespace(v.ObjectInstanceName) then
				local tagsString = Ext.StatGetAttribute(v.ObjectInstanceName, "Tags")
				if not StringHelpers.IsNullOrWhitespace(tagsString) then
					local tags = StringHelpers.Split(tagsString, ";")
					if TableHelpers.HasValue(tags, _UNARMEDTAGS, false) then
						return true
					end
				end
			end
		end
	end
end

---@param char StatCharacter
---@param allowShields boolean|nil
function UnarmedHelpers.HasUnarmedWeaponStats(char, allowShields)
	local character = nil
	if GameHelpers.Ext.ObjectIsStatCharacter(char) then
		character = char
	elseif GameHelpers.Ext.ObjectIsCharacter(char) then
		character = char.Stats
	else
		local cObj = GameHelpers.GetCharacter(char)
		if cObj then
			character = cObj.Stats
		end
	end
	if character then
		local hasValidOffhand = (allowShields == true and character.OffHandWeapon ~= nil and character.OffHandWeapon.Slot == "Shield") or character.OffHandWeapon == nil
		if UnarmedHelpers.IsUnarmedWeaponStat(character.MainWeapon)
		and (UnarmedHelpers.IsUnarmedWeaponStat(character.OffHandWeapon) or hasValidOffhand) then
			return true
		end
	end
	return false
end

---@param uuid string
function UnarmedHelpers.IsUnarmedWeapon(uuid)
	if StringHelpers.IsNullOrEmpty(uuid) then
		return true
	else
		local item = GameHelpers.GetItem(uuid)
		if item and GameHelpers.ItemHasTag(item, _UNARMEDTAGS) then
			return true
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter
function UnarmedHelpers.IsUnarmed(character)
	return character.Stats:GetItemBySlot("Weapon") == nil and character.Stats:GetItemBySlot("Shield") == nil
end
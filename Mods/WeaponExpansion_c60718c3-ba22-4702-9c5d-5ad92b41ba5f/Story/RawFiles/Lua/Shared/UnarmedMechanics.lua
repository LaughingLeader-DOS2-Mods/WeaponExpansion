local unarmedAttributes = {
	"Strength",
	"Finesse",
	"Constitution"
}

function GetUnarmedMasteryBoost(unarmedMastery)
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

local unarmedWeaponSlots = {
	"Gloves",
	"Boots"
}

---@param character StatCharacter
---@return StatItem,number,integer,string,boolean
function GetUnarmedWeapon(character, skipItemCheck)
	local hasUnarmedWeapon
	local weaponStat = "NoWeapon"
	local level = character.Level
	print("Checking for LLWEAPONEX_UnarmedWeaponEquipped tag", character, character.Character)
	if skipItemCheck ~= true and character.Character:HasTag("LLWEAPONEX_UnarmedWeaponEquipped") then
		for i,slot in pairs(unarmedWeaponSlots) do
			---@type StatItem
			local item = character:GetItemBySlot(slot)
			if item ~= nil then
				if string.find(item.Tags, "LLWEAPONEX_UnarmedWeaponEquipped") then
					local unarmedWeaponStat = UnarmedWeaponStats[item.Name]
					if unarmedWeaponStat ~= nil then
						weaponStat = unarmedWeaponStat
						hasUnarmedWeapon = true
						level = item.Level
						break
					end
				end
			end
		end
	end
	local highestAttribute = Skills.GetHighestAttribute(character, unarmedAttributes)
	local unarmedMasteryRank = 0
	for i=1,5,1 do
		local tag = "LLWEAPONEX_Unarmed_Mastery" .. i
		if character.Character:HasTag(tag) then
			unarmedMasteryRank = i
		end
	end
	local unarmedMasteryBoost = GetUnarmedMasteryBoost(unarmedMasteryRank)
	---@type StatItem
	local weapon = Skills.CreateWeaponTable(weaponStat, level, highestAttribute, "None", unarmedMasteryBoost)
	--print("Unarmed weapon:", Common.Dump(weapon), getmetatable(character.Character))
	--print(getmetatable(character), type(getmetatable(character)))
	return weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon
end

---@param character StatCharacter
---@return table<string,number[]>,number,integer,string
function GetUnarmedDamageRange(character)
	local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = GetUnarmedWeapon(character)
	local damageRange = Game.Math.CalculateWeaponDamageRange(character, weapon)
	return damageRange,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon
end

---@param character StatCharacter
---@param item StatItem
---@return table<string,number[]>,string
function GetUnarmedWeaponDamageRange(character, item)
	local noWeapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = GetUnarmedWeapon(character, true)
	if item.Tags ~= nil and string.find(item.Tags, "LLWEAPONEX_UnarmedWeaponEquipped") then
		local unarmedWeaponStatName = UnarmedWeaponStats[item.Name]
		if unarmedWeaponStatName ~= nil then
			local unarmedWeapon = Skills.CreateWeaponTable(unarmedWeaponStatName, item.Level, highestAttribute, "None", unarmedMasteryBoost)
			if unarmedWeapon ~= nil then
				for i,stat in ipairs(unarmedWeapon.DynamicStats) do
					if i > 1 then
						table.insert(noWeapon.DynamicStats, stat)
					elseif i == 1 then
						noWeapon.DynamicStats[1] = stat
					end
				end
			end
		end
	end
	local damageRange = Game.Math.CalculateWeaponDamageRange(character, noWeapon)
	print("noWeapon:", Ext.JsonStringify(noWeapon))
	print("GetUnarmedWeaponDamageRange:", Ext.JsonStringify(damageRange))
	return damageRange,highestAttribute
end

local function statMatchOrNil(stat, name)
	return stat == nil or (stat ~= nil and stat.Name == name)
end

---@param character StatCharacter
function IsUnarmed(character, allowShields)
	if type(character) == "string" then
		character = Ext.GetCharacter(character).Stats
	elseif type(character) == "userdata" then
		local objType = getmetatable(character)
		if objType == "ecl::Character" then
			character = character.Stats
		elseif objType ~= "CDivinityStats_Character" then
			Ext.PrintError("[WeaponExpansion:IsUnarmed] The character param should be a string, EsvCharacter, or StatCharacter. Type is:", character, objType)
			character = nil
		end
	end
	if character ~= nil then
		return statMatchOrNil(character.MainWeapon, "NoWeapon") and (statMatchOrNil(character.OffHandWeapon, "NoWeapon") or (allowShields == true and character.OffHandWeapon ~= nil and character.OffHandWeapon.Slot == "Shield"))
	end
	return false
end
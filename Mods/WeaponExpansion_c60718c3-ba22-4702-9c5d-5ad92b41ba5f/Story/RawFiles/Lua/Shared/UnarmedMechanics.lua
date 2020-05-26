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

---@param character StatCharacter
---@param hasUnarmedWeapon boolean
function GetUnarmedWeapon(character, hasUnarmedWeapon)
	local weaponStat = "NoWeapon"
	if hasUnarmedWeapon == true then
		---@type StatItem
		local gloves = character:GetItemBySlot("Gloves")
		if gloves ~= nil then
			local unarmedWeaponStat = UnarmedWeaponStats[gloves.Name]
			if unarmedWeaponStat ~= nil then
				weaponStat = unarmedWeaponStat
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
	local weapon = Skills.CreateWeaponTable(weaponStat, character.Level, highestAttribute, "None", unarmedMasteryBoost)
	print("Unarmed weapon:", Common.Dump(weapon))
	return weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute
end

local function statMatchOrNil(stat, name)
	return stat == nil or (stat ~= nil and stat.Name == name)
end

---@param character StatCharacter
function IsUnarmed(character, allowShields)
	if type(character) == "string" then
		character = Ext.GetCharacter(character).Stats
	elseif character.Character == nil and character.Stats ~= nil then -- EsvCharacter to StatCharacter
		character = character.Stats
	end
	--Ext.PrintError(character, character.MainWeapon.Name, character.OffHandWeapon)
	if character ~= nil then
		return statMatchOrNil(character.MainWeapon, "NoWeapon") and (statMatchOrNil(character.OffHandWeapon, "NoWeapon") or (allowShields == true and character.OffHandWeapon ~= nil and character.OffHandWeapon.Slot == "Shield"))
	end
	return false
end
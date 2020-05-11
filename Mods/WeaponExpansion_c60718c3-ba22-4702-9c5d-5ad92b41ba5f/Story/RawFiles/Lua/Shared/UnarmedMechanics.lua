local unarmedAttributes = {
	"Strength",
	"Finesse",
	"Constitution"
}

function GetUnarmedMasteryBoost(unarmedMastery)
	if unarmedMastery == 1 then
		return LeaderLib.Game.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost1", 20)
	elseif unarmedMastery == 2 then
		return LeaderLib.Game.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost2", 40)
	elseif unarmedMastery == 3 then
		return LeaderLib.Game.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost3", 60)
	elseif unarmedMastery >= 4 then
		return LeaderLib.Game.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost4", 70)
	end
	return 0
end

---@param character StatCharacter
function GetUnarmedWeapon(character)
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
	local weapon = Skills.PrepareWeaponStat("NoWeapon", character.Level, highestAttribute, "None", unarmedMasteryBoost)
	print("Weapon:", LeaderLib.Common.Dump(weapon))
	return weapon
end

---@param character StatCharacter
function IsUnarmed(character, noShields)
	if character ~= nil then
		return (character.MainWeapon == nil or character.MainWeapon.Name == "NoWeapon") and (
			character.OffHandWeapon == nil or (noShields == true and character.OffHandWeapon ~= nil and character.OffHandWeapon.Slot == "Shield"))
	end
	return false
end
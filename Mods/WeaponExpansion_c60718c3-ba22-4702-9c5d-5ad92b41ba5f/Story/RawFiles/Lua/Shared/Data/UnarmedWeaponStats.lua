UnarmedData = {
	---Armor StatId to Weapon StatId
	---@type table<string,string>
	ArmorToWeapon = {},
	---Weapon StatId to Armor StatId
	---@type table<string,string>
	WeaponToArmor = {}
}

---Unarmed weapons are armor items that modify the damage of NoWeapon on hit
---ArmorStat => WeaponStat
---@deprecated
---@type table<string,string>
UnarmedWeaponStats = {}
setmetatable(UnarmedWeaponStats, {
	__index = function (_,k)
		return UnarmedData.ArmorToWeapon[k] or UnarmedData.WeaponToArmor[k]
	end,
	__newindex = function (_,k,v)
		UnarmedHelpers.RegisterUnarmedStat(k,v)
	end
})

if UnarmedHelpers == nil then
	UnarmedHelpers = {}
end

---Register a weapon stat to use for unarmed damage when an armor stat is equipped.
---@param armorStat string The armor stat to associate with a weapon stat, such as ARM_UNIQUE_LLWEAPONEX_DragonBoneClaws_A.
---@param weaponStat string The weapon stat to use for damage calculation, such as WPN_UNIQUE_LLWEAPONEX_DragonBoneClaws_A.
---@param skillPropertiesStat string|nil The skill to execute properties from when hitting something with the weapon stat.
function UnarmedHelpers.RegisterUnarmedStat(armorStat, weaponStat)
	UnarmedData.ArmorToWeapon[armorStat] = weaponStat
	UnarmedData.WeaponToArmor[weaponStat] = armorStat
end

---@param statId string An armor stat or weapon stat.
---@return string|nil associatedStat The associated weapon or armor stat ID.
---@return string|nil skillID Returns a skill associated with the weapon stat, if any.
function UnarmedHelpers.GetAssociatedStats(statId)
	local weaponStat = UnarmedData.ArmorToWeapon[statId]
	if weaponStat then
		return weaponStat
	end
	local armorStat = UnarmedData.WeaponToArmor[statId]
	if armorStat then
		return armorStat
	end
end

UnarmedHelpers.RegisterUnarmedStat("ARM_UNIQUE_LLWEAPONEX_DragonBoneClaws_A", "WPN_UNIQUE_LLWEAPONEX_DragonBoneClaws_A")
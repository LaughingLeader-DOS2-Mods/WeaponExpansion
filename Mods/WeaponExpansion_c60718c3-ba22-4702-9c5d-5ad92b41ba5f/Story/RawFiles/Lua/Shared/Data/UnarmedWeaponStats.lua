---Unarmed weapons are armor items that modify the damage of NoWeapon on hit
---ArmorStat => WeaponStat
---@type table<string,string>
UnarmedWeaponStats = {
	ARM_UNIQUE_LLWEAPONEX_DragonBoneClaws_A = "WPN_UNIQUE_LLWEAPONEX_DragonBoneClaws_A"
}

if UnarmedHelpers == nil then
	UnarmedHelpers = {}
end

---@param armorStat string The armor stat to associate with a weapon stat, such as ARM_UNIQUE_LLWEAPONEX_DragonBoneClaws_A.
---@param weaponStat string The weapon stat to use for damage calculation, such as WPN_UNIQUE_LLWEAPONEX_DragonBoneClaws_A.
function UnarmedHelpers.RegisterUnarmedStat(armorStat, weaponStat)
	UnarmedWeaponStats[armorStat] = weaponStat
end
TableHelpers.AddOrUpdate(Tags.TemplateToTag, {
	--WPN_Ataraxians_Scythe_2H_A
	["3b45c978-5a42-40b5-a7aa-183852616910"] = "LLWEAPONEX_Scythe",
	--WPN_Tool_Scythe_2H_A_
	["44525b09-a2b1-4b45-8d52-e893d04390dd"] = "LLWEAPONEX_Scythe",
})

TableHelpers.AddOrUpdate(Tags.WeaponTypeToTag, {
	Axe = "LLWEAPONEX_Axe",
	Bow = "LLWEAPONEX_Bow",
	Club = "LLWEAPONEX_Bludgeon",
	Crossbow = "LLWEAPONEX_Crossbow",
	Rifle = "LLWEAPONEX_Firearm",
	Knife = "LLWEAPONEX_Dagger",
	Spear = "LLWEAPONEX_Spear",
	Staff = "LLWEAPONEX_Staff",
	Sword = "LLWEAPONEX_Sword",
	Wand = "LLWEAPONEX_Wand",
	--Arrow = "LLWEAPONEX_Arrow",
	--Sentinel = "LLWEAPONEX_Sentinel",
})

TableHelpers.AddOrUpdate(Tags.RangedWeaponTags, {
	"LLWEAPONEX_Bow",
	"LLWEAPONEX_Crossbow",
	"LLWEAPONEX_Firearm",
	"LLWEAPONEX_Wand",
})

TableHelpers.AddOrUpdate(Tags.StatWordToTag, {
	["Scythe"] = "LLWEAPONEX_Scythe"
})

function AddWeaponTypeTag(tag)
	Tags.WeaponTypes[tag] = tag.."_Equipped"
end

AddWeaponTypeTag("LLWEAPONEX_Axe")
AddWeaponTypeTag("LLWEAPONEX_Banner")
AddWeaponTypeTag("LLWEAPONEX_BattleBook")
--AddWeaponTypeTag("LLWEAPONEX_Blunderbuss")
AddWeaponTypeTag("LLWEAPONEX_Bludgeon")
AddWeaponTypeTag("LLWEAPONEX_Bow")
--AddWeaponTypeTag("LLWEAPONEX_CombatShield")
AddWeaponTypeTag("LLWEAPONEX_DualShields")
AddWeaponTypeTag("LLWEAPONEX_Crossbow")
AddWeaponTypeTag("LLWEAPONEX_Dagger")
AddWeaponTypeTag("LLWEAPONEX_Firearm")
--AddWeaponTypeTag("LLWEAPONEX_Glaive")
AddWeaponTypeTag("LLWEAPONEX_Greatbow")
AddWeaponTypeTag("LLGRIMOIRE_Grimoire")
--AddWeaponTypeTag("LLWEAPONEX_Halberd")
AddWeaponTypeTag("LLWEAPONEX_HandCrossbow")
AddWeaponTypeTag("LLWEAPONEX_Katana")
AddWeaponTypeTag("LLWEAPONEX_Pistol")
AddWeaponTypeTag("LLWEAPONEX_Polearm")
AddWeaponTypeTag("LLWEAPONEX_Quarterstaff")
AddWeaponTypeTag("LLWEAPONEX_Rapier")
--AddWeaponTypeTag("LLWEAPONEX_Rod")
Tags.WeaponTypes["LLWEAPONEX_Rod"] = "LLWEAPONEX_Wand_Equipped"
AddWeaponTypeTag("LLWEAPONEX_Runeblade")
AddWeaponTypeTag("LLWEAPONEX_Scythe")
AddWeaponTypeTag("LLWEAPONEX_Shield")
AddWeaponTypeTag("LLWEAPONEX_Spear")
AddWeaponTypeTag("LLWEAPONEX_Staff")
AddWeaponTypeTag("LLWEAPONEX_Sword")
AddWeaponTypeTag("LLWEAPONEX_Throwing")
AddWeaponTypeTag("LLWEAPONEX_Unarmed")
AddWeaponTypeTag("LLWEAPONEX_Wand")
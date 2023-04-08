---@meta
---@diagnostic disable

--This file is never actually loaded, and is used to make the vscode extension work better.

if not Mods then Mods = {} end

---@class WeaponExpansionModTable
---@field PersistentVars WeaponExpansionVars
Mods.WeaponExpansion = {
	AttributeScaleTables = AttributeScaleTables,
	BonusSkills = BonusSkills,
	Config = Config,
	ItemProcessor = ItemProcessor,
	Mastery = Mastery,
	MasteryBonusManager = MasteryBonusManager,
	MasteryDataClasses = MasteryDataClasses,
	MasteryID = MasteryID,
	MasteryMenu = MasteryMenu,
	MODID = MODID,
	ModuleUUID = "c60718c3-ba22-4702-9c5d-5ad92b41ba5f",
	NPC = NPC,
	Origin = Origin,
	OriginColors = OriginColors,
	Skills = Skills,
	Tags = Tags,
	UnarmedData = UnarmedData,
	UnarmedHelpers = UnarmedHelpers,
	UniqueManager = UniqueManager,
	Uniques = Uniques,
	WeaponExTesting = WeaponExTesting,
}

---@alias EquipmentChangedCallback fun(char:EsvCharacter, item:EsvItem, template:string, equipped:boolean)
---@alias EquipmentChangedIDType string|"Tag"|"Template"
---@alias ItemListenerEvent string|"EquipmentChanged"
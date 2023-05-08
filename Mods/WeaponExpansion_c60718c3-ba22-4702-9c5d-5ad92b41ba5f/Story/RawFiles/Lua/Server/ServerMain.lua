---@class HitFlagPreset
local HitFlagPreset = {}
HitFlagPreset.__index = HitFlagPreset

---@param params HitRequest
---@return HitFlagPreset
function HitFlagPreset:Create(params)
    local this = {}
    for k,v in pairs(params) do
        this[k] = v
    end
    setmetatable(this, self)
    return this
end

---@param params HitRequest
---@return HitFlagPreset
function HitFlagPreset:Append(params)
    local this = {}
    for k,v in pairs(self) do
        this[k] = v
    end
    for k,v in pairs(params) do
        this[k] = v
    end
    setmetatable(this, self)
    return this
end

HitFlagPresets = {
    GuaranteedWeaponHit = HitFlagPreset:Create({
        SimulateHit = true,
        HitType = "WeaponDamage",
        HitWithWeapon = true,
        Hit = true,
        Blocked = false,
        Dodged = false,
        Missed = false,
    }),
    EventlessMagicHit = HitFlagPreset:Create({
        SimulateHit = false,
        NoHitRoll = true,
        HitType = "DoT",
        HitWithWeapon = false,
        NoEvents = true,
        DontCreateBloodSurface = true,
    }),
    DevilHandActiveDefense = HitFlagPreset:Create({
        SimulateHit = false,
        NoHitRoll = true,
        HitType = "DoT",
        HitWithWeapon = false,
        NoEvents = true,
        DontCreateBloodSurface = true,
        CounterAttack = true,
    }),
}

function GetHandedness(weapon)
    if weapon == nil then
        return nil
    end
    local stat = NRD_ItemGetStatsId(weapon)
    local handedness = NRD_StatGetString(stat, "IsTwoHanded")
    if handedness == "Yes" then
        Ext.Utils.Print("[LLWEAPONEX_Main.lua:GetHandedness] Item is two-handed.")
        return true
    elseif handedness == "No" then
        Ext.Utils.Print("[LLWEAPONEX_Main.lua:GetHandedness] Item is one-handed.")
        return false
    else
        return nil
    end
end

local weapon_slots = {"Weapon", "Shield"}

function TagHandedness(player)
    for _,slot in pairs(weapon_slots) do
        local item = CharacterGetEquippedItem(player, slot)
        if item ~= nil then
            local handedness = GetHandedness(item)
            if handedness ~= nil then
                if handedness == true then
                    SetTag(item, "LLWEAPONEX_IsTwoHanded")
                else
                    SetTag(item, "LLWEAPONEX_IsOneHanded")
                end
            end
        end
    end
    Ext.Utils.Print("[LLWEAPONEX_Main.lua:GetHandedness] Item check done.")
end

function TagItemType(player)
    local slots = {"Weapon", "Shield"}
    local anim_to_type = {
        --None = "",
        --OneHanded = "",
        --TwoHanded = "",
        Bow = "Bow",
        --DualWield = "",
        Shield = "Shield",
        SmallWeapons = "Dagger",
        PoleArms = "Spear",
        Unarmed = "Unarmed",
        CrossBow = "Crossbow",
        TwoHanded_Sword = "Sword",
        --Sitting = ""
        --Lying = ""
        --DualWieldSmall = ""
        Staves = "Staff",
        Wands = "Wand",
        DualWieldWands = "Wand",
        ShieldWands = "Wand"}
        
    for i, slot in pairs(slots) do
        local item = CharacterGetEquippedItem(player, slot)
        if item ~= nil then
            local stat = NRD_ItemGetStatsId(item)
            local itemtype = NRD_StatGetType(stat)
            if itemtype ~= nil then
                if itemtype == "Weapon" then
                    local weapon_type = NRD_StatGetString(stat, "WeaponType")
                    if weapon_type ~= nil then
                        if weapon_type ~= "None" then
                            local tag = "LLWEAPONEX_" .. weapon_type
                            SetTag(item, tag)
                        else
                            local anim_type = NRD_StatGetString(stat, "AnimType")
                            if anim_type ~= nil then
                                local type_from_anim = anim_to_type[anim_type]
                                if type_from_anim ~= nil then
                                    local tag = "LLWEAPONEX_" .. type_from_anim
                                    SetTag(item, tag)
                                end
                            end
                        end
                    end
                elseif itemtype ~= "None" then
                    local tag = "LLWEAPONEX_" .. itemtype
                    SetTag(item, tag)
                end
            end
        end
    end
end

---@param targetGUID ObjectParam
function PlayBulletImpact(targetGUID)
    local target = GameHelpers.TryGetObject(targetGUID, "EsvCharacter")
    local sound = "LLWEAPONEX_Bullet_Impact_Body_Thump_All"
    if GameHelpers.Status.IsActive(target, {"PETRIFIED", "FORTIFIED"}) then
        sound = "LLWEAPONEX_Bullet_Impact_Rock_All"
    elseif GameHelpers.Status.IsActive(target, {"FROZEN", "PERMAFROST"}) then
        sound = "LLWEAPONEX_Bullet_Impact_Ice_All"
    elseif GameHelpers.Ext.ObjectIsCharacter(target) then
        if Osi.CharacterGetArmorPercentage(targetGUID) <= 0.05 and GameHelpers.Character.IsUndead(target) then
            if target:HasTag("ZOMBIE") then
                sound = "LLWEAPONEX_Bullet_Impact_Body_Flesh_All"
            else
                sound = "LLWEAPONEX_Bullet_Impact_Body_Thump_All"
            end
        else
            local chestArmor = GameHelpers.Item.GetItemInSlot(target, "Breast")
            if chestArmor and chestArmor.Stats.StatsEntry.ArmorType == "Plate" then
                sound = "LLWEAPONEX_Bullet_Impact_Metal_Heavy_All"
            end
        end
    else 
        sound = "LLWEAPONEX_Bullet_Impact_Dirt_All"
    end
    Osi.PlaySound(targetGUID, sound)
end

---Change a two-handed weapon to a one-handed weapon.
---@param char string
---@param item string
---@return string Weapon
local function TwoHandedToOnehanded(char, item)
    local stat = NRD_ItemGetStatsId(item)
    local level = NRD_ItemGetInt(item, "LevelOverride")
    if level == nil then
        level = CharacterGetLevel(char)
    end
    local template = GetTemplate(item)
	local last_underscore = string.find(template, "_[^_]*$")
	local stripped_template = string.sub(template, last_underscore+1)

	NRD_ItemCloneBegin(item)
	Osi.LeaderLog_Log("DEBUG", "[LLWEAPONEX_Main.lua:TwoHandedToOnehanded] Changing IsTwoHanded for ("..stat..")("..stripped_template..").")
	Ext.Utils.Print("[LLWEAPONEX_Main.lua:TwoHandedToOnehanded] Changing IsTwoHanded for ("..stat..")("..stripped_template..").")
	NRD_ItemCloneSetString("RootTemplate", stripped_template)
	NRD_ItemCloneSetString("OriginalRootTemplate", stripped_template)
	if stat ~= nil and stat ~= "" then
		NRD_ItemCloneSetString("GenerationStatsId", stat)
		NRD_ItemCloneSetString("StatsEntryName", stat)
	end
	local cloned = NRD_ItemClone()
	ItemRemove(item)
    ItemLevelUpTo(cloned,level)
    --NRD_ItemSetPermanentBoostString(cloned, "IsTwoHanded", "Yes")
    NRD_ItemSetPermanentBoostInt(cloned, "IsTwoHanded", 0)
    CharacterEquipItem(char, cloned)
    return cloned
end

Events.RegionChanged:Subscribe(function (e)
    if e.State == REGIONSTATE.GAME and e.LevelType == LEVELTYPE.GAME then
        for player in GameHelpers.Character.GetPlayers() do
            EquipmentManager:CheckWeaponRequirementTags(player)
        end
        UpdateDarkFireballSkill(Origin.Korvash)
    end
end)

Ext.RegisterConsoleCommand("weaponex_refreshtags", function ()
    for player in GameHelpers.Character.GetPlayers() do
        ClearAllMasteryRankTags(player.MyGuid)
        Mastery.Experience.TagMasteryRanks(player)
    end
end)
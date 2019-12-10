local function GetHandedness(weapon)
    if weapon == nil then
        return nil
    end
    local stat = NRD_ItemGetStatsId(weapon)
    local handedness = NRD_StatGetAttributeString(stat, "IsTwoHanded")
    if handedness == "Yes" then
        DebugBreak("[LL-OsiExtender] Item is two-handed.")
        return true
    elseif handedness == "No" then
        DebugBreak("[LL-OsiExtender] Item is one-handed.")
        return false
    else
        return nil
    end
end

local function TagHandedness(player)
    local slots = {"Weapon", "Shield"}
    for i, slot in ipairs(slots) do
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
    DebugBreak("[LL-OsiExtender] Item check done.")
end

local function TagItemType(player)
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
        
    for i, slot in ipairs(slots) do
        local item = CharacterGetEquippedItem(player, slot)
        if item ~= nil then
            local stat = NRD_ItemGetStatsId(item)
            local itemtype = NRD_StatGetType(stat)
            if itemtype ~= nil then
                if itemtype == "Weapon" then
                    local weapon_type = NRD_StatGetAttributeString(stat, "WeaponType")
                    if weapon_type ~= nil then
                        if weapon_type ~= "None" then
                            local tag = "LLWEAPONEX_" .. weapon_type
                            SetTag(item, tag)
                        else
                            local anim_type = NRD_StatGetAttributeString(stat, "AnimType")
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

local function PlayBulletImpact(target)
    local sound = "LLWEAPONEX_Bullet_Impact_Body_Thump_All"
    if (HasActiveStatus(target, "PETRIFIED") == 1 or HasActiveStatus(target, "FORTIFIED")) then
        sound = "LLWEAPONEX_Bullet_Impact_Rock_All"
    elseif HasActiveStatus(target, "FROZEN") == 1 then
        sound = "LLWEAPONEX_Bullet_Impact_Ice_All"
    elseif ObjectIsCharacter(target) then
        if CharacterGetArmorPercentage(target) <= 0 then
            if IsTagged(target, "UNDEAD") == 0 or IsTagged(target, "ZOMBIE") == 1 then
                sound = "LLWEAPONEX_Bullet_Impact_Body_Flesh_All"
            else
                sound = "LLWEAPONEX_Bullet_Impact_Body_Thump_All"
            end
        else
            local chest_armor = CharacterGetEquippedItem(target, "Breast")
            if chest_armor ~= nil then
                local item_stat = NRD_ItemGetStatsId(chest_armor)
                DebugBreak("Chest Armor Stat: " .. item_stat)
                if NRD_StatAttributeExists(item_stat, "ArmorType") then
                    local armor_type = NRD_StatGetString(item_stat, "ArmorType")
                    print("Armor type: " .. armor_type)
                    DebugBreak("Armor type: " .. armor_type)
                    if armor_type == "Plate" then
                        sound = "LLWEAPONEX_Bullet_Impact_Metal_Heavy_All"
                    end
                else
                    DebugBreak("Chest Armor Stat: " .. item_stat .. " does not have ArmorType!")
                end
            end
        end
        CharacterStatusText(target, sound)
    else 
        sound = "LLWEAPONEX_Bullet_Impact_Dirt_All"
    end
    DebugBreak(sound)
    PlaySound(target, sound)
end

-- local function SwapRangerSkillProjectileTemplate(char, skill)
--     local template = NRD_StatGetString(skill, "Template")
-- end

WeaponExpansion = {
    GetHandedness = GetHandedness,
    TagHandedness = TagHandedness,
    TagItemType = TagItemType,
    PlayBulletImpact = PlayBulletImpact
}

--Export local functions to global for now
for name,func in pairs(WeaponExpansion) do
    _G["LLWEAPONEX_" .. name] = func
end
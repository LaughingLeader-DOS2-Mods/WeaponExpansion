function get_handedness(weapon)
    if weapon == nil then
        return nil
    end
	local stat = NRD_ItemGetStatsId(weapon)
    local handedness = NRD_StatGetAttributeString(stat, "IsTwoHanded")
    if handedness == "Yes" then
        DebugBreak("[LL-OsiExtender] Item is two-handed.")
        return true
    else if handedness == "No" then
        DebugBreak("[LL-OsiExtender] Item is one-handed.")
        return false
    else
        return nil
    end
end

function tag_handedness()
    local player = CharacterGetHostCharacter()
    local slots = {"Weapon", "Shield"}
    for i, slot in ipairs(slots) do
        local item = CharacterGetEquippedItem(player, slot)
        if item ~= nil then
            local handedness = get_handedness(item)
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

function tag_itemtype()
    local player = CharacterGetHostCharacter()
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
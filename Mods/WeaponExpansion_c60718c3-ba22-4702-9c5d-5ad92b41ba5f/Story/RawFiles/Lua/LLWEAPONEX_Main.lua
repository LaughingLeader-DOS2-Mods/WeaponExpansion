
local function GetHandedness(weapon)
    if weapon == nil then
        return nil
    end
    local stat = NRD_ItemGetStatsId(weapon)
    local handedness = NRD_StatGetString(stat, "IsTwoHanded")
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

local function PlayBulletImpact(target)
    local sound = "LLWEAPONEX_Bullet_Impact_Body_Thump_All"
    if (HasActiveStatus(target, "PETRIFIED") == 1 or HasActiveStatus(target, "FORTIFIED") == 1) then
        sound = "LLWEAPONEX_Bullet_Impact_Rock_All"
    elseif HasActiveStatus(target, "FROZEN") == 1 then
        sound = "LLWEAPONEX_Bullet_Impact_Ice_All"
    elseif ObjectIsCharacter(target) == 1 then
        if CharacterGetArmorPercentage(target) <= 0.05 then
            if IsTagged(target, "UNDEAD") == 0 or IsTagged(target, "ZOMBIE") == 1 then
                sound = "LLWEAPONEX_Bullet_Impact_Body_Flesh_All"
            else
                sound = "LLWEAPONEX_Bullet_Impact_Body_Thump_All"
            end
        else
            local chest_armor = CharacterGetEquippedItem(target, "Breast")
            if chest_armor ~= nil then
                local item_stat = NRD_ItemGetStatsId(chest_armor)
                if item_stat ~= nil then
                    local armor_type = NRD_StatGetString(item_stat, "ArmorType")
                    if armor_type == "Plate" then
                        sound = "LLWEAPONEX_Bullet_Impact_Metal_Heavy_All"
                    end
                end
            end
        end
    else 
        sound = "LLWEAPONEX_Bullet_Impact_Dirt_All"
    end
    --DebugBreak("Final sound: " .. sound)
    PlaySound(target, sound)
end

local function CanRedirectHit(target, handle, hit_type)
    if hit_type ~= 4 and hit_type ~= 6 and hit_type ~= 5 then
        local missed = NRD_HitGetInt(handle, "Missed")
        local dodged = NRD_HitGetInt(handle, "Dodged")
        local blocked = NRD_HitGetInt(handle, "Blocked")
        Ext.Print("[LLWEAPONEX_Main.lua:CanRedirectHit] Missed (",missed,"). Dodged (",dodged,") Blocked (",blocked,")")
        if missed ~= 1 and dodged ~= 1 and blocked ~= 1 then
            return true
        end
    end
    return false
end

local function RedirectDamage(blocker, target, attacker, handlestr, reduction_str)
    local handle = tonumber(handlestr)
    local reduction = tonumber(reduction_str)
    --if CanRedirectHit(target, handle, hit_type) then -- Ignore surface, DoT, and reflected damage
    local hit_type_name = NRD_StatusGetString(target, handle, "DamageSourceType")
    --local hit_type = NRD_StatusGetInt(target, handle, "HitType")
    Ext.Print("[LLWEAPONEX_Main.lua:RedirectDamage] Redirecting damage Handle("..handlestr.."). Blocker(",blocker,") Target(",target,") Attacker(",attacker,")")
    local redirected_hit = NRD_HitPrepare(blocker, attacker)
    local damageRedirected = false

    for k,v in pairs(_G["LeaderLib"].Data["DamageTypes"]) do
        local damage = NRD_HitStatusGetDamage(target, handle, v)
        if damage ~= nil and damage > 0 then
            local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            NRD_HitStatusClearDamage(target, handle, v)
            NRD_HitStatusAddDamage(target, handle, v, reduced_damage)
            NRD_HitAddDamage(redirected_hit, v, reduced_damage)
            Ext.Print("Redirected damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..v)
            damageRedirected = true
        end
    end

    if damageRedirected then
        local is_crit = NRD_StatusGetInt(target, handle, "CriticalHit") == 1
        if is_crit then
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 1);
        else
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 2);
        end
        NRD_HitSetInt(redirected_hit, "SimulateHit", 1);
        NRD_HitSetInt(redirected_hit, "HitType", 6);
        NRD_HitSetInt(redirected_hit, "Hit", 1);
        NRD_HitSetInt(redirected_hit, "RollForDamage", 1);
            
        --Osi.LLWEAPONEX_DualShields_ShieldCover_StoreHit(blocker, target, attacker, redirected_hit)
        NRD_HitExecute(redirected_hit);
        Osi.LLWEAPONEX_DualShields_ShieldCover(attacker, blocker, target);
    end
end

WeaponExpansion.Main = {
	GetHandedness = GetHandedness,
    TagHandedness = TagHandedness,
    TagItemType = TagItemType,
    PlayBulletImpact = PlayBulletImpact,
    RedirectDamage = RedirectDamage
}

WeaponExpansion.Register.Table(WeaponExpansion.Main)
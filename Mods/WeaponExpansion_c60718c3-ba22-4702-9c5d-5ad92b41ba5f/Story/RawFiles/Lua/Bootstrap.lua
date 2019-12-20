local function Debug_Init()
    local templates = {
        "EQ_Clothing_UNIQUE_LLWEAPONEX_Blindfolds_Monk_A_78b08f39-3d9d-47b5-b251-f1b8dcebe65b",
        "EQ_UNIQUE_LLWEAPONEX_ArmCannon_A_8a02d95d-dd91-4d97-9265-c3254923f9ee",
        "EQ_UNIQUE_LLWEAPONEX_Backpack_Demolition_A_8995798f-f5b6-4e71-ae84-a29ed4ca51d7",
        "EQ_UNIQUE_LLWEAPONEX_DemonGauntlet_Arms_A_f5d0a9b3-b83c-4b78-8bc6-a097a26ddf53",
        "EQ_UNIQUE_LLWEAPONEX_DragonBoneClaws_A_ce535023-af7f-46a3-bd70-85c8f820dc21",
        "EQ_UNIQUE_LLWEAPONEX_Mask_Tengu_A_84af126d-0e35-482b-b117-f85e7672a129",
        "EQ_UNIQUE_LLWEAPONEX_OniGauntlet_Arms_A_1_27ac5dab-00a7-4013-9568-2d669b581939",
        "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_85e2e75e-4333-425e-adc4-94474c3fc201",
        "WPN_UNIQUE_LLWEAPONEX_Axe_Halberd_2H_Warchief_A_76ab9d36-2f5f-4cb1-822d-2da2040a5347",
        "WPN_UNIQUE_LLWEAPONEX_BattleBook_2H_Bible_B_d67c4ed3-4892-48e5-94fd-1cd966fe1f27",
        "WPN_UNIQUE_LLWEAPONEX_BattleBook_2H_SpellScroll_A_f393c9d6-d90c-483f-be94-b47e9419395d",
        "WPN_UNIQUE_LLWEAPONEX_Bokken_Sword_2H_A_ed8eadc4-41c9-4f99-b77a-a79a711ca6af",
        "EQ_UNIQUE_LLWEAPONEX_Belt_Pistol_A_Isshin_A_6e667d23-c8a6-46d6-b6ec-2aa6aa95241d",
        "WPN_UNIQUE_LLWEAPONEX_Firearm_Blunderbuss_2H_A_507801c0-4c6b-4b39-9aed-13fcd0962dd9",
        "WPN_UNIQUE_LLWEAPONEX_Firearm_Flamethrower_2H_A_6b7e1caa-a610-4e40-91dc-7f2df1b86d42",
        "WPN_UNIQUE_LLWEAPONEX_Greatbow_Lightning_Bow_2H_A_7efec0e0-1c2e-4f0d-9ec5-e3a1f40c97b8",
        "EQ_UNIQUE_LLWEAPONEX_HandCrossbow_A_Ring_ad15f666-285d-4634-a832-ea643fa0a9d2",
        "WPN_UNIQUE_LLWEAPONEX_Grimoire_Death_3ef2d9c5-13e3-48a2-ab11-36f118ec7e67",
        "WPN_UNIQUE_LLWEAPONEX_Grimoire_Fire_3d834205-a88b-459b-8e83-f44fbb166011",
        "WPN_UNIQUE_LLWEAPONEX_Grimoire_Mimicry_c9fcc947-4423-40b9-9629-ae2d1e156dfc",
        "WPN_UNIQUE_LLWEAPONEX_Grimoire_Swap_f4227e7f-86df-498f-817c-fc00896eb040",
        "WPN_UNIQUE_LLWEAPONEX_Grimoire_Wind_c12e4d82-a6a5-4b3b-b29d-9e7810ff3216",
        "WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_8ff641b7-920a-4bbc-b1c1-d17a73312e53",
        "WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Runeblade_Fire_1H_A_25726991-6bc1-45fb-a00b-d3bf855cd0d1",
        "WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Sword_2H_Muramasa_4be8ec78-17ed-4f61-b3d8-96c260d1c80a",
        "WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Sword_2H_Raizan_3_fa2345b0-68f5-443f-8665-d2a5991bbf29",
        "WPN_UNIQUE_LLWEAPONEX_Quarterstaff_Spear_2H_PowerPole_3a40634d-b4c3-482a-9f24-c5e93b336d6a",
        "WPN_UNIQUE_LLWEAPONEX_Rapier_Dagger_Runeblade_Water_1H_2_6a811339-a28f-44a6-980b-0289cc45cffa",
        "WPN_UNIQUE_LLWEAPONEX_Rod_1H_MagicMissile_A_1566e0f6-3718-40b4-a7ff-e2c07c3cbd96",
        "WPN_UNIQUE_LLWEAPONEX_Runeblade_Chaos_Sword_2H_428c023d-a614-49cc-911d-499a6af4cbf5",
        "WPN_UNIQUE_LLWEAPONEX_Scythe_2H_DeathEdge_A_ca61e441-9446-40ac-811d-736327d4a0f0",
        "WPN_UNIQUE_LLWEAPONEX_Scythe_2H_SoulHarvest_A_c308b26a-98d1-4429-8cce-4940f6eb5f69",
        "WPN_UNIQUE_LLWEAPONEX_Spear_Halberd_2H_Warchief_A_93acdd5a-dc43-4cdc-90cf-560b310d5f08",
        "WPN_UNIQUE_LLWEAPONEX_Staff_Banner_DivineOrder_A_ee686596-394f-44ae-867b-4596de1feedb",
        "WPN_UNIQUE_LLWEAPONEX_Staff_Banner_Dwarves_A_59675259-8e78-48fd-acad-cf70c90bc909",
        "WPN_UNIQUE_LLWEAPONEX_Sword_2H_Beholder_A_1cc2baa1-cd58-40a3-8b53-89ef2e081616",
        "WPN_UNIQUE_LLWEAPONEX_Wand_1H_MagicMissile_A_67ef34e7-5f50-4ef9-9e40-8c7c04884812",
        "WPN_UNIQUE_LLWEAPONEX_Wraithblade_Sword_2H_A_ca59856d-6876-4f9c-8fe5-e086df193ca6",
        --"WPN_UNIQUE_LLWEAPONEX_BattleBook_2H_Spellbook_A_ecb56a2b-0bfa-40d7-ba92-525c2aab0ae1",
        --"WPN_UNIQUE_LLWEAPONEX_Bokken_Sword_1H_A_e5fc86f9-a4fd-43dd-8814-b6ec906c287c",
        --"WPN_UNIQUE_LLWEAPONEX_CombatShield_GiantDoor_A_b4748a58-427c-4652-bf6c-d596ddcc134d",
        --"WPN_UNIQUE_LLWEAPONEX_Grimoire_Magic_EternalSpark_0f469658-5dee-454c-a458-eff50a845970",
        --"WPN_UNIQUE_LLWEAPONEX_Gun_1H_VampireSlayer_A_Melee_867b1acd-165d-42cb-9fed-7d165845915a",
        --"WPN_UNIQUE_LLWEAPONEX_Gun_1H_VampireSlayer_A_Ranged_e1bb0780-be83-4425-850c-dce56e1706ef",
        --"WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_Air_f4db8570-4a0b-4292-bb36-f66fb2d8b0c3",
        --"WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_Fire_1f3bc0cd-6c5f-4291-812b-50a92bba3adb",
        --"WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_Oil_6e245aba-3bf5-45cd-a95f-7ec29635b8fb",
        --"WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_Water_e15b0225-bc10-4c1d-8088-8aec094a1435",
        --"WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Sword_2H_Raizan_1_b1320940-1afb-479a-b510-875afdb12d41",
        --"WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Sword_2H_Raizan_2_e03787b9-acac-4563-953e-a1149a6ebec1",
        --"WPN_UNIQUE_LLWEAPONEX_Rapier_Dagger_Runeblade_Water_1H_3_c715d004-5d66-4301-8360-2c6c2e25f678",
        --"WPN_UNIQUE_LLWEAPONEX_Rapier_Dagger_Runeblade_Water_1H_d82bc239-4782-484c-88ab-e1fa571c9f6a",
        --"WPN_UNIQUE_LLWEAPONEX_Scythe_2H_BurialBlade_A_e955f532-3e2c-41e7-b834-c53a50d4708c",
        --"WPN_UNIQUE_LLWEAPONEX_Shield_1H_BurialBlade_Offhand_A_a7512f1c-3c94-4b91-8d20-2580343e1cac",
        --"WPN_UNIQUE_LLWEAPONEX_Shield_DualShields_GiantDoor_A_5e8ca310-616d-4f18-b455-e510dade5b62",
        --"WPN_UNIQUE_LLWEAPONEX_Sword_1H_BurialBlade_Mainhand_A_0f42e70c-5b1b-4a8f-9f3e-e462e2f70850",
    };

    local target = "S_LLWEAPONEX_PointTrigger_UniqueItemTest_8d4e1ba9-6b1b-4ce3-bdbc-268dc7b56a9b"
    local x,y,z = GetPosition(target)

    for i,template in ipairs(templates) do
        local item = CreateItemTemplateAtPosition(template, x, y, z)
        x = x + 1
    end
end

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

-- local function SwapRangerSkillProjectileTemplate(char, skill)
--     local template = NRD_StatGetString(skill, "Template")
-- end

WeaponExpansion = {
    GetHandedness = GetHandedness,
    TagHandedness = TagHandedness,
    TagItemType = TagItemType,
    PlayBulletImpact = PlayBulletImpact,
    Debug_Init = Debug_Init
}

--Export local functions to global for now
for name,func in pairs(WeaponExpansion) do
    _G["LLWEAPONEX_" .. name] = func
end

Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_StatOverrides.lua");
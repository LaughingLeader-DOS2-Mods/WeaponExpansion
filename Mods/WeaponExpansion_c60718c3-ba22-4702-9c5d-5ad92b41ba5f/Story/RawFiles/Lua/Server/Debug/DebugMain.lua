---@type MessageData
local MessageData = Classes["MessageData"]

local debug_templates = {
    "WPN_LLWEAPONEX_Shield_DualShields_Dwarves_A_91fd35cb-93dd-4489-9cf5-2dcc9b0ac168",
    "EQ_UNIQUE_LLWEAPONEX_Blindfold_Monk_A_78b08f39-3d9d-47b5-b251-f1b8dcebe65b",
    "EQ_UNIQUE_LLWEAPONEX_ArmCannon_A_8a02d95d-dd91-4d97-9265-c3254923f9ee",
    "EQ_UNIQUE_LLWEAPONEX_Backpack_Demolition_A_8995798f-f5b6-4e71-ae84-a29ed4ca51d7",
    "EQ_UNIQUE_LLWEAPONEX_DemonGauntlet_Arms_A_f5d0a9b3-b83c-4b78-8bc6-a097a26ddf53",
    "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_85e2e75e-4333-425e-adc4-94474c3fc201",
    "WPN_UNIQUE_LLWEAPONEX_Axe_Halberd_2H_Warchief_A_76ab9d36-2f5f-4cb1-822d-2da2040a5347",
    "WPN_UNIQUE_LLWEAPONEX_BattleBook_2H_Bible_B_d67c4ed3-4892-48e5-94fd-1cd966fe1f27",
    "WPN_UNIQUE_LLWEAPONEX_BattleBook_2H_SpellScroll_A_f393c9d6-d90c-483f-be94-b47e9419395d",
    "WPN_UNIQUE_LLWEAPONEX_Bokken_Sword_2H_A_ed8eadc4-41c9-4f99-b77a-a79a711ca6af",
    "WPN_UNIQUE_LLWEAPONEX_Firearm_Blunderbuss_2H_A_507801c0-4c6b-4b39-9aed-13fcd0962dd9",
    "WPN_UNIQUE_LLWEAPONEX_Greatbow_Lightning_Bow_2H_A_7efec0e0-1c2e-4f0d-9ec5-e3a1f40c97b8",
    "EQ_UNIQUE_LLWEAPONEX_HandCrossbow_A_Ring_ad15f666-285d-4634-a832-ea643fa0a9d2",
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
    --"WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_Air_f4db8570-4a0b-4292-bb36-f66fb2d8b0c3",
    --"WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_Fire_1f3bc0cd-6c5f-4291-812b-50a92bba3adb",
    --"WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_Oil_6e245aba-3bf5-45cd-a95f-7ec29635b8fb",
    --"WPN_UNIQUE_LLWEAPONEX_Humans_Axe_1H_A_Water_e15b0225-bc10-4c1d-8088-8aec094a1435",
    --"WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Sword_2H_Raizan_1_b1320940-1afb-479a-b510-875afdb12d41",
    --"WPN_UNIQUE_LLWEAPONEX_Katana_Dagger_Sword_2H_Raizan_2_e03787b9-acac-4563-953e-a1149a6ebec1",
    --"WPN_UNIQUE_LLWEAPONEX_Rapier_Dagger_Runeblade_Water_1H_3_c715d004-5d66-4301-8360-2c6c2e25f678",
    --"WPN_UNIQUE_LLWEAPONEX_Rapier_Dagger_Runeblade_Water_1H_d82bc239-4782-484c-88ab-e1fa571c9f6a",
    --"WPN_UNIQUE_LLWEAPONEX_Shield_DualShields_GiantDoor_A_5e8ca310-616d-4f18-b455-e510dade5b62",
};

function LLWEAPONEX_Ext_Debug_Init()
    local target = "S_LLWEAPONEX_PointTrigger_UniqueItemTest_8d4e1ba9-6b1b-4ce3-bdbc-268dc7b56a9b"
    local x,y,z = GetPosition(target)

    local i = 1
    local count = #debug_templates
    while i < count do
        local template = debug_templates[i]
        local item = CreateItemTemplateAtPosition(template, x, y, z)
        x = x + 1
        i = i + 1
    end
end

function LLWEAPONEX_Ext_Debug_CleanLevelItem(item)
    if item ~= nil and ObjectExists(item) == 1 then
        local template = GetTemplate(item)
        if template ~= nil and template ~= "" then
            --Ext.Utils.Print("[LLWEAPONEX_Debug.lua] Checking item ("..item..")["..template.."] for cleaning.")
            local i = 1
            local count = #debug_templates
            while i < count do
                local t = debug_templates[i]
                if t ~= nil and t == template then
                    --Ext.Utils.Print("[LLWEAPONEX_Debug.lua] Removing item ("..item..").")
                    ItemRemove(item)
                    break
                end
                i = i + 1
            end
        end
    end
end


local boltTemplates = {
    "baf9826a-abe8-4bc8-8c56-b68b5611c223",
    "72a7d3aa-02d7-4c9b-a565-d94c8a5664b0",
    "598b8cb5-7f76-4c50-a609-2a3cd0aa0415",
}

local bulletTemplates = {
    "6c14edba-cc11-4e9f-be04-685f09c0aadd",
    "58638ac8-d0d2-4a60-a6a6-76e0be07d58a",
    "056a48f4-2b5f-4882-aefa-05162ad4c427",
    "009eecab-d9bc-454d-afca-5c512f10b182",
    "2e6c0fd4-3d9e-4492-aa21-6047eca15b1a",
    "0377162e-51fa-499a-ab58-4cad5104d888",
    "fc05e69b-bb8b-4d0d-a94c-e1ecafa1c9a9",
    "fc05e69b-bb8b-4d0d-a94c-e1ecafa1c9a9",
    "071b6f55-64a5-4efe-af02-1910d400e6b5",
}

local tokens = {
    "c77de879-b29b-4707-a75c-2c42adc0712b",
	"95284549-f8c1-496b-af36-9d96565f6c0f",
	"bc8c81a1-106d-49ef-beac-e97678ba9b16",
	"d360798f-50e3-4c9e-b0e5-0c69345b1a92",
	"1a3acb90-a152-4ebd-8b02-c5fe99f6c0e3",
	"dfb3db93-2562-46d2-9cd1-5ea5b57b72b9",
}

local gameTestTemplates = {
    "LOOT_LeaderLib_Ring_Shapeshifter_1892531e-4eeb-42ff-907e-4a7ce2278b3d",
    "EQ_LLWEAPONEX_Belt_Pistol_A_94838d55-d5e6-4115-b736-b8b26f321003",
    "WPN_Lizards_Dagger_1H_A_028e9d6a-92b7-494b-a7fa-62218cf63914",
    "WPN_Tool_Scythe_2H_A_44525b09-a2b1-4b45-8d52-e893d04390dd",
    --"WPN_Dwarves_Staff_2H_A_545f2dc2-1da9-4387-af90-9e866f6288a8",
    "WPN_LLWEAPONEX_Firearm_2H_Rifle_A_0e98584a-7c57-4a5c-b7d9-57ec79aee85e",
    "WPN_LLWEAPONEX_Firearm_2H_Rifle_B_068246d7-b4cc-4b6d-9ac8-716fdfd1822d",
    "WPN_LLWEAPONEX_Firearm_2H_Rifle_B_NoScope_67b548a2-5fb3-44c1-bf9b-7148728df7c7",
    "WPN_LLWEAPONEX_Tanto_1H_A_53a214ff-46b3-428d-ad35-02543b8e10f9",
}

local function AddTestItems(host)
    local x,y,z = GetPosition(host)

    if ItemTemplateIsInPartyInventory(host, "ad15f666-285d-4634-a832-ea643fa0a9d2", 0) <= 0 then
        ItemTemplateAddTo("ad15f666-285d-4634-a832-ea643fa0a9d2", host, 1, 0)
        for i,template in pairs(boltTemplates) do
            ItemTemplateAddTo(template, host, 1, 0)
        end
    end
    if ItemTemplateIsInPartyInventory(host, "WPN_Dwarves_Staff_2H_A_545f2dc2-1da9-4387-af90-9e866f6288a8", 0) <= 0 then
       local item = CreateItemTemplateAtPosition("WPN_Dwarves_Staff_2H_A_545f2dc2-1da9-4387-af90-9e866f6288a8", x, y, z)
       ItemAddDeltaModifier(item, "Boost_Weapon_LLWEAPONEX_DamageType_Chill")
       ItemToInventory(item, host)
    end
    for i,template in pairs(bulletTemplates) do
        if ItemTemplateIsInPartyInventory(host, template, 0) <= 0 then
            ItemTemplateAddTo(template, host, 1, 0)
        end
    end
    for i,template in pairs(gameTestTemplates) do
        if ItemTemplateIsInPartyInventory(host, template, 0) <= 0 then
            ItemTemplateAddTo(template, host, 1, 0)
        end
    end
    for i,template in pairs(tokens) do
        if ItemTemplateIsInPartyInventory(host, template, 0) <= 0 then
            ItemTemplateAddTo(template, host, 10, 0)
        end
    end
    if ItemTemplateIsInPartyInventory(host, "LOOT_LLWEAPONEX_Token_Shard_dcd92e16-80a6-43bc-89c5-8e147d95606c", 0) <= 3 then
        ItemTemplateAddTo("LOOT_LLWEAPONEX_Token_Shard_dcd92e16-80a6-43bc-89c5-8e147d95606c", host, 3, 0)
    end
end

local function DebugInit()
    --Ext.BroadcastMessage("LLWEAPONEX_OnClientMessage", "HookUI", nil)
    PrintDebug("[WeaponExpansion] Running debug init code.")
    
    local host = CharacterGetHostCharacter()

    local template = "LOOT_LeaderLib_Ring_Shapeshifter_1892531e-4eeb-42ff-907e-4a7ce2278b3d"
    if ItemTemplateIsInPartyInventory(host, template, 0) < 1 then
        ItemTemplateAddTo(template, host, 1, 0)
    end

    if Vars.LeaderDebugMode then
        GlobalSetFlag("LLWEAPONEX_Debug_LeaderModeEngaged")
    end

    -- GameMaster_RewardChest_Small
    --local chest = CreateItemTemplateAtPosition("dca4ff7a-c916-4e3a-968c-54adef3b10e2", x, y, z)
    --GenerateTreasure(chest, "TEST_Generation", 16, host)
    --ContainerIdentifyAll(chest)
    --local tx,ty,tz = FindValidPosition(x,y,z,12.0,chest)
    --TeleportToPosition(chest, tx,ty,tz)
    --PrintDebug("[WeaponExpansion:DebugInit] Generated treasure chest.")
    --TeleportToRandomPosition(chest, 8.0, "")
end

Ext.RegisterConsoleCommand("weaponex_masterymenu", function()
    OpenMasteryMenu(GameHelpers.GetCharacter(CharacterGetHostCharacter()))
end)

Ext.RegisterConsoleCommand("weaponex_removemastery", function(call, mastery)
    local host = CharacterGetHostCharacter()
    Osi.DB_LLWEAPONEX_WeaponMastery_PlayerData_Experience:Delete(host, mastery, nil, nil)
    Osi.DB_LLWEAPONEX_WeaponMastery_Temp_ActiveMasteries:Delete(host, nil, mastery)
    Osi.LLWEAPONEX_WeaponMastery_Internal_CheckRemovedMasteries(host, mastery)
end)

if Ext.IsDeveloperMode() then
    Ext.RegisterConsoleCommand("weaponex_masterall", function(call)
        local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
        for mastery,masterData in pairs(Masteries) do
            --local rank = Ext.Utils.Random(1,4)
            local rank = 4--Ext.Utils.Random(1,4)
            local xp = 0
            if rank > 0 then
                if rank >= 4 then
                    xp = Mastery.Variables.RankVariables[rank].Required
                else
                    local rankData = Mastery.Variables.RankVariables[rank]
                    local nextRankData = Mastery.Variables.RankVariables[rank+1]
                    if rankData.Amount > 0 then
                        xp = Ext.Utils.Random(rankData.Required, nextRankData.Required - 1)
                    else
                        xp = rankData.Required
                    end
                end
            else
                xp = Ext.Utils.Random(0, Mastery.Variables.RankVariables[1].Required)
            end
            MasterySystem.SetMasteryExperience(host,mastery,rank,xp)
            TagMasteryRanks(host, mastery, rank)
        end
        Ext.Dump(PersistentVars.MasteryExperience)
    end)

    local function Debug_TradeTest(command, effect, bone, target)
        if target == nil then 
            target = CharacterGetHostCharacter() 
        end
        Osi.RequestTrade(target, target)
    end
    Ext.RegisterConsoleCommand("trade", Debug_TradeTest)

    local function Debug_AddItem(command, template, target)
        if target == nil then 
            target = CharacterGetHostCharacter() 
        end
        ItemTemplateAddTo(template, target, 1, 1)
    end
    Ext.RegisterConsoleCommand("item", Debug_AddItem)

    Ext.RegisterConsoleCommand("statusDuration", function(command, effect, bone, target)
        local host = CharacterGetHostCharacter()
        if HasActiveStatus(host, "HASTED") == 0 then
            GameHelpers.Status.Apply(host, "HASTED", 24.0, 1, host)
        else
            local handle = NRD_StatusGetHandle(host, "HASTED")
            if handle ~= nil then
                local duration = NRD_StatusGetReal(host, handle, "CurrentLifeTime")
                duration = duration + 6.0
                NRD_StatusSetReal(host, handle, "CurrentLifeTime", duration)
                local id = CharacterGetReservedUserID(host)
                Ext.PostMessageToUser(id, "LLWEAPONEX_UpdateStatusMC", MessageData:CreateFromTable("StatusUpdate", {
                    UUID = host,
                    ID = id,
                    StatusName = "HASTED",
                    StatusHandle = Ext.HandleToDouble(handle)
                }):ToString())
            end
        end
    end)
    --!reward ST_LLWEAPONEX_RunebladesRare
    --!reward ST_LLWEAPONEX_TestDeltamodReplacement
    --!PrintDebugeltamods

    -- local generateTreasureOriginal = GenerateTreasure
    -- local generateTreasureHook = function(item, treasure, level, player)
    --     Osi.LeaderLog_Log("DEBUG", "[GenerateTreasure] ",string.format("%s,%s,%i,%s",item, treasure, level, player))
    --     generateTreasureOriginal(item, treasure, level, player)
    --     --print("[GenerateTreasure] ",item, treasure, level, player)
    -- end
    -- GenerateTreasure = generateTreasureHook

    -- local rewardOriginal = CharacterGiveReward
    -- local rewardHook = function(player, treasure, identified)
    --     Osi.LeaderLog_Log("DEBUG", "[CharacterGiveReward] ",string.format("%s,%s,%s",player,treasure,identified))
    --     rewardOriginal(player, treasure, identified)
    --     --print("[GenerateTreasure] ",item, treasure, level, player)
    -- end
    -- CharacterGiveReward = rewardHook
end

local debug_DeltaModBoostProperties = {
    { Name="Boost", Type="string"},
    { Name="Count", Type="integer"}
}

local debug_DeltaModProperties = {
    {Name="Name", Type="string"},
    {Name="BoostType", Type="string"},
    {Name="MinLevel", Type="integer"},
    {Name="MaxLevel", Type="integer"},
    {Name="Frequency", Type="integer"},
    {Name="ModifierType", Type="string"},
    {Name="SlotType", Type="string"},
    {Name="WeaponType", Type="string"},
    {Name="Handedness", Type="string"},
    {Name="ArmorType", Type="string"},
    {Name="Boosts", Type="table"},
}

function Debug_PrintDeltaMod(item, deltamod, isGenerated)
    local modifierType = NRD_StatGetType(NRD_ItemGetStatsId(item))
    ---@type DeltaMod
    local deltamodObj = Ext.GetDeltaMod(deltamod, modifierType)
    print("*********")
    print("DeltaMod:",deltamod, "ModifierType", modifierType, "IsGenerated:",isGenerated)
    print("*********")
    if deltamodObj ~= nil then
        for i,prop in pairs(debug_DeltaModProperties) do
            if prop.Name == "Boosts" then
                print("-------")
                print("Deltamod Boosts:")
                print("-------")
                for i,boost in pairs(deltamodObj.Boosts) do
                    print(boost.Boost, boost.Count)
                end
                print("-------")
            else
                print(prop.Name, deltamodObj[prop.Name])
            end
        end
    end
end

---Cool effects:
---RS3_FX_Skills_Void_Power_Attack_Impact_01
---Cracked ground with blueish smoke and a spooky impact sound.
---
---RS3_FX_Skills_Voodoo_Impact_Target_Voodoo_Root_01
---Poison burst with a beam from above.
---
---RS3_FX_Char_Creatures_Condor_Impact_Warrior_01
---Would make for a cool Goblin Punch effect if played multiple times.


---@param projectile EsvProjectile
local function CreateRectSurface(projectile, endPos)
	Ext.EnableExperimentalPropertyWrites()
	---@type EsvRectangleSurfaceAction
	local surf = Ext.CreateSurfaceAction("RectangleSurfaceAction")
	surf.Target = endPos
	surf.Position = GameHelpers.Math.ExtendPositionWithForwardDirection(GameHelpers.GetCharacter(projectile.SourceHandle), 2.0, projectile.SourcePosition[1], projectile.SourcePosition[2], projectile.SourcePosition[3])
	surf.SurfaceType = "Fire"
	surf.SurfaceArea = 2.0
	surf.Width = 2.0
	surf.Length = GameHelpers.Math.GetDistance(endPos, projectile.SourcePosition) + 0.01
	surf.Duration = 3.0
	surf.StatusChance = 0.0
	surf.GrowStep = 128
	surf.LineCheckBlock = 0
	surf.DeathType = "DoT"
	surf.OwnerHandle = projectile.SourceHandle
	return surf
end

---@type table<integer,EsvChangeSurfaceOnPathAction>
local surfaceActions = {}

local function CreateFollowSurface(projectile)
	Ext.EnableExperimentalPropertyWrites()
	---@type EsvChangeSurfaceOnPathAction
	local surf = Ext.CreateSurfaceAction("ChangeSurfaceOnPathAction")
	surf.FollowObject = projectile.Handle
	surf.SurfaceType = "FrostCloud"
	--surf.SurfaceLayer = 0
	surf.Radius = 4.0
	--surf.CheckExistingSurfaces = false
	--surf.IgnoreIrreplacableSurfaces = true
	surf.Duration = 12.0
	--surf.OwnerHandle = projectile.OwnerHandle
	return surf
end

---@param projectile EsvProjectile
RegisterProtectedExtenderListener("ShootProjectile", function (projectile)
	if string.find(projectile.SkillId, "Projectile_EnemyTotem") then
		local surf = CreateFollowSurface(projectile)
		print("Created surface action for", projectile.Handle, surf.MyHandle)
		surfaceActions[projectile.Handle] = surf.MyHandle
		Ext.ExecuteSurfaceAction(surf)
	end
end)

---@param projectile EsvProjectile
RegisterProtectedExtenderListener("ProjectileHit", function (projectile, hitObject, position)
	local surfHandle = surfaceActions[projectile.Handle]
	if surfHandle ~= nil then
		print("Canceled surface action for", projectile.Handle, surfHandle)
		surfaceActions[projectile.Handle] = nil
		Ext.CancelSurfaceAction(surfHandle)
	end
	if string.find(projectile.SkillId, "Projectile_EnemyTotem") then
		local surf = CreateRectSurface(projectile, position)
		Ext.ExecuteSurfaceAction(surf)
    end
    
end)

--[[
local p = _C(); local fx = Ext.Effect.CreateEffect("RS3_FX_Skills_Warrior_GroundSmash_Cast_01", Ext.Entity.NullHandle(), "");fx.Position = p.WorldPos;local angle = Ext.Math.ExtractEulerAngles(p.Stats.Rotation); angle[2] = angle[2] + 180; angle = Ext.Math.BuildFromEulerAngles(angle);fx.Rotation = angle;fx.ForgetEffect = true;fx.Loop = false

Ext.Math.ExtractEulerAngles({table.unpack(me.Stats.Rotation),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})

]]

-- local _ISCLIENT = Ext.IsClient()
-- if not _ISCLIENT then
--     local _rotationActive = false
--     local _targetItem = 66709
--     local _targetRotation = {}
--     --local _targetItem = "46a44365-29c5-4864-a1b3-957bfe81152e"
    
--     Ext.RegisterConsoleCommand("debug_rotation", function()
--         _rotationActive = not _rotationActive

--         local item = GameHelpers.GetItem(_targetItem)
--         if item then
--             _targetRotation = GameHelpers.Math.RotationMatrixToEuler(item.Rotation)
--             _targetRotation[1] = _targetRotation[1] + 45
--             _targetRotation = GameHelpers.Math.EulerToRotationMatrix(_targetRotation)
            
--         end
--     end)

--     ---@param e GameTime
--     Ext.Events.Tick:Subscribe(function (e)
--         if _rotationActive then
--             local item = GameHelpers.GetItem(_targetItem)
--             if item then
                
--             end
--         end
--     end)
-- else
--     Ext.RegisterNetListener("MyMod_Debug_SetRotation", function (cmd, payload)
--         local data = Ext.JsonParse(payload)
--         local item = GameHelpers.GetItem(data.NetID)
--         item.Rotation = data.Rotation
--     end)
-- end
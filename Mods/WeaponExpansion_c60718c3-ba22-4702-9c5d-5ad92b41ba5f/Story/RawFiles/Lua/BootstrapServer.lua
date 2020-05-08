Ext.Require("Shared/_Main.lua")
Ext.Require("Server/_ServerMain.lua")
Ext.Require("Server/TimerListeners.lua")
Ext.Require("Server/EquipmentEvents.lua")
Ext.Require("Server/GameMechanics.lua")
Ext.Require("Server/UI/MasteryMenuCommands.lua")
Ext.Require("Server/MasteryHelpers.lua")
Ext.Require("Server/PistolMechanics.lua")
Ext.Require("Server/HitHandler.lua")
Ext.Require("Server/StatusHandler.lua")
Ext.Require("Server/Skills/DamageHandler.lua")
Ext.Require("Server/Skills/ElementalFirearms.lua")
Ext.Require("Server/Skills/MasteryBonuses.lua")
Ext.Require("Server/Skills/PrepareEffects.lua")
Ext.Require("Server/TagHelpers.lua")
Ext.Require("Server/ServerDebug.lua")

local function dumpRanks(...)
    --DB_LLWEAPONEX_WeaponMastery_RankNames("LLWEAPONEX_DualShields", 0, "<font color='#FDFFEA'>Beginner</font>")
    local rankNamesDB = Osi.DB_LLWEAPONEX_WeaponMastery_RankNames:Get(nil, nil, nil)
    local output = ""
    for i,entry in ipairs(rankNamesDB) do
        --AddRank(masteryID, level, color, name)
        local masteryID = entry[1]
        local level = entry[2]
        local text = entry[3]
        local _,_,color = string.find(text, "color='(.+)'")
        local _,_,rankName = string.find(text, ">(.+)<")
        output = output .. string.format("AddRank(\"%s\", %s, \"%s\", \"%s\")\n", masteryID, level, color, rankName)
    end
    print(output)
end
Ext.RegisterConsoleCommand("dumpRanks", dumpRanks);

local function SessionSetup()
    if Ext.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") then
        Mods["EnemyUpgradeOverhaul"].IgnoredSkills["Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"] = true
        Mods["EnemyUpgradeOverhaul"].IgnoredSkills["Target_LLWEAPONEX_Pistol_Shoot_Enemy"] = true
    end
    Ext.Print("[WeaponExpansion:BootstrapServer.lua] Session is loading.")
    Mods.LeaderLib.AddDebugInitCall(Mods["WeaponExpansion"].DebugInit)
end
Ext.RegisterListener("SessionLoaded", SessionSetup)

Ext.Print("[WeaponExpansion:BootstrapServer.lua] Finished running.")
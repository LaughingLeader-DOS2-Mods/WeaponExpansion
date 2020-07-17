PersistentVars = {}
LoadPersistentVars = {}
BonusSkills = {}

Ext.Require("Shared/Init.lua")
Ext.Require("Server/Init.lua")
Ext.Require("Server/HitHandler.lua")
Ext.Require("Server/StatusHandler.lua")
Ext.Require("Server/BasicAttackHandler.lua")
Ext.Require("Server/TimerListeners.lua")
Ext.Require("Server/EquipmentEvents.lua")
Ext.Require("Server/UnarmedDamageScaling.lua")
Ext.Require("Server/UI/MasteryMenuCommands.lua")
Ext.Require("Server/UI/UIHelpers.lua")
Ext.Require("Server/MasteryHelpers.lua")
Ext.Require("Server/PistolMechanics.lua")
Ext.Require("Server/Mastery/SkillBonuses.lua")
Ext.Require("Server/Mastery/HitBonuses.lua")
Ext.Require("Server/Mastery/StatusBonuses.lua")
Ext.Require("Server/Skills/DamageHandler.lua")
Ext.Require("Server/Skills/ElementalFirearms.lua")
Ext.Require("Server/Skills/PrepareEffects.lua")
Ext.Require("Server/Skills/SkillHelpers.lua")
Ext.Require("Server/Skills/SkillListeners.lua")
Ext.Require("Server/TagHelpers.lua")
Ext.Require("Server/Items/ItemHandler.lua")
Ext.Require("Server/Items/UniqueItems.lua")
Ext.Require("Server/Items/CraftingMechanics.lua")
Ext.Require("Server/Items/DeltaModSwapper.lua")
local itemBonusSkills = Ext.Require("Server/Items/ItemBonusSkills.lua")
Ext.Require("Server/Debug/DebugMain.lua")

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

---@param target EsvCharacter
---@param attacker StatCharacter|StatItem
---@param hit HitRequest
---@param causeType string
---@param impactDirection number[]
---@param context any
local function BeforeCharacterApplyDamage(target, attacker, hit, causeType, impactDirection, context)
	if hit.DamageType == "Magic" then
        hit.DamageList:ConvertDamageType("Water")
    elseif hit.DamageType == "Corrosive" then
        hit.DamageList:ConvertDamageType("Physical")
    end
end

local function SessionSetup()
    -- Enemy Upgrade Overhaul
    if Ext.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") then
        Mods["EnemyUpgradeOverhaul"].IgnoredSkills["Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"] = true
        Mods["EnemyUpgradeOverhaul"].IgnoredSkills["Target_LLWEAPONEX_Pistol_Shoot_Enemy"] = true
    end
    Ext.Print("[WeaponExpansion:BootstrapServer.lua] Session is loading.")
    Mods.LeaderLib.AddDebugInitCall(Mods["WeaponExpansion"].DebugInit)

    LeaderLib.EnableFeature("ApplyBonusWeaponStatuses")

    -- Divinity Unleashed
    if not Ext.IsModLoaded("e844229e-b744-4294-9102-a7362a926f71") then
        Ext.Print("[WeaponExpansion:BootstrapServer.lua] Enabled Magic/Corrosive damage type conversions.")
		Ext.RegisterListener("BeforeCharacterApplyDamage", BeforeCharacterApplyDamage)
    end
    
    for i,callback in ipairs(LoadPersistentVars) do
        local status,err = xpcall(callback, debug.traceback)
        if not status then
            Ext.PrintError("[WeaponExpansion:SessionLoaded] Error invoking LoadPersistentVars callback:",err)
        end
    end

    itemBonusSkills.Init()
end
Ext.RegisterListener("SessionLoaded", SessionSetup)

Ext.Print("[WeaponExpansion:BootstrapServer.lua] Finished running.")
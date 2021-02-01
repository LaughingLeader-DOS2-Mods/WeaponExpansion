Ext.Require("Shared/_InitShared.lua")

RegisterProtectedOsirisListener = Mods.LeaderLib.RegisterProtectedOsirisListener
StartOneshotTimer = Mods.LeaderLib.StartOneshotTimer
StartTimer = Mods.LeaderLib.StartTimer
CancelTimer = Mods.LeaderLib.CancelTimer
RegisterSkillListener = Mods.LeaderLib.RegisterSkillListener
RegisterStatusListener = Mods.LeaderLib.RegisterStatusListener

---@class WeaponExpansionVars
local defaultPersistentVars = {
    SkillData = {
        DarkFireballCount = {},
        RunicCannonCharges = {},
        GnakSpells = {},
        ShieldCover = {
            Blocking = {},
            BlockedHit = {},
        },
        ThrowWeapon = {},
        ThrowBalrinAxe = {},
        VanquishersPath = {},
        ---@class RemoteMineDetonationData:table
        ---@field Mines string[]
        ---@field Remaining integer
        ---@type table<string, table<string, RemoteMineDetonationData>>
        RemoteMineDetonation = {}
    },
    StatusData = {
        RemoveOnTurnEnd = {},
        KatanaCombo = {},
    },
    MasteryMechanics = {},
    Timers = {},
    OnDeath = {},
    ExtraUniques = {},
    UniqueRequirements = {}
}
---@type WeaponExpansionVars
PersistentVars = Common.CopyTable(defaultPersistentVars, true)

LeaderLib.RegisterListener("Initialized", function(region)
    Common.InitializeTableFromSource(PersistentVars, defaultPersistentVars)
    if PersistentVars.StatusData.RemoveOnTurnEnd ~= nil then
        for uuid,data in pairs(PersistentVars.StatusData.RemoveOnTurnEnd) do
            StatusManager.RemoveAllInactiveStatuses(uuid)
        end
    end
end)

LeaderLib.RegisterListener("LuaReset", function()
    Common.InitializeTableFromSource(PersistentVars, defaultPersistentVars)
    for i,callback in pairs(LoadPersistentVars) do
        local status,err = xpcall(callback, debug.traceback)
        if not status then
            Ext.PrintError("[WeaponExpansion:SessionLoaded] Error invoking LoadPersistentVars callback:",err)
        end
    end
    printd(Ext.JsonStringify(PersistentVars))
    UpdateDarkFireballSkill(Origin.Korvash)
end)

---@alias EquipmentChangedCallback fun(char:EsvCharacter, item:EsvItem, template:string, equipped:boolean):void
---@alias EquipmentChangedIDType Tag|Template
---@alias ItemListenerEvent EquipmentChanged

---@alias StatusEventCallback fun(target:string, status:string, source:string|nil):void
---@alias StatusEventID StatusApplied|StatusAttempt|StatusRemoved|EndTurnStatusRemoved

---@alias MasteryEventID MasteryActivated|MasteryDeactivated
---@alias MasteryEventCallback fun(uuid:string, mastery:string):void

---@alias HitEventID OnHit|OnWeaponSkillHit
---@alias HitHandlerCallback fun(target:string, source:string, damage:integer, handle:integer, masteryBonuses:table<string, boolean>, tag:string, skill:string|nil):void

LoadPersistentVars = {}
BonusSkills = {}
Listeners = {
    ---@type table<string, StatusEventCallback>
    StatusApplied = {},
    ---@type table<string, StatusEventCallback>
    StatusAttempt = {},
    ---@type table<string, StatusEventCallback>
    StatusRemoved = {},
    ---@type table<string, fun(target:string, status:string, source:string):void>
    EndTurnStatusRemoved = {},
    ---@type table<string, table<string, EquipmentChangedCallback>>
    EquipmentChanged = {
        Template = {},
        Tag = {}
    },
    ---@type table<string, MasteryEventCallback>
    MasteryActivated = {},
    ---@type table<string, MasteryEventCallback>
    MasteryDeactivated = {},
    ---@type table<string, HitHandlerCallback>
    OnHit = {},
    ---@type table<string, HitHandlerCallback>
    OnWeaponSkillHit = {},
}

EID = {
    EquipmentChanged = {
        Template = "Template",
        Tag = "Tag",
    }
}

---@param event HitEventID
---@param tag string
---@param callback HitHandlerCallback
function RegisterHitListener(event, tag, callback)
    local eventHolder = Listeners[event]
    if eventHolder ~= nil then
        if type(tag) == "table" then
            for i,v in pairs(tag) do
                if eventHolder[v] == nil then
                    eventHolder[v] = {}
                end
                table.insert(eventHolder[v], callback)
            end
        else
            if eventHolder[tag] == nil then
                eventHolder[tag] = {}
            end
            table.insert(eventHolder[tag], callback)
        end
    end
end

---@param event MasteryEventID
---@param mastery string
---@param callback MasteryEventCallback
function RegisterMasteryListener(event, mastery, callback)
    local eventHolder = Listeners[event]
    if eventHolder ~= nil then
        if type(mastery) == "table" then
            for i,v in pairs(mastery) do
                if eventHolder[v] == nil then
                    eventHolder[v] = {}
                end
                table.insert(eventHolder[v], callback)
            end
        else
            if eventHolder[mastery] == nil then
                eventHolder[mastery] = {}
            end
            table.insert(eventHolder[mastery], callback)
        end
    end
end

---@param event ItemListenerEvent
---@param idType EquipmentChangedIDType
---@param id string The template, tag, etc.
---@param callback EquipmentChangedCallback
function RegisterItemListener(event, idType, id, callback)
    local callbackHolder = Listeners[event]
    if callbackHolder ~= nil then
        if callbackHolder[idType] == nil then
            callbackHolder[idType] = {}
        end
        if callbackHolder[idType][id] == nil then
            callbackHolder[idType][id] = {}
        end
        table.insert(callbackHolder[idType][id], callback)
    end
end

Ext.Require("Server/ServerMain.lua")
Ext.Require("Server/HitHandler.lua")
Ext.Require("Server/StatusHandler.lua")
Ext.Require("Server/BasicAttackListeners.lua")
Ext.Require("Server/TimerListeners.lua")
Ext.Require("Server/EquipmentEvents.lua")
Ext.Require("Server/OsirisListeners.lua")
Ext.Require("Server/DeathMechanics.lua")
Ext.Require("Server/UI/MasteryMenuCommands.lua")
Ext.Require("Server/UI/UIHelpers.lua")
Ext.Require("Server/Skills/DamageHandler.lua")
Ext.Require("Server/Skills/ElementalFirearms.lua")
Ext.Require("Server/Skills/PrepareEffects.lua")
Ext.Require("Server/Skills/SkillHelpers.lua")
Ext.Require("Server/Skills/SkillListeners.lua")
Ext.Require("Server/Skills/RemoteMines.lua")
Ext.Require("Server/MasteryExperience.lua")
Ext.Require("Server/MasteryHelpers.lua")
Ext.Require("Server/PistolMechanics.lua")
Ext.Require("Server/Mastery/SkillBonuses.lua")
Ext.Require("Server/Mastery/HitBonuses.lua")
Ext.Require("Server/Mastery/StatusBonuses.lua")
Ext.Require("Server/TagHelpers.lua")
Ext.Require("Server/Origins/OriginsMain.lua")
Ext.Require("Server/Origins/OriginsEvents.lua")
Ext.Require("Server/Items/ItemHandler.lua")
Ext.Require("Server/Items/Uniques/UniqueItemsMain.lua")
Ext.Require("Server/Items/Quivers.lua")
Ext.Require("Server/Items/CraftingMechanics.lua")
if Ext.IsDeveloperMode() then
    Ext.Require("Server/Items/DeltaModSwapperv2.lua")
else
    Ext.Require("Server/Items/DeltaModSwapper.lua")
end
Ext.Require("Server/Items/LootBonuses.lua")
Ext.Require("Server/Items/TreasureTableMerging.lua")
local itemBonusSkills = Ext.Require("Server/Items/ItemBonusSkills.lua")
Ext.Require("Server/Items/Uniques/_Init.lua")
Ext.Require("Server/Debug/ConsoleCommands.lua")
Ext.Require("Server/Updates.lua")
if Ext.IsDeveloperMode() then
    Ext.Require("Server/Debug/DebugMain.lua")
end
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
        hit.DamageList:ConvertDamageType("Earth")
    end
end

local function SessionSetup()
    -- Divinity Unleashed or Armor Mitigation
    if not Ext.IsModLoaded(MODID.DivinityUnleashed) and not Ext.IsModLoaded(MODID.ArmorMitigation) then
        Ext.Print("[WeaponExpansion:BootstrapServer.lua] Enabled Magic/Corrosive damage type conversions.")
        Ext.RegisterListener("BeforeCharacterApplyDamage", BeforeCharacterApplyDamage)
    end

    -- Enemy Upgrade Overhaul
    if Ext.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") then
        Mods["EnemyUpgradeOverhaul"].IgnoredSkills["Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"] = true
        Mods["EnemyUpgradeOverhaul"].IgnoredSkills["Projectile_LLWEAPONEX_Pistol_Shoot_Enemy"] = true
    end
    Ext.Print("[WeaponExpansion:BootstrapServer.lua] Session is loading.")

    for i,callback in pairs(LoadPersistentVars) do
        local status,err = xpcall(callback, debug.traceback)
        if not status then
            Ext.PrintError("[WeaponExpansion:SessionLoaded] Error invoking LoadPersistentVars callback:",err)
        end
    end

    local b,err = xpcall(function()
        --local uniqueDataStr = Ext.LoadFile("WeaponExpansion_UniqueBaseStats.json")
        local uniqueDataStr = Ext.LoadFile("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Stats/Custom/WeaponExpansion_UniqueBaseStats.json", "data")
        if uniqueDataStr ~= nil then
            Temp.OriginalUniqueStats = Ext.JsonParse(uniqueDataStr) or {}
        end
	end, debug.traceback)
	if not b then
		Ext.PrintError(err)
	end

    itemBonusSkills.Init()
end
Ext.RegisterListener("SessionLoaded", SessionSetup)

Ext.Print("[WeaponExpansion:BootstrapServer.lua] Finished running.")

Ext.AddPathOverride("Mods/Kalavinkas_Combat_Enhanced_e844229e-b744-4294-9102-a7362a926f71/Story/RawFiles/Goals/KCE_CoreRules_Story.txt", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/KCE_CoreRules_Story.txt")
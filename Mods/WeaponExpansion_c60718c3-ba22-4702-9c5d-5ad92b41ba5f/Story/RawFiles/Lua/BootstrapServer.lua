Ext.Require("BootstrapShared.lua")

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
        ---@type table<GUID, {Item:GUID, Slot:string, Skill:string, Target:GUID|nil}>
        ThrowBalrinAxe = {},
        VanquishersPath = {},
        ---@type table<string, table<string, {Mines:string[], Remaining:integer}>>
        RemoteMineDetonation = {},
        ---@type table<GUID,number[]>
        FutureBarrage = {},
        WandSurfaceBonuses = {},
        ---@type table<GUID,integer>
        ScattershotHits = {}
    },
    StatusData = {
        ---@type table<GUID,table<string,{Target:GUID, Source:GUID, Status:string}>>
        RemoveOnTurnEnd = {},
        KatanaCombo = {},
    },
    MasteryMechanics = {
        ---@type table<GUID,integer>
        AxeFlurryHits = {},
        ---A table of active statuses to remove.
        ---@type table<GUID,table<string,boolean>>
        BludgeonShattering = {},
        ---@type table<GUID,integer>
        CrossbowRicochetHits = {},
        ---@type table<GUID,number[]>
        StillStanceLastPosition = {},
        ---@type table<GUID,integer>
        SneakingTurnsInCombat = {},
        ---@type table<GUID,integer>
        BlinkStrikeTargetsHit = {},
        ---Challenger and the target.
        ---@type table<GUID,GUID>
        BattlebookChallenge = {},
        ---Protected character to the source (Guardian Angel Banner wielder)
        ---@type table<GUID,GUID>
        GuardianAngelResurrect = {},
        ---@type table<GUID,{Remaining:integer, Total:integer}>
        BowExplosiveRainArrowCount = {},
        ---@type table<GUID,{Hits:integer, Target:GUID}>
        BowCumulativeCriticalChance = {},
        ---Skill ID, GUID to boolean
        ---@type table<string,table<GUID,number[]>>
        BowCastingPiercingSkill = {},
        ---@type table<GUID,integer>
        BowFarsightAttacks = {},
    },
    Timers = {},
    OnDeath = {},
    ---All GUIDs for specific uniques (GUID -> Tag).
    ---@type table<GUID,string>
    Uniques = {},
    ---Item GUID to Attribute
    ---@type table<GUID,string>
    AttributeRequirementChanges = {},
    ---Character GUID to Book ID -> Bool
    ---@type table<GUID,table<string, boolean>>
    BattleBookExperienceGranted = {},
    ---Character GUID to BonusID -> Bool
    ---@type table<GUID,table<string, boolean>>
    DisabledBonuses = {},
    ---Character GUID to Mastery ID -> Bool
    ---@type table<GUID,table<string, boolean>>
    ActiveMasteries = {},
}

---@type WeaponExpansionVars
PersistentVars = GameHelpers.PersistentVars.Initialize(Mods.WeaponExpansion, defaultPersistentVars, function ()
    PersistentVars = GameHelpers.PersistentVars.Update(defaultPersistentVars, PersistentVars)
    if PersistentVars.StatusData.RemoveOnTurnEnd ~= nil then
        for uuid,data in pairs(PersistentVars.StatusData.RemoveOnTurnEnd) do
            StatusTurnHandler.RemoveAllInactiveStatuses(uuid)
        end
    end
end)

if Vars.DebugMode then
    RegisterListener("LuaReset", function()
        UpdateDarkFireballSkill(Origin.Korvash)
    end)
end

---@alias EquipmentChangedCallback fun(char:EsvCharacter, item:EsvItem, template:string, equipped:boolean):void
---@alias EquipmentChangedIDType string|"Tag"|"Template"
---@alias ItemListenerEvent string|"EquipmentChanged"

BonusSkills = {}

if SkillConfiguration == nil then SkillConfiguration = {} end
SkillConfiguration.TempData = {RecalculatedUnarmedSkillDamage = {}}

if MasterySystem == nil then
	MasterySystem = {}
end

ItemProcessor = {}

Ext.Require("Server/Data/PresetEntries.lua")
Ext.Require("Server/ServerMain.lua")
Ext.Require("Server/Skills/SkillHelpers.lua")
Ext.Require("Server/HitHandler.lua")
Ext.Require("Server/StatusHandler.lua")
Ext.Require("Server/StatusMechanics.lua")
Ext.Require("Server/TimerListeners.lua")
Ext.Require("Server/EquipmentManager/_Main.lua")
Ext.Require("Server/OsirisListeners.lua")
Ext.Require("Server/UI/MasteryMenuCommands.lua")
Ext.Require("Server/UI/UIHelpers.lua")
Ext.Require("Server/Runeblades/__Init.lua")
Ext.Require("Server/System/DeathManager.lua")
Ext.Require("Server/Skills/ElementalFirearms.lua")
Ext.Require("Server/Skills/PrepareEffects.lua")
Ext.Require("Server/Skills/SkillListeners.lua")
Ext.Require("Server/Skills/RemoteMines.lua")
Ext.Require("Server/MasteryExperience.lua")
Ext.Require("Server/MasteryHelpers.lua")
Ext.Require("Server/PistolMechanics.lua")
Ext.Require("Server/Mastery/HitBonuses.lua")
Ext.Require("Server/Mastery/StatusBonuses.lua")
Ext.Require("Server/Origins/OriginsMain.lua")
Ext.Require("Server/Origins/OriginsEvents.lua")
Ext.Require("Server/Items/ItemHandler.lua")
Ext.Require("Server/Items/DualShieldsGeneration.lua")
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
Ext.Require("Shared/Uniques/UniqueManager.lua")
Ext.Require("Server/Origins/OriginsUniqueItems.lua")
Ext.Require("Shared/Mastery/_Init.lua")
Ext.Require("Server/Debug/ConsoleCommands.lua")
Ext.Require("Server/Updates.lua")
if Ext.IsDeveloperMode() then
    Ext.Require("Server/Debug/DebugMain.lua")
end

Timer.Subscribe("LLWEAPONEX_ClearDisableArmorDamageConversion", function (e)
    if ObjectExists(e.Data.UUID) == 1 then
        ClearTag(e.Data.UUID, "LLWEAPONEX_DisableArmorDamageConversion")
    end
end)

---@param e EsvLuaBeforeCharacterApplyDamageEventParams
local function BeforeCharacterApplyDamage(e)
    if not e.Target:HasTag("LLWEAPONEX_DisableArmorDamageConversion") then
        local magicDamage = e.Hit.DamageList:GetByType("Magic")
        if magicDamage > 0 then
            e.Hit.DamageList:Clear("Magic")
            e.Hit.DamageList:Add("Water", magicDamage)
        end
        local corrosiveDamage = e.Hit.DamageList:GetByType("Corrosive")
        if corrosiveDamage > 0 then
            e.Hit.DamageList:Clear("Corrosive")
            e.Hit.DamageList:Add("Earth", corrosiveDamage)
        end
    end
end

--Make Magic/Corrosive damage get reduced like regular damage
Ext.AddPathOverride("Mods/Kalavinkas_Combat_Enhanced_e844229e-b744-4294-9102-a7362a926f71/Story/RawFiles/Goals/KCE_CoreRules_Story.txt", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/KCE_CoreRules_Story.txt")

Ext.Events.SessionLoaded:Subscribe(function(e)
    if not Ext.IsModLoaded(MODID.ArmorMitigation) then
        Ext.Print("[WeaponExpansion:BootstrapServer.lua] Enabled Magic/Corrosive damage type conversions.")
        Ext.Events.BeforeCharacterApplyDamage:Subscribe(BeforeCharacterApplyDamage)
    end

    -- Enemy Upgrade Overhaul
    if Ext.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") then
        Mods.EnemyUpgradeOverhaul.IgnoredSkills["Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"] = true
        Mods.EnemyUpgradeOverhaul.IgnoredSkills["Projectile_LLWEAPONEX_Pistol_Shoot_Enemy"] = true
    end

    -- Super Enemy Upgrade Overhaul
    if Ext.IsModLoaded("e21fcd37-daec-490d-baec-f6f3e83f1ac9") then
        Mods.SuperEnemyUpgradeOverhaul.IgnoredSkills["Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"] = true
        Mods.SuperEnemyUpgradeOverhaul.IgnoredSkills["Projectile_LLWEAPONEX_Pistol_Shoot_Enemy"] = true
    end
    Ext.Print("[WeaponExpansion:BootstrapServer.lua] Session is loading.")

    itemBonusSkills.Init()
end)
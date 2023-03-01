Ext.Require("BootstrapShared.lua")

---@class MasteryExperienceData
---@field Level integer
---@field Experience integer

---@class WeaponExpansionVars
local defaultPersistentVars = {
    SkillData = {
        --Owner GUID Item GUIDs
        ---@type table<Guid, Guid[]>
        BlunderbussDuds = {},
        DarkFireballCount = {},
        ---Item GUID to amount
        ---@type table<Guid, integer>
        RunicCannonEnergy = {},
        GnakSpells = {},
        ShieldCover = {
            ---@type table<Guid,{Blocker:Guid, CanCounterAttack:boolean}>
            Blocking = {},
            ---@type table<Guid,{Blocker:Guid, Attacker:Guid}>
            BlockedHit = {},
        },
        ThrowWeapon = {},
        ---@type table<Guid, {Item:Guid, Slot:string, Skill:string, Target:Guid|nil}>
        ThrowBalrinAxe = {},
        VanquishersPath = {},
        ---@type table<string, table<string, {Mines:string[], Remaining:integer}>>
        RemoteMineDetonation = {},
        ---Used when remote mine skills hit an object, if that object is about to die. This table prevents adding more than one charge per killed enemy.
        ---@type table<Guid,table<Guid,boolean>>
        RemoteMineJustHit = {},
        ---Remote mine -> All targets affected
        ---@type table<Guid,{Position:vec3, Targets:table<Guid,boolean>}>
        RemoteMineDisplacement = {},
        ---@type table<Guid,number[]>
        FutureBarrage = {},
        WandSurfaceBonuses = {},
        ---@type table<Guid,{Hits:integer, Source:Guid}>
        ScattershotHits = {},
        ---Used to count the current total jumps, to ultimately stop jumping when the limit is reached.
        ---@type table<Guid,integer>
        FlickerStrikeTotalJumps = {},
        ---Used to limit targets hit (either when rushed through or after the movement ends).
        ---@type table<Guid,{Ready:boolean, Targets:table<Guid,boolean>}>
        WarchiefWhirlwindTargets = {},
        ---Used to limit targets hit (either when rushed through or after the movement ends).
        ---@type table<Guid,{StartingPosition:vec3, Targets:table<Guid,boolean>, }>
        WraithbladeSlayHiddenData = {},
        ---@type table<Guid,{Handle:integer, Surface:SurfaceType, Owner:Guid}>
        ChaosSlashPathAction = {},
        ---@type table<Guid,{Handle:integer, Surface:SurfaceType}>
        ChaosChargePathAction = {},
        ---Active banner items created by the related banner rally skills.
        ---Owner GUID to a table of banners, with the status source ID.
        ---@type table<Guid,{Banners:table<Guid,string>, PartyMembers:table<Guid,string>}>
        BannerRally = {},
        ---Used to immediately shoot the return projectile after the remaining hits equals 0.
        ---@type table<Guid,integer>
        KevinHitsRemaining = {},
        ---Used to immediately shoot the return projectile after the remaining hits equals 0.
        ---@type table<Guid,integer>
        ShieldTossHitsRemaining = {},
    },
    StatusData = {
        ---@type table<Guid,table<string,{Target:Guid, Source:Guid, Status:string}>>
        RemoveOnTurnEnd = {},
        KatanaCombo = {},
        ---@type table<Guid,integer>
        BasilusHauntedTarget = {},
        ---Revenant GUID to source character GUID
        ---@type table<Guid,Guid>
        Revenants = {},
    },
    MasteryMechanics = {
        ---@type table<Guid,integer>
        AxeFlurryHits = {},
        ---Challenger and the target.
        ---@type table<Guid,Guid>
        BattlebookChallenge = {},
        ---@type table<Guid,integer>
        BlinkStrikeTargetsHit = {},
        ---A table of active statuses to remove.
        ---@type table<Guid,table<string,boolean>>
        BludgeonShattering = {},
        ---@type table<Guid,{Remaining:integer, Total:integer}>
        BowExplosiveRainArrowCount = {},
        ---@type table<Guid,{Hits:integer, Target:Guid}>
        BowCumulativeCriticalChance = {},
        ---Skill ID, GUID to boolean
        ---@type table<string,table<Guid,number[]>>
        CrossbowCastingPiercingSkill = {},
        ---@type table<Guid,integer>
        BowFarsightAttacks = {},
        ---@type table<Guid,integer>
        CrossbowRicochetHits = {},
        ---The last target the source applied MARKED to.
        ---@type table<Guid,Guid>
        CrossbowMarkedTarget = {},
        ---Protected character to the source (Guardian Angel Banner wielder)
        ---@type table<Guid,Guid>
        GuardianAngelResurrect = {},
        ---@type table<Guid,number[]>
        StillStanceLastPosition = {},
        ---@type table<Guid,integer>
        SneakingTurnsInCombat = {},
    },
    Timers = {},
    OnDeath = {},
    ---All GUIDs for specific uniques (GUID -> Tag).
    ---@type table<Guid,string>
    Uniques = {},
    ---Item GUID to Attribute
    ---@type table<Guid,string>
    AttributeRequirementChanges = {},
    ---Character GUID to Book ID -> Bool
    ---@type table<Guid,table<string, boolean>>
    BattleBookExperienceGranted = {},
    ---Character GUID to BonusID -> Bool
    ---@type table<Guid,table<string, boolean>>
    DisabledBonuses = {},
    ---Character GUID to Mastery ID -> Bool
    ---@type table<Guid,table<string, boolean>>
    ActiveMasteries = {},
    ---Character GUID to Mastery ID -> MasteryExperienceData
    ---@type table<Guid,table<string, MasteryExperienceData>>
    MasteryExperience = {},
}

---@type WeaponExpansionVars
PersistentVars = GameHelpers.PersistentVars.Initialize(Mods.WeaponExpansion, defaultPersistentVars, function ()
    PersistentVars = GameHelpers.PersistentVars.Update(defaultPersistentVars, PersistentVars)
    if PersistentVars.StatusData.RemoveOnTurnEnd ~= nil then
        for uuid,data in pairs(PersistentVars.StatusData.RemoveOnTurnEnd) do
            StatusTurnHandler.RemoveAllInactiveStatuses(uuid)
        end
    end

    for revenantGUID,sourceGUID in pairs(PersistentVars.StatusData.Revenants) do
		if ObjectExists(revenantGUID) == 1 then
			CharacterRemoveFromPlayerCharacter(revenantGUID, sourceGUID)
		else
            PersistentVars.StatusData.Revenants[revenantGUID] = nil
		end
	end
end)

if Vars.DebugMode then
    RegisterListener("LuaReset", function()
        UpdateDarkFireballSkill(Origin.Korvash)
    end)
end

---@alias EquipmentChangedCallback fun(char:EsvCharacter, item:EsvItem, template:string, equipped:boolean)
---@alias EquipmentChangedIDType string|"Tag"|"Template"
---@alias ItemListenerEvent string|"EquipmentChanged"

BonusSkills = {}
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
Ext.Require("Server/Skills/Toss.lua")
Ext.Require("Server/MasteryExperience.lua")
Ext.Require("Server/MasteryHelpers.lua")
Ext.Require("Server/Origins/Main.lua")
Ext.Require("Server/Origins/Events.lua")
Ext.Require("Server/Items/ItemHandler.lua")
Ext.Require("Server/Items/DualShieldsGeneration.lua")
Ext.Require("Server/Items/Mechanics/Quivers.lua")
Ext.Require("Server/Items/Mechanics/Pistols.lua")
Ext.Require("Server/Items/Mechanics/HandCrossbows.lua")
Ext.Require("Server/Items/Mechanics/Crafting.lua")
Ext.Require("Server/Items/Mechanics/VendingMachine.lua")
Ext.Require("Server/Items/DeltaModSwapper.lua")
Ext.Require("Server/Items/LootBonuses.lua")
Ext.Require("Server/Items/TreasureTableMerging.lua")
local itemBonusSkills = Ext.Require("Server/Items/ItemBonusSkills.lua")
Ext.Require("Shared/Uniques/UniqueManager.lua")
Ext.Require("Server/Origins/Uniques.lua")
Ext.Require("Shared/Mastery/_Init.lua")
Ext.Require("Server/Debug/ConsoleCommands.lua")
Ext.Require("Server/Updates.lua")
if Ext.Debug.IsDeveloperMode() then
    Ext.Require("Server/Debug/DebugMain.lua")
end

Timer.Subscribe("LLWEAPONEX_ClearDisableArmorDamageConversion", function (e)
    if ObjectExists(e.Data.UUID) == 1 then
        ClearTag(e.Data.UUID, "LLWEAPONEX_DisableArmorDamageConversion")
    end
end)

---@param e EsvLuaBeforeCharacterApplyDamageEvent
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
Ext.IO.AddPathOverride("Mods/Kalavinkas_Combat_Enhanced_e844229e-b744-4294-9102-a7362a926f71/Story/RawFiles/Goals/KCE_CoreRules_Story.txt", "Mods/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Overrides/KCE_CoreRules_Story.txt")

Ext.Events.SessionLoaded:Subscribe(function(e)
    if not Ext.Mod.IsModLoaded(MODID.ArmorMitigation) then
        Ext.Utils.Print("[WeaponExpansion:BootstrapServer.lua] Enabled Magic/Corrosive damage type conversions.")
        Ext.Events.BeforeCharacterApplyDamage:Subscribe(BeforeCharacterApplyDamage)
    end

    -- Enemy Upgrade Overhaul
    if Ext.Mod.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") then
        Mods.EnemyUpgradeOverhaul.IgnoredSkills["Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"] = true
        Mods.EnemyUpgradeOverhaul.IgnoredSkills["Projectile_LLWEAPONEX_Pistol_Shoot_Enemy"] = true
    end

    -- Super Enemy Upgrade Overhaul
    if Ext.Mod.IsModLoaded("e21fcd37-daec-490d-baec-f6f3e83f1ac9") then
        Mods.SuperEnemyUpgradeOverhaul.IgnoredSkills["Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy"] = true
        Mods.SuperEnemyUpgradeOverhaul.IgnoredSkills["Projectile_LLWEAPONEX_Pistol_Shoot_Enemy"] = true
    end
    Ext.Utils.Print("[WeaponExpansion:BootstrapServer.lua] Session is loading.")

    itemBonusSkills.Init()
end)
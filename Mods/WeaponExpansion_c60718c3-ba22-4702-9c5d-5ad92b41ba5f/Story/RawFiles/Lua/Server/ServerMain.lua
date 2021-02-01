---@class HitFlagPreset
local HitFlagPreset = {}
HitFlagPreset.__index = HitFlagPreset

function HitFlagPreset:Create(params)
    local this = {}
    for k,v in pairs(params) do
        this[k] = v
    end
    setmetatable(this, self)
    return this
end

function HitFlagPreset:Append(params)
    local this = {}
    for k,v in pairs(self) do
        this[k] = v
    end
    for k,v in pairs(params) do
        this[k] = v
    end
    setmetatable(this, self)
    return this
end

---@type table<string, HitFlagPreset>
HitFlagPresets = {
    ---@type HitFlagPreset
    GuaranteedWeaponHit = HitFlagPreset:Create({
        SimulateHit = 1,
        HitType = "WeaponDamage",
        HitWithWeapon = 1,
        Hit = 1,
        Blocked = 0,
        Dodged = 0,
        Missed = 0,
    })
}

---@type StatusEventValues
StatusEvent = LeaderLib.Vars.StatusEvent

Vars.SERVEREVENT = {
    OnModUpdated = "OnModUpdated"
}

ServerEvents = {
    ---@type fun(lastVersion:integer, nextVersion:integer, player:string)[]
    OnModUpdated = {}
}

---@param event string
---@param callback function
function RegisterServerEventCallback(event, callback)
    if ServerEvents[event] ~= nil then
		table.insert(ServerEvents[event], callback)
	else
		Ext.PrintError("[WeaponExpansion:ServerMain.lua:RegisterServerEventCallback] Event ("..tostring(event)..") is not a valid event!")
	end
end

function GetHandedness(weapon)
    if weapon == nil then
        return nil
    end
    local stat = NRD_ItemGetStatsId(weapon)
    local handedness = NRD_StatGetString(stat, "IsTwoHanded")
    if handedness == "Yes" then
        Ext.Print("[LLWEAPONEX_Main.lua:GetHandedness] Item is two-handed.")
        return true
    elseif handedness == "No" then
        Ext.Print("[LLWEAPONEX_Main.lua:GetHandedness] Item is one-handed.")
        return false
    else
        return nil
    end
end

local weapon_slots = {"Weapon", "Shield"}

function TagHandedness(player)
    for _,slot in pairs(weapon_slots) do
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
    Ext.Print("[LLWEAPONEX_Main.lua:GetHandedness] Item check done.")
end

function TagItemType(player)
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
        
    for i, slot in pairs(slots) do
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

function PlayBulletImpact(target)
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

function CanRedirectHit(target, handle, hit_type)
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

function RedirectDamage(blocker, target, attacker, handlestr, reduction_str)
    local redirect_damage_func = Mods.LeaderLib.RedirectDamage
    if redirect_damage_func ~= nil then
        local run_success,redirected = pcall(redirect_damage_func, blocker, target, attacker, handlestr, reduction_str)
        if run_success and redirected then
            Osi.LLWEAPONEX_DualShields_ShieldCover(attacker, blocker, target);
        end
    else
        local handle = tonumber(handlestr)
        local reduction = tonumber(reduction_str)
        --if CanRedirectHit(target, handle, hit_type) then -- Ignore surface, DoT, and reflected damage
        local hit_type_name = NRD_StatusGetString(target, handle, "DamageSourceType")
        --local hit_type = NRD_StatusGetInt(target, handle, "HitType")
        Ext.Print("[LLWEAPONEX_Main.lua:RedirectDamage] Redirecting damage Handle("..handlestr.."). Blocker(",blocker,") Target(",target,") Attacker(",attacker,")")
        local redirected_hit = NRD_HitPrepare(blocker, attacker)
        local damageRedirected = false

        for _,v in Data.DamageTypes:Get() do
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
            NRD_HitSetInt(redirected_hit, "NoHitRoll", 1);
                
            --Osi.LLWEAPONEX_DualShields_ShieldCover_StoreHit(blocker, target, attacker, redirected_hit)
            NRD_HitExecute(redirected_hit);
            Osi.LLWEAPONEX_DualShields_ShieldCover(attacker, blocker, target);
        end
    end
end

---Change a two-handed weapon to a one-handed weapon.
---@param char string
---@param item string
---@return string Weapon
function TwoHandedToOnehanded(char, item)
    local stat = NRD_ItemGetStatsId(item)
    local level = NRD_ItemGetInt(item, "LevelOverride")
    if level == nil then
        level = CharacterGetLevel(char)
    end
    local template = GetTemplate(item)
	local last_underscore = string.find(template, "_[^_]*$")
	local stripped_template = string.sub(template, last_underscore+1)

	NRD_ItemCloneBegin(item)
	Osi.LeaderLog_Log("DEBUG", "[LLWEAPONEX_Main.lua:TwoHandedToOnehanded] Changing IsTwoHanded for ("..stat..")("..stripped_template..").")
	Ext.Print("[LLWEAPONEX_Main.lua:TwoHandedToOnehanded] Changing IsTwoHanded for ("..stat..")("..stripped_template..").")
	NRD_ItemCloneSetString("RootTemplate", stripped_template)
	NRD_ItemCloneSetString("OriginalRootTemplate", stripped_template)
	if stat ~= nil and stat ~= "" then
		NRD_ItemCloneSetString("GenerationStatsId", stat)
		NRD_ItemCloneSetString("StatsEntryName", stat)
	end
	local cloned = NRD_ItemClone()
	ItemRemove(item)
    ItemLevelUpTo(cloned,level)
    --NRD_ItemSetPermanentBoostString(cloned, "IsTwoHanded", "Yes")
    NRD_ItemSetPermanentBoostInt(cloned, "IsTwoHanded", 0)
    CharacterEquipItem(char, cloned)
end

function IsPlayer(uuid)
    if StringHelpers.IsNullOrEmpty(uuid) then
        return false
    end
	return CharacterIsPlayer(uuid) == 1 or CharacterGameMaster(uuid) == 1
end

function IsPlayerQRY(uuid)
    if CharacterIsPlayer(uuid) == 1 or CharacterGameMaster(uuid) == 1 then
        return 1
    end
    return 0
end

Ext.NewQuery(IsPlayerQRY, "LLWEAPONEX_Ext_QRY_IsPlayer", "[in](CHARACTERGUID)_Character, [out](INTEGER)_IsPlayer")

function OnGameStarted(region, editorMode, postReset)
    if region == nil then
        region = GetRegion(CharacterGetHostCharacter())
    end
    Vars.GAME_STARTED = true
    if IsGameLevel(region) == 1 or editorMode == "1" then
        local playersDB = Osi.DB_IsPlayer:Get(nil)
        if playersDB ~= nil then
            for i,entry in pairs(playersDB) do
                EquipmentManager.CheckWeaponRequirementTags(entry[1])
            end
        end
    end

    if postReset ~= nil then
        Ext.BroadcastMessage("LLWEAPONEX_LuaWasReset", "", nil)
    end

    UpdateDarkFireballSkill(Origin.Korvash)
    GameHelpers.Data.SyncSharedData(nil,nil,true)
end
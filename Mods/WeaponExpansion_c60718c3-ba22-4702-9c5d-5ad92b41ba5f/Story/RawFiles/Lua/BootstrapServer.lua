
-- local function SwapRangerSkillProjectileTemplate(char, skill)
--     local template = NRD_StatGetString(skill, "Template")
-- end

local function Register_Function(name, func)
    if type(func) == "function" then
        local func_name = "LLWEAPONEX_Ext_" .. name
        _G[func_name] = func
        Ext.Print("[WeaponExpansion:Bootstrap.lua] Registered function ("..func_name..").")
    end
end

local function Register_Table(tbl)
    for k,func in pairs(tbl) do
        if type(func) == "function" then
            local func_name = "LLWEAPONEX_Ext_" .. k
            _G[func_name] = func
            Ext.Print("[WeaponExpansion:Bootstrap.lua] Registered function ("..func_name..").")
        else
            Ext.Print("[WeaponExpansion:Bootstrap.lua] Not a function type ("..type(func)..").")
        end
    end
end

WeaponExpansion = {
    Register = {
        Function = Register_Function,
        Table = Register_Table
    },
    Main = {},
    Debug = {}
}

Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_Main.lua");
Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_SkillDamage.lua");
Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_StatOverrides.lua");
Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_Debug.lua");

--Export local functions to global for now
-- for name,func in pairs(WeaponExpansion.Export) do
--     local func_name = "LLWEAPONEX_Ext_" .. name
--     _G[func_name] = func
--     Ext.Print("[WeaponExpansion:Bootstrap.lua] Registered function ("..func_name..").")
-- end

local GameSessionLoad = function ()
	Ext.Print("[WeaponExpansion:Bootstrap.lua] Session is loading.")
end

local GetDescriptionParam = function (skill, character, param)
    if skill.Name == "Projectile_LLWEAPONEX_ChaosSlash" then
        Ext.Print("==GetDescriptionParam==")
        Ext.Print("** Param: " .. LeaderLib.Common.Dump(param))
        Ext.Print("** Character: " .. LeaderLib.Common.Dump(character))
        Ext.Print("** Skill: " .. LeaderLib.Common.Dump(skill))
    end
end

--v36 and higher
if Ext.RegisterListener ~= nil then
    Ext.RegisterListener("SessionLoading", GameSessionLoad)
    -- if Ext.Version() >= 39 then
    --     Ext.RegisterListener("SkillGetDescriptionParam", GetDescriptionParam)
    -- end
end

Ext.Print("[WeaponExpansion:Bootstrap.lua] Finished running.")
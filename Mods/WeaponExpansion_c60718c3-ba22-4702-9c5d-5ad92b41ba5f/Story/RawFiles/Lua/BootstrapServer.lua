
-- local function SwapRangerSkillProjectileTemplate(char, skill)
--     local template = NRD_StatGetString(skill, "Template")
-- end

Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "Shared.lua");

local function Register_Function(name, func)
    if type(func) == "function" then
        local func_name = "LLWEAPONEX_Ext_" .. name
        _G[func_name] = func
        Ext.Print("[WeaponExpansion:BootstrapServer.lua] Registered function ("..func_name..").")
	end
end

local function Register_Table(tbl)
    for k,func in pairs(tbl) do
        if type(func) == "function" then
            local func_name = "LLWEAPONEX_Ext_" .. k
            _G[func_name] = func
            Ext.Print("[WeaponExpansion:BootstrapServer.lua] Registered function ("..func_name..").")
        else
            Ext.Print("[WeaponExpansion:BootstrapServer.lua] Not a function type ("..type(func)..").")
        end
    end
end

WeaponExpansion.Register = {
    Function = Register_Function,
    Table = Register_Table
}

Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_Main.lua");
Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_Debug.lua");

--Export local functions to global for now
-- for name,func in pairs(WeaponExpansion.Export) do
--     local func_name = "LLWEAPONEX_Ext_" .. name
--     _G[func_name] = func
--     Ext.Print("[WeaponExpansion:Bootstrap.lua] Registered function ("..func_name..").")
-- end

local function DebugInit()
    Ext.BroadcastMessage("LLWEAPONEX_OnClientMessage", "HookUI", nil)
end

local function LLWEAPONEX_GameSessionLoad()
    Ext.Print("[WeaponExpansion:BootstrapServer.lua] Session is loading.")
    LeaderLib_DebugInitCalls[#LeaderLib_DebugInitCalls+1] = DebugInit
end
Ext.RegisterListener("SessionLoading", LLWEAPONEX_GameSessionLoad)

Ext.Print("[WeaponExpansion:BootstrapServer.lua] Finished running.")
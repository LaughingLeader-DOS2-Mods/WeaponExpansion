
-- local function SwapRangerSkillProjectileTemplate(char, skill)
--     local template = NRD_StatGetString(skill, "Template")
-- end

local function RegisterFunction(func)

end

local function RegisterFunction(func)
    local tbl = WeaponExpansion.Export
    tbl[#tbl+1] = func
end

WeaponExpansion = {
    Register = {
        Function = function(func)
            local target = WeaponExpansion.Export
            target[#target+1] = func
        end,
        Table = function(tbl)
            local target = WeaponExpansion.Export
            local i = 1
            local count = #tbl
            if count > 0 then
                while i < count do
                    local func = tbl[i]
                    if type(func) == "function" then
                        target[#target+1] = func
                    end
                    i = i + 1
                end
            end
        end
    },
    Main = {},
    Debug = {},
    Export = {},
}

Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_Main.lua");
Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_StatOverrides.lua");

--Export local functions to global for now
for name,func in pairs(WeaponExpansion.Export) do
    _G["LLWEAPONEX_Ext_" .. name] = func
end

local GameSessionLoad = function ()
	Ext.Print("[WeaponExpansion:Bootstrap.lua] Session is loading.")
end

--v36 and higher
if Ext.RegisterListener ~= nil then
    Ext.RegisterListener("SessionLoading", GameSessionLoad)
end

Ext.Print("[WeaponExpansion:Bootstrap.lua] Finished running.")
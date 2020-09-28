---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

Ext.Require("Client/UI/ClientUIData.lua")
local masteryMenu = Ext.Require("Client/UI/MasteryMenu.lua")
local tooltipHandler = Ext.Require("Client/UI/TooltipHandler.lua")

local uiOverrides = {
	--["Public/Game/GUI/tooltip.swf"] = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/LLWEAPONEX_ToolTip.swf",
	--["Public/Game/GUI/mouseIcon.swf"] = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/mouseIcon.swf",
	--["Public/Game/GUI/tooltipHelper_kb.swf"] = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/tooltipHelper_kb.swf",
	--["Public/Game/GUI/tooltip.swf"] = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/tooltip.swf",
}

local function LLWEAPONEX_Client_ModuleSetup()
	for filepath,overridepath in pairs(uiOverrides) do
		Ext.AddPathOverride(filepath, overridepath)
		Ext.Print("[LLWEAPONEX:Client:UI.lua] Enabled UI override ("..filepath..") => ("..overridepath..").")
	end
end

--Ext.RegisterListener("ModuleLoadStarted", LLWEAPONEX_Client_ModuleSetup)
--Ext.RegisterListener("ModuleLoading", LLWEAPONEX_Client_ModuleSetup)
--Ext.RegisterListener("ModuleResume", LLWEAPONEX_Client_ModuleSetup)
--Ext.RegisterListener("SessionLoading", LLWEAPONEX_Client_ModuleSetup)
--Ext.RegisterListener("SessionLoaded", LLWEAPONEX_Client_ModuleSetup)

local function OnMouseIconEvent(ui, call, ...)
	local params = LeaderLib.Common.FlattenTable({...})
	Ext.Print("[LLWEAPONEX:Client:UI.lua:OnMouseIconEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")
end

local events = {
	"onSetTexture",
	"onSetCrossVisible",
	"onSetVisible",
}

local function SetupUIListeners(ui)
	for i,event in pairs(events) do
		Ext.RegisterUICall(ui, event, OnMouseIconEvent)
	end
end

local function SetUserCharacters(channel, data)
	local messageData = MessageData:CreateFromString(data)
	if messageData.Params ~= nil then
		CLIENT_UI.PARTY = messageData.Params
	end
	if Ext.GetGameState() == "Running" then
		for i,v in pairs(CLIENT_UI.PARTY) do
			---@type EsvCharacter
			local character = Ext.GetCharacter(v)
			if character.HostControl == true then
				CLIENT_UI.ACTIVE_CHARACTER = v
			end
		end
	end
	LeaderLib.PrintDebug("Set active character for client to", CLIENT_UI.ACTIVE_CHARACTER, "Party:", LeaderLib.Common.Dump(CLIENT_UI.PARTY))
end

Ext.RegisterNetListener("LLWEAPONEX_SetUserCharacters", SetUserCharacters)

--[[ 
addSecondaryStat(statType:Number, labelText:String, valueText:String, tooltipStatId:Number, iconFrame:Number, boostValue:Number)

secStat_array Mapping:

0 is not null:
0 = anything
1 - id:number
2 - height:number

0 is null:
1 = statType:number, 
2 = labelText:string
3 = valueText:string
4 = tooltipStatId:number
5 = iconFrame:number
6 = boostValue:number]]

local damageStatID = 6

---@param ui UIObject
---@param uuid string
function UI.SetCharacterSheetDamageText(ui,uuid)
	local character = Ext.GetCharacter(uuid)
	if character ~= nil and IsUnarmed(character.Stats) then
		local weapon,boost = GetUnarmedWeapon(character.Stats)
		local baseMin,baseMax,totalMin,totalMax = Math.GetTotalBaseAndCalculatedWeaponDamage(character.Stats, weapon)
		local i = 0
		ui:SetValue("secStat_array", 1, i+1)
		ui:SetValue("secStat_array", Ext.GetTranslatedString("h9531fd22g6366g4e93g9b08g11763cac0d86", "Damage"), i+2)
		ui:SetValue("secStat_array", string.format("%i-%i", totalMin, totalMax), i+3)
		ui:SetValue("secStat_array", damageStatID, i+4)
		ui:Invoke("updateArraySystem")
	end
end

---@param ui UIObject
local function OnCharacterSheetUpdating(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion:UI/Init.lua:OnCharacterSheetUpdating] Function running params("..LeaderLib.Common.Dump(params)..")")

	local arrayValueSet = ui:GetValue("secStat_array", "number", 1)
	if arrayValueSet ~= nil then
		for i=0,999,7 do
			local statType = ui:GetValue("secStat_array", "number", i+1)
			if statType ~= nil then
				local label = ui:GetValue("secStat_array", "string", i+2)
				local value = ui:GetValue("secStat_array", "string", i+3)
				local tooltipId = ui:GetValue("secStat_array", "number", i+4)
				--print(statType, label, value, tooltipId)
				if tooltipId == damageStatID then
					if CLIENT_UI.ACTIVE_CHARACTER ~= nil then
						local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
						--print(tooltipHeader,isDamageTooltip,CLIENT_UI.ACTIVE_CHARACTER,IsUnarmed(character.Stats), character.Stats.MainWeapon.Name)
						if character ~= nil and IsUnarmed(character.Stats) then
							local weapon,boost = GetUnarmedWeapon(character.Stats)
							local baseMin,baseMax,totalMin,totalMax = Math.GetTotalBaseAndCalculatedWeaponDamage(character.Stats, weapon)
							ui:SetValue("secStat_array", string.format("%i-%i", totalMin, totalMax), i+3)
						end
					end
					break
				end
			else
				break
			end
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_OnCharacterCreationStarted", function(...)
	CLIENT_UI.IsInCharacterCreation = true
	MasteryMenu.SetToggleButtonVisibility(false, false) 
end)
Ext.RegisterNetListener("LLWEAPONEX_OnCharacterCreationFinished", function(...)
	CLIENT_UI.IsInCharacterCreation = false
	MasteryMenu.SetToggleButtonVisibility(true, true) 
end)

---@param ui UIObject
---@param call string
---@param isVisible boolean
local function OnShowSkillBar(ui, call, isVisible)
	if isVisible ~= nil then
		MasteryMenu.RepositionToggleButton(MasteryMenu.ToggleButtonInstance, nil, nil, isVisible)
		--MasteryMenu.SetToggleButtonVisibility(isVisible)
	end
end

local ccUIMirrorHeaderText = Ext.GetTranslatedString("hf11e1d54g4cb6g4950g91e4g4d006ef46f15", "Magic Mirror")

---@param ui UIObject
---@param call string
local function OnCCEvent(ui, call, ...)
	local params = {...}
	print("UI Type:", ui:GetTypeId())
	LeaderLib.PrintDebug("[WeaponExpansion:UI/Init.lua:OnCCEvent] Event(",call,") params("..LeaderLib.Common.Dump(params)..")")

	if call == "setText" and params[2] == ccUIMirrorHeaderText then
		MasteryMenu.Instance:Invoke("setToggleButtonVisibility", false)
	elseif call == "creationDone" or call == "updatePortraits" and params[1] == false then
		MasteryMenu.Instance:Invoke("setToggleButtonVisibility", true)
	end
end

local debug = nil
if Ext.IsDeveloperMode() then
	debug = Ext.Require("Client/UI/Debug.lua")
end

local function LLWEAPONEX_Client_SessionLoaded()
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		--Ext.RegisterUICall(ui, "showSkillTooltip", GetCharacterHandle)
		--Ext.RegisterUICall(ui, "showStatTooltip", GetCharacterHandle)
		
		--Ext.RegisterUIInvokeListener(ui, "addSecondaryStat", OnCharacterSheetUpdating)
		Ext.RegisterUIInvokeListener(ui, "updateArraySystem", OnCharacterSheetUpdating)
		--Ext.RegisterUICall(ui, "selectCharacter", OnCharacterSelected)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if ui ~= nil then
		Ext.RegisterUIInvokeListener(ui, "showSkillBar", OnShowSkillBar)
	end
	-- ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	-- if ui ~= nil then
	-- 	Ext.RegisterUICall(ui, "showSkillTooltip", GetCharacterHandle)
	-- 	Ext.RegisterUICall(ui, "showStatTooltip", GetCharacterHandle)
	-- end
	-- ui = Ext.GetBuiltinUI("Public/Game/GUI/skills.swf")
	-- if ui ~= nil then
	-- 	Ext.RegisterUICall(ui, "showSkillTooltip", GetCharacterHandle)
	-- 	Ext.RegisterUICall(ui, "showStatTooltip", GetCharacterHandle)
	-- end
	--Ext.RegisterUINameInvokeListener("creationDone", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("setBackButtonVisible", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("setPanel", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("mainMenu", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("setGM", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("enableStoryPlayback", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("onEventInit", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("setText", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("setDetails", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("setTextField", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("setClassEditTabLabel", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("setFreeClassPoints", OnCCEvent)
	--Ext.RegisterUINameInvokeListener("updatePortraits", OnCCEvent)
	masteryMenu.Init()
	--tooltipOverrides.Init()
	tooltipHandler.Init()
	if Ext.IsDeveloperMode() then
		debug.Client_UIDebugTest()
		--debug.MouseTest()
	end
end

Ext.RegisterListener("SessionLoaded", LLWEAPONEX_Client_SessionLoaded)
--Ext.RegisterNetListener("LLWEAPONEX_LuaWasReset", LLWEAPONEX_Client_SessionLoaded)

Ext.RegisterConsoleCommand("gender", function(cmd)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if ui ~= nil then
		local main = ui:GetRoot()
		main.setDetails(0, true)
		print("Unhid gender button?")
	end
end)

local function LLWEAPONEX_OnClientMessage(call,param)
	if param == "HookUI" then
		LLWEAPONEX_Client_SessionLoaded()
	end
end

local function LLWEAPONEX_UpdateStatusMC(call,datastr)
	---@type MessageData
	local data = MessageData:CreateFromString(datastr)
	if data ~= nil then
		--print(LeaderLib.Common.Dump(data.Params))
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
		if ui ~= nil then
			
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_UpdateStatusMC", LLWEAPONEX_UpdateStatusMC)

local function DisplayOverheadDamage(call,datastr)
	---@type MessageData
	local data = MessageData:CreateFromString(datastr)
	if data ~= nil then
		--print(LeaderLib.Common.Dump(data.Params))
		---@type UIObject
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/overhead.swf")
		if ui ~= nil then
			local handle = Ext.HandleToDouble(data.Params.Handle)
			ui:Invoke("addOverheadDamage", handle, data.Params.Text)
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_DisplayOverheadDamage", DisplayOverheadDamage)
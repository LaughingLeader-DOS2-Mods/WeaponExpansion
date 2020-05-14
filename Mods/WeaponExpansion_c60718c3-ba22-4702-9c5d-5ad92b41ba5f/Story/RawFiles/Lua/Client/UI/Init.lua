---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

local uiOverrides = {
	--["Public/Game/GUI/tooltip.swf"] = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/LLWEAPONEX_ToolTip.swf",
	--["Public/Game/GUI/mouseIcon.swf"] = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/mouseIcon.swf",
	["Public/Game/GUI/tooltipHelper_kb.swf"] = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/tooltipHelper_kb.swf",
	["Public/Game/GUI/tooltip.swf"] = "Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/tooltip.swf",
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

--[Osiris] [WeaponExpansion:UI/Init.lua:OnSheetEvent] Event called. call(showStatTooltip) params({  [1] = 6.0, [2] = 63.999996185303, [3] = 522.0, [4] = 269.0, [5] = 31.0, [6] = right,}

local function tryFindTooltip()
	local tooltipUI = Ext.GetBuiltinUI("Public/Game/GUI/tooltipHelper_kb.swf")
	if tooltipUI == nil then
		Ext.PrintError("tooltipHelper_kb is nil?")
		tooltipUI = Ext.GetBuiltinUI("Public/Game/GUI/tooltipHelper.swf") 
	else
		Ext.Print("Got tooltipHelper_kb.swf")
	end
	if tooltipUI == nil then 
		Ext.PrintError("tooltipHelper is nil?")
		tooltipUI = Ext.GetBuiltinUI("Public/Game/GUI/tooltip.swf") 
	else
		Ext.Print("Got tooltipHelper.swf")
	end
	if tooltipUI == nil then 
		Ext.PrintError("tooltip is nil?")
		tooltipUI = Ext.GetBuiltinUI("Public/Game/GUI/tooltipHelper.iggy") 
	else
		Ext.Print("Got tooltip.swf")
	end
	if tooltipUI == nil then 
		Ext.PrintError("tooltipHelper.iggy is nil?")
	else
		Ext.Print("Got tooltipHelper.iggy")
	end
end

local function OnSheetEvent(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion:UI/Init.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")
	local minimap = Ext.GetBuiltinUI("Public/Game/GUI/minimap.swf")
	if minimap ~= nil then
		minimap:Invoke("showMiniMap", false)
	end
end

---@param ui UIObject
local function OnCharacterSelected(ui, call, ...)
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion:UI/Init.lua:OnCharacterSelected] call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")
	Ext.PostMessageToServer("LLWEAPONEX_RequestActiveCharacter", tostring(CLIENT_ID))
	-- if call == "updateCharList" then
	-- 	--characterId, icon, orderIndex
	-- 	local id = ui:GetValue("charList_array", "number", 0)
	-- 	local icon = ui:GetValue("charList_array", "string", 1)
	-- 	--local orderIndex = ui:GetValue("charList_array", "number", 2)
	-- 	if PARTY ~= nil then
	-- 		for i,v in pairs(PARTY) do
	-- 			---@type EsvCharacter
	-- 			local character = Ext.GetCharacter(v)
	-- 			local handle = Ext.HandleToDouble(character.Handle)
	-- 			if handle == id then
	-- 				Ext.Print(character.PlayerCustomData.Name, "is selected")
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- if PARTY ~= nil then
	-- 	for i,v in pairs(PARTY) do
	-- 		---@type EsvCharacter
	-- 		local character = Ext.GetCharacter(v)
	-- 		--if character.HostControl == true then
	-- 		if character:HasTag("LLWEAPONEX_Active") == true then
	-- 			ACTIVE_CHARACTER = character.NetID
	-- 			Ext.Print(ACTIVE_CHARACTER, "is selected?", character.PlayerCustomData.Name)
	-- 		end
	-- 	end
	-- else
	-- 	Ext.PostMessageToServer("LLWEAPONEX_RequestUserCharacters", tostring(CLIENT_ID))
	-- end
end

local function SetUserCharacters(channel, data)
	local messageData = MessageData:CreateFromString(data)
	if messageData.Params ~= nil then
		PARTY = messageData.Params
	end
	for i,v in pairs(PARTY) do
		---@type EsvCharacter
		local character = Ext.GetCharacter(v)
		if character.HostControl == true then
			ACTIVE_CHARACTER = character.NetID
		end
	end
	LeaderLib.PrintDebug("Set active character for client to", ACTIVE_CHARACTER, "Party:", LeaderLib.Common.Dump(PARTY))
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

local function SetCharacterSheetDamageText(ui,character)
	if IsUnarmed(character.Stats) then
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

local function SetActiveCharacter(channel, netid)
	ACTIVE_CHARACTER = tonumber(netid)
	local character = Ext.GetCharacter(ACTIVE_CHARACTER)
	if character ~= nil then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
		if ui ~= nil then
			SetCharacterSheetDamageText(ui,character)
		end
		LeaderLib.PrintDebug("Set active character for client to", netid, character.Stats.Name, character.MyGuid)
	end
end

Ext.RegisterNetListener("LLWEAPONEX_SetActiveCharacter", SetActiveCharacter)

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
				print(statType, label, value, tooltipId)
				if tooltipId == damageStatID then
					if ACTIVE_CHARACTER ~= nil then
						local character = Ext.GetCharacter(ACTIVE_CHARACTER)
						--print(tooltipHeader,isDamageTooltip,ACTIVE_CHARACTER,IsUnarmed(character.Stats), character.Stats.MainWeapon.Name)
						if IsUnarmed(character.Stats) then
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

	for i=0,99,1 do
		local var = ui:GetValue("tags_array", "number", i)
	end
end

---@param ui UIObject
local function OnDebugTooltip(ui, ...)
	-- local params = {...}
	-- LeaderLib.PrintDebug("[OnDebugTooltip] Function running params("..LeaderLib.Common.Dump(params)..")")
	-- local arrayValueSet = ui:GetValue("tooltip_array", "number", 0)
	-- local totalNil = 0
	-- if arrayValueSet ~= nil then
	-- 	for i=0,999,1 do
	-- 		local val = ui:GetValue("tooltip_array", "number", i)
	-- 		if val == nil then val = ui:GetValue("tooltip_array", "string", i) end
	-- 		if val == nil then val = ui:GetValue("tooltip_array", "boolean", i) end
	-- 		if val ~= nil then
	-- 			print(i, val)
	-- 		else
	-- 			totalNil = totalNil + 1
	-- 			if totalNil > 20 then
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end
end

---@param ui UIObject
local function OnAddFormattedTooltip(ui, call, tooltipX, tooltipY, noCompare)
	local tooltipHeader = ui:GetValue("tooltip_array", "string", 1)
	local isDamageTooltip = tooltipHeader == "Damage"
	if isDamageTooltip then
		if ACTIVE_CHARACTER ~= nil then
			local character = Ext.GetCharacter(ACTIVE_CHARACTER)
			--print(tooltipHeader,isDamageTooltip,ACTIVE_CHARACTER,IsUnarmed(character.Stats), character.Stats.MainWeapon.Name)
			if IsUnarmed(character.Stats) then
				local totalDamageText = Ext.GetTranslatedString("h1035c3e5gc73dg4cc4ga914ga03a8a31e820", "Total damage: [1]-[2]")
				--local weaponDamageText = Ext.GetTranslatedString("hfa8c138bg7c52g4b7fgaccdgbe39e6a3324c", "<br>From Weapon: [1]-[2]")
				--local offhandWeaponDamageText = Ext.GetTranslatedString("hfe5601bdg2912g4beag895eg6c28772311fb", "From Offhand Weapon: [1]-[2]")
				local fromFistsText = Ext.GetTranslatedString("h0881bb60gf067g4223ga925ga343fa0f2cbd", "<br>From Fists: [1]-[2]")
				local weapon,boost,unarmedMasteryRank = GetUnarmedWeapon(character.Stats)
				--local weaponDamageRange,totalDamageRange = Math.GetBaseAndCalculatedWeaponDamageRange(character.Stats, weapon)
				local baseMin,baseMax,totalMin,totalMax = Math.GetTotalBaseAndCalculatedWeaponDamage(character.Stats, weapon)

				local totalDamageFinalText = totalDamageText:gsub("%[1%]", totalMin):gsub("%[2%]", totalMax)
				local weaponDamageFinalText = fromFistsText:gsub("%[1%]", baseMin):gsub("%[2%]", baseMax)
				-- Total Damage
				ui:SetValue("tooltip_array", totalDamageFinalText, 7)
				-- From Fists
				ui:SetValue("tooltip_array", weaponDamageFinalText, 9)
				if boost > 0 then
					ui:SetValue("tooltip_array", 102, 14)
					ui:SetValue("tooltip_array", string.format("From Unarmed Mastery %i: +%i%%", unarmedMasteryRank,boost), 15)
				end
				print("Custom unarmed tooltip damage text:",totalDamageFinalText,weaponDamageFinalText,character.Stats.Name)
			end
		end
	end
	-- local totalNil = 0
	-- if arrayValueSet ~= nil then
	-- 	for i=0,999,1 do
	-- 		local val = ui:GetValue("tooltip_array", "number", i)
	-- 		if val == nil then val = ui:GetValue("tooltip_array", "string", i) end
	-- 		if val == nil then val = ui:GetValue("tooltip_array", "boolean", i) end
	-- 		if val ~= nil then
	-- 			print(i, val)
	-- 		else
	-- 			totalNil = totalNil + 1
	-- 			if totalNil > 20 then
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end
end

local function Client_UIDebugTest()
	-- local ui = Ext.GetBuiltinUI("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/mouseIcon_WithCallback.swf")
	-- if ui == nil then
	-- 	Ext.Print("[LLWEAPONEX:Client:UI.lua:SetupOptionsSettings] Failed to get (Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/GUI/mouseIcon_WithCallback.swf).")
	-- 	ui = Ext.GetBuiltinUI("Public/Game/GUI/mouseIcon.swf")
	-- 	if ui ~= nil then
	-- 		Ext.Print("[LLWEAPONEX:Client:UI.lua:SetupOptionsSettings] Found (mouseIcon.swf). Enabling event listener.")
	-- 		SetupUIListeners(ui)
	-- 	else
	-- 		Ext.Print("[LLWEAPONEX:Client:UI.lua:SetupOptionsSettings] Failed to get (Public/Game/GUI/mouseIcon.swf).")
	-- 	end
	-- else
	-- 	Ext.Print("[LLWEAPONEX:Client:UI.lua:SetupOptionsSettings] Found (mouseIcon_WithCallback.swf). Enabling event listener.")
	-- 	SetupUIListeners(ui)
	-- end
	--showSkillTooltip
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/skills.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showSkillTooltip", OnSheetEvent)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "setPlayerInfo", OnSheetEvent)
		Ext.RegisterUICall(ui, "showSkillTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "showStatTooltip", OnSheetEvent)
		--Ext.RegisterUIInvokeListener(ui, "addSecondaryStat", OnCharacterSheetUpdating)
		Ext.RegisterUIInvokeListener(ui, "updateArraySystem", OnCharacterSheetUpdating)
		Ext.RegisterUICall(ui, "selectCharacter", OnCharacterSelected)
		--Ext.RegisterUIInvokeListener(ui, "selectCharacter", OnCharacterSelected)
		--Ext.RegisterUIInvokeListener(ui, "updateCharList", OnCharacterSelected)
		--Ext.RegisterUIInvokeListener(ui, "cycleCharList", OnCharacterSelected)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showStatusTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "charSel", OnCharacterSelected)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showSkillTooltip", OnSheetEvent)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/examine.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "showStatusTooltip", OnSheetEvent)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/tooltip.swf")
	if ui ~= nil then
		if Ext.IsDeveloperMode() then
			Ext.RegisterUIInvokeListener(ui, "INTshowTooltip", OnDebugTooltip)
			Ext.RegisterUIInvokeListener(ui, "INTRemoveTooltip", OnDebugTooltip)
			Ext.RegisterUIInvokeListener(ui, "addTooltip", OnDebugTooltip)
			Ext.RegisterUIInvokeListener(ui, "addStatusTooltip", OnDebugTooltip)
			Ext.RegisterUIInvokeListener(ui, "setGroupLabel", OnDebugTooltip)
			Ext.RegisterUIInvokeListener(ui, "addFormattedTooltip", OnDebugTooltip)
		end
		Ext.RegisterUIInvokeListener(ui, "addFormattedTooltip", OnAddFormattedTooltip)
	end
end

local function LLWEAPONEX_Client_SessionLoaded()
	InitMasteryMenu()
	if Ext.IsDeveloperMode() then
		Client_UIDebugTest()
	end
end

Ext.RegisterListener("SessionLoaded", LLWEAPONEX_Client_SessionLoaded)

local function LLWEAPONEX_OnClientMessage(call,param)
	if param == "HookUI" then
		LLWEAPONEX_Client_SessionLoaded()
	end
end

--Ext.RegisterNetListener("LLWEAPONEX_OnClientMessage", LLWEAPONEX_OnClientMessage)
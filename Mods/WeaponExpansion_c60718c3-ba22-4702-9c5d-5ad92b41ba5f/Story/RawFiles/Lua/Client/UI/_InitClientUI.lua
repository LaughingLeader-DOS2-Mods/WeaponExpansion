---@type MessageData
local MessageData = LeaderLib.Classes["MessageData"]

Ext.Require("Client/UI/ClientUIData.lua")
Ext.Require("Client/UI/MasteryMenu/_Init.lua")
local tooltipHandler = Ext.Require("Client/UI/TooltipHandler.lua")

local function LLWEAPONEX_Client_ModuleSetup()
	for filepath,overridepath in pairs(uiOverrides) do
		Ext.AddPathOverride(filepath, overridepath)
		Ext.Print("[LLWEAPONEX:Client:UI.lua] Enabled UI override ("..filepath..") => ("..overridepath..").")
	end
end

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
function SetCharacterSheetDamageText(ui, uuid)
	local character = Ext.GetCharacter(uuid)
	if character ~= nil and UnarmedHelpers.HasUnarmedWeaponStats(character.Stats) then
		local baseMin,baseMax,totalMin,totalMax,boost = UnarmedHelpers.GetUnarmedBaseAndTotalDamage(character)
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
	--PrintDebug("[WeaponExpansion:UI/Init.lua:OnCharacterSheetUpdating] ",call," running params(", Common.Dump(params))

	local main = ui:GetRoot()
	local array = main.secStat_array

	if array ~= nil and #array > 0 then
		for i=0,#array,7 do
			local statType = array[i+1]
			if statType ~= nil then
				local label = array[i+2]
				local value = array[i+3]
				local tooltipId = array[i+4]
				--print(statType, label, value, tooltipId)
				if tooltipId == damageStatID then
					local character = Client:GetCharacter()
					if character ~= nil and UnarmedHelpers.HasUnarmedWeaponStats(character.Stats) then
						local baseMin,baseMax,totalMin,totalMax,boost = UnarmedHelpers.GetUnarmedBaseAndTotalDamage(character)
						array[i+3] = string.format("%i-%i", totalMin, totalMax)
					end
					break
				end
			end
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_OnCharacterCreationStarted", function(call, uuid)
	MasteryMenu:Close(true)
	if uuid == Origin.Korvash then
		Ext.PostMessageToServer("LLWEAPONEX_CC_CheckKorvashColor", uuid)
	end
end)
-- Ext.RegisterNetListener("LLWEAPONEX_OnCharacterCreationFinished", function(call, uuid)
	
-- end)

---@param ui UIObject
---@param call string
---@param isVisible boolean
local function OnShowSkillBar(ui, call, isVisible)
	if isVisible ~= nil and SharedData.RegionData.LevelType ~= LEVELTYPE.CHARACTER_CREATION then
		if MasteryMenu.ToggleButtonInstance ~= nil then
			MasteryMenu.RepositionToggleButton(MasteryMenu.ToggleButtonInstance, nil, nil, isVisible)
		end
	end
end

local ccUIMirrorHeaderText = Ext.GetTranslatedString("hf11e1d54g4cb6g4950g91e4g4d006ef46f15", "Magic Mirror")

---@param ui UIObject
---@param call string
local function OnCCEvent(ui, call, param1, param2)
	if call == "setText" and param2 == ccUIMirrorHeaderText then
		MasteryMenu.SetToggleButtonVisibility(false, false) 
	elseif call == "creationDone" or call == "updatePortraits" and param1 == false then
		--MasteryMenu.SetToggleButtonVisibility(false, true) 
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", OnCharacterSheetUpdating)
Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "showSkillBar", OnShowSkillBar)

local function LLWEAPONEX_Client_SessionLoaded()
	tooltipHandler.Init()
end

Ext.RegisterListener("SessionLoaded", LLWEAPONEX_Client_SessionLoaded)
--Ext.RegisterNetListener("LLWEAPONEX_LuaWasReset", LLWEAPONEX_Client_SessionLoaded)

Ext.RegisterConsoleCommand("gender", function(cmd)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if ui ~= nil then
		local main = ui:GetRoot()
		main.setDetails(0, true)
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
		--print(Common.Dump(data.Params))
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
		--print(Common.Dump(data.Params))
		---@type UIObject
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/overhead.swf")
		if ui ~= nil then
			local handle = Ext.HandleToDouble(data.Params.Handle)
			ui:Invoke("addOverheadDamage", handle, data.Params.Text)
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_DisplayOverheadDamage", DisplayOverheadDamage)

Ext.RegisterListener("GameStateChanged", function(from, to)
	if from == "Running" and to == "UnloadLevel" then
		MasteryMenu.SetToggleButtonVisibility(false, true)
	elseif from == "Sync" and to == "Running" then
		--MasteryMenu.SetToggleButtonVisibility(true, true)
	end
end)

Ext.RegisterListener("SessionLoaded", function()
	local rollingText = Ext.GetTranslatedString("he38e2e7bg72dbg4477g86f9ga1fedc4f6750", "Dice Rolls")
	CombatLog.AddFilter("Rolls", rollingText, Vars.DebugMode or nil, 3)
	if Mods.CharacterExpansionLib then
		---@param player EclCharacter
		---@param origin string
		---@param race string
		---@param skills string[]
		Mods.CharacterExpansionLib.Listeners.SetCharacterCreationOriginSkills.Register(function(player, origin, race, skills)
			if origin == "LLWEAPONEX_Korvash" then
				---@type StatSkillSet
				local skillSet = Ext.GetSkillSet("Avatar_LLWEAPONEX_Korvash")
				if skillSet ~= nil then
					local i = 2
					for _,skill in pairs(skillSet.Skills) do
						skills[i] = skill
						i = i + 1
					end
				else
					skills[2] = "Projectile_LLWEAPONEX_DarkFireball"
				end
				if race == "Lizard" then
					skills[1] = "Cone_LLWEAPONEX_DarkFlamebreath"
				end
				return skills
			end
		end)
	end
end)

RegisterListener("BeforeLuaReset", function()
	CombatLog.RemoveFilter("Rolls")
end)
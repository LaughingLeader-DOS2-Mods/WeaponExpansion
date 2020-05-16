local tooltipType = ""
local lastTooltipCall = ""
local setupTooltip = Ext.Require("Client/UI/SetupTooltipSwitchStatement.lua")
local weaponTooltips = Ext.Require("Client/UI/WeaponTooltips.lua")

-- local function GetTooltipDataStart(ui, enumVal)
-- 	for i=0,#LeaderLib.Data.UI.TOOLTIP_ENUM,1 do
-- 		local val = ui:GetValue("tooltip_array", "number", i)
-- 		if val == enumVal then
-- 			return i
-- 		end
-- 	end
-- end

local function sortTagParams(a,b)
	return a:upper() < b:upper()
end

---@param character EsvCharacter
---@param data MasteryData
local function GetDescriptionText(character, data)
	local descriptionText = ""
	local namePrefix = ""
	if data.Tags ~= nil then
		local tagKeys = {}
		for tagName,tagData in pairs(data.Tags) do
			table.insert(tagKeys, tagName)
		end
		local count = #tagKeys
		table.sort(tagKeys, sortTagParams)
		for i,tagName in ipairs(tagKeys) do
			local tagData = data.Tags[tagName]
			if Mastery.HasMasteryRequirement(character, tagName) then
				if tagData.NamePrefix ~= nil then
					if namePrefix ~= "" then
						namePrefix = namePrefix .. " "
					end
					namePrefix = namePrefix .. tagData.NamePrefix
				end
				local paramText = ""
				--local tagLocalizedName = Text.MasteryRankTagText[tagName]
				local tagLocalizedName = Ext.GetTranslatedStringFromKey(tagName)
				if tagLocalizedName == nil then 
					tagLocalizedName = ""
				else
					tagLocalizedName = tagLocalizedName .. "<br>"
				end
				if tagData.Param ~= nil then
					if tagLocalizedName ~= "" then
						paramText = tagLocalizedName..tagData.Param.Value
					else
						paramText = tagData.Param.Value
					end
				end
				paramText = Tooltip.ReplacePlaceholders(paramText)
				if tagData.GetParam ~= nil then
					local status,result = xpcall(tagData.GetParam, debug.traceback, character.Stats, tagName, tagLocalizedName, paramText)
					if status and result ~= nil then
						paramText = result
					elseif not status then
						Ext.PrintError("Error calling GetParam function for "..tagName..":\n", result)
					end
				end
				if descriptionText ~= "" then descriptionText = descriptionText .. "<br>" end
				descriptionText = descriptionText .. paramText
			end
		end
	end
	return descriptionText
end

local adrenaline = Ext.GetTranslatedString("h4c891442g3b79g4dbeg906fgf8eeffcf60df", "Adrenaline")

---@param ui UIObject
local function FormatStatusTooltip(ui, tooltipX, tooltipY)
	local tooltipType = ui:GetValue("tooltip_array", "number", 0)
	local tooltipHeader = ui:GetValue("tooltip_array", "string", 1)
	print("[FormatStatusTooltip] ", LeaderLib.Data.UI.TOOLTIP_ENUM[tooltipType], tooltipHeader, tooltipX, tooltipY)
	print("CLIENT_UI.ACTIVE_CHARACTER", CLIENT_UI.LAST_STATUS_CHARACTER)
	print("CLIENT_UI.LAST_STATUS", CLIENT_UI.LAST_STATUS)

	if CLIENT_UI.LAST_STATUS ~= nil then
		if tooltipHeader == adrenaline then
			local data = Mastery.Params.StatusData["ADRENALINE"]
			if data ~= nil then
				local index = setupTooltip.FindFreeIndex(ui)
				if index ~= nil then
					ui:SetValue("tooltip_array", LeaderLib.Data.UI.TOOLTIP_TYPE.StatusDescription, index)
					local text = GetDescriptionText(Ext.GetCharacter(CLIENT_UI.LAST_STATUS_CHARACTER), data)
					ui:SetValue("tooltip_array", text, index+1)
				end
			end
		end
		---@type EsvStatus
		-- local status = Ext.GetStatus(CLIENT_UI.LAST_STATUS_CHARACTER, CLIENT_UI.LAST_STATUS)
		-- if status ~= nil then
		-- 	print(status.StatusId)
		-- end
	end

	setupTooltip.DumpTooltipArray(ui)
end

---@param ui UIObject
local function OnAddFormattedTooltip(ui, call, tooltipX, tooltipY, noCompare)
	local tooltipType = ui:GetValue("tooltip_array", "number", 0)
	local tooltipHeader = ui:GetValue("tooltip_array", "string", 1)
	local isDamageTooltip = tooltipHeader == "Damage"
	print("[OnAddFormattedTooltip] ", LeaderLib.Data.UI.TOOLTIP_ENUM[tooltipType], tooltipHeader, tooltipX, tooltipY, noCompare)
	print("CLIENT_UI.ACTIVE_CHARACTER", CLIENT_UI.ACTIVE_CHARACTER)
	print("CLIENT_UI.LAST_SKILL", CLIENT_UI.LAST_SKILL)
	print("CLIENT_UI.LAST_ITEM", CLIENT_UI.LAST_ITEM)

	if CLIENT_UI.LAST_ITEM ~= nil and CLIENT_UI.ACTIVE_CHARACTER ~= nil then
		local item = Ext.GetItem(CLIENT_UI.LAST_ITEM)
		local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
		if item ~= nil and character ~= nil then
			weaponTooltips.TryOverrideItemTooltip(ui, item, character, setupTooltip)
		end
	end
	setupTooltip.DumpTooltipArray(ui)

	local isSkill = LeaderLib.Data.UI.TOOLTIP_ENUM[tooltipType] == "SkillName"
	--local isStatus = LeaderLib.Data.UI.TOOLTIP_ENUM[tooltipType] == Data.UI.TOOLTIP_TYPE.StatusDescription
	-- local school = ui:GetValue("tooltip_array", "string", 5)
	-- if school ~= nil then
	-- 	ui:SetValue("tooltip_array", "<font color='#FF00FF'>Witchery</font>", 5)
	-- end
	if isSkill then
		if CLIENT_UI.LAST_SKILL ~= nil then
			local data = Mastery.Params.SkillData[CLIENT_UI.LAST_SKILL]
			if data ~= nil then
				local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
				local descriptionText = ""
				local namePrefix = ""
				if data.Tags ~= nil then
					local tagKeys = {}
					for tagName,tagData in pairs(data.Tags) do
						table.insert(tagKeys, tagName)
					end
					local count = #tagKeys
					table.sort(tagKeys, sortTagParams)
					for i,tagName in ipairs(tagKeys) do
						print(tagName)
						local tagData = data.Tags[tagName]
						if Mastery.HasMasteryRequirement(character, tagName) then
							if tagData.NamePrefix ~= nil then
								if namePrefix ~= "" then
									namePrefix = namePrefix .. " "
								end
								namePrefix = namePrefix .. tagData.NamePrefix
							end
							local paramText = ""
							--local tagLocalizedName = Text.MasteryRankTagText[tagName]
							local tagLocalizedName = Ext.GetTranslatedStringFromKey(tagName)
							if tagLocalizedName == nil then 
								tagLocalizedName = ""
							else
								tagLocalizedName = tagLocalizedName .. "<br>"
							end
							if tagData.Param ~= nil then
								if tagLocalizedName ~= "" then
									paramText = tagLocalizedName..tagData.Param.Value
								else
									paramText = tagData.Param.Value
								end
							end
							paramText = Tooltip.ReplacePlaceholders(paramText)
							if tagData.GetParam ~= nil then
								local status,result = xpcall(tagData.GetParam, debug.traceback, character.Stats, tagName, tagLocalizedName, paramText)
								if status and result ~= nil then
									paramText = result
								elseif not status then
									Ext.PrintError("Error calling GetParam function for "..tagName..":\n", result)
								end
							end
							if descriptionText ~= "" then descriptionText = descriptionText .. "<br>" end
							descriptionText = descriptionText .. paramText
						end
					end
				end
				if descriptionText ~= "" then
					local index = setupTooltip.FindTooltipTypeIndex(ui, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillDescription)
					if index ~= nil then
						local description = ui:GetValue("tooltip_array", "string", index+1)
						if description == nil then description = "" end
						description = description .."<br>"..descriptionText
						ui:SetValue("tooltip_array", description, index+1)
					end
				end
				if Ext.IsDeveloperMode() then
					if namePrefix ~= "" then
						local index = setupTooltip.FindTooltipTypeIndex(ui, LeaderLib.Data.UI.TOOLTIP_TYPE.SkillName)
						if index ~= nil then
							local name = ui:GetValue("tooltip_array", "string", index+1)
							if name == nil then name = "" end
							name = namePrefix .. " ".. name
							ui:SetValue("tooltip_array", name, index+1)
						end
					end
				end
			else
				--Ext.PrintError("No data for ", CLIENT_UI.LAST_SKILL)
			end
		end

	elseif lastTooltipCall == "showStatTooltip" then
		if tooltipType == 6 and tooltipHeader == "Damage" then
			if CLIENT_UI.ACTIVE_CHARACTER ~= nil then
				local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
				--print(tooltipHeader,isDamageTooltip,CLIENT_UI.ACTIVE_CHARACTER,IsUnarmed(character.Stats), character.Stats.MainWeapon.Name)
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
	end
end

local function OnTooltip(ui, call, ...)
	if call ~= "addFormattedTooltip" then
		lastTooltipCall = call
	end
	local params = {...}
	if Ext.IsDeveloperMode() then
		if params[1] ~= nil and not string.find(params[1], "Experience") then
			LeaderLib.PrintDebug("[WeaponExpansion:UI/TooltipOverrides.lua:OnTooltip] Event called. call("..tostring(call)..") params("..LeaderLib.Common.Dump(params)..")")
		end
	end
	if call == "showSkillTooltip" then
		CLIENT_UI.LAST_SKILL = params[2]
		if Ext.DoubleToHandle ~= nil then
			CLIENT_UI.ACTIVE_CHARACTER = Ext.DoubleToHandle(params[1])
		end
	elseif call == "showStatTooltip" then
		tooltipType = params[1]
	elseif call == "showItemTooltip" then
		local handle = params[1]
		if handle ~= nil and type(handle) == "number" then
			CLIENT_UI.LAST_ITEM = Ext.DoubleToHandle(handle)
		end
	elseif call == "showStatusTooltip" then
		CLIENT_UI.LAST_STATUS_CHARACTER = Ext.DoubleToHandle(params[1])
		CLIENT_UI.LAST_STATUS = Ext.DoubleToHandle(params[2])
	elseif call == "addStatusTooltip" then
		FormatStatusTooltip(ui, ...)
	end
	-- local minimap = Ext.GetBuiltinUI("Public/Game/GUI/minimap.swf")
	-- if minimap ~= nil then
	-- 	minimap:Invoke("showMiniMap", false)
	-- end
end

local function OnSlotOut(ui, call, ...)
	if call ~= "addFormattedTooltip" then
		lastTooltipCall = call
	end
	local params = {...}
	LeaderLib.PrintDebug("[WeaponExpansion:UI/TooltipOverrides.lua:OnSlotOut] params("..LeaderLib.Common.Dump(params)..")")
	CLIENT_UI.LAST_ITEM = nil
end

local itemTooltipFiles = {
	"Public/Game/GUI/characterSheet.swf",
	"Public/Game/GUI/partyInventory.swf",
	"Public/Game/GUI/trade.swf",
	"Public/Game/GUI/playerInfo.swf",
	"Public/Game/GUI/statusConsole.swf",
	"Public/Game/GUI/uiElements.swf",
	"Public/Game/GUI/worldTooltip.swf",
	"Public/Game/GUI/LSClasses.swf",
	"Public/Game/GUI/tooltip.swf",
	"Public/Game/GUI/tooltipHelper.swf",
	"Public/Game/GUI/tooltipHelper_kb.swf",
}

local function HookIntoTrade()
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/trade.swf")
	if ui ~= nil then
		Ext.Print("Found trade window")
		Ext.RegisterUICall(ui, "showItemTooltip", OnTooltip)
		Ext.RegisterUICall(ui, "slotOver", OnTooltip)
		Ext.RegisterUICall(ui, "slotOut", OnSlotOut)
	else
		Ext.PrintError("Cound not find trade window")
	end
end

Ext.RegisterNetListener("LLWEAPONEX_HookIntoTradeWindow", function(call, id)
	CLIENT_UI.ACTIVE_CHARACTER = tonumber(id)
	HookIntoTrade()
end)

local function InitTooltipOverrides()
	if Ext.RegisterUINameInvokeListener ~= nil then
		Ext.RegisterUINameInvokeListener("addFormattedTooltip", OnAddFormattedTooltip)
	end
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/tooltip.swf")
	if ui ~= nil then
		if Ext.IsDeveloperMode() then
			Ext.RegisterUIInvokeListener(ui, "INTshowTooltip", OnTooltip)
			Ext.RegisterUIInvokeListener(ui, "INTRemoveTooltip", OnTooltip)
			Ext.RegisterUIInvokeListener(ui, "setGroupLabel", OnTooltip)
			Ext.RegisterUIInvokeListener(ui, "addFormattedTooltip", OnTooltip)
			Ext.RegisterUIInvokeListener(ui, "addFormattedTooltip", OnTooltip)
		end
		Ext.RegisterUIInvokeListener(ui, "addTooltip", OnTooltip)
		Ext.RegisterUIInvokeListener(ui, "showStatTooltip", OnTooltip)
		Ext.RegisterUIInvokeListener(ui, "addStatusTooltip", OnTooltip)
		Ext.RegisterUIInvokeListener(ui, "addFormattedTooltip", OnAddFormattedTooltip)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showSkillTooltip", OnTooltip)
		Ext.RegisterUICall(ui, "showStatTooltip", OnTooltip)
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showStatusTooltip", OnTooltip)
	end
	for i,file in pairs(itemTooltipFiles) do
		ui = Ext.GetBuiltinUI(file)
		if ui ~= nil then
			Ext.RegisterUICall(ui, "showItemTooltip", OnTooltip)
			Ext.RegisterUICall(ui, "slotOver", OnTooltip)
			Ext.RegisterUICall(ui, "slotOut", OnSlotOut)
		end
	end
	ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showSkillTooltip", OnTooltip)
	end
	-- ui = Ext.GetBuiltinUI("Public/Game/GUI/dialog.swf")
	-- if ui ~= nil then
	-- 	Ext.RegisterUICall(ui, "TradeButtonPressed", HookIntoTrade)
	-- else
	-- 	Ext.PrintError("Cound not find dialog.swf")
	-- end
end

return {
	Init = InitTooltipOverrides
}
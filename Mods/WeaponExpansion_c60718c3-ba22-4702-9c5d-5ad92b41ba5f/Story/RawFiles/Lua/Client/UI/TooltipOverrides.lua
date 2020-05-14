local tooltipType = ""
local lastTooltipCall = ""
local setupTooltip = Ext.Require("Client/UI/SetupTooltipSwitchStatement.lua")


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

---@param ui UIObject
local function OnAddFormattedTooltip(ui, call, tooltipX, tooltipY, noCompare)
	local tooltipType = ui:GetValue("tooltip_array", "number", 0)
	local tooltipHeader = ui:GetValue("tooltip_array", "string", 1)
	local isDamageTooltip = tooltipHeader == "Damage"
	LeaderLib.PrintDebug("[OnAddFormattedTooltip] ", LeaderLib.Data.UI.TOOLTIP_ENUM[tooltipType], tooltipHeader, tooltipX, tooltipY, noCompare)
	--setupTooltip.DumpTooltipArray(ui)

	local isSkill = LeaderLib.Data.UI.TOOLTIP_ENUM[tooltipType] == "SkillName"

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
						local tagData = data.Tags[tagName]
						if HasMasteryRequirement(character, tagName) then
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
							end
							if tagLocalizedName ~= "" then
								paramText = tagLocalizedName.."<br>"..tagData.Param.Value
							else
								paramText = tagData.Param.Value
							end
							paramText = Tooltip.ReplacePlaceholders(paramText)
							if tagData.GetParam ~= nil then
								local status,result = xpcall(tagData.GetParam, debug.traceback, character.Stats, tagName, paramText)
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
	end
	-- local minimap = Ext.GetBuiltinUI("Public/Game/GUI/minimap.swf")
	-- if minimap ~= nil then
	-- 	minimap:Invoke("showMiniMap", false)
	-- end
end

local function InitTooltipOverrides()
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/tooltip.swf")
	if ui ~= nil then
		if Ext.IsDeveloperMode() then
			Ext.RegisterUIInvokeListener(ui, "INTshowTooltip", OnTooltip)
			Ext.RegisterUIInvokeListener(ui, "INTRemoveTooltip", OnTooltip)
			Ext.RegisterUIInvokeListener(ui, "setGroupLabel", OnTooltip)
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
	ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "showSkillTooltip", OnTooltip)
	end
end

return {
	Init = InitTooltipOverrides
}
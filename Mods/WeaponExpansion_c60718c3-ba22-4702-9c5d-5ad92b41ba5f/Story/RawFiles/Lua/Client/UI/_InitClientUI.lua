Ext.Require("Client/UI/ClientUIData.lua")
Ext.Require("Client/UI/MasteryMenu/_Init.lua")
local tooltipHandler = Ext.Require("Client/UI/TooltipHandler.lua")

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

---@deprecated Moved to a Damage stat listener in StatTooltips.lua
---@param ui UIObject
function SetCharacterSheetDamageText(ui, uuid)
	local character = Ext.GetCharacter(uuid)
	if character ~= nil and UnarmedHelpers.HasUnarmedWeaponStats(character.Stats) then
		local baseMin,baseMax,totalMin,totalMax,boost = UnarmedHelpers.GetUnarmedBaseAndTotalDamage(character)
		local i = 0
		ui:SetValue("secStat_array", 1, i+1)
		ui:SetValue("secStat_array", LocalizedText.CharacterSheet.Damage.Value, i+2)
		if totalMin ~= totalMax then
			ui:SetValue("secStat_array", string.format("%i-%i", totalMin, totalMax), i+3)
		else
			ui:SetValue("secStat_array", string.format("%i", totalMax), i+3)
		end
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

Ext.RegisterNetListener("LLWEAPONEX_DisplayOverheadDamage", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data ~= nil then
		--print(Common.Dump(data.Params))
		---@type UIObject
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/overhead.swf")
		if ui ~= nil then
			local handle = Ext.HandleToDouble(data.Params.Handle)
			ui:Invoke("addOverheadDamage", handle, data.Params.Text)
		end
	end
end)

Ext.RegisterListener("SessionLoaded", function()
	tooltipHandler.Init()
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

		---@param entry {ID:string, Value:string, GeneratedID:integer}
		---@param player EclCharacter
		Mods.CharacterExpansionLib.SheetManager:RegisterEntryUpdatingListener("Damage", function (entry, player)
			local baseMin,baseMax,totalMin,totalMax,boost = UnarmedHelpers.GetUnarmedBaseAndTotalDamage(player)
			entry.Value = string.format("%i-%i", totalMin, totalMax)
		end)
	else
		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", OnCharacterSheetUpdating)
	end
end)

RegisterListener("BeforeLuaReset", function()
	CombatLog.RemoveFilter("Rolls")
end)
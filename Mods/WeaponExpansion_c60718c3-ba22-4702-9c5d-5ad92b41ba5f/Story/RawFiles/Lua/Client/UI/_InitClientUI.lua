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

---@param ui UIObject
local function OnCharacterSheetUpdating(ui, call, ...)
	local main = ui:GetRoot()
	if not main then
		return
	end
	local array = main.secStat_array

	local character = Client:GetCharacter()
	if character and UnarmedHelpers.HasUnarmedWeaponStats(character.Stats) and array ~= nil and #array > 0 then
		for i=0,#array,7 do
			local statType = array[i+1]
			if statType ~= nil then
				local label = array[i+2]
				local value = array[i+3]
				local tooltipId = array[i+4]
				--print(statType, label, value, tooltipId)
				if tooltipId == damageStatID then
					local baseMin,baseMax,totalMin,totalMax,boost = UnarmedHelpers.GetUnarmedBaseAndTotalDamage(character)
					array[i+3] = string.format("%i-%i", totalMin, totalMax)
					break
				end
			end
		end
	end
end

Events.RegionChanged:Subscribe(function (e)
	if e.LevelType == LEVELTYPE.CHARACTER_CREATION then
		MasteryMenu:Close(true)
		if e.State == REGIONSTATE.GAME then
			local player = Client:GetCharacter()
			if player and player.PlayerCustomData and player.PlayerCustomData.OriginName == "LLWEAPONEX_Korvash" then
				Ext.PostMessageToServer("LLWEAPONEX_CC_CheckKorvashColor", tostring(player.NetID))
			end
		end
	end
end)

Events.ClientCharacterChanged:Subscribe(function (e)
	if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
		if e.Character.PlayerCustomData and e.Character.PlayerCustomData.OriginName == "LLWEAPONEX_Korvash" then
			Ext.PostMessageToServer("LLWEAPONEX_CC_CheckKorvashColor", tostring(e.Character.NetID))
		end
	end
end)

Ext.Events.SessionLoaded:Subscribe(function()
	tooltipHandler.Init()
	local rollingText = GameHelpers.GetTranslatedString("he38e2e7bg72dbg4477g86f9ga1fedc4f6750", "Dice Rolls")
	CombatLog.AddFilter("Rolls", rollingText, Vars.DebugMode or nil, 3)
	if Mods.CharacterExpansionLib then
		---@param player EclCharacter
		---@param origin string
		---@param race string
		---@param skills string[]
		Mods.CharacterExpansionLib.Listeners.SetCharacterCreationOriginSkills.Register(function(player, origin, race, skills)
			if origin == "LLWEAPONEX_Korvash" then
				local skillSet = Ext.Stats.SkillSet.GetLegacy("Avatar_LLWEAPONEX_Korvash")
				if skillSet then
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

		Mods.CharacterExpansionLib.SheetManager.Events.OnEntryUpdating:Subscribe(function (e)
			if UnarmedHelpers.HasUnarmedWeaponStats(e.Character.Stats) then
				local baseMin,baseMax,totalMin,totalMax,boost = UnarmedHelpers.GetUnarmedBaseAndTotalDamage(e.Character)
				if totalMin and totalMax then
					local value = string.format("%i - %i", totalMin, totalMax)
					e.Stat.Value = value
				end
			end
		end, {MatchArgs={ID="Damage"}})
	else
		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", OnCharacterSheetUpdating)
	end
	-- Lower priority so mastery stuff hopefully is appended last, but we want LeaderLib to still go after this
end, {Priority=50})

Events.BeforeLuaReset:Subscribe(function (e)
	CombatLog.RemoveFilter("Rolls")
end)
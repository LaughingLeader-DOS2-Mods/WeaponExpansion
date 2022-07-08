if not Vars.IsClient then
	Ext.RegisterNetListener("LLWEAPONEX_ForcePickpocket", function(cmd, payload)
		local data = Common.JsonParse(payload)
		local player = Ext.GetCharacter(data.Player)
		local target = Ext.GetCharacter(data.Target)
		StartPickpocket(player.MyGuid,target.MyGuid,1)
	end)
else
	local PICKPOCKET_ID = 1
	local PICKPOCKET_ACTION_ID = 15
	local FORCE_PICKPOCKET_ID = 777
	local pickpocketTarget = nil

	Ext.RegisterUITypeInvokeListener(Data.UIType.contextMenu.Object, "updateButtons", function(ui, event)
		local cursor = Ext.GetPickingState()
		if cursor and cursor.HoverCharacter then
			pickpocketTarget = Ext.GetCharacter(cursor.HoverCharacter)
		end
		--[[ local this = ui:GetRoot()
		local buttons = {}
		local arr = this.buttonArr
		if arr then
			local length = #arr
			if length > 0 then
				for i=0,length,7 do
					buttons[#buttons+1] = {
						Index = i,
						id = arr[i],
						actionID = arr[i+1],
						clickSound = arr[i+2],
						unusedText = arr[i+3],
						text = arr[i+4],
						disabled = arr[i+5],
						legal = arr[i+6],
					}
				end
			end
		end
		Ext.Print(event,Lib.serpent.block(buttons)) ]]
	end)
	Ext.RegisterUITypeCall(Data.UIType.contextMenu.Object, "setMcSize", function(ui, event)
		if Vars.DebugMode or GameHelpers.CharacterOrEquipmentHasTag(Client:GetCharacter(), "LLWEAPONEX_InfinitePickpocket") then
			local this = ui:GetRoot()
			local arr = this.windowsMenu_mc.list.content_array
			for i=0,#arr-1 do
				local element = arr[i]
				if element then
					--fprint(LOGLEVEL.WARNING, "[%s] = id(%s) actionID(%s) text(%s)", i, element.id, element.actionID, element.text)
					if element.id == PICKPOCKET_ID and element.actionID == PICKPOCKET_ACTION_ID then
						--element.actionID = FORCE_PICKPOCKET_ID
						element.id = FORCE_PICKPOCKET_ID
						-- element.text = "Mug"
						-- element.text_txt.htmlText = "Mug"
					end
				end
			end
		end
	end)
	Ext.RegisterUITypeCall(Data.UIType.contextMenu.Object, "buttonPressed", function(ui, event, id, actionID, handle)
		if id == FORCE_PICKPOCKET_ID then
			Ext.PostMessageToServer("LLWEAPONEX_ForcePickpocket", Ext.JsonStringify({
				Player = Client:GetCharacter().NetID,
				Target = pickpocketTarget.NetID
			}))
		end
	end)

	Ext.RegisterUITypeInvokeListener(Data.UIType.containerInventory, "updateItems", function(ui, event)
		--TODO Make items unclickable/unmovable if this is additional pickpocketing with the gloves
	end)

	local thiefGloveChanceBonusText = Classes.TranslatedString:Create("h1fce3bfeg41a6g41adgbc5bg03d39281b469", "<font color='#11D87A'>+[1]% chance from [2]</font>")
	Tags.SkillBonusText["LLWEAPONEX_PirateGloves_Equipped"] = function(character, skill, tag, tooltip)
		if skill == "Target_LLWEAPONEX_Steal" then
			local chance = math.floor(GameHelpers.GetExtraData("LLWEAPONEX_Steal_GlovesBonusChance", 30.0))
			local gloveName = GameHelpers.GetStringKeyText("ARM_UNIQUE_LLWEAPONEX_PirateGloves_A_DisplayName", "Thief's Gloves")
			if gloveName ~= "" then
				return thiefGloveChanceBonusText:ReplacePlaceholders(chance, gloveName),true
			end
		end
	end
end
-- Ext.RegisterOsirisListener("RequestPickpocket", 2, "after", function(player, target)
-- 	if GameHelpers.CharacterOrEquipmentHasTag(player, "LLWEAPONEX_PirateGloves_Equipped") then
	
-- 	end
-- end)
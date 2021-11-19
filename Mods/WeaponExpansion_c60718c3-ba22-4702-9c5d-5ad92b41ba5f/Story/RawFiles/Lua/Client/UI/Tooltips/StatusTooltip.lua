---@param character EclCharacter
---@param status EclStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
	---@type MasteryRankBonus
	local data = Mastery.Params.StatusData[status.StatusId]
	if data ~= nil then
		local bonusIsActive = true
		--deprecated
		if data.Active ~= nil then
			if data.Active.Type == "Tag" then
				if data.Active.Source == true then
					if status.StatusSourceHandle ~= nil then
						local source = Ext.GetCharacter(status.StatusSourceHandle)
						if source ~= nil then
							bonusIsActive = GameHelpers.CharacterOrEquipmentHasTag(source, data.Active.Value)
						end
					end
					bonusIsActive = GameHelpers.CharacterOrEquipmentHasTag(character, data.Active.Value)
				else
					bonusIsActive = GameHelpers.CharacterOrEquipmentHasTag(character, data.Active.Value)
				end
			end
		end
		if data.Type == "MasteryRankBonus" then
			if data.GetIsTooltipActive then
				local b,result = xpcall(data.GetIsTooltipActive, debug.traceback, data, status, character, "status", status)
				if b then
					bonusIsActive = result ~= nil and result or false
				else
					Ext.PrintError(result)
				end
			end
		end
		if bonusIsActive then
			local descriptionText = TooltipHandler.GetDescriptionText(character, data, status, true)
			if descriptionText ~= "" then
				local existingDescription = tooltip:GetElement("StatusDescription")
				if existingDescription ~= nil then
					local description = existingDescription.Label
					if description == nil then 
						description = "" 
					else
						description = description.."<br>"
					end
					description = description..descriptionText
					existingDescription.Label = description
				else
					local description = {
						Label = descriptionText
					}
					tooltip:AppendElement(description)
				end
			end
		end
	end
	if status.StatusId == "LLWEAPONEX_ARMCANNON_CHARGED" then
		-- local item = nil
		-- for i,v in pairs(character:GetInventoryItems()) do
		-- 	local x = Ext.GetItem(v)
		-- 	if x:HasTag("LLWEAPONEX_RunicCannon") then
		-- 		item = x
		-- 		break
		-- 	end
		-- end
		-- if item ~= nil then
		-- 	local charges = PersistentVars.SkillData.RunicCannonCharges[item.NetID] or 0
		-- end
		local max = Ext.ExtraData.LLWEAPONEX_RunicCannon_MaxEnergy or 3
		local text = Text.ItemTooltip.RunicCannonEnergy:ReplacePlaceholders(max, max)
		local element = {
			Type = "StatusImmunity",
			Label = text
		}
		tooltip:AppendElement(element)
	elseif status.StatusId == "LLWEAPONEX_MURAMASA_CURSE" then
		local max = Ext.ExtraData.LLWEAPONEX_Muramasa_MaxCriticalDamageIncrease or 50
		local hpPercentage = character.Stats.CurrentVitality / character.Stats.MaxVitality
		local damageBoost = Ext.Round(((100 - hpPercentage)/100) * max)
		local text = string.format("+%s%% %s", damageBoost, Text.Game.CriticalDamage.Value)
		tooltip:AppendElement({
			Type="StatusBonus",
			Label=text
		})
	elseif status.StatusId == "LLWEAPONEX_UNRELENTING_RAGE" then
		local maxResBonus = Ext.ExtraData["LLWEAPONEX_UnrelentingRage_MaxPhysicalResistanceBonus"] or 20
		local currentRes = character.Stats.PhysicalResistance
		local bonus = 0
		if currentRes < maxResBonus then
			bonus = maxResBonus - currentRes
		end
		local text = Text.Game.CappedBonus:ReplacePlaceholders(bonus, LocalizedText.ResistanceNames.PhysicalResistance.Text.Value, maxResBonus)
		tooltip:AppendElement({
			Type="StatusBonus",
			Label=text
		})
	end
end

return OnStatusTooltip
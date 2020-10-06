---@param character EclCharacter
---@param status EclStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
	local data = Mastery.Params.StatusData[status.StatusId]
	if data ~= nil then
		local bonusIsActive = true
		if data.Active ~= nil then
			if data.Active.Type == "Tag" then
				if data.Active.Source == true then
					if status.StatusSourceHandle ~= nil then
						local source = Ext.GetCharacter(status.StatusSourceHandle)
						if source ~= nil then
							bonusIsActive = source:HasTag(data.Active.Value)
						end
					end
					bonusIsActive = character:HasTag(data.Active.Value)
				else
					bonusIsActive = character:HasTag(data.Active.Value)
				end
			end
		end
		if bonusIsActive then
			local descriptionText = TooltipHandler.GetDescriptionText(character, data)
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
	end
end

return OnStatusTooltip
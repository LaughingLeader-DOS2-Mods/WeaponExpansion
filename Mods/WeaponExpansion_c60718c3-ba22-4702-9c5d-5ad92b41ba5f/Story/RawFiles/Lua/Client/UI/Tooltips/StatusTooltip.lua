---@param character EsvCharacter
---@param status EsvStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
	local data = Mastery.Params.StatusData[status.StatusId]
	if data ~= nil then
		local bonusIsActive = true
		if data.Active ~= nil then
			if data.Active.Type == "Tag" then
				bonusIsActive = character:HasTag(data.Active.Value)
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
end

return OnStatusTooltip
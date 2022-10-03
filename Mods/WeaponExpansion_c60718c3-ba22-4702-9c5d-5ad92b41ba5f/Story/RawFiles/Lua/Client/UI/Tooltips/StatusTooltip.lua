---@param character EclCharacter
---@param status EclStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
	if status.StatusId == "LLWEAPONEX_ARMCANNON_CHARGED" then
		local max = GameHelpers.GetExtraData("LLWEAPONEX_RunicCannon_MaxEnergy", 3, true)
		local text = Text.ItemTooltip.RunicCannonEnergy:ReplacePlaceholders(max, max)
		local element = {
			Type = "StatusImmunity",
			Label = text
		}
		tooltip:AppendElement(element)
	elseif status.StatusId == "LLWEAPONEX_MURAMASA_CURSE" then
		local max = GameHelpers.GetExtraData("LLWEAPONEX_Muramasa_MaxCriticalDamageIncrease", 50)
		local hpPercentage = character.Stats.CurrentVitality / character.Stats.MaxVitality
		local damageBoost = Ext.Utils.Round(((100 - hpPercentage)/100) * max)
		local text = string.format("+%s%% %s", damageBoost, Text.Game.CriticalDamage.Value)
		tooltip:AppendElement({
			Type="StatusBonus",
			Label=text
		})
	elseif status.StatusId == "LLWEAPONEX_UNRELENTING_RAGE" then
		local maxResBonus = GameHelpers.GetExtraData("LLWEAPONEX_UnrelentingRage_MaxPhysicalResistanceBonus", 20)
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
	elseif status.StatusId == "LLWEAPONEX_BANNER_RALLY_DIVINEORDER_AURABONUS" or status.StatusId == "LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS" then
		local immuneText = LocalizedText.Tooltip.ImmuneTo:ReplacePlaceholders(GameHelpers.GetStringKeyText("LeaderLib_Flanking", "Flanking"))
		tooltip:AppendElement({
			Type="StatusImmunity",
			Label=immuneText
		})
	end
	local bonusText = MasteryBonusManager.GetBonusText(character, status.StatusId, "status", status)
	if bonusText then
		local description = tooltip:GetElement("StatusDescription") or tooltip:AppendElement({Type="StatusDescription", Label = ""})
		if not StringHelpers.IsNullOrWhitespace(description.Label) then
			description.Label = description.Label .. "<br>"
		end
		description.Label = description.Label .. bonusText
	end
end

return OnStatusTooltip
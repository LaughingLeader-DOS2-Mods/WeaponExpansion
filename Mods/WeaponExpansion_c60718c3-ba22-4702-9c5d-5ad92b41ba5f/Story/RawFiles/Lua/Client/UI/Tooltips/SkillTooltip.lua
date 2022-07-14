---@type TranslatedString
local ts = Classes.TranslatedString

---@type table<string,fun(character:EsvCharacter):string>
local AlternativeScaling = {
	---@param character EsvCharacter
	Target_LLWEAPONEX_Steal = function(character)
		return Text.SkillScaling.AttributeAndAbility:ReplacePlaceholders(LocalizedText.AbilityNames.RogueLore.Value, LocalizedText.AttributeNames[Skills.GetHighestAttribute(character.Stats, AttributeScaleTables.NoMemory)].Value)
	end
}

---@type table<string, TranslatedString>
local AbilitySchool = {
	Target_LLWEAPONEX_Steal = Text.NewAbilitySchools.Pirate,
	Shout_LLWEAPONEX_OpenMenu = Text.Game.WeaponExpansion,
}

local darkFireballEmptyLevelText = ts:Create("h83e65b1fg30c2g4e9ega9bag005eb17c5d75", "<font color='#FF2200'>[1]/[2] Death Charges</font>")
local darkFireballLevelText = ts:Create("h67e6fbecg1cafg4202ga78ag45db47880450", "<font color='#AA00FF'>[1]/[2] Death Charges</font>")
local heavyBoltText = ts:Create("hb931f729g9df1g461bg887fgb7eae7662e12", "Heavy Bolt (+AP Cost)")

local AppendedText = {
	---@param character EsvCharacter
	Projectile_LLWEAPONEX_DarkFireball = function(character)
		if PersistentVars ~= nil and PersistentVars.SkillData ~= nil and PersistentVars.SkillData.DarkFireballCount ~= nil then
			local count = PersistentVars.SkillData.DarkFireballCount[character.NetID] or 0
			local max = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_MaxKillCount", 10)
			if count > 0 then
				return darkFireballLevelText:ReplacePlaceholders(count, max)
			else
				return darkFireballEmptyLevelText:ReplacePlaceholders(count, max)
			end
		end
	end,
}

---@param checkText string
---@param character EsvCharacter
---@param element table
---@param func fun(character:EsvCharacter):string
local function ReplaceScalingText(checkText, character, element, func)
	local _,_,replaceText = string.find(element.Label, checkText)
	if replaceText ~= nil then
		local newText = func(character)
		if newText ~= nil then
			element.Label = string.gsub(element.Label, replaceText, newText)
			return true
		end
	end
	return false
end

SkillConfiguration.DisplayScalingStatSkills = {
	Projectile_LLWEAPONEX_Pistol_Shoot = true,
	Projectile_LLWEAPONEX_Pistol_Shoot_Enemy = true,
	Projectile_LLWEAPONEX_HandCrossbow_Shoot = true,
	Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy = true,
}

---@param character EclCharacter
---@param skill string
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	--print(skill, Ext.JsonStringify(tooltip.Data))
	local descriptionElement = tooltip:GetElement("SkillDescription") or {Type="SkillDescription", Label = ""}
	if skill == "Target_LLWEAPONEX_RemoteMine_Detonate" then
		if GetSettings().Global:FlagEquals("LLWEAPONEX_RemoteChargeDetonationCountDisabled", true) then
			descriptionElement.Label = Text.SkillTooltip.RemoteMineNoRestrictionDescription:ReplacePlaceholders(Ext.StatGetAttribute("Target_LLWEAPONEX_RemoteMine_Detonate", "TargetRadius"))
		end
	end

	local getAltScalingText = AlternativeScaling[skill]
	if getAltScalingText ~= nil then
		local element = tooltip:GetElement("SkillProperties")
		if element ~= nil then
			for i,prop in pairs(element.Properties) do
				for key,text in pairs(Text.DefaultSkillScaling) do
					local checkText = text.Value:gsub("%[1%]", "(%%w+)")
					if ReplaceScalingText(checkText, character, prop, getAltScalingText) then
						break
					end
				end
			end
		end
	end
	if AbilitySchool[skill] ~= nil then
		local element = tooltip:GetElement("SkillSchool")
		if element ~= nil then
			element.Label = AbilitySchool[skill].Value
		end
	end

	if AppendedText[skill] ~= nil then
		local b,text,appendToSkillProperties = xpcall(AppendedText[skill], debug.traceback, character, skill)
		if b then
			if text ~= nil then
				if appendToSkillProperties == true then
					local element = tooltip:GetElement("SkillProperties") or {Type="SkillProperties", Properties={}, Resistances={}}
					if element ~= nil then
						table.insert(element.Properties, {
							Label = text
						})
					end
				else
					if not StringHelpers.IsNullOrWhitespace(descriptionElement.Label) then
						descriptionElement.Label = string.format("%s<br>%s", descriptionElement.Label, text)
					else
						descriptionElement.Label = text
					end
				end
			end
		else
			Ext.PrintError(text)
		end
	end

	local characterTags = GameHelpers.GetAllTags(character, true, true)

	for tag,callback in pairs(Tags.SkillBonusText) do
		if characterTags[tag] then
			local b,text,appendToSkillProperties = xpcall(callback, debug.traceback, character, skill, tag, tooltip)
			if b then
				if text ~= nil then
					text = GameHelpers.Tooltip.ReplacePlaceholders(text, character)
					if appendToSkillProperties == true then
						local element = tooltip:GetElement("SkillProperties") or {Type="SkillProperties", Properties={}, Resistances={}}
						if element ~= nil then
							table.insert(element.Properties, {
								Label = text
							})
						end
					else
						if not StringHelpers.IsNullOrWhitespace(descriptionElement.Label) then
							descriptionElement.Label = string.format("%s<br>%s", descriptionElement.Label, text)
						else
							descriptionElement.Label = text
						end
					end
				end
			else
				Ext.PrintError(text)
			end
		end
	end

	-- These lines alter the "Incompatible with" text that's a result of using an inverse condition tag.
	-- We want these skills to work unless the tags are set.
	if Skills.WarfareMeleeSkills[skill] == true then
		local requirementName = GameHelpers.GetStringKeyText("LLWEAPONEX_NoMeleeWeaponEquipped", "a Melee Weapon")
		for i,element in pairs(tooltip:GetElements("SkillRequiredEquipment")) do
			if element.RequirementMet == false then
				if element.Label == Text.Game.NotImmobileRequirement.Value then
					tooltip:RemoveElement(element)
				elseif string.find(element.Label, requirementName) then
					element.Label = Text.Game.RequiresTag:ReplacePlaceholders("", requirementName):gsub("  ", " ")
				end
			end
		end
	elseif Skills.ScoundrelMeleeSkills[skill] == true then
		local requirementName = GameHelpers.GetStringKeyText("LLWEAPONEX_CannotUseScoundrelSkills", "a Scoundrel Weapon")
		for i,element in pairs(tooltip:GetElements("SkillRequiredEquipment")) do
			if element.RequirementMet == false then
				if element.Label == Text.Game.NotImmobileRequirement.Value then
					tooltip:RemoveElement(element)
				elseif string.find(element.Label, requirementName) then
					element.Label = Text.Game.RequiresTag:ReplacePlaceholders("", requirementName):gsub("  ", " ")
				end
			end
		end
	end

	if not Data.ActionSkills[skill] then
		local hasRuneProps = false
		local stat = Ext.GetStat(skill)
		if stat and stat.SkillProperties then
			for i,v in pairs(stat.SkillProperties) do
				if v.Action == "LLWEAPONEX_ApplyPistolBullet" then
					local rune,weaponBoostStat = Skills.GetPistolRuneBoost(character.Stats)
					if weaponBoostStat ~= nil then
						---@type StatProperty[]
						local props = Ext.StatGetAttribute(weaponBoostStat, "ExtraProperties")
						if props ~= nil then
							hasRuneProps = true
							for i,v in pairs(props) do
								if v.Type == "Status" then
									local chance = math.min(100, math.ceil(v.StatusChance * 100))
									local turns = v.Duration
									local text = ""
									local chanceText = ""
									local name = GameHelpers.GetStringKeyText(Ext.StatGetAttribute(v.Action, "DisplayName") or "", v.Action)
									if chance > 0 then
										chanceText = LocalizedText.Tooltip.ChanceToSucceed:ReplacePlaceholders(chance)
									end
									if turns > 0 then
										turns = math.ceil(v.Duration / 6.0)
										text = LocalizedText.Tooltip.ExtraPropertiesWithTurns:ReplacePlaceholders(name, "", chanceText, turns)
									else
										text = LocalizedText.Tooltip.ExtraPropertiesPermanent:ReplacePlaceholders(name, "", chanceText)
									end
									tooltip:AppendElement({
										Type="ExtraProperties",
										Label=text
									})
								end
							end
						end
					end
				elseif v.Action == "LLWEAPONEX_ApplyHandCrossbowBolt" then
					local rune,weaponBoostStat = Skills.GetHandCrossbowRuneBoost(character.Stats)
					if weaponBoostStat ~= nil then
						local weaponBoost = Ext.GetStat(weaponBoostStat)
						---@type StatProperty[]
						local props = weaponBoost.ExtraProperties
						if props then
							hasRuneProps = true
							for i,v in pairs(props) do
								if v.Type == "Status" then
									local chance = math.min(100, math.ceil(v.StatusChance * 100))
									local turns = v.Duration
									local text = ""
									local chanceText = ""
									local name = GameHelpers.GetStringKeyText(Ext.StatGetAttribute(v.Action, "DisplayName") or "", v.Action)
									if chance > 0 then
										chanceText = LocalizedText.Tooltip.ChanceToSucceed:ReplacePlaceholders(chance)
									end
									if turns > 0 then
										turns = math.ceil(v.Duration / 6.0)
										text = LocalizedText.Tooltip.ExtraPropertiesWithTurns:ReplacePlaceholders(name, "", chanceText, turns)
									else
										text = LocalizedText.Tooltip.ExtraPropertiesPermanent:ReplacePlaceholders(name, "", chanceText)
									end
									tooltip:AppendElement({
										Type="ExtraProperties",
										Label=text
									})
								end
							end
						end
						local isHeavyBolt = string.find(weaponBoost.Tags, "LLWEAPONEX_HeavyAmmo")
						if isHeavyBolt then
							tooltip:AppendElement({
								Type="ExtraProperties",
								Label=heavyBoltText.Value
							})
						end
					end
				end
			end
		end
		if hasRuneProps then
			--Remove the empty entry for LLWEAPONEX_ApplyHandCrossbowBolt/LLWEAPONEX_ApplyPistolBullet
			for i,v in pairs(tooltip:GetElements("ExtraProperties")) do
				if v.Label == "" then
					tooltip:RemoveElement(v)
				end
			end
		end
	end
	if string.find(skill, "Banner") then
		local element = tooltip:GetElement("SkillRequiredEquipment")
		if element ~= nil then
			if string.find(element.Label:lower(), "staff") then
				element.Label = string.gsub(element.Label, "Staff", Text.WeaponType.Banner.Value)
				element.Label = string.gsub(element.Label, "staff", Text.WeaponType.Banner.Value:lower())
			end
		end
	end

	local bonusText = MasteryBonusManager.GetBonusText(character, skill, "skill", tooltip.IsFromItem == true)
	if bonusText then
		if not StringHelpers.IsNullOrWhitespace(descriptionElement.Label) then
			descriptionElement.Label = descriptionElement.Label .. "<br>"
		end
		descriptionElement.Label = descriptionElement.Label .. bonusText
	end

	if Mastery.HasMinimumMasteryLevel(character, MasteryID.Crossbow, 1)
	and characterTags["LLWEAPONEX_Crossbow_Equipped"]
	and Mastery.Variables.Bonuses.IsStillStanceSkill(skill) then
		local sp = tooltip:GetElement("SkillProperties")
		if sp then
			local bonus = Mastery.Variables.Bonuses.GetStillStanceBonus(character)
			if bonus > 0 then
				local rankName = StringHelpers.StripFont(GameHelpers.GetStringKeyText(Masteries.LLWEAPONEX_Crossbow.RankBonuses[1].Tag, "Crossbow I"))
				table.insert(sp.Properties, {
					Label = Text.SkillTooltip.StillStance:ReplacePlaceholders(string.format("+%s", bonus), rankName),
                    Warning = ""
				})
			end
		end
	end

	if characterTags["LLWEAPONEX_Firearm_Equipped"] and not StringHelpers.IsNullOrEmpty(descriptionElement.Label) then
		descriptionElement.Label = descriptionElement.Label:gsub("arrow", "bullet"):gsub("Arrow", "Bullet")
	end

	if SkillConfiguration.DisplayScalingStatSkills[skill] then
		local text = Skills.Params["LLWEAPONEX_ScalingStat"](skill, character.Stats)
		if not StringHelpers.IsNullOrEmpty(text) then
			local props = tooltip:GetElement("SkillProperties", {Properties={}, Resistances={}})
			local properties = {}
			for i,v in pairs(props.Properties) do
				if not StringHelpers.IsNullOrWhitespace(v.Label) then
					properties[#properties+1] = v
				end
			end
			properties[#properties+1] = {
				Label = text,
				Warning = ""
			}
			props.Properties = properties
		end
	end
end

return OnSkillTooltip
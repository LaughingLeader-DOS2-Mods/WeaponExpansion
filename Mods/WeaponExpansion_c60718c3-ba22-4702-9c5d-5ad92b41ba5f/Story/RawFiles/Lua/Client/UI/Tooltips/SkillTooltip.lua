---@type TranslatedString
local ts = LeaderLib.Classes.TranslatedString

---@type table<string,fun(character:EsvCharacter):string>
local AlternativeScaling = {
	---@param character EsvCharacter
	Target_LLWEAPONEX_Steal = function(character)
		return Text.SkillScaling.AttributeAndAbility:ReplacePlaceholders(LocalizedText.AbilityNames.RogueLore.Value, LocalizedText.AttributeNames[Skills.GetHighestAttribute(character.Stats, AttributeScaleTables.NoMemory)].Value)
	end	
}

---@type table<string, ts>
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
			local max = Ext.ExtraData["LLWEAPONEX_DarkFireball_MaxKillCount"] or 10
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

---@param character EclCharacter
---@param skill string
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	--print(skill, Ext.JsonStringify(tooltip.Data))
	local descriptionElement = tooltip:GetElement("SkillDescription")
	local description = ""
	if descriptionElement ~= nil then
		description = descriptionElement.Label
	end

	local data = Mastery.Params.SkillData[skill]
	if data ~= nil then
		local descriptionText = TooltipHandler.GetDescriptionText(character, data)
		if not StringHelpers.IsNullOrEmpty(descriptionText) then
			if descriptionElement ~= nil then
				if description == nil then 
					description = ""
				else
					description = description.."<br>"
				end
				description = description..descriptionText
				descriptionElement.Label = description
			else
				descriptionElement = {
					Label = descriptionText
				}
				description = descriptionText
				tooltip:AppendElement(descriptionElement)
			end
		end
	end

	if character:HasTag("LLWEAPONEX_Firearm_Equipped") then
		if not StringHelpers.IsNullOrEmpty(description) then
			description = description:gsub("arrow", "bullet"):gsub("Arrow", "Bullet")
			descriptionElement.Label = description
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
					local element = tooltip:GetElement("SkillDescription")
					if element ~= nil then
						element.Label = string.format("%s<br>%s", element.Label, text)
					end
				end
			end
		else
			Ext.PrintError(text)
		end
	end

	for tag,callback in pairs(Tags.SkillBonusText) do
		if GameHelpers.CharacterOrEquipmentHasTag(character, tag) then
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
						local element = tooltip:GetElement("SkillDescription")
						if element ~= nil then
							element.Label = string.format("%s<br>%s", element.Label, text)
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

	if skill == "Target_LLWEAPONEX_RemoteMine_Detonate" then
		if Settings.Global:FlagEquals("LLWEAPONEX_RemoteChargeDetonationCountDisabled", true) then
			local element = tooltip:GetElement("SkillDescription")
			if element ~= nil then
				local desc,_ = GameHelpers.GetStringKeyText("Target_LLWEAPONEX_RemoteMine_Detonate_NoRestriction_Description", "Detonate remote charges in a [1] radius.<br><font color='#188EDE'>Can target mines in the world, or an object holding mines.</font>")
				if desc ~= nil then
					desc:gsub("%[1%]", Ext.StatGetAttribute("Target_LLWEAPONEX_RemoteMine_Detonate", "TargetRadius"))
					element.Label = desc
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
									local chance = max.min(100, math.ceil(v.StatusChance * 100))
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
									local chance = max.min(100, math.ceil(v.StatusChance * 100))
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

	-- if GameHelpers.CharacterOrEquipmentHasTag(character, "LLWEAPONEX_PacifistsWrath_Equipped") then
	-- 	if Ext.StatGetAttribute(skill, "UseWeaponDamage") == "Yes" then
	-- 		local main = character:GetItemBySlot("Weapon")
	-- 		local offhand = character:GetItemBySlot("Shield")
	-- 		if main and GameHelpers.ItemHasTag(main, "LLWEAPONEX_PacifistsWrath_Equipped") then
	-- 			main.Stats.DynamicStats[1].MinDamage = 1
	-- 			main.Stats.DynamicStats[1].MaxDamage = 1
	-- 		end
	-- 		if offhand and GameHelpers.ItemHasTag(offhand, "LLWEAPONEX_PacifistsWrath_Equipped") then
	-- 			offhand.Stats.DynamicStats[1].MinDamage = 1
	-- 			offhand.Stats.DynamicStats[1].MaxDamage = 1
	-- 		end
	-- 	end
	-- end
end

return OnSkillTooltip
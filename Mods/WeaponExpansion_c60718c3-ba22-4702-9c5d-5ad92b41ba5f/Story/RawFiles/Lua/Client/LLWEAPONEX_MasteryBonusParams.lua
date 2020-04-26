local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function GetThrowingKnifeBonusParam(character, param)
	local paramText = param:gsub("%[1%]", math.tointeger(math.min(Ext.ExtraData["LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance"], 100)))
	local damageSkillProps = WeaponExpansion.Skills.PrepareSkillProperties("Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive")
	local damageRange = Game.Math.GetSkillDamageRange(character, damageSkillProps)
	if damageRange ~= nil then
		local damageText = ""
		local totalMin = 0
		local totalMax = 0
		for damageType,damage in pairs(damageRange) do
			totalMin = totalMin + damage[1]
			totalMax = totalMax + damage[2]
		end
		damageText = string.format("%s-%s", math.tointeger(totalMin), math.tointeger(totalMax))
		paramText = string.gsub(paramText, "%[2%]", damageText)
	end
	return paramText
end

local MasteryParams = {
	SkillData = {
		Projectile_ThrowingKnife = {
			Description = TranslatedString:Create("h5fdfca1dg8dd4g4cc3g9939g7433a38d4658","Throw a knife at your opponent, dealing [1].[2]"),
			Tags = {
				LLWEAPONEX_Dagger_Mastery1 = {
					Param = TranslatedString:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","<font color='#8F7CFF' size='16'>Dagger Mastery I</font><br><font color='#F19824'>The knife thrown has a <font color='#CC33FF'>[1]%</font> to be coated in poison or explosive oil, dealing <font color='#00FFAA'>[2] bonus damage</font> on hit.</font>"),
					--LockedParam = TranslatedString:Create("h50295d19g3065g4099g9e78g7c6e7b45c579","<font color='#AE9F95' size='16'>Bonus Unlocked at Dagger Mastery I</font>"),
					GetParam = GetThrowingKnifeBonusParam,
				}
			}
		},
		Target_CripplingBlow = {
			Description = TranslatedString:Create("h5fdfca1dg8dd4g4cc3g9939g7433a38d4658","Throw a knife at your opponent, dealing [1].[2]"),
			Tags = {
				LLWEAPONEX_Blunt_Mastery1 = {
					Param = TranslatedString:Create("h1eb09384g6bfeg4cdaga83fgc408d86cfee4","<font color='#FFE7AA' size='16'>Blunt Weapons Mastery 1</font><br><font color='#F19824'>Sunder the armor of hit targets, <font color='#00FFAA'>reducing max Physical/Magic Armor by [1]%</font> for 1 turn.</font>"),
					--LockedParam = TranslatedString:Create("h50295d19g3065g4099g9e78g7c6e7b45c579","<font color='#AE9F95' size='16'>Bonus Unlocked at Dagger Mastery I</font>"),
					GetParam = function(character,param)
						local armorReduction = Ext.StatGetAttribute("Stats_LLWEAPONEX_MasteryBonus_Blunt_Sunder", "ArmorBoost")
						if armorReduction == nil then
							armorReduction = Ext.StatGetAttribute("Stats_LLWEAPONEX_MasteryBonus_Blunt_Sunder", "MagicArmorBoost")
						end
						local turns = 0
						local duration = Ext.ExtraData["LLWEAPONEX_MasteryBonus_CripplingBlow_SunderDuration"]
						if duration ~= nil and duration > 0 then
							turns = math.tointeger(duration / 6.0)
						else
							turns = 1
						end
						return param:gsub("%[1%]", armorReduction):gsub("%[2%]", turns)
					end,
				}
			}
		}
	}
}

--- @param character StatCharacter
--- @param tag string
local function HasMasteryRequirement(character, tag)
	if character.Character:HasTag(tag) == true then
		---@type StatItem
		local weapon = character:GetItemBySlot("Weapon")
		---@type StatItem
		local offhand = character:GetItemBySlot("Shield")
		if weapon ~= nil then
			Ext.Print(string.format("HasMasteryRequirement[%s] MainWeapon[%s]", tag, weapon.Name))
		end
		if offhand ~= nil then
			Ext.Print(string.format("HasMasteryRequirement[%s] OffHandWeapon[%s]", tag, offhand.Name))
		end
		return true
	end
	return false
end

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function GetMasteryBonuses(skill, character, isFromItem, param)
	local data = MasteryParams.SkillData[skill.Name]
	Ext.Print(LeaderLib.Common.Dump(data))
	if data ~= nil then
		local paramText = ""
		if data.Tags ~= nil then
			for tagName,tagData in pairs(data.Tags) do
				if tagData.GetParam ~= nil and HasMasteryRequirement(character, tagName) then
					local nextText = tagData.GetParam(character, tagData.Param.Value)
					paramText = paramText.."<br>"..nextText
				end
			end
		end
		return paramText
	end
	return ""
end

WeaponExpansion.Skills.Params["LLWEAPONEX_MasteryBonuses"] = GetMasteryBonuses
WeaponExpansion.Skills.MasteryParams = MasteryParams
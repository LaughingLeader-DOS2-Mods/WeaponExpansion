local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function GetThrowingKnifeBonusParam(character, tagName, param)
	local chance = Ext.ExtraData["LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance"]
	if chance == nil or chance < 0 then chance = 25 end
	local paramText = param:gsub("%[1%]", tagName):gsub("%[2%]", math.tointeger(math.min(chance, 100)))
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
		paramText = string.gsub(paramText, "%[3%]", damageText)
	end
	return paramText
end

WeaponExpansion.MasteryParams = {
	SkillData = {
		Projectile_ThrowingKnife = {
			Description = TranslatedString:Create("h5fdfca1dg8dd4g4cc3g9939g7433a38d4658","Throw a knife at your opponent, dealing [1].[2]"),
			Tags = {
				LLWEAPONEX_Dagger_Mastery2 = {
					Param = TranslatedString:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","[1]<br><font color='#F19824'>The knife thrown has a <font color='#CC33FF'>[2]%</font> to be coated in poison or explosive oil, dealing <font color='#00FFAA'>[3] bonus damage</font> on hit.</font>"),
					GetParam = GetThrowingKnifeBonusParam,
				}
			}
		},
		Target_CripplingBlow = {
			Description = TranslatedString:Create("h5fdfca1dg8dd4g4cc3g9939g7433a38d4658","Throw a knife at your opponent, dealing [1].[2]"),
			Tags = {
				LLWEAPONEX_Blunt_Mastery2 = {
					Param = TranslatedString:Create("h1eb09384g6bfeg4cdaga83fgc408d86cfee4","[1]<br><font color='#F19824'>Sunder the armor of hit targets, <font color='#00FFAA'>reducing max Physical/Magic Armor by [2]%</font> for [3] turn(s).</font>"),
					GetParam = function(character, tagName, param)
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
						return param:gsub("%[1%]", tagName):gsub("%[2%]", armorReduction):gsub("%[3%]", turns)
					end,
				},
				LLWEAPONEX_Axe_Mastery2 = {
					Param = TranslatedString:Create("h46875020ge016g4eccg94ecgc9f5233c07fd","[1]<br><font color='#F19824'>Your axe deal an additional [2]% of the original damage as [3].</font>"),
					GetParam = function(character, tagName, param)
						local damagePercentage = Ext.ExtraData["LLWEAPONEX_MasteryBonus_CripplingBlow_PiercingDamagePercentage"]
						if damagePercentage == nil then damagePercentage = 25 end
						damagePercentage = math.tointeger(damagePercentage)
						return param:gsub("%[1%]", tagName):gsub("%[2%]", damagePercentage):gsub("%[3%]", LeaderLib.Game.GetDamageText("Piercing"))
					end,
				},
			}
		}
	}
}
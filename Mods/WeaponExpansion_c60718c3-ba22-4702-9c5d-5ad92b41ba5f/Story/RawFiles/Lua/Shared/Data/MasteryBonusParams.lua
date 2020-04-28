local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function GetThrowingKnifeBonusParam(character, tagName, param)
	local chance = Ext.ExtraData["LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance"]
	if chance == nil or chance < 0 then chance = 25 end
	local paramText = param:gsub("%[1%]", tagName):gsub("%[2%]", math.tointeger(math.min(chance, 100)))
	local damageSkillProps = Skills.PrepareSkillProperties("Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive")
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

local function GetSkillDamageRange(character, skill)
    local damageMultiplier = skill['Damage Multiplier'] * 0.01

    if skill.UseWeaponDamage == "Yes" then
        local mainWeapon = character.MainWeapon
        local mainDamageRange = Game.Math.CalculateWeaponDamageRange(character, mainWeapon)
        local offHandWeapon = character.OffHandWeapon

        if offHandWeapon ~= nil and Game.Math.IsRangedWeapon(mainWeapon) == Game.Math.IsRangedWeapon(offHandWeapon) then
            local offHandDamageRange = Game.Math.CalculateWeaponDamageRange(character, offHandWeapon)

            local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
            for damageType, range in pairs(offHandDamageRange) do
                local min = range[1] * dualWieldPenalty
                local max = range[2] * dualWieldPenalty
                if mainDamageRange[damageType] ~= nil then
                    mainDamageRange[damageType][1] = mainDamageRange[damageType][1] + min
                    mainDamageRange[damageType][2] = mainDamageRange[damageType][2] + max
                else
                    mainDamageRange[damageType] = {min, max}
                end
            end
		end
		
		Ext.Print("mainDamageRange", LeaderLib.Common.Dump(mainDamageRange))

        for damageType, range in pairs(mainDamageRange) do
            local min = Ext.Round(range[1] * damageMultiplier)
            local max = Ext.Round(range[2] * damageMultiplier)
            range[1] = min + math.ceil(min * Game.Math.GetDamageBoostByType(character, damageType))
            range[2] = max + math.ceil(max * Game.Math.GetDamageBoostByType(character, damageType))
		end
		
		Ext.Print("mainDamageRange Boosted", LeaderLib.Common.Dump(mainDamageRange))

        local damageType = skill.DamageType
        if damageType ~= "None" and damageType ~= "Sentinel" then
            local min, max = 0, 0
            for _, range in pairs(mainDamageRange) do
                min = min + range[1]
                max = max + range[2]
            end
    
            mainDamageRange = {}
            mainDamageRange[damageType] = {min, max}
		end
		
		Ext.Print("mainDamageRange Final", LeaderLib.Common.Dump(mainDamageRange))

        return mainDamageRange
    else
        local damageType = skill.DamageType
        if damageMultiplier <= 0 then
            return {}
        end

        local level = character.Level
        if (level < 0 or skill.OverrideSkillLevel == "Yes") and skill.Level > 0 then
            level = skill.Level
        end

        local skillDamageType = skill.Damage
        local attrDamageScale
        if skillDamageType == "BaseLevelDamage" or skillDamageType == "AverageLevelDamge" then
            attrDamageScale = Game.Math.GetSkillAttributeDamageScale(skill, character)
        else
            attrDamageScale = 1.0
        end

        local baseDamage = Game.Math.CalculateBaseDamage(skill.Damage, character, 0, level) * attrDamageScale * damageMultiplier
        local damageRange = skill['Damage Range'] * baseDamage * 0.005

        local damageType = skill.DamageType
        local damageTypeBoost = 1.0 + Game.Math.GetDamageBoostByType(character, damageType)
        local damageBoost = 1.0 + (character.DamageBoost / 100.0)
        local damageRanges = {}
        damageRanges[damageType] = {
            math.ceil(math.ceil(Ext.Round(baseDamage - damageRange) * damageBoost) * damageTypeBoost),
            math.ceil(math.ceil(Ext.Round(baseDamage + damageRange) * damageBoost) * damageTypeBoost)
        }
        return damageRanges
    end
end

local function GetCripplingBlowBonusDamage(character, tagName, param)
	--Ext.Print("Character:",character, "tagName:",tagName, "param:",param)
	local damageText = ""
	local damageSkillProps = Skills.PrepareSkillProperties("Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage")
	local damageRange = GetSkillDamageRange(character, damageSkillProps)
	if damageRange ~= nil then
		--Ext.Print(LeaderLib.Common.Dump(damageRange))
		local totalMin = 0
		local totalMax = 0
		for damageType,damage in pairs(damageRange) do
			totalMin = totalMin + damage[1]
			totalMax = totalMax + damage[2]
		end
		damageText = string.format("%s-%s", math.tointeger(totalMin), math.tointeger(totalMax))
	end
	return param:gsub("%[1%]", tagName):gsub("%[2%]", LeaderLib.Game.GetDamageText("Piercing", damageText))
end

Mastery.Params = {
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
				LLWEAPONEX_Bludgeon_Mastery2 = {
					ID = "SUNDER",
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
					ID = "BONUSDAMAGE",
					Param = TranslatedString:Create("h46875020ge016g4eccg94ecgc9f5233c07fd","[1]<br><font color='#F19824'>If the target is disabled, deal an additional [2].</font>"),
					GetParam = GetCripplingBlowBonusDamage,
				},
			}
		}
	}
}
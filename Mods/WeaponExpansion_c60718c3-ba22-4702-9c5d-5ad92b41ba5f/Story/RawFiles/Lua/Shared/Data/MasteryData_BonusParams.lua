local TranslatedString = LeaderLib.Classes["TranslatedString"]

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

local elementalWeakness = {
	Air = "LLWEAPONEX_WEAKNESS_AIR",
	Chaos = "LLWEAPONEX_WEAKNESS_CHAOS",
	Earth = "LLWEAPONEX_WEAKNESS_EARTH",
	Fire = "LLWEAPONEX_WEAKNESS_FIRE",
	Poison = "LLWEAPONEX_WEAKNESS_POISON",
	Water = "LLWEAPONEX_WEAKNESS_WATER",
	Piercing = "LLWEAPONEX_WEAKNESS_PIERCING",
	Shadow = "LLWEAPONEX_WEAKNESS_SHADOW",
	--Physical = "LLWEAPONEX_WEAKNESS_Physical",
}


local checkResistanceStats = {
	--"PhysicalResistance",
	"PiercingResistance",
	--"CorrosiveResistance",
	--"MagicResistance",
	--"ChaosResistance",-- Special LeaderLib Addition
	"AirResistance",
	"EarthResistance",
	"FireResistance",
	"PoisonResistance",
	--"ShadowResistance", -- Technically Tenebrium
	"WaterResistance",
}

---@param character StatCharacter
---@param tagName string
---@param rankHeader string
---@param param string
---@return string
local function GetElementalWeakness(character, tagName, rankHeader, param)
	local paramText = param
	local resistanceReductions = {}
	local resistanceCount = 0
	local weapon = character.MainWeapon
	if weapon ~= nil then
		local stats = weapon.DynamicStats
		for i,stat in pairs(stats) do
			if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
				local status = elementalWeakness[stat.DamageType]
				if status ~= nil then
					local potion = Ext.StatGetAttribute(status, "StatsId")
					if potion ~= nil and potion ~= "" then
						for i,resistanceStat in pairs(checkResistanceStats) do
							local resistanceValue = Ext.StatGetAttribute(potion, resistanceStat)
							if resistanceValue ~= 0 then
								local resEntry = resistanceReductions[resistanceStat]
								if resEntry == nil then
									resEntry = 0
									resistanceCount = resistanceCount + 1
								end
								resEntry = resEntry + resistanceValue
								resistanceReductions[resistanceStat] = resEntry
							end
						end
					end
				end
			end
		end
	end

	local resistanceText = ""
	if #resistanceReductions > 0 then
		local i = 0
		for stat,value in pairs(resistanceReductions) do
			resistanceText = resistanceText.."<img src='Icon_BulletPoint'>"..LeaderLib.Game.GetResistanceText(stat, value)
			i = i + 1
			if i < resistanceCount then
				resistanceText = resistanceText .. "<br>"
			end
		end
		paramText = string.gsub(paramText, "%[Special%]", resistanceText)
		return paramText
	else
		return rankHeader..Tooltip.ReplacePlaceholders(Text.MasteryBonusParams.ElementalWeakness_NoElement.Value)
	end
end

Mastery.Params = {
	SkillData = {},
	UI = {}
}

Mastery.Params.SkillData.Projectile_ThrowingKnife = {
	Tags = {
		LLWEAPONEX_Dagger_Mastery1 = {
			ID = "BONUS_DAGGER",
			Param = TranslatedString:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","<font color='#F19824'>The knife thrown has a <font color='#CC33FF'>[ExtraData:LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance]%</font> to be <font color='#00FFAA'>coated in poison or explosive oil</font>, dealing [SkillDamage:Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive] or [SkillDamage:Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison] on hit.</font>"),
		}
	}
}

Mastery.Params.SkillData.Projectile_EnemyThrowingKnife = Mastery.Params.SkillData.Projectile_ThrowingKnife

Mastery.Params.SkillData.Target_CripplingBlow = {
	Tags = {
		LLWEAPONEX_Bludgeon_Mastery2 = {
			ID = "SUNDER",
			Param = TranslatedString:Create("h1eb09384g6bfeg4cdaga83fgc408d86cfee4","<font color='#F19824'>Sunder the armor of hit targets, <font color='#00FFAA'>reducing max Physical/Magic Armor by [Stats:Stats_LLWEAPONEX_MasteryBonus_Sunder:ArmorBoost]%/[Stats:Stats_LLWEAPONEX_MasteryBonus_Sunder:MagicArmorBoost]%</font> for [ExtraData:LLWEAPONEX_MasteryBonus_CripplingBlow_SunderDuration] turn(s).</font>"),
			NamePrefix = "<font color='#F19824'>Sundering</font>"
		},
		LLWEAPONEX_Axe_Mastery1 = {
			ID = "BONUSDAMAGE",
			Param = TranslatedString:Create("h46875020ge016g4eccg94ecgc9f5233c07fd","<font color='#F19824'>If the target is disabled, deal an additional [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage].</font>"),
			NamePrefix = "<font color='#DD4444'>Executioner's</font>"
		},
	}
}

Mastery.Params.SkillData.Target_EnemyCripplingBlow = Mastery.Params.SkillData.Target_CripplingBlow

Mastery.Params.SkillData.MultiStrike_BlinkStrike = {
	Tags = {
		LLWEAPONEX_Axe_Mastery2 = {
			ID = "VULNERABLE",
			Param = TranslatedString:Create("h173b9449ge0c5g4f29g86f4g01124907841b","Each target hit becomes <font color='#F13324'>Vulnerable</font>. If hit again, <font color='#F13324'>Vulnerable</font> is removed and the target takes [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_VulnerableDamage].<br><font color='#F1CC00'><font color='#F13324'>Vulnerable</font> is removed when your turn ends.</font>"),
		},
	}
}

Mastery.Params.SkillData.Shout_Whirlwind = {
	Tags = {
		LLWEAPONEX_Scythe_Mastery1 = {
			ID = "RUPTURE",
			Param = TranslatedString:Create("h5ca24bfeg14f5g437fg92fag4708f87547de","<font color='#DC143C'>Rupture</font> the wounds of <font color='#FF0000'>Bleeding</font> targets, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding] for each turn of <font color='#FF0000'>Bleeding</font> remaining.")
		},
		LLWEAPONEX_Staff_Mastery1 = {
			ID = "ELEMENTAL_DEBUFF",
			Param = TranslatedString:Create("h0ee72b7cg5a84g4efcgb8e2g8a02113196e6","<font color='#9BF0FF'>Targets hit become weak to your weapon's element, gaining [Special] for [ExtraData:LLWEAPONEX_MasteryBonus_ElementalWeaknessTurns] turn(s).</font>"),
			GetParam = GetElementalWeakness,
		},
		LLWEAPONEX_HandCrossbow_Mastery1 = {
			ID = "WHIRLWIND_BOLTS",
			Param = TranslatedString:Create("h665d9b1age332g4988gb57cgd1357c4c9af2","<font color='#F19824'>While spinning, shoot [ExtraData:LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MinTargets]-[ExtraData:LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MaxTargets] enemies in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_FindTarget:ExplodeRadius]m radius, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_Shoot:LLWEAPONEX_HandCrossbow_ShootDamage].</font>"),
		},
	}
}

Mastery.Params.SkillData.Shout_EnemyWhirlwind = Mastery.Params.SkillData.Shout_Whirlwind

Mastery.Params.SkillData.Shout_InspireStart = {
	Tags = {
		LLWEAPONEX_Banner_Mastery1 = {
			ID = "BANNER_INSPIRE",
			Param = TranslatedString:Create("h4190e997g6776g46a5gbff1g711a310c6d38","<font color='#FFCE58'>Fear, Madness, and Sleep are cleansed from encouraged allies.</font>")
		},
	}
}

Mastery.Params.SkillData.Shout_EnemyInspire = Mastery.Params.SkillData.Shout_InspireStart

Mastery.Params.SkillData.Target_PetrifyingTouch = {
	Tags = {
		LLWEAPONEX_Unarmed_Mastery1 = {
			ID = "PETRIFYING_SLAM",
			Param = TranslatedString:Create("h01468f79gd9b2g4479ga596g8a68e07c39e7","<font color='#FFCE58'>Slam the target with your palm, knocking them back [ExtraData:LLWEAPONEX_MasteryBonus_PetrifyingTouch_KnockbackDistance]m and dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage].</font>")
		},
	}
}

Mastery.Params.SkillData.Target_EnemyPetrifyingTouch = Mastery.Params.SkillData.Target_PetrifyingTouch

Mastery.Params.SkillData.Shout_FleshSacrifice = {
	Tags = {
		LLWEAPONEX_Wand_Mastery1 = {
			ID = "BLOOD_EMPOWER",
			Param = TranslatedString:Create("h0ad1536cg0e74g46dag8e1egc15967242d14","<font color='#CC33FF'>Allies standing on <font color='#F13324'>blood surfaces</font> or in <font color='#F13324'>blood clouds</font> gain a [Stats:Stats_LLWEAPONEX_BloodEmpowered:DamageBoost]% damage bonus.</font>")
		} 
	}
}

Mastery.Params.SkillData.Shout_EnemyFleshSacrifice = Mastery.Params.SkillData.Shout_FleshSacrifice

Mastery.Params.SkillData.Target_LLWEAPONEX_BasicAttack = {
	Tags = {
		LLWEAPONEX_Wand_Mastery1 = {
			ID = "ELEMENTAL_DEBUFF",
			Param = TranslatedString:Create("h0ee72b7cg5a84g4efcgb8e2g8a02113196e6","<font color='#9BF0FF'>Targets hit become weak to your weapon's element, gaining [Special] for [ExtraData:LLWEAPONEX_MasteryBonus_ElementalWeaknessDuration] turn(s).</font>"),
			GetParam = GetElementalWeakness,
		},
	}
}

Mastery.Params.SkillData.Rush_BatteringRam = {
	Tags = {
		LLWEAPONEX_Banner_Mastery1 = {
			ID = "WAR_CHARGE_RUSH",
			Param = TranslatedString:Create("h3c34bca6gc080g4de4gae5eg4909ad60ecc8","If under the effects of <font color='#FFCE58'>War Charge</font>, deal [ExtraData:LLWEAPONEX_MasteryBonus_WarChargeDamageBoost]% more damage and gain <font color='#7D71D9'>[Key:HASTED_DisplayName]</font> after rushing."),
		},
		LLWEAPONEX_Bludgeon_Mastery1 = {
			ID = "RUSH_DIZZY",
			Param = TranslatedString:Create("h9831ecc7g21feg403cg9bd6ga0bab3f7eb9c", "Become a thundering force of will when rushing, <font color='#FFCE58'>knocking enemies aside</font> with a <font color='#F19824'>[ExtraData:LLWEAPONEX_MasteryBonus_RushDizzyChance]% chance to apply Dizzy for [ExtraData:LLWEAPONEX_MasteryBonus_RushDizzyTurns] turn(s)</font>.")
		}
	}
}

Mastery.Params.SkillData.Rush_BullRush = {
	Tags = {
		LLWEAPONEX_Banner_Mastery1 = Mastery.Params.SkillData.Rush_BatteringRam.Tags.LLWEAPONEX_Banner_Mastery1,
		LLWEAPONEX_Bludgeon_Mastery1 = Mastery.Params.SkillData.Rush_BatteringRam.Tags.LLWEAPONEX_Bludgeon_Mastery1,
	}
}

Mastery.Params.SkillData.Shout_RecoverArmour = {
	Tags = {
		LLWEAPONEX_Shield_Mastery1 = {
			ID = "GUARANTEED_BLOCK",
			Param = TranslatedString:Create("h6a284017g342dg4809gab69g6e77bddaf8c2","Damage from the next direct hit taken is reduced by <font color='#33FF00'>[ExtraData:LLWEAPONEX_MasteryBonus_RecoverArmour_DamageReduction]%</font>."),
		},
	}
}
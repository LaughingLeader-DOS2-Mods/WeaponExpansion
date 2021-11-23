local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

Mastery.Variables.Bonuses.ElementalWeaknessStatuses = {
	Air = "LLWEAPONEX_WEAKNESS_AIR",
	Chaos = "LLWEAPONEX_WEAKNESS_CHAOS",
	Earth = "LLWEAPONEX_WEAKNESS_EARTH",
	Fire = "LLWEAPONEX_WEAKNESS_FIRE",
	Poison = "LLWEAPONEX_WEAKNESS_POISON",
	Water = "LLWEAPONEX_WEAKNESS_WATER",
	Piercing = "LLWEAPONEX_WEAKNESS_PIERCING",
	Shadow = "LLWEAPONEX_WEAKNESS_SHADOW",
	--Physical = "LLWEAPONEX_WEAKNESS_PHYSICAL",
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

--Technically used for wands too
---@param character StatCharacter
---@return string
local function GetElementalWeakness(character)
	local paramText = ""
	local resistanceReductions = {}
	local resistanceCount = 0
	local weapon = character.MainWeapon
	if weapon ~= nil then
		local stats = weapon.DynamicStats
		for i,stat in pairs(stats) do
			if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
				local status = Mastery.Variables.Bonuses.ElementalWeaknessStatuses[stat.DamageType]
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
			resistanceText = resistanceText.."<img src='Icon_BulletPoint'>"..GameHelpers.GetResistanceText(stat, value)
			i = i + 1
			if i < resistanceCount then
				resistanceText = resistanceText .. "<br>"
			end
		end
		return resistanceText
	else
		return Text.MasteryBonusParams.ElementalWeakness_NoElement.Value
	end
end

if Vars.IsClient then
	TooltipHandler.SpecialParamFunctions.LLWEAPONEX_WeaponElementalWeakness = function(param, statCharacter)
		return GetElementalWeakness(statCharacter)
	end
end

MasteryBonusManager.AddRankBonuses(MasteryID.Staff, 1, {
	rb:Create("STAFF_ELEMENTAL_WEAKNESS", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Staff_ElementalWeakness", "<font color='#9BF0FF'>Targets hit become weak to your staff's element, gaining [Special:LLWEAPONEX_WeaponElementalWeakness] for [ExtraData:LLWEAPONEX_MB_Staff_ElementalWeaknessTurns] turn(s).</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local duration = GameHelpers.GetExtraData("LLWEAPONEX_MB_Staff_ElementalWeaknessTurns", 1) * 6.0
			if duration > 0 then
				for slot,v in pairs(GameHelpers.Item.FindTaggedEquipment(char, "LLWEAPONEX_Staff")) do
					local weapon = Ext.GetItem(v)
					if weapon and weapon.ItemType == "Weapon" then
						for i, stat in pairs(weapon.Stats.DynamicStats) do
							if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
								local status = Mastery.Variables.Bonuses.ElementalWeaknessStatuses[stat.DamageType]
								if status then
									ApplyStatus(data.Target, status, duration, 0, char)
								end
							end
						end
					end
				end
			end
		end
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Staff, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Staff, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Staff, 4, {
	
})
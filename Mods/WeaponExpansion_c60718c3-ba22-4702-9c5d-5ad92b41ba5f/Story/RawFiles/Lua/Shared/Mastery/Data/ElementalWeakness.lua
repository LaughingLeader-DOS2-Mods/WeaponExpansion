local elementalWeaknessStatuses = {
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
				local status = elementalWeaknessStatuses[stat.DamageType]
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
		paramText = string.gsub(paramText, "%[Special%]", resistanceText)
		return paramText
	else
		return rankHeader..GameHelpers.Tooltip.ReplacePlaceholders(Text.MasteryBonusParams.ElementalWeakness_NoElement.Value)
	end
end

local ELEMENTAL_WEAKNESS = {
	Param = LeaderLib.Classes.TranslatedString:Create("h0ee72b7cg5a84g4efcgb8e2g8a02113196e6","<font color='#9BF0FF'>Targets hit become weak to your weapon's element, gaining [Special] for [ExtraData:LLWEAPONEX_MB_Staff_ElementalWeaknessTurns] turn(s).</font>"),
	GetParam = GetElementalWeakness,
}

return ELEMENTAL_WEAKNESS
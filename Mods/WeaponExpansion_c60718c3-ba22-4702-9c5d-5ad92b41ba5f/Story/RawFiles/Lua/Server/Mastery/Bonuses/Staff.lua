
local elementalWeakness = {
	Air = "LLWEAPONEX_WEAKNESS_AIR",
	Chaos = "LLWEAPONEX_WEAKNESS_CHAOS",
	Earth = "LLWEAPONEX_WEAKNESS_EARTH",
	Fire = "LLWEAPONEX_WEAKNESS_FIRE",
	Poison = "LLWEAPONEX_WEAKNESS_POISON",
	Water = "LLWEAPONEX_WEAKNESS_WATER",
	Piercing = "LLWEAPONEX_WEAKNESS_PIERCING",
	--Shadow = "LLWEAPONEX_WEAKNESS_SHADOW",
	--Physical = "LLWEAPONEX_WEAKNESS_Physical",
}

MasteryBonusManager.RegisterSkillListener({"Shout_Whirlwind", "Shout_EnemyWhirlwind"}, {"ELEMENTAL_DEBUFF"}, function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		local duration = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_ElementalWeaknessTurns", 1) * 6.0
		local weaponuuid = CharacterGetEquippedWeapon(char)
		--local damageType = Ext.StatGetAttribute(NRD_ItemGetStatsId(weapon), "Damage Type")
		local weapon = Ext.GetItem(weaponuuid).Stats or nil
		if weapon ~= nil then
			local stats = weapon.DynamicStats
			if stats ~= nil then
				for i, stat in pairs(stats) do
					if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
						local status = elementalWeakness[stat.DamageType]
						if status ~= nil then
							ApplyStatus(hitData.Target, status, duration, 0, char)
						end
					end
				end
			end
		end
	end
end)
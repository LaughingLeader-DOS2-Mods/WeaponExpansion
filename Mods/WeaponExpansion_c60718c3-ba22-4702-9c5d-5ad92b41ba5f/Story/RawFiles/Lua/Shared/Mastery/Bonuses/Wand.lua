local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryRankBonus

MasteryBonusManager.AddRankBonuses(MasteryID.Wand, 1, {
	rb:Create("WAND_ELEMENTAL_WEAKNESS", {
		Skills = {"Target_LLWEAPONEX_BasicAttack"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Wand_ElementalWeakness", "<font color='#9BF0FF'>Targets hit by basic attacks become weak to your wand's element, gaining [Special:LLWEAPONEX_WeaponElementalWeakness] for [ExtraData:LLWEAPONEX_MB_Wand_ElementalWeaknessTurns] turn(s).</font>"),
	}):RegisterOnWeaponTagHit("LLWEAPONEX_Wand", function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
		if not isFromSkill then
			local duration = GameHelpers.GetExtraData("LLWEAPONEX_MB_Wand_ElementalWeaknessTurns", 1) * 6.0
			if duration > 0 then
				for slot,v in pairs(GameHelpers.Item.FindTaggedEquipment(source, "LLWEAPONEX_Wand")) do
					local weapon = Ext.GetItem(v)
					if weapon and weapon.ItemType == "Weapon" then
						for i, stat in pairs(weapon.Stats.DynamicStats) do
							if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
								local status = Mastery.Variables.Bonuses.ElementalWeaknessStatuses[stat.DamageType]
								if status then
									GameHelpers.Status.Apply(target, status, duration, false, source, 1.1)
								end
							end
						end
					end
				end
			end
		end
	end),

	rb:Create("WAND_BLOOD_EMPOWER", {
		Skills = {"Shout_FleshSacrifice", "Shout_EnemyFleshSacrifice"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Wand_FleshSacrifice", "<font color='#CC33FF'>Allies standing on <font color='#F13324'>blood surfaces</font> or in <font color='#F13324'>blood clouds</font> gain a <font color='#33FF00'>[Stats:Stats_LLWEAPONEX_BloodEmpowered:DamageBoost]% damage bonus</font>.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			local grid = Ext.GetAiGrid()
			for _,partyMember in pairs(GameHelpers.GetParty(char, true, true, true, false)) do
				local x,y,z = GetPosition(partyMember)
				if GameHelpers.Surface.HasSurface(x,z "Blood", 1.5, true, nil, grid) then
					ApplyStatus(partyMember, "LLWEAPONEX_BLOOD_EMPOWERED", 6.0, 0, char)
				end
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Wand, 2, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Wand, 3, {
	
})

MasteryBonusManager.AddRankBonuses(MasteryID.Wand, 4, {
	
})
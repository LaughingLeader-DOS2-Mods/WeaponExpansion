local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

MasteryBonusManager.AddRankBonuses(MasteryID.Bludgeon, 1, {
	rb:Create("BLUDGEON_RUSH_DIZZY", {
		Skills = MasteryBonusManager.Vars.RushSkills,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_Rush", "Become a thundering force of will when rushing, <font color='#FFCE58'>knocking enemies aside</font> with a <font color='#F19824'>[ExtraData:LLWEAPONEX_MB_Bludgeon_Rush_DizzyChance]% chance to apply Dizzy for [ExtraData:LLWEAPONEX_MB_Bludgeon_Rush_DizzyTurns] turn(s)</font>."),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local dizzyChance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_Rush_DizzyChance", 40.0)
			if dizzyChance > 0 then
				local dizzyDuration = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_Rush_DizzyTurns", 1.0) * 6.0
				if Ext.Random(0,100) <= dizzyChance then
					local forceDist = Ext.Random(2,4)
					GameHelpers.ForceMoveObject(char, data.Target, forceDist, skill)
					ApplyStatus(data.Target, "LLWEAPONEX_DIZZY", dizzyDuration, 0, char)
				end
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bludgeon, 2, {
	rb:Create("BLUDGEON_SUNDER", {
		Skills = {"Target_CripplingBlow","Target_EnemyCripplingBlow"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_CripplingBlow", "<font color='#F19824'>Sunder targets hit, reducing <font color='#AE9F95'>[Handle:h856999degd5aag435eg895fg50546f5a87f6:Maximum Physical Armour] by [Stats:Stats_LLWEAPONEX_MasteryBonus_Sunder:ArmorBoost]%</font> and <font color='#4197E2'>[Handle:h92acd36agc072g4ec8g9ca2g32fe6f89f375:Maximum Magic Armour] by [Stats:Stats_LLWEAPONEX_MasteryBonus_Sunder:MagicArmorBoost]%</font> for [ExtraData:LLWEAPONEX_MB_Bludgeon_SunderTurns] turn(s).</font>"),
		NamePrefix = "<font color='#F19824'>Sundering</font>"
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local duration = GameHelpers.GetExtraData("LLWEAPONEX_MB_Bludgeon_SunderTurns", 2) * 6.0
			if HasActiveStatus(data.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER") == 1 then
				local status = data.TargetObject:GetStatus("LLWEAPONEX_MASTERYBONUS_SUNDER")
				if status then
					status.CurrentLifeTime = duration
					status.RequestClientSync = true
				end
			else
				ApplyStatus(data.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER", duration, 0, char)
			end
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bludgeon, 3, {
	rb:Create("BLUDGEON_GROUNDQUAKE", {
		Skills = {"Cone_GroundSmash","Cone_EnemyGroundSmash"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Bludgeon_GroundSmashQuake", "A <font color='#F19824'>localized quake</font> is created where your weapon contacts the ground, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake] to enemies in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake:ExplodeRadius]m radius.</font>"),
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			local weaponRange = 1.5
			local weapons = GameHelpers.Item.FindTaggedEquipment(char, "LLWEAPONEX_Bludgeon")
			if #weapons > 0 then
				for i,v in pairs(weapons) do
					local range = Ext.GetItem(v).Stats.WeaponRange / 100
					if range > weaponRange then
						weaponRange = range + 0.25
					end
				end
			end
			local pos = GameHelpers.Math.GetForwardPosition(char, weaponRange)
			GameHelpers.Skill.Explode(pos, "Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake", char, {EnemiesOnly = true})
			-- TODO: Swap to a different effect
			local x,y,z = table.unpack(pos)
			PlayEffectAtPosition("LLWEAPONEX_FX_AnvilMace_Impact_01", x,y,z)
		end
	end),
})

MasteryBonusManager.AddRankBonuses(MasteryID.Bludgeon, 4, {
	
})
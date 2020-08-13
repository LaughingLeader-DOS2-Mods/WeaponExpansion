local rushSkills = {"Rush_BatteringRam", "Rush_BullRush", "Rush_EnemyBatteringRam", "Rush_EnemyBullRush"}

---@param hitData HitData
MasteryBonusManager.RegisterSkillListener(rushSkills, "RUSH_DIZZY", function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		local dizzyChance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_RushDizzyChance", 40.0)
		if dizzyChance > 0 then
			local dizzyDuration = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_RushDizzyTurns", 1.0) * 6.0
			if Ext.Random(0,100) <= dizzyChance then
				local forceDist = Ext.Random(2,4)
				local forceProjectile = "Projectile_LeaderLib_Force"..tostring(math.floor(forceDist))
				GameHelpers.ShootProjectile(char, hitData.Target, forceProjectile, true)
				ApplyStatus(hitData.Target, "LLWEAPONEX_DIZZY", dizzyDuration, 0, char)
			end
		end
	end
end)

---@param hitData HitData
MasteryBonusManager.RegisterSkillListener({"Target_CripplingBlow", "Target_EnemyCripplingBlow"}, "BLUDGEON_SUNDER", function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		local duration = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_CripplingBlow_SunderTurns", 2) * 6.0
		if HasActiveStatus(hitData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER") == 1 then
			local handle = NRD_StatusGetHandle(hitData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER")
			NRD_StatusSetReal(hitData.Target, handle, "CurrentLifeTime", duration)
		else
			ApplyStatus(hitData.Target, "LLWEAPONEX_MASTERYBONUS_SUNDER", duration, 0, char)
		end
	end
end)

---@param data SkillData
MasteryBonusManager.RegisterSkillListener({"Cone_GroundSmash","Cone_EnemyGroundSmash"}, "BLUDGEON_GROUNDQUAKE", function(bonuses, skill, char, state, data)
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
		GameHelpers.ExplodeProjectile(char, pos, "Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake")
		-- TODO: Swap to a different effect
		PlayEffectAtPosition("LLWEAPONEX_FX_AnvilMace_Impact_01", pos)
	end
end)
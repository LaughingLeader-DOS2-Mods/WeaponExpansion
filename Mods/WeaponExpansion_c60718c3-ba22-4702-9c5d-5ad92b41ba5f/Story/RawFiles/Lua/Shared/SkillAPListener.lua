local _ISCLIENT = Ext.IsClient()

local SwappedAPSkills = {
	Target_LLWEAPONEX_AnvilMace_GroundSmash = "Rush_LLWEAPONEX_AnvilMace_GroundSmash"
}


Ext.Events.GetSkillAPCost:Subscribe(function(e)
	if _ISCLIENT then
		local swapSkill = SwappedAPSkills[e.Skill.Name]
		if swapSkill ~= nil then
			local swapSkillStat = Ext.Stats.Get(swapSkill, nil, false)
			if swapSkillStat then
				local skillData = GameHelpers.Ext.CreateSkillTable(e.Skill.Name)
				skillData.ActionPoints = swapSkillStat.ActionPoints
				skillData.OverrideMinAP = swapSkillStat.OverrideMinAP
				local apMod = 0
				for i,status in pairs(e.Character.Character:GetStatuses()) do
					if Data.EngineStatus[status] ~= true then
						local potion = GameHelpers.Stats.GetAttribute(status, "StatsId", "") or ""
						if potion ~= "" then
							local apCostBoost = GameHelpers.Stats.GetAttribute(potion, "APCostBoost", 0)
							if apCostBoost ~= 0 then
								apMod = apMod + apCostBoost
							end
						end
					end
				end
				local ap,elementalAffinity = Game.Math.GetSkillAPCost(skillData, e.Character, e.AiGrid, e.Position, e.Radius)
				e.AP = math.max(0, ap+apMod)
				e.ElementalAffinity = elementalAffinity
			end
		end
	end
	if e.Skill.Name == "Projectile_LLWEAPONEX_HandCrossbow_Shoot" then
		if Skills.HasTaggedRuneBoost(e.Character, "LLWEAPONEX_HeavyAmmo", "_LLWEAPONEX_HandCrossbows") then
			local masteryLevel = Mastery.GetHighestMasteryRank(e.Character.Character, "LLWEAPONEX_HandCrossbow")
			if masteryLevel >= 3 then
				e.AP = 2
				e.ElementalAffinity = false
			else
				e.AP = math.min(3, e.Skill.ActionPoints*3)
				e.ElementalAffinity = false
			end
			e:StopPropagation()
		end
	end
end)
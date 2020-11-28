local EngineStatus = {
	CLIMBING = true,
	COMBAT = true,
	DYING = true,
	ENCUMBERED = true,
	EXPLODE = true,
	FLANKED = true,
	HEALING = true,
	HIT = true,
	INSURFACE = true,
	LEADERSHIP = true,
	LYING = true,
	MATERIAL = true,
	ROTATE = true,
	SHACKLES_OF_PAIN_CASTER = true,
	SITTING = true,
	SMELLY = true,
	SNEAKING = true,
	SOURCE_MUTED = true,
	SPIRIT = true,
	SPIRIT_VISION = true,
	SUMMONING = true,
	TELEPORT_FALLING = true,
	THROWN = true,
	TUTORIAL_BED = true,
	UNSHEATHED = true,
}

local SwappedAPSkills = {
	Target_LLWEAPONEX_AnvilMace_GroundSmash = "Rush_LLWEAPONEX_AnvilMace_GroundSmash"
}

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param grid AiGrid
--- @param position number[]
--- @param radius number
Ext.RegisterListener("GetSkillAPCost", function (skill, character, grid, position, radius)
	if Ext.IsClient() then
		local swapSkill = SwappedAPSkills[skill.Name]
		if swapSkill ~= nil then
			local skillData = GameHelpers.Ext.CreateSkillTable(skill.Name)
			skillData.ActionPoints = Ext.StatGetAttribute(swapSkill, "ActionPoints")
			skillData.OverrideMinAP = Ext.StatGetAttribute(swapSkill, "OverrideMinAP")

			local apMod = 0
			for i,status in pairs(character.Character:GetStatuses()) do
				if LeaderLib.Data.EngineStatus[status] ~= true then
					local potion = Ext.StatGetAttribute(status, "StatsId") or ""
					if potion ~= "" then
						local apCostBoost = Ext.StatGetAttribute(potion, "APCostBoost")
						if apCostBoost ~= nil then
							apMod = apMod + apCostBoost
						end
					end
				end
			end
			local ap,elementalAffinity = Game.Math.GetSkillAPCost(skillData, character, grid, position, radius)
			return math.max(0, ap+apMod),elementalAffinity
		end
	end
	if skill.Name == "Projectile_LLWEAPONEX_HandCrossbow_Shoot" then
		if Skills.HasTaggedRuneBoost(character, "LLWEAPONEX_HeavyAmmo", "_LLWEAPONEX_HandCrossbows") then
			local masteryLevel = Mastery.GetHighestMasteryRank(character.Character, "LLWEAPONEX_HandCrossbow")
			if masteryLevel >= 3 then
				return 2,false
			else
				return math.min(3, skill.ActionPoints*3),false
			end
		end
	end
end)
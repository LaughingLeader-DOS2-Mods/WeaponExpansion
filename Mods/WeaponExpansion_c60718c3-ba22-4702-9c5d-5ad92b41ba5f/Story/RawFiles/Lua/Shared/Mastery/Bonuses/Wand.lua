MasteryBonusManager.RegisterSkillListener({"Shout_FleshSacrifice", "Shout_EnemyFleshSacrifice"}, "BLOOD_EMPOWER", function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		---@return string[]
		local party = GameHelpers.GetParty(char, true, true, true, false)
		if #party > 0 then
			for i,partyMember in pairs(party) do
				local surfaceGround = GetSurfaceGroundAt(partyMember)
				local surfaceCloud = GetSurfaceCloudAt(partyMember)
				if string.find(surfaceCloud, "Blood") or string.find(surfaceCloud, "Blood") then
					ApplyStatus(partyMember, "LLWEAPONEX_BLOOD_EMPOWERED", 6.0, 0, char)
				end
			end
		end
	end
end)
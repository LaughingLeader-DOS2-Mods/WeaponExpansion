if Vars.DebugMode then
	--TeleportTo(CharacterGetHostCharacter(), Mods.WeaponExpansion.NPC.VendingMachine)
	Ext.RegisterConsoleCommand("weaponex_movealluniques", function()
		local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
		for k,v in pairs(Uniques) do
			if not v.IsLinkedItem then
				local b,err = xpcall(v.Transfer, debug.traceback, v, host)
				if not b then
					fprint(LOGLEVEL.ERROR, "Error transferring Unique [%s]:\n%s", k, err)
				end
			end
		end
	end)

	Ext.RegisterConsoleCommand("weaponex_returnalluniques", function()
		for i,v in pairs(Uniques) do
			v:Transfer(NPC.UniqueHoldingChest)
		end
		UniqueManager.FirstLoad = true
		UniqueManager.InitializeUniques()
	end)

	local function dumpRanks(...)
		--DB_LLWEAPONEX_WeaponMastery_RankNames("LLWEAPONEX_DualShields", 0, "<font color='#FDFFEA'>Beginner</font>")
		local rankNamesDB = Osi.DB_LLWEAPONEX_WeaponMastery_RankNames:Get(nil, nil, nil)
		local output = ""
		for i,entry in pairs(rankNamesDB) do
			--AddRank(masteryID, level, color, name)
			local masteryID = entry[1]
			local level = entry[2]
			local text = entry[3]
			local _,_,color = string.find(text, "color='(.+)'")
			local _,_,rankName = string.find(text, ">(.+)<")
			output = output .. string.format("AddRank(\"%s\", %s, \"%s\", \"%s\")\n", masteryID, level, color, rankName)
		end
		fprint(LOGLEVEL.TRACE, output)
	end
	Ext.RegisterConsoleCommand("dumpRanks", dumpRanks)

	Ext.RegisterConsoleCommand("llweaponex_tovendor", function(cmd)
		Osi.TeleportTo(CharacterGetHostCharacter(), NPC.VendingMachine)
	end)

	Ext.RegisterConsoleCommand("llweaponex_testmastery", function(cmd, masteryId, subcmd)
		local mastery = Masteries[masteryId]
		if not mastery then
			masteryId = string.lower(masteryId)
			for k,v in pairs(Masteries) do
				if string.find(string.lower(k), masteryId) or string.find(string.lower(v.Name.Value), masteryId) then
					mastery = v
					break
				end
			end
		end
		if mastery then
			local host = CharacterGetHostCharacter()
			if subcmd == "addskills" then
				for rank,rankData in pairs(mastery.RankBonuses) do
					for _,bonus in pairs(rankData.Bonuses) do
						if bonus.Skills then
							local enemySkill = nil
							local hasSkill = false
							for _,skill in pairs(bonus.Skills) do
								if string.find(skill, "Enemy") then
									enemySkill = skill
								elseif CharacterHasSkill(host, skill) == 1 then
									hasSkill = true
								end
							end
							if not hasSkill and enemySkill then
								CharacterAddSkill(host, enemySkill, 0)
							end
						end
					end
				end
			end
		end
	end)
end
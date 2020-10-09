local StartOneshotTimer = LeaderLib.StartOneshotTimer

if Ext.IsDeveloperMode() then
	Ext.RegisterConsoleCommand("weaponex_tagboost", function()
		local host = CharacterGetHostCharacter()
		local weapon = CharacterGetEquippedWeapon(host)
		if weapon ~= nil then
			ItemAddDeltaModifier(weapon, "Boost_LLWEAPONEX_Debug_Tags")
			CharacterUnequipItem(host, weapon)
			StartOneshotTimer("LLWEAPONEX_Debug_DeltamodTagTest", 500, function()
				CharacterEquipItem(host, weapon)
				print("Tagged:", IsTagged(host, "LLWEAPONEX_BOOST_TAG_TEST"))
	
				local item = Ext.GetItem(weapon)
				for i,v in pairs(item:GetDeltaMods()) do
					local status,err = xpcall(function()
						local deltamod = Ext.GetDeltaMod(v, "Weapon")
						for _,v2 in pairs(deltamod.Boosts) do
							local tags = Ext.StatGetAttribute(v2.Boost, "Tags")
							print(v2.Boost, tags)
						end
					end, debug.traceback)
					if not status then
						print(err)
					end
				end
			end)
		end
	end)
	
	Ext.RegisterConsoleCommand("weaponex_movealluniques", function()
		local host = CharacterGetHostCharacter()
		for i,v in pairs(Uniques) do
			local inventory = GetInventoryOwner(v.UUID)
			if StringHelpers.IsNullOrEmpty(inventory) or StringHelpers.IsNullOrEmpty(v.Owner) or v.Owner == NPC.VendingMachine then
				v:Transfer(host)
			end
		end
	end)
	
	Ext.RegisterConsoleCommand("weaponex_movealluniques", function()
		local host = CharacterGetHostCharacter()
		for i,v in pairs(Uniques) do
			local inventory = GetInventoryOwner(v.UUID)
			if StringHelpers.IsNullOrEmpty(inventory) or StringHelpers.IsNullOrEmpty(v.Owner) or v.Owner == NPC.VendingMachine then
				v:Transfer(host)
			end
		end
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
		print(output)
	end
	Ext.RegisterConsoleCommand("dumpRanks", dumpRanks);
end
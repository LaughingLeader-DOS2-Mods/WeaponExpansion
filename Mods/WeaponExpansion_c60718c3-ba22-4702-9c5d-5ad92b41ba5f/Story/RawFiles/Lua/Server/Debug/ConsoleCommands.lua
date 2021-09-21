if Vars.DebugMode then
	Ext.RegisterConsoleCommand("weaponex_tagboost", function()
		local host = CharacterGetHostCharacter()
		local weapon = CharacterGetEquippedWeapon(host)
		if weapon ~= nil then
			ItemAddDeltaModifier(weapon, "Boost_LLWEAPONEX_Debug_Tags")
			CharacterUnequipItem(host, weapon)
			Timer.StartOneshot("LLWEAPONEX_Debug_DeltamodTagTest", 500, function()
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
	--TeleportTo(CharacterGetHostCharacter(), Mods.WeaponExpansion.NPC.VendingMachine)
	Ext.RegisterConsoleCommand("weaponex_movealluniques", function()
		local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
		for i,v in pairs(Uniques) do
			if not v.IsLinkedItem then
				local owner = v.Owner
				if not v:IsReleasedFromOwner() or owner == NPC.VendingMachine or owner == NPC.UniqueHoldingChest then
					v:ReleaseFromOwner()
					v:Transfer(host)
				elseif not GameHelpers.Character.IsPlayer(owner) and owner ~= host then
					v:Transfer(host)
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
		print(output)
	end
	Ext.RegisterConsoleCommand("dumpRanks", dumpRanks)

	RegisterListener("BeforeLuaReset", function()
		Ext.BroadcastMessage("LLWEAPONEX_Debug_DestroyUI", "", nil)
	end)

	--Ext.GetStat(Ext.GetItem(CharacterGetEquippedWeapon(CharacterGetHostCharacter())).StatsId).Requirements = {[1]={Requirement="Finesse", Not=false, Param=0}}
	--Ext.BroadcastMessage("LLWEAPONEX_SetItemStats", Ext.JsonStringify({NetID=Ext.GetItem(CharacterGetEquippedWeapon(CharacterGetHostCharacter())).NetID, Stats={Requirements={[1]={Requirement="Finesse", Not=false, Param=0}}}}), nil)
	Ext.RegisterConsoleCommand("llweaponex_changereq", function(cmd)
		local item = Ext.GetItem(CharacterGetEquippedWeapon(CharacterGetHostCharacter()))
		local stat = Ext.GetStat(item.StatsId)
		stat.Requirements = {[1]={Requirement="Memory", Not=false, Param=0}}
		EquipmentManager.SyncItemStatChanges(item, {Requirements=stat.Requirements})
	end)
end

Ext.RegisterConsoleCommand("llweaponex_tovendor", function(cmd)
	TeleportTo(CharacterGetHostCharacter(), NPC.VendingMachine)
end)
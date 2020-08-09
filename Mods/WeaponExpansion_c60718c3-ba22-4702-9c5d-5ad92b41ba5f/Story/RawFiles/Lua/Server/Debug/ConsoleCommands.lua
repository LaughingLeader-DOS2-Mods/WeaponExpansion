local StartOneshotTimer = LeaderLib.StartOneshotTimer

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
					print(i,v,deltamod)
					for _,v2 in pairs(deltamod.Boosts) do
						print(v2, tags)
						local tags = Ext.StatGetAttribute(v2, "Tags")
					end
				end, debug.traceback)
				if not status then
					print(err)
				end
			end
		end)
	end
end)
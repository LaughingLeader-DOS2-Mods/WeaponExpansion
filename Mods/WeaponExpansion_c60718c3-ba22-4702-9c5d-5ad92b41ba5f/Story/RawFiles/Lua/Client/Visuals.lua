Ext.Events.CreateEquipmentVisualsRequest:Subscribe(function (e)
	local character = e.Character or Client:GetCharacter()
	if character then
		local visualResource = e.Params.VisualResourceID
		--LLWEAPONEX_Shield_NoVisual_24b9c4b1-a7bf-4d73-8df7-fd8ec1279b60
		if visualResource == "24b9c4b1-a7bf-4d73-8df7-fd8ec1279b60" then
			local combatShield = character:GetItemObjectBySlot("Weapon")
			if combatShield then
				local config = Config.Visuals.DualShields
				local template = GameHelpers.GetTemplate(combatShield)
				local data = config.CombatShieldTemplates[template]
				if data then
					if character:GetStatus("UNSHEATHED") then
						e.Params.AttachmentBoneName = config.CombatShieldBones.Unsheathed
						e.Params.VisualResourceID = data.Visual
					else
						e.Params.VisualResourceID = data.Sheathed or data.Visual
						e.Params.AttachmentBoneName = config.CombatShieldBones.Sheathed
					end
					e.Params.Weapon = true
				end
			end
		else
			-- if e.Params.Slot == "Weapon" then
			-- 	local item = character:GetItemObjectBySlot(e.Params.Slot)
			-- 	if item and item.Stats.IsTwoHanded and GameHelpers.ItemHasTag(item, "LLWEAPONEX_Katana") and not character:GetStatus("UNSHEATHED") then
			-- 		e.Params.AttachmentBoneName = "Dummy_Weapon_2H"
			-- 	end
			-- end
			--[[ if visualResource == "877ae976-2c28-4581-8c4f-fac0f28053d1" then
				if not character:GetStatus("UNSHEATHED") then
					e.Params.AttachmentBoneName = "Dummy_Root"
					e.Params.VisualResourceID = "cc2bdce4-9596-476c-80fc-b26fb791858f"
					e.Params.Armor = true
					e.Params.Weapon = false
					e.Params.InheritAnimations = true
				end
			end ]]
		end
	end
end)
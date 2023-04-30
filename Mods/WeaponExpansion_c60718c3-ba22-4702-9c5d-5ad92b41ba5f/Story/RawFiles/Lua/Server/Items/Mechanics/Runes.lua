Events.RuneChanged:Subscribe(function (e)
	if e.Inserted then
		local _TAGS = GameHelpers.GetItemTags(e.Item, true)
		for groupName,data in pairs(Config.Runes) do
			if data.RestrictTag and data.RootTemplates and data.RootTemplates[e.RuneTemplateGUID] then
				for _,tag in pairs(data.RestrictTag) do
					if not _TAGS[tag] then
						e:StopPropagation()
						local rune = Osi.ItemRemoveRune(e.CharacterGUID, e.ItemGUID, e.RuneSlot)
						if not StringHelpers.IsNullOrEmpty(rune) then
							Osi.ItemToInventory(rune, e.CharacterGUID, 1, 0, 0)
							if data.RestrictText and e.Character.CharacterControl then
								Osi.ShowNotification(e.CharacterGUID, tostring(data.RestrictText))
							end
							return
						end
					end
				end
			end
		end
	end
end)
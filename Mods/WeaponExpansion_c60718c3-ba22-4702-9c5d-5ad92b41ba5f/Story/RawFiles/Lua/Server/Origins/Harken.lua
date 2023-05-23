local anvilSwapPresets = {
	Knight = true,
	Inquisitor = true,
	Berserker = true,
	Barbarian = true,
}

function CC_SwapToHarkenAnvilPreview(uuid, preset)
	if anvilSwapPresets[preset] == true then
		local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(uuid)
		if mainhand and not mainhand.Global then
			Osi.ItemRemove(mainhand.MyGuid)
			local item = GameHelpers.Item.CreateItemByTemplate("85e2e75e-4333-425e-adc4-94474c3fc201", {
				GenerationStatsId = "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_Preview",
				StatsEntryName = "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_Preview",
				HasGeneratedStats = false,
				GenerationLevel = 1,
				StatsLevel = 1,
				IsIdentified = true,
			})
			if item then
				Osi.NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 0, 1)
			end
		end
	end
end

SkillManager.Register.Cast("Shout_LLWEAPONEX_UnrelentingRage", function (e)
	Osi.ClearTag(e.CharacterGUID, "LLWEAPONEX_EnemyDiedInCombat")
end)



local function HasHarkenVisualSet(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	return character ~= nil and character.RootTemplate ~= nil and character.RootTemplate.VisualTemplate == "b8ddbc75-415f-4894-afc2-2256e11b723d"
end

---@param uuid CharacterParam
function Harken_SetTattoosActive(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		local canSetVisualElement = Ext.Utils.GameVersion() ~= "v3.6.51.9303" and HasHarkenVisualSet(uuid)
		local needsSync = false
		local stat = Ext.Stats.Get("LLWEAPONEX_TATTOOS_STRENGTH", nil, false)

		if GameHelpers.Item.GetItemInSlot(character, "Breast") == nil and GameHelpers.Character.IsInCombat(character) then
			if stat.StatsId ~= "Stats_LLWEAPONEX_Tattoos_Strength_Active" then
				needsSync = true
				stat.StatsId = "Stats_LLWEAPONEX_Tattoos_Strength_Active"
				stat.Description = "LLWEAPONEX_TATTOOS_STRENGTH_ACTIVE_Description"
				stat.Icon = "LLWEAPONEX_Items_Armor_Unique_Tattoos_Magic_A"
			end
			if canSetVisualElement then
				Osi.CharacterSetVisualElement(character.MyGuid, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Magic_A")
			end
		else
			if stat.StatsId ~= "Stats_LLWEAPONEX_Tattoos_Strength" then
				needsSync = true
				stat.StatsId = "Stats_LLWEAPONEX_Tattoos_Strength"
				stat.Description = "LLWEAPONEX_TATTOOS_STRENGTH_Description"
				stat.Icon = "LLWEAPONEX_Items_Armor_Unique_Tattoos_A"
			end
			if canSetVisualElement then
				Osi.CharacterSetVisualElement(character.MyGuid, 3, "LLWEAPONEX_Dwarves_Male_Body_Naked_A_UpperBody_Tattoos_Normal_A")
			end
		end
		
		if needsSync then
			Ext.Stats.Sync("Stats_LLWEAPONEX_Tattoos_Strength", true)
			StatusManager.RemovePermanentStatus(character, "LLWEAPONEX_TATTOOS_STRENGTH")
			Timer.StartObjectTimer("LLWEAPONEX_Harken_ApplyTattooStatus", character, 250)
		end
	end
end

Ext.RegisterConsoleCommand("harkencrash", function ()
	local items = {"a4bf443f-5cb3-4271-bd10-b5002792f3fe","c7226c64-4270-4501-b78d-1d8cc31bb769","e8ac87e5-0fce-40f9-b9e2-ddbd742c91d0"}
	for i,v in pairs(items) do
		Osi.CharacterEquipItem(Origin.Harken, v)
	end
end)

Timer.Subscribe("LLWEAPONEX_Harken_ApplyTattooStatus", function (e)
	if e.Data.UUID then
		StatusManager.ApplyPermanentStatus(e.Data.UUID, "LLWEAPONEX_TATTOOS_STRENGTH")
	end
end)

Timer.Subscribe("LLWEAPONEX_Harken_CheckTattoos", function (e)
	if e.Data.Object then
		Harken_SetTattoosActive(e.Data.Object)
	end
end)

Events.ObjectEvent:Subscribe(function (e)
	Harken_SetTattoosActive(e.Objects[1])
end, {MatchArgs={Event="LLWEAPONEX_Harken_SetTattoosActive", EventType="StoryEvent"}})

Events.Initialized:Subscribe(function(e)
	if Osi.ObjectExists(Origin.Harken) == 1 then
		local harken = GameHelpers.GetCharacter(Origin.Harken)
		if harken and not GameHelpers.Status.IsActive(harken, "LLWEAPONEX_TATTOOS_STRENGTH") then
			StatusManager.ApplyPermanentStatus(harken, "LLWEAPONEX_TATTOOS_STRENGTH")
			Harken_SetTattoosActive(harken)
		end
	end
end)
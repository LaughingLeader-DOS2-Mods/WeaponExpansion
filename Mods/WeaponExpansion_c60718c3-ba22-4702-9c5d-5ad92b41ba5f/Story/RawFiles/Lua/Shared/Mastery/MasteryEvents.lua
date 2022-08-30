if Mastery.Events == nil then
	Mastery.Events = {}
end

---@class MasteryChangedEventArgs
---@field ID string|WeaponExpansionMasteryID The mastery ID
---@field Character EsvCharacter
---@field CharacterGUID GUID
---@field Enabled boolean
---@field IsPlayer boolean

---@type LeaderLibSubscribableEvent<MasteryChangedEventArgs>
Mastery.Events.MasteryChanged = Classes.SubscribableEvent:Create("MasteryChanged")

if not Ext.IsClient() then
	Ext.RegisterOsirisListener("CharacterDied", 1, "after", function(character)
		local uuid = GameHelpers.GetUUID(character)
		--Delete various vars here
		PersistentVars.MasteryMechanics.BludgeonShattering[uuid] = nil
	end)
end
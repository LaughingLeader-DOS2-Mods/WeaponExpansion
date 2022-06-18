if Mastery.Events == nil then
	Mastery.Events = {}
end

---@class MasteryChangedEventArgs
---@field ID string The mastery ID
---@field Character EsvCharacter
---@field Enabled boolean

---@type SubscribableEvent<MasteryChangedEventArgs>
Mastery.Events.MasteryChanged = Classes.SubscribableEvent:Create("MasteryChanged")

if not Ext.IsClient() then
	Ext.RegisterOsirisListener("CharacterDied", 1, "after", function(character)
		local uuid = GameHelpers.GetUUID(character)
		--Delete various vars here
		PersistentVars.MasteryMechanics.BludgeonShattering[uuid] = nil
	end)
end
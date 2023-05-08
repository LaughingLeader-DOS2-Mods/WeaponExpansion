if Mastery.Events == nil then
	Mastery.Events = {}
end

---@class MasteryChangedEventArgs
---@field Mastery string|WeaponExpansionMasteryID
---@field Character EsvCharacter
---@field CharacterGUID Guid
---@field Enabled boolean
---@field IsPlayer boolean

---@type LeaderLibSubscribableEvent<MasteryChangedEventArgs>
Mastery.Events.MasteryChanged = Classes.SubscribableEvent:Create("WeaponExpansion.MasteryChanged")

---@class MasteryLeveledUpEventArgs
---@field Mastery string|WeaponExpansionMasteryID
---@field Character EsvCharacter
---@field CharacterGUID Guid
---@field Last integer
---@field Current integer
---@field IsPlayer boolean

---@type LeaderLibSubscribableEvent<MasteryLeveledUpEventArgs>
Mastery.Events.MasteryLeveledUp = Classes.SubscribableEvent:Create("WeaponExpansion.MasteryLeveledUp")

if not Ext.IsClient() then
	Ext.RegisterOsirisListener("CharacterDied", 1, "after", function(character)
		local uuid = GameHelpers.GetUUID(character)
		--Delete various vars here
		PersistentVars.MasteryMechanics.BludgeonShattering[uuid] = nil
	end)
end
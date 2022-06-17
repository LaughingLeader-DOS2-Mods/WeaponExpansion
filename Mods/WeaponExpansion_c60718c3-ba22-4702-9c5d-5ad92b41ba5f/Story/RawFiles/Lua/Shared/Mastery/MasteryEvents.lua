if Mastery.Events == nil then
	Mastery.Events = {}
end

---@class MasteryChangedEventArgs
---@field ID string The mastery ID
---@field Character EsvCharacter
---@field Enabled boolean

---@type SubscribableEvent<MasteryChangedEventArgs>
Mastery.Events.MasteryChanged = Classes.SubscribableEvent:Create("MasteryChanged")


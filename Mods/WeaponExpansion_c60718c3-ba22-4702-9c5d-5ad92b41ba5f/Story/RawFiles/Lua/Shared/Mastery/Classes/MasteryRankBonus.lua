local isClient = Ext.IsClient()

---@class MasteryRankBonus
---@field ID string
---@field Skills string[]|string Optional skills associated.
---@field Statuses string[]|string Optional statuses associated.
---@field Tooltip TranslatedString
---@field NamePrefix TranslatedString|string|nil
local MasteryRankBonus = {
	Type = "MasteryRankBonus"
}

setmetatable(MasteryRankBonus, {
	__call = function(tbl, ...)
		return MasteryRankBonus:Create(...)
	end
})

---@class MasteryRankBonusParams:table
---@field Skills string[]|string
---@field Tooltip TranslatedString
---@field NamePrefix TranslatedString|string

---@param id string
---@param params MasteryRankBonusParams
---@return MasteryRankBonus
function MasteryRankBonus:Create(id, params)
	local this = {
		ID = id or ""
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, {
		__index = function(tbl,k)
			return MasteryRankBonus[k]
		end
	})
	return this
end

---@param callback WeaponExpansionMasterySkillListenerCallback
---@return MasteryRankBonus
function MasteryRankBonus:RegisterSkillListener(callback)
	if not isClient then
		MasteryBonusManager.RegisterSkillListener(self.Skills, self.ID, callback)
	end
	return self
end

---@param skillType string
---@param callback WeaponExpansionMasterySkillListenerCallback
---@return MasteryRankBonus
function MasteryRankBonus:RegisterSkillTypeListener(skillType, callback)
	if not isClient then
		MasteryBonusManager.RegisterSkillTypeListener(skillType, self.ID, callback)
	end
	return self
end

---@param event StatusEventID
---@param callback WeaponExpansionMasteryStatusListenerCallback
---@return MasteryRankBonus
function MasteryRankBonus:RegisterStatusListener(event, callback)
	if not isClient then
		MasteryBonusManager.RegisterStatusListener(self.Statuses, self.ID, callback)
	end
	return self
end

MasteryDataClasses.MasteryRankBonus = MasteryRankBonus
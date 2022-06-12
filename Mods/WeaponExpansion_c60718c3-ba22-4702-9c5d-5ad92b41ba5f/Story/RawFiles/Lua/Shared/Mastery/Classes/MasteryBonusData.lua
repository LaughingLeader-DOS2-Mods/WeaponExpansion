local isClient = Ext.IsClient()

---@alias MasteryBonusDataGetIsTooltipActiveCallback fun(self:MasteryBonusData, skillOrStatus:string, character:EclCharacter, tooltipType:MasteryBonusDataTooltipID, data:EsvStatus|StatEntrySkillData):boolean

---@class MasteryBonusDataParams
---@field ID string
---@field Skills string[] Optional skills associated.
---@field Statuses string[] Optional statuses associated.
---@field Tooltip TranslatedString
---@field StatusTooltip TranslatedString If set, statuses will use this for tooltips, instead of Tooltip.
---@field AllStatuses boolean
---@field AllSkills boolean
---@field DisableStatusTooltip boolean
---@field NamePrefix TranslatedString|string
---@field GetIsTooltipActive MasteryBonusDataGetIsTooltipActiveCallback Custom callback to determine if a bonus is "active" when a tooltip occurs.
---@field OnGetTooltip fun(self:MasteryBonusData, skillOrStatus:string, character:EclCharacter, tooltipType:MasteryBonusDataTooltipID):string|TranslatedString Custom callback to determine tooltip text dynamically.

---@alias MasteryBonusDataTooltipID string|'"skill"'|'"status"'|'"item"'
---@alias MasteryBonusCallbackBonuses MasteryActiveBonusesTable|MasteryActiveBonuses

---@alias WeaponExpansionSkillManagerAllStateCallback fun(self:MasteryBonusData, e:OnSkillStateAllEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerSkillEventCallback fun(self:MasteryBonusData, e:OnSkillStateSkillEventEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerHitCallback fun(self:MasteryBonusData, e:OnSkillStateHitEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerProjectileHitCallback fun(self:MasteryBonusData, e:OnSkillStateProjectileHitEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerProjectileShootCallback fun(self:MasteryBonusData, e:OnSkillStateProjectileShootEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionOnHealCallback fun(self:MasteryBonusData, e:OnHealEventArgs, bonuses:MasteryBonusCallbackBonuses)

---@class MasteryBonusDataRegistrationFunctions
---@field SkillUsed fun(callback:WeaponExpansionSkillManagerSkillEventCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusData
---@field SkillCast fun(callback:WeaponExpansionSkillManagerSkillEventCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusData
---@field SkillHit fun(callback:WeaponExpansionSkillManagerHitCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusData
---@field SkillProjectileHit fun(callback:WeaponExpansionSkillManagerProjectileHitCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusData
---@field SkillProjectileShoot fun(callback:WeaponExpansionSkillManagerProjectileShootCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusData
---@field OnHeal fun(callback:WeaponExpansionOnHealCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusData
---@field Test fun(operation:MasteryTestingTaskCallback):MasteryBonusData

local _INTERNALREG = {}

---@class MasteryBonusData:MasteryBonusDataParams
---@field Register MasteryBonusDataRegistrationFunctions
local MasteryBonusData = {
	Type = "MasteryBonusData",
	AllStatuses = false,
	AllSkills = false
}

setmetatable(MasteryBonusData, {
	__call = function(tbl, ...)
		return MasteryBonusData:Create(...)
	end,
	__tostring = function(tbl)
		return string.format("%s%s%s", 
		tbl.ID,
		tbl.Skills and "|Skills(" .. StringHelpers.Join(";",tbl.Skills) .. ")" or "",
		tbl.Statuses and "|Statuses(" .. StringHelpers.Join(";",tbl.Statuses) .. ")" or "")
	end
})

---@param id string
---@param params MasteryBonusDataParams
---@return MasteryBonusData
function MasteryBonusData:Create(id, params)
	local this = {
		ID = id or ""
	}
	local _private = {
		Register = {}
	}
	for k,v in pairs(_INTERNALREG) do
		_private.Register[k] = function(...)
			return v(this, ...)
		end
	end
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	if this.Skills and Common.TableHasEntry(this.Skills, "All") then
		this.AllSkills = true
	end
	if this.Statuses and Common.TableHasEntry(this.Statuses, "All") then
		this.AllStatuses = true
	end
	setmetatable(this, {
		__index = function(_,k)
			if _private[k] ~= nil then
				return _private[k]
			end
			return MasteryBonusData[k]
		end
	})
	return this
end

---Returns a default function for callback that checks for a tag specified, either on the status target or source.
---@return MasteryBonusDataGetIsTooltipActiveCallback
function MasteryBonusData.DefaultStatusTagCheck(tag, checkSource)
	if checkSource then
		return function(bonus, id, character, tooltipType, status)
			if tooltipType == "status" and status then
				local source = GameHelpers.TryGetObject(status.StatusSourceHandle)
				if source and GameHelpers.CharacterOrEquipmentHasTag(source, tag) or Vars.LeaderDebugMode then
					return true
				end
				return false
			end
			return true
		end
	else
		return function(bonus, id, character, tooltipType, status)
			if tooltipType == "status" then
				return GameHelpers.CharacterOrEquipmentHasTag(character, tag) or Vars.LeaderDebugMode
			end
			return true
		end
	end
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerSkillEventCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillUsed(self, callback, checkBonusOn)
	if not isClient then
		local wrapper = function (...) callback(self, ...) end
		MasteryBonusManager.RegisterNewSkillListener(SKILL_STATE.USED, self.Skills, self.ID, wrapper, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerSkillEventCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillCast(self, callback, checkBonusOn)
	if not isClient then
		local wrapper = function (...) callback(self, ...) end
		MasteryBonusManager.RegisterNewSkillListener(SKILL_STATE.CAST, self.Skills, self.ID, wrapper, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerHitCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillHit(self, callback, checkBonusOn)
	if not isClient then
		local wrapper = function (...) callback(self, ...) end
		MasteryBonusManager.RegisterNewSkillListener(SKILL_STATE.HIT, self.Skills, self.ID, wrapper, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerProjectileHitCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillProjectileHit(self, callback, checkBonusOn)
	if not isClient then
		local wrapper = function (...) callback(self, ...) end
		MasteryBonusManager.RegisterNewSkillListener(SKILL_STATE.PROJECTILEHIT, self.Skills, self.ID, wrapper, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerProjectileShootCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillProjectileShoot(self, callback, checkBonusOn)
	if not isClient then
		local wrapper = function (...) callback(self, ...) end
		MasteryBonusManager.RegisterNewSkillListener(SKILL_STATE.SHOOTPROJECTILE, self.Skills, self.ID, wrapper, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionOnHealCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.OnHeal(self, callback, checkBonusOn)
	if not isClient then
		local wrapper = function (...) callback(self, ...) end
		MasteryBonusManager.RegisterOnHealListener(self.ID, wrapper, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param operation MasteryTestingTaskCallback
---@return MasteryBonusData
function _INTERNALREG.Test(self, operation)
	if not isClient and Vars.DebugMode then
		MasteryTesting.RegisterTest(self.ID, operation, {Params={self}})
	end
	return self
end

---@param callback WeaponExpansionMasterySkillListenerCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterSkillListener(callback, checkBonusOn)
	if not isClient then
		MasteryBonusManager.RegisterSkillListener(self.Skills, self.ID, callback, checkBonusOn)
	end
	return self
end

---@param skillType string
---@param callback WeaponExpansionMasterySkillListenerCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterSkillTypeListener(skillType, callback,
	checkBonusOn)
	if not isClient then
		MasteryBonusManager.RegisterSkillTypeListener(skillType, self.ID, callback, checkBonusOn)
	end
	return self
end

---@param event StatusEventID
---@param callback MasteryBonusStatusCallback
---@param specificStatuses string|string[] If set, these statuses will be used instead of the Statuses table. Use this to show text in a specific set of statuses, but listen for a different status.
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterStatusListener(event, callback, 
	specificStatuses, checkBonusOn)
	if not isClient then
		MasteryBonusManager.RegisterStatusListener(event, specificStatuses or self.Statuses, self.ID, callback, checkBonusOn)
	end
	return self
end

---@param event StatusEventID
---@param callback MasteryBonusStatusCallback
---@param statusType string|string[]
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterStatusTypeListener(event, callback,
	statusType, checkBonusOn)
	if not isClient then
		MasteryBonusManager.RegisterStatusTypeListener(event, statusType, self.ID, callback, checkBonusOn)
	end
	return self
end

---@param callback MasteryBonusStatusBeforeAttemptCallback
---@param specificStatuses string|string[] If set, these statuses will be used instead of the Statuses table. Use this to show text in a specific set of statuses, but listen for a different status.
---@param skipBonusCheck boolean|nil
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterStatusBeforeAttemptListener(callback,
	specificStatuses, skipBonusCheck, checkBonusOn)
	if not isClient then
		MasteryBonusManager.RegisterStatusBeforeAttemptListener(specificStatuses or self.Statuses, self.ID,
		callback, skipBonusCheck, checkBonusOn)
	end
	return self
end

---@param callback BasicAttackOnHitCallback
---@param skipBonusCheck boolean|nil
---@param priority integer|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterOnHit(callback,
	skipBonusCheck, priority)
	if not isClient then
		if skipBonusCheck then
			AttackManager.OnHit.Register(callback, priority)
		else
			local wrapper = function(attacker, target, data, targetIsObject, skill)
				if MasteryBonusManager.HasMasteryBonus(attacker, self.ID) then
					local b,err = xpcall(callback, debug.traceback, attacker, target, data, targetIsObject, skill, self)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			AttackManager.OnHit.Register(wrapper, priority)
		end
	end
	return self
end

---@param tag string|string[]
---@param callback BasicAttackOnWeaponTagHitCallback
---@param skipBonusCheck boolean|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterOnWeaponTagHit(tag, callback, skipBonusCheck, priority)
	if not isClient then
		if skipBonusCheck then
			AttackManager.OnWeaponTagHit.Register(tag, callback, priority)
		else
			local wrapper = function(tag, attacker, target, data, targetIsObject, skill)
				if MasteryBonusManager.HasMasteryBonus(attacker, self.ID) then
					local b,err = xpcall(callback, debug.traceback, tag, attacker, target, data, targetIsObject, skill, self)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			AttackManager.OnWeaponTagHit.Register(tag, wrapper, priority)
		end
	end
	return self
end

---@param weaponType string|string[]
---@param callback BasicAttackOnWeaponTypeHitCallback
---@param skipBonusCheck boolean|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterOnWeaponTypeHit(weaponType, callback, skipBonusCheck, priority)
	if not isClient then
		if skipBonusCheck then
			AttackManager.OnWeaponTypeHit.Register(weaponType, callback, priority)
		else
			local wrapper = function(weaponType, attacker, target, data, targetIsObject, skill)
				if MasteryBonusManager.HasMasteryBonus(attacker, self.ID) then
					local b,err = xpcall(callback, debug.traceback, weaponType, attacker, target, data, targetIsObject, skill, self)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			AttackManager.OnWeaponTypeHit.Register(weaponType, wrapper, priority)
		end
	end
	return self
end

---@param event string
---@param arity integer
---@param state string
---@param callback function
---@param skipBonusCheck boolean|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterOsirisListener(event, arity, state, callback, skipBonusCheck)
	if not isClient then
		if skipBonusCheck then
			RegisterProtectedOsirisListener(event, arity, state, callback)
		else
			local wrapper = function(...)
				local params = {...}
				local hasMasteryBonus = false
				for i,v in pairs(params) do
					if type(v) == "string" and string.find(v, "-", 1, true) then
						if MasteryBonusManager.HasMasteryBonus(v, self.ID) then
							hasMasteryBonus = true
							break
						end
					end
				end
				if hasMasteryBonus then
					local b,err = xpcall(callback, debug.traceback, ...)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			RegisterProtectedOsirisListener(event, arity, state, wrapper)
		end
	end
	return self
end

---@param id string
---@param callback fun(uuid:UUID, id:string):void
---@param skipBonusCheck boolean
---@return MasteryBonusData
function MasteryBonusData:RegisterTurnEndedListener(id, callback, skipBonusCheck)
	if not isClient then
		if skipBonusCheck then
			Events.OnTurnEnded:Subscribe(callback, {MatchArgs={ID = id}})
		else
			local wrapper = function(character, turnId)
				if MasteryBonusManager.HasMasteryBonus(character, self.ID) then
					local b,err = xpcall(callback, debug.traceback, character, turnId)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			Events.OnTurnEnded:Subscribe(wrapper, {MatchArgs={ID = id}})
		end
	end
	return self
end

---@param callback fun(uuid:UUID):void
---@param skipBonusCheck boolean
---@return MasteryBonusData
function MasteryBonusData:RegisterTurnDelayedListener(callback, skipBonusCheck)
	if not isClient then
		if skipBonusCheck then
			RegisterListener("TurnDelayed", callback)
		else
			local wrapper = function(character)
				if MasteryBonusManager.HasMasteryBonus(character, self.ID) then
					local b,err = xpcall(callback, debug.traceback, character)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			RegisterListener("TurnDelayed", wrapper)
		end
	end
	return self
end

---@param id string
---@param callback TurnCounterCallback
---@param skipBonusCheck boolean
---@return MasteryBonusData
function MasteryBonusData:RegisterTurnCounterListener(id, callback, skipBonusCheck)
	if not isClient then
		if skipBonusCheck then
			TurnCounter.Subscribe(id, callback)
		else
			local wrapper = function(counterId, turnCount, lastTurn, finished, data)
				if data.Target and MasteryBonusManager.HasMasteryBonus(data.Target, self.ID) then
					local b,err = xpcall(callback, debug.traceback, counterId, turnCount, lastTurn, finished, data)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			TurnCounter.Subscribe(id, wrapper)
		end
	end
	return self
end

---@param this MasteryBonusData
---@param character EclCharacter
---@param skillOrStatus string
---@param tooltipType MasteryBonusDataTooltipID|nil
---@return TranslatedString|string
local function FinallyGetTooltipText(this, character, skillOrStatus, tooltipType, ...)
	if this.OnGetTooltip then
		local b,result = xpcall(this.OnGetTooltip, debug.traceback, this, skillOrStatus, character, tooltipType, ...)
		if b then
			if result then
				return result
			end
		else
			Ext.PrintError(result)
		end
	end
	if tooltipType == "status" then
		return this.StatusTooltip or this.Tooltip
	else
		return this.Tooltip
	end
end

---@param this MasteryBonusData
---@param character EclCharacter
---@param skillOrStatus string
---@param tooltipType MasteryBonusDataTooltipID|nil
---@return TranslatedString|string
local function TryGetTooltipText(this, character, skillOrStatus, tooltipType, ...)
	if this.GetIsTooltipActive then
		local b,result = xpcall(this.GetIsTooltipActive, debug.traceback, this, skillOrStatus, character, tooltipType, ...)
		if b then
			if result == false then
				return nil
			end
		else
			Ext.PrintError(result)
		end
	end

	if tooltipType == "status" then
		if not this.DisableStatusTooltip and (this.AllStatuses or Common.TableHasEntry(this.Statuses, skillOrStatus)) then
			return FinallyGetTooltipText(this, character, skillOrStatus, tooltipType, ...)
		end
	elseif tooltipType == "skill" or tooltipType == "item" then -- Items can have skill tooltip elements
		if this.AllSkills or Common.TableHasEntry(this.Skills, skillOrStatus) then
			return FinallyGetTooltipText(this, character, skillOrStatus, tooltipType, ...)
		end
	end
end

---@param character EclCharacter
---@param skillOrStatus string|nil
---@param tooltipType MasteryBonusDataTooltipID|nil
---@return TranslatedString
function MasteryBonusData:GetTooltipText(character, skillOrStatus, tooltipType, ...)
	local text = TryGetTooltipText(self, character, skillOrStatus, tooltipType, ...)
	if text then
		local t = type(text)
		if t == "string" then
			return text
		elseif t == "table" and text.Type == "TranslatedString" then
			return text.Value
		end
	end
	return nil
end

MasteryDataClasses.MasteryBonusData = MasteryBonusData
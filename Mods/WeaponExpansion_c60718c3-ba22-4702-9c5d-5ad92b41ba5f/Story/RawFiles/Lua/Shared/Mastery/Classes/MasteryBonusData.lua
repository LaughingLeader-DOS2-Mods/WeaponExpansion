local _ISCLIENT = Ext.IsClient()
local _type = type

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
---@field OnGetTooltip fun(self:MasteryBonusData, id:string, character:EclCharacter, tooltipType:MasteryBonusDataTooltipID, extraParam:EclStatus|EclItem|any):string|TranslatedString Custom callback to determine tooltip text dynamically.

---@alias MasteryBonusDataTooltipID string|'"skill"'|'"status"'|'"item"'
---@alias MasteryBonusCallbackBonuses MasteryActiveBonusesTable|MasteryActiveBonuses

---@alias WeaponExpansionSkillManagerAllStateCallback fun(self:MasteryBonusData, e:OnSkillStateAllEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerSkillEventCallback fun(self:MasteryBonusData, e:OnSkillStateSkillEventEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerSkillPreparedCallback fun(self:MasteryBonusData, e:OnSkillStatePrepareEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerSkillCancelCallback fun(self:MasteryBonusData, e:OnSkillStateCancelEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerHitCallback fun(self:MasteryBonusData, e:OnSkillStateHitEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerProjectileHitCallback fun(self:MasteryBonusData, e:OnSkillStateProjectileHitEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionSkillManagerProjectileShootCallback fun(self:MasteryBonusData, e:OnSkillStateProjectileShootEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias WeaponExpansionOnHealCallback fun(self:MasteryBonusData, e:OnHealEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@alias MasteryBonusOnTimerCallback fun(self:MasteryBonusData, e:TimerFinishedEventArgs, bonuses:MasteryBonusCallbackBonuses)

---@class MasteryBonusDataRegistrationFunctions
---@field __self MasteryBonusData
---@field SkillUsed fun(callback:WeaponExpansionSkillManagerSkillEventCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field SkillCast fun(callback:WeaponExpansionSkillManagerSkillEventCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field SkillPrepare fun(callback:WeaponExpansionSkillManagerSkillPreparedCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field SkillCancel fun(callback:WeaponExpansionSkillManagerSkillCancelCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field SkillHit fun(callback:WeaponExpansionSkillManagerHitCallback, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field SkillProjectileHit fun(callback:WeaponExpansionSkillManagerProjectileHitCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field SkillProjectileShoot fun(callback:WeaponExpansionSkillManagerProjectileShootCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field OnHit fun(callback:BasicAttackOnHitCallback, skipBonusCheck:boolean|nil, priority:integer|nil):MasteryBonusDataRegistrationFunctions
---@field OnWeaponTagHit fun(tag:string|string[], callback:fun(tag:string, attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData, targetIsObject:boolean, skill:StatEntrySkillData, self:MasteryBonusData), skipBonusCheck:boolean|nil):MasteryBonusDataRegistrationFunctions
---@field OnWeaponTypeHit fun(weaponType:string|string[], callback:BasicAttackOnWeaponTypeHitCallback, skipBonusCheck:boolean|nil):MasteryBonusDataRegistrationFunctions
---@field OnHeal fun(callback:WeaponExpansionOnHealCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field TimerFinished fun(id:string|string[], callback:MasteryBonusOnTimerCallback, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field Test fun(operation:MasteryTestingTaskCallback):MasteryBonusDataRegistrationFunctions

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
		Register = {
			__self = this
		}
	}
	for k,v in pairs(_INTERNALREG) do
		_private.Register[k] = function(...)
			v(this, ...)
			return _private.Register
		end
	end
	if _type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	if _type(this.Skills) == "table" and Common.TableHasEntry(this.Skills, "All") then
		this.AllSkills = true
	end
	if _type(this.Statuses) == "table" and Common.TableHasEntry(this.Statuses, "All") then
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
---@param callback WeaponExpansionSkillManagerSkillPreparedCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillPrepared(self, callback, checkBonusOn)
	if not _ISCLIENT then
		local skills = self.AllSkills and "All" or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.PREPARE, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerSkillCancelCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillCancel(self, callback, checkBonusOn)
	if not _ISCLIENT then
		local skills = self.AllSkills and "All" or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.CANCEL, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerSkillEventCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillUsed(self, callback, checkBonusOn)
	if not _ISCLIENT then
		local skills = self.AllSkills and "All" or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.USED, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerSkillEventCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillCast(self, callback, checkBonusOn)
	if not _ISCLIENT then
		local skills = self.AllSkills and "All" or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.CAST, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerHitCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificSkills string|string[]|nil
---@return MasteryBonusData
function _INTERNALREG.SkillHit(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills
		if not skills then
			skills = self.AllSkills and "All" or self.Skills
		end
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.HIT, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerProjectileHitCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillProjectileHit(self, callback, checkBonusOn)
	if not _ISCLIENT then
		local skills = self.AllSkills and "All" or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.PROJECTILEHIT, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionSkillManagerProjectileShootCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillProjectileShoot(self, callback, checkBonusOn)
	if not _ISCLIENT then
		local skills = self.AllSkills and "All" or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.SHOOTPROJECTILE, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback WeaponExpansionOnHealCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.OnHeal(self, callback, checkBonusOn, priority)
	if not _ISCLIENT then
		local wrapper = function (...) callback(self, ...) end
		MasteryBonusManager.RegisterOnHealListener(self.ID, wrapper, checkBonusOn, priority)
	end
	return self
end

---@param self MasteryBonusData
---@param id string|string[]
---@param callback MasteryBonusOnTimerCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.TimerFinished(self, id, callback, checkBonusOn)
	if not _ISCLIENT then
		checkBonusOn = checkBonusOn or "None"
		Timer.Subscribe(id, function (e)
			local bonuses = {HasBonus = function() end}
			if e.Data.UUID then
				bonuses = MasteryBonusManager._INTERNAL.GatherMasteryBonuses(checkBonusOn, e.Data.Object, e.Data.Target)
			end
			if checkBonusOn == "None" or MasteryBonusManager._INTERNAL.HasMatchedBonuses(bonuses, self.ID) then
				callback(self, e, bonuses)
			end
		end)
	end
	return self
end

---@param callback BasicAttackOnHitCallback
---@param skipBonusCheck boolean|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.OnHit(self, callback, skipBonusCheck, priority)
	if not _ISCLIENT then
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
---@param callback fun(tag:string, attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData, targetIsObject:boolean, skill:StatEntrySkillData, self:MasteryBonusData)
---@param skipBonusCheck boolean|nil
---@return MasteryBonusData
function _INTERNALREG.OnWeaponTagHit(self, tag, callback, skipBonusCheck, priority)
	if not _ISCLIENT then
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
function _INTERNALREG.OnWeaponTypeHit(self, weaponType, callback, skipBonusCheck, priority)
	if not _ISCLIENT then
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

---@param self MasteryBonusData
---@param operation MasteryTestingTaskCallback
---@return MasteryBonusData
function _INTERNALREG.Test(self, operation)
	if not _ISCLIENT and Vars.DebugMode then
		MasteryTesting.RegisterTest(self.ID, operation, {Params={self}})
	end
	return self
end

---@param callback WeaponExpansionMasterySkillListenerCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterSkillListener(callback, checkBonusOn)
	if not _ISCLIENT then
		local skills = self.AllSkills and "All" or self.Skills
		MasteryBonusManager.RegisterSkillListener(skills, self.ID, callback, checkBonusOn)
	end
	return self
end

---@param skillType string
---@param callback WeaponExpansionMasterySkillListenerCallback
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterSkillTypeListener(skillType, callback,
	checkBonusOn)
	if not _ISCLIENT then
		MasteryBonusManager.RegisterSkillTypeListener(skillType, self.ID, callback, checkBonusOn)
	end
	return self
end

---@param event StatusEventID
---@param callback MasteryBonusStatusCallback
---@param specificStatuses string|string[] If set, these statuses will be used instead of the Statuses table. Use this to show text in a specific set of statuses, but listen for a different status.
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterStatusListener(event, callback, specificStatuses, checkBonusOn)
	if not _ISCLIENT then
		MasteryBonusManager.RegisterStatusListener(event, specificStatuses or self.Statuses, self.ID, callback, checkBonusOn)
	end
	return self
end

---@param event StatusEventID
---@param callback MasteryBonusStatusCallback
---@param statusType string|string[]
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterStatusTypeListener(event, callback, statusType, checkBonusOn)
	if not _ISCLIENT then
		MasteryBonusManager.RegisterStatusTypeListener(event, statusType, self.ID, callback, checkBonusOn)
	end
	return self
end

---@param callback MasteryBonusStatusBeforeAttemptCallback
---@param specificStatuses string|string[] If set, these statuses will be used instead of the Statuses table. Use this to show text in a specific set of statuses, but listen for a different status.
---@param skipBonusCheck boolean|nil
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterStatusBeforeAttemptListener(callback, specificStatuses, skipBonusCheck, checkBonusOn)
	if not _ISCLIENT then
		MasteryBonusManager.RegisterStatusBeforeAttemptListener(specificStatuses or self.Statuses, self.ID,
		callback, skipBonusCheck, checkBonusOn)
	end
	return self
end

---@param callback BasicAttackOnHitCallback
---@param skipBonusCheck boolean|nil
---@param priority integer|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterOnHit(callback, skipBonusCheck, priority)
	if not _ISCLIENT then
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
---@param callback fun(tag:string, attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData, targetIsObject:boolean, skill:StatEntrySkillData, self:MasteryBonusData)
---@param skipBonusCheck boolean|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterOnWeaponTagHit(tag, callback, skipBonusCheck, priority)
	if not _ISCLIENT then
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
	if not _ISCLIENT then
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

---Allows conditionalizing when the listener can run, for specific osiris listeners.
---@alias MasteryBonusOsirisListenerCustomBonusCheck fun(...:string|number):boolean

---@param event string
---@param arity integer
---@param state string
---@param callback function
---@param skipBonusCheck boolean|nil
---@param canRunCallback MasteryBonusOsirisListenerCustomBonusCheck|nil
---@return MasteryBonusData
function MasteryBonusData:RegisterOsirisListener(event, arity, state, callback, skipBonusCheck, canRunCallback)
	if not _ISCLIENT then
		if skipBonusCheck then
			RegisterProtectedOsirisListener(event, arity, state, callback)
		else
			local wrapper = function(...)
				local params = {...}
				local hasMasteryBonus = false
				if canRunCallback then
					hasMasteryBonus = canRunCallback(...) == true
				else
					for i,v in pairs(params) do
						if _type(v) == "string" and string.find(v, "-", 1, true) and ObjectIsCharacter(v) == 1 then
							if MasteryBonusManager.HasMasteryBonus(v, self.ID) then
								hasMasteryBonus = true
								break
							end
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
	if not _ISCLIENT then
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
	if not _ISCLIENT then
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
	if not _ISCLIENT then
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
		local t = _type(text)
		if t == "string" then
			return text
		elseif t == "table" and text.Type == "TranslatedString" then
			return text.Value
		end
	end
	return nil
end

MasteryDataClasses.MasteryBonusData = MasteryBonusData
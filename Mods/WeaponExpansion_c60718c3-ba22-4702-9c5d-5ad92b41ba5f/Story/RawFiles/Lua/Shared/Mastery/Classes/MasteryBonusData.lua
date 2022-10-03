local _ISCLIENT = Ext.IsClient()
local _type = type

---@alias MasteryBonusDataGetIsTooltipActiveCallback fun(self:MasteryBonusData, skillOrStatus:string, character:EclCharacter, tooltipType:MasteryBonusDataTooltipID, data:EsvStatus|StatEntrySkillData):boolean

---@class MasteryBonusDataMasteryMenuSettings
---@field OnlyUseTable "Skill"|"Status" Make the rank text only show the affected statuses or skills tables.
---@field TooltipSkill FixedString|nil The skill ID to use for passive bonuses with "AllSkills" to specify a skill's text to display in the mastery menu.
---@field TooltipStatus FixedString|nil The status ID to use for passive bonuses with "AllSkills" to specify a skill's text to display in the mastery menu.

---@class MasteryBonusDataParams
---@field ID string
---@field Mastery string
---@field Rank integer
---@field IsPassive boolean
---@field Skills string[] Optional skills associated.
---@field Statuses string[] Optional statuses associated.
---@field Tooltip TranslatedString
---@field StatusTooltip TranslatedString If set, statuses will use this for tooltips, instead of Tooltip.
---@field AllStatuses boolean
---@field AllSkills boolean
---@field MasteryMenuSettings MasteryBonusDataMasteryMenuSettings
---@field DisableStatusTooltip boolean
---@field NamePrefix TranslatedString|string
---@field GetIsTooltipActive MasteryBonusDataGetIsTooltipActiveCallback Custom callback to determine if a bonus is "active" when a tooltip occurs.
---@field OnGetTooltip fun(self:MasteryBonusData, id:string, character:EclCharacter, tooltipType:MasteryBonusDataTooltipID, extraParam:EclStatus|EclItem|any):string|TranslatedString Custom callback to determine tooltip text dynamically.

---@alias MasteryBonusDataTooltipID string|'"skill"'|'"status"'|'"item"'
---@alias MasteryBonusCallbackBonuses MasteryActiveBonusesTable|MasteryActiveBonuses

---@alias MasteryBonusEventWrapper<T> fun(self:MasteryBonusData, e:T, bonuses:MasteryBonusCallbackBonuses)

---@class MasteryBonusDataRegistrationFunctions
---@field __self MasteryBonusData
---@field AnySkillState fun(callback:MasteryBonusEventWrapper<OnSkillStateAllEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field SkillUsed fun(callback:MasteryBonusEventWrapper<OnSkillStateSkillEventEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field SkillCast fun(callback:MasteryBonusEventWrapper<OnSkillStateSkillEventEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field SkillPrepare fun(callback:MasteryBonusEventWrapper<OnSkillStatePrepareEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field SkillCancel fun(callback:MasteryBonusEventWrapper<OnSkillStateCancelEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field SkillHit fun(callback:MasteryBonusEventWrapper<OnSkillStateHitEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field SkillProjectileHit fun(callback:MasteryBonusEventWrapper<OnSkillStateProjectileHitEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field SkillProjectileShoot fun(callback:MasteryBonusEventWrapper<OnSkillStateProjectileShootEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificSkills:string|string[]|nil):MasteryBonusDataRegistrationFunctions
---@field StatusBeforeAttempt fun(callback:MasteryBonusEventWrapper<OnStatusBeforeAttemptEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificStatuses:string|string[]|nil, isStatusType:boolean|nil):MasteryBonusDataRegistrationFunctions
---@field StatusAttempt fun(callback:MasteryBonusEventWrapper<OnStatusAttemptEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificStatuses:string|string[]|nil, isStatusType:boolean|nil):MasteryBonusDataRegistrationFunctions
---@field StatusApplied fun(callback:MasteryBonusEventWrapper<OnStatusAppliedEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificStatuses:string|string[]|nil, isStatusType:boolean|nil):MasteryBonusDataRegistrationFunctions
---@field StatusRemoved fun(callback:MasteryBonusEventWrapper<OnStatusRemovedEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil, specificStatuses:string|string[]|nil, isStatusType:boolean|nil):MasteryBonusDataRegistrationFunctions
---@field BasicAttackStart fun(callback:MasteryBonusEventWrapper<OnBasicAttackStartEventArgs>, skipBonusCheck:boolean|nil, checkBonusOn:MasteryBonusCheckTarget|nil, priority:integer|nil):MasteryBonusDataRegistrationFunctions
---@field WeaponHit fun(callback:MasteryBonusEventWrapper<OnWeaponHitEventArgs>, skipBonusCheck:boolean|nil, checkBonusOn:MasteryBonusCheckTarget|nil, priority:integer|nil):MasteryBonusDataRegistrationFunctions
---@field WeaponTagHit fun(tag:string|string[], callback:MasteryBonusEventWrapper<OnWeaponTagHitEventArgs>, skipBonusCheck:boolean|nil, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field WeaponTypeHit fun(weaponType:string|string[], callback:MasteryBonusEventWrapper<OnWeaponTypeHitEventArgs>, skipBonusCheck:boolean|nil, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field Healed fun(callback:MasteryBonusEventWrapper<OnHealEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field TimerFinished fun(id:string|string[], callback:MasteryBonusEventWrapper<TimerFinishedEventArgs>, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field TurnEnded fun(id:string|string[]|nil, callback:MasteryBonusEventWrapper<OnTurnEndedEventArgs>, skipBonusCheck:boolean|nil, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field TurnCounter fun(id:string|string[], callback:MasteryBonusEventWrapper<OnTurnCounterEventArgs>, skipBonusCheck:boolean|nil, checkBonusOn:MasteryBonusCheckTarget|nil):MasteryBonusDataRegistrationFunctions
---@field TurnDelayed fun(callback:MasteryBonusEventWrapper<TurnDelayedEventArgs>, skipBonusCheck:boolean|nil, priority:integer|nil):MasteryBonusDataRegistrationFunctions
---@field SpecialTooltipParam fun(id:string, callback:LeaderLibGetTextPlaceholderCallback):MasteryBonusDataRegistrationFunctions
---@field Osiris fun(event:string, arity:integer, state:string, callback:function, skipBonusCheck:boolean|nil, canRunCallback:MasteryBonusOsirisListenerCustomBonusCheck|nil):MasteryBonusDataRegistrationFunctions
---@field Test fun(operation:_LLWEAPONEX_BonusTestTaskCallback):MasteryBonusDataRegistrationFunctions

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

local _DefaultMasteryMenuSettings = {
	OnlyUseTable = "",
	TooltipSkill = "",
	TooltipStatus = "",
}

---@param id string
---@param params MasteryBonusDataParams
---@return MasteryBonusData
function MasteryBonusData:Create(id, params)
	local this = {
		ID = id or "",
		IsPassive = false,
		MasteryMenuSettings = {
			OnlyUseTable = "",
			TooltipSkill = "",
			TooltipStatus = "",
		}
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
			if k == "MasteryMenuSettings" then
				for k2,v2 in pairs(v) do
					this.MasteryMenuSettings[k2] = v2
				end
			else
				this[k] = v
			end
		end
	end
	setmetatable(this.MasteryMenuSettings, {
		__index = function (_,k)
			return _DefaultMasteryMenuSettings[k]
		end
	})
	if _type(this.Skills) == "table" and Common.TableHasEntry(this.Skills, "All") then
		this.AllSkills = true
	end
	if _type(this.Statuses) == "table" and Common.TableHasEntry(this.Statuses, "All") then
		this.AllStatuses = true
	end
	setmetatable(this, {
		---@param tbl MasteryBonusData
		__index = function(tbl,k)
			if _private[k] ~= nil then
				return _private[k]
			end
			return MasteryBonusData[k]
		end
	})
	return this
end


---@param bonusID string
---@param character CharacterParam|nil
local function IsMasteryBonusEnabled(bonusID, character)
	local characterId = GameHelpers.GetObjectID(character)
	if _ISCLIENT and not characterId then
		characterId = GameHelpers.GetNetID(Client:GetCharacter())
	end
	if characterId then
		local data = MasteryBonusManager._INTERNAL.CharacterDisabledBonuses[characterId]
		if data then
			return data[bonusID] ~= true
		end
	end
	return true
end

---@param character CharacterParam|nil
function MasteryBonusData:IsEnabled(character)
	return IsMasteryBonusEnabled(self.ID, character)
end

---Returns a default function for callback that checks for a tag specified, either on the status target or source.
---@return MasteryBonusDataGetIsTooltipActiveCallback
function MasteryBonusData.DefaultStatusTagCheck(tag, checkSource)
	if checkSource then
		return function(bonus, id, character, tooltipType, status)
			if tooltipType == "status" and status then
				local source = GameHelpers.TryGetObject(status.StatusSourceHandle)
				---@cast source EclCharacter
				if source and GameHelpers.Ext.ObjectIsCharacter(source)
				and GameHelpers.CharacterOrEquipmentHasTag(source, tag) then
					return true
				end
				return false
			end
			return true
		end
	else
		return function(bonus, id, character, tooltipType, status)
			if tooltipType == "status" then
				return GameHelpers.CharacterOrEquipmentHasTag(character, tag)
			end
			return true
		end
	end
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificSkills string|string[]|nil
---@return MasteryBonusData
function _INTERNALREG.AnySkillState(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills or (self.AllSkills and "All") or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(nil, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificSkills string|string[]|nil
---@return MasteryBonusData
function _INTERNALREG.SkillPrepare(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills or (self.AllSkills and "All") or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.PREPARE, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificSkills string|string[]|nil
---@return MasteryBonusData
function _INTERNALREG.SkillCancel(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills or (self.AllSkills and "All") or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.CANCEL, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificSkills string|string[]|nil
---@return MasteryBonusData
function _INTERNALREG.SkillUsed(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills or (self.AllSkills and "All") or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.USED, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@return MasteryBonusData
function _INTERNALREG.SkillCast(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills or (self.AllSkills and "All") or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.CAST, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificSkills string|string[]|nil
---@return MasteryBonusData
function _INTERNALREG.SkillHit(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills or (self.AllSkills and "All") or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.HIT, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificSkills string|string[]|nil
---@return MasteryBonusData
function _INTERNALREG.SkillProjectileHit(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills or (self.AllSkills and "All") or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.PROJECTILEHIT, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificSkills string|string[]|nil
---@return MasteryBonusData
function _INTERNALREG.SkillProjectileShoot(self, callback, checkBonusOn, specificSkills)
	if not _ISCLIENT then
		local skills = specificSkills or (self.AllSkills and "All") or self.Skills
		MasteryBonusManager.RegisterBonusSkillListener(SKILL_STATE.SHOOTPROJECTILE, skills, self, callback, checkBonusOn)
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.Healed(self, callback, checkBonusOn, priority)
	if not _ISCLIENT then
		local wrapper = function (...) callback(self, ...) end
		MasteryBonusManager.RegisterOnHealListener(self.ID, wrapper, checkBonusOn, priority)
	end
	return self
end

---@param self MasteryBonusData
---@param id string|string[]
---@param callback function
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

---@param self MasteryBonusData
---@param callback fun(self:MasteryBonusData, e:OnBasicAttackStartEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@param skipBonusCheck boolean|nil
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.BasicAttackStart(self, callback, skipBonusCheck, checkBonusOn, priority)
	if not _ISCLIENT then
		checkBonusOn = checkBonusOn or "Source"
		local bonuses = {HasBonus = function() end}
		if skipBonusCheck then
			Events.OnBasicAttackStart:Subscribe(function (e)
				callback(self, e, bonuses)
			end, {Priority=priority})
		else
			---@param e OnBasicAttackStartEventArgs
			local wrapper = function(e)
				bonuses = MasteryBonusManager._INTERNAL.GatherMasteryBonuses(self.ID, e.Attacker, e.TargetIsObject and e.Target or nil)
				if checkBonusOn == "None" or MasteryBonusManager._INTERNAL.HasMatchedBonuses(bonuses, self.ID) then
					callback(self, e, bonuses)
				end
			end
			Events.OnBasicAttackStart:Subscribe(wrapper, {Priority=priority})
		end
	end
	return self
end

---@param self MasteryBonusData
---@param callback fun(self:MasteryBonusData, e:OnWeaponHitEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@param skipBonusCheck boolean|nil
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.WeaponHit(self, callback, skipBonusCheck, checkBonusOn, priority)
	if not _ISCLIENT then
		checkBonusOn = checkBonusOn or "Source"
		local bonuses = {HasBonus = function() end}
		if skipBonusCheck then
			Events.OnWeaponHit:Subscribe(function (e)
				callback(self, e, bonuses)
			end, {Priority=priority})
		else
			---@param e OnWeaponHitEventArgs
			local wrapper = function(e)
				bonuses = MasteryBonusManager._INTERNAL.GatherMasteryBonuses(self.ID, e.Attacker, e.TargetIsObject and e.Target or nil)
				if checkBonusOn == "None" or MasteryBonusManager._INTERNAL.HasMatchedBonuses(bonuses, self.ID) then
					callback(self, e, bonuses)
				end
			end
			Events.OnWeaponHit:Subscribe(wrapper, {Priority=priority})
		end
	end
	return self
end

---@param self MasteryBonusData
---@param tag string|string[]
---@param callback fun(self:MasteryBonusData, e:OnWeaponTagHitEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@param skipBonusCheck boolean|nil
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.WeaponTagHit(self, tag, callback, skipBonusCheck, checkBonusOn, priority)
	if not _ISCLIENT then
		checkBonusOn = checkBonusOn or "Source"
		local t = _type(tag)
		if t == "table" then
			for _,tag in pairs(tag) do
				_INTERNALREG.WeaponTagHit(self, tag, callback, skipBonusCheck, checkBonusOn, priority)
			end
		else
			AttackManager.EnabledTags[tag] = true
			local bonuses = {HasBonus = function() end}
			if skipBonusCheck then
				Events.OnWeaponTagHit:Subscribe(function (e)
					callback(self, e, bonuses)
				end, {MatchArgs={Tag=tag}, Priority=priority})
			else
				---@param e OnWeaponTypeHitEventArgs
				local wrapper = function(e)
					bonuses = MasteryBonusManager._INTERNAL.GatherMasteryBonuses(self.ID, e.Attacker, e.TargetIsObject and e.Target or nil)
					if checkBonusOn == "None" or MasteryBonusManager._INTERNAL.HasMatchedBonuses(bonuses, self.ID) then
						callback(self, e, bonuses)
					end
				end
				Events.OnWeaponTagHit:Subscribe(wrapper, {MatchArgs={Tag=tag}, Priority=priority})
			end
		end
	end
	return self
end

---@param self MasteryBonusData
---@param weaponType string|string[]
---@param callback fun(self:MasteryBonusData, e:OnWeaponTypeHitEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@param skipBonusCheck boolean|nil
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.WeaponTypeHit(self, weaponType, callback, skipBonusCheck, checkBonusOn, priority)
	if not _ISCLIENT then
		checkBonusOn = checkBonusOn or "Source"
		local t = _type(weaponType)
		if t == "table" then
			for _,weaponType in pairs(weaponType) do
				_INTERNALREG.WeaponTypeHit(self, weaponType, callback, skipBonusCheck, checkBonusOn, priority)
			end
		else
			local bonuses = {HasBonus = function() end}
			if skipBonusCheck then
				Events.OnWeaponTypeHit:Subscribe(function (e)
					callback(self, e, bonuses)
				end, {MatchArgs={WeaponType=weaponType}, Priority=priority})
			else
				---@param e OnWeaponTypeHitEventArgs
				local wrapper = function(e)
					bonuses = MasteryBonusManager._INTERNAL.GatherMasteryBonuses(self.ID, e.Attacker, e.TargetIsObject and e.Target or nil)
					if checkBonusOn == "None" or MasteryBonusManager._INTERNAL.HasMatchedBonuses(bonuses, self.ID) then
						callback(self, e, bonuses)
					end
				end
				Events.OnWeaponTypeHit:Subscribe(wrapper, {MatchArgs={WeaponType=weaponType}, Priority=priority})
			end
		end
	end
	return self
end

---@param self MasteryBonusData
---@param id string
---@param callback LeaderLibGetTextPlaceholderCallback
---@return MasteryBonusData
function _INTERNALREG.SpecialTooltipParam(self, id, callback)
	if _ISCLIENT then
		TooltipParams.SpecialParamFunctions[id] = callback
	end
	return self
end

---@param self MasteryBonusData
---@param event string
---@param arity integer
---@param state string
---@param callback function
---@param skipBonusCheck boolean|nil
---@param canRunCallback MasteryBonusOsirisListenerCustomBonusCheck|nil
---@return MasteryBonusData
function _INTERNALREG.Osiris(self, event, arity, state, callback, skipBonusCheck, canRunCallback)
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
						Ext.Utils.PrintError(err)
					end
				end
			end
			RegisterProtectedOsirisListener(event, arity, state, wrapper)
		end
	end
	return self
end

---@param self MasteryBonusData
---@param id string|string[]|nil Optional ID, otherwise this will be called for every turn that ends.
---@param callback fun(self:MasteryBonusData, e:OnTurnEndedEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@param skipBonusCheck boolean|nil
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.TurnEnded(self, id, callback, skipBonusCheck, checkBonusOn, priority)
	if not _ISCLIENT then
		checkBonusOn = checkBonusOn or "Source"
		local t = _type(id)
		if t == "table" then
			for _,tag in pairs(id) do
				_INTERNALREG.TurnEnded(self, tag, callback, skipBonusCheck, checkBonusOn, priority)
			end
		else
			local matchArgs = nil
			if not StringHelpers.IsNullOrEmpty(id) then
				matchArgs = {ID=id}
			end
			local bonuses = {HasBonus = function() end}
			if skipBonusCheck then
				Events.OnTurnEnded:Subscribe(function (e)
					callback(self, e, bonuses)
				end, {MatchArgs={ID=id}, Priority=priority})
			else
				---@param e OnTurnEndedEventArgs
				local wrapper = function(e)
					bonuses = MasteryBonusManager._INTERNAL.GatherMasteryBonuses(self.ID, e.Object)
					if checkBonusOn == "None" or MasteryBonusManager._INTERNAL.HasMatchedBonuses(bonuses, self.ID) then
						callback(self, e, bonuses)
					end
				end
				Events.OnTurnEnded:Subscribe(wrapper, {matchArgs, Priority=priority})
			end
		end
	end
	return self
end

---@param self MasteryBonusData
---@param id string|string[] Turn Counter ID
---@param callback fun(self:MasteryBonusData, e:OnTurnCounterEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@param skipBonusCheck boolean|nil
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.TurnCounter(self, id, callback, skipBonusCheck, checkBonusOn, priority)
	if not _ISCLIENT then
		checkBonusOn = checkBonusOn or "Source"
		local t = _type(id)
		if t == "table" then
			for _,tag in pairs(id) do
				_INTERNALREG.TurnCounter(self, tag, callback, skipBonusCheck, checkBonusOn, priority)
			end
		else
			local bonuses = {HasBonus = function() end}
			if skipBonusCheck then
				TurnCounter.Subscribe(id, function (e)
					callback(self, e, bonuses)
				end)
			else
				---@param e OnTurnEndedEventArgs
				local wrapper = function(e)
					bonuses = MasteryBonusManager._INTERNAL.GatherMasteryBonuses(self.ID, e.Object)
					if checkBonusOn == "None" or MasteryBonusManager._INTERNAL.HasMatchedBonuses(bonuses, self.ID) then
						callback(self, e, bonuses)
					end
				end
				TurnCounter.Subscribe(id, wrapper)
			end
		end
	end
	return self
end

---@param self MasteryBonusData
---@param callback fun(self:MasteryBonusData, e:TurnDelayedEventArgs, bonuses:MasteryBonusCallbackBonuses)
---@param skipBonusCheck boolean|nil
---@param priority integer|nil
---@return MasteryBonusData
function _INTERNALREG.TurnDelayed(self, callback, skipBonusCheck, priority)
	if not _ISCLIENT then
		local eventOpts = nil
		if priority then
			eventOpts = {Priority=priority}
		end
		local bonuses = {HasBonus = function() end}
		if skipBonusCheck then
			Events.TurnDelayed:Subscribe(function (e)
				callback(self, e, bonuses)
			end, eventOpts)
		else
			---@param e TurnDelayedEventArgs
			local wrapper = function(e)
				bonuses = MasteryBonusManager._INTERNAL.GatherMasteryBonuses(self.ID, e.Character)
				if MasteryBonusManager._INTERNAL.HasMatchedBonuses(bonuses, self.ID) then
					callback(self, e, bonuses)
				end
			end
			Events.TurnDelayed(wrapper, eventOpts)
		end
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificStatuses string|string[]|nil
---@param isStatusType boolean|nil
---@return MasteryBonusData
function _INTERNALREG.StatusBeforeAttempt(self, callback, checkBonusOn, specificStatuses, isStatusType)
	if not _ISCLIENT then
		local statuses = specificStatuses or (self.AllStatuses and "All") or self.Statuses
		if not isStatusType then
			MasteryBonusManager.RegisterBonusStatusListener("BeforeAttempt", statuses, self, callback, checkBonusOn)
		else
			MasteryBonusManager.RegisterBonusStatusTypeListener("BeforeAttempt", statuses, self, callback, checkBonusOn)
		end
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificStatuses string|string[]|nil
---@param isStatusType boolean|nil
---@return MasteryBonusData
function _INTERNALREG.StatusAttempt(self, callback, checkBonusOn, specificStatuses, isStatusType)
	if not _ISCLIENT then
		local statuses = specificStatuses or (self.AllStatuses and "All") or self.Statuses
		if not isStatusType then
			MasteryBonusManager.RegisterBonusStatusListener("Attempt", statuses, self, callback, checkBonusOn)
		else
			MasteryBonusManager.RegisterBonusStatusTypeListener("Attempt", statuses, self, callback, checkBonusOn)
		end
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificStatuses string|string[]|nil
---@param isStatusType boolean|nil
---@return MasteryBonusData
function _INTERNALREG.StatusApplied(self, callback, checkBonusOn, specificStatuses, isStatusType)
	if not _ISCLIENT then
		local statuses = specificStatuses or (self.AllStatuses and "All") or self.Statuses
		if not isStatusType then
			MasteryBonusManager.RegisterBonusStatusListener("Applied", statuses, self, callback, checkBonusOn)
		else
			MasteryBonusManager.RegisterBonusStatusTypeListener("Applied", statuses, self, callback, checkBonusOn)
		end
	end
	return self
end

---@param self MasteryBonusData
---@param callback function
---@param checkBonusOn MasteryBonusCheckTarget|nil
---@param specificStatuses string|string[]|nil
---@param isStatusType boolean|nil
---@return MasteryBonusData
function _INTERNALREG.StatusRemoved(self, callback, checkBonusOn, specificStatuses, isStatusType)
	if not _ISCLIENT then
		checkBonusOn = checkBonusOn or "Target"
		local statuses = specificStatuses or (self.AllStatuses and "All") or self.Statuses
		if not isStatusType then
			MasteryBonusManager.RegisterBonusStatusListener("Removed", statuses, self, callback, checkBonusOn)
		else
			MasteryBonusManager.RegisterBonusStatusTypeListener("Removed", statuses, self, callback, checkBonusOn)
		end
	end
	return self
end

---@param self MasteryBonusData
---@param operation _LLWEAPONEX_BonusTestTaskCallback
---@return MasteryBonusData
function _INTERNALREG.Test(self, operation)
	if not _ISCLIENT and Vars.DebugMode then
		WeaponExTesting.RegisterBonusTest(self.ID, operation, {Params={self}})
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
						Ext.Utils.PrintError(err)
					end
				end
			end
			RegisterProtectedOsirisListener(event, arity, state, wrapper)
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
			Ext.Utils.PrintError(result)
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
			Ext.Utils.PrintError(result)
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
---@return string|nil
function MasteryBonusData:GetTooltipText(character, skillOrStatus, tooltipType, ...)
	local text = TryGetTooltipText(self, character, skillOrStatus, tooltipType, ...)
	if text then
		local t = _type(text)
		if t == "table" and text.Type == "TranslatedString" then
			---@cast text -TranslatedString
			text = text.Value
		end
		if not self:IsEnabled(character) then
			text = string.format("<font color='#DD3333'>[Disabled]</font><br><font color='#606060'>%s</font>", StringHelpers.StripFont(text))
		end
		return text
	end
	return nil
end

---@param character EclCharacter
---@param skillOrStatus string|nil
---@param tooltipType MasteryBonusDataTooltipID|nil
---@return string|nil
function MasteryBonusData:GetMenuTooltipText(character, skillOrStatus, tooltipType, ...)
	local text = nil
	if tooltipType == "status" then
		text = FinallyGetTooltipText(self, character, skillOrStatus, tooltipType, ...)
	elseif tooltipType == "skill" or tooltipType == "item" then
		text = FinallyGetTooltipText(self, character, skillOrStatus, tooltipType, ...)
	end
	if text then
		local t = _type(text)
		if t == "table" and text.Type == "TranslatedString" then
			---@cast text -TranslatedString
			text = text.Value
		end
		return text
	end
	return ""
end

MasteryDataClasses.MasteryBonusData = MasteryBonusData
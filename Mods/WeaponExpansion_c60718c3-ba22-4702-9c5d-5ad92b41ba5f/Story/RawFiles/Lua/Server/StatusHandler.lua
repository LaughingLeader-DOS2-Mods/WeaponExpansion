if StatusTurnHandler == nil then
	StatusTurnHandler = {}
end

local _listeners = {
    ---@type table<string, fun(target:string, status:string, source:string):void>
    EndTurnStatusRemoved = {},
}

local function CleanupForceAction(handle, target, x, y, z, timerStartFunc)
	if GetDistanceToPosition(target, x,y,z) < 1 then
		NRD_GameActionDestroy(handle)
		return true
	end
	return false
end

---@param source EsvCharacter
---@param target EsvGameObject|number[]
---@param item EsvItem
---@param targetPosition number[]
---@param radius number
---@param skill string|nil
function ApplyRuneExtraProperties(source, target, item, targetPosition, radius, skill)
	local targetIsObject = type(target) == "userdata"
	local runes = GameHelpers.Stats.GetRuneBoosts(item.Stats)
	if #runes > 0 then
		for _,runeEntry in pairs(runes) do
			for _,boost in pairs(runeEntry.Boosts) do
				if not StringHelpers.IsNullOrEmpty(boost) then
					if targetIsObject then
						Ext.PropertyList.ExecuteExtraPropertiesOnTarget(boost, "ExtraProperties", source, target, targetPosition, "Target", false, skill)
					else
						Ext.PropertyList.ExecuteExtraPropertiesOnPosition(boost, "ExtraProperties", source, targetPosition, radius, "AoE", false, skill)
					end
				end
			end
		end
	end
end

local function GrantMasteryExperienceFromStatus(target, status, source, statusType)
	if not StringHelpers.IsNullOrEmpty(source) and ObjectIsCharacter(source) == 1 and MasterySystem.CanGainExperience(source) then
		if status == "LLWEAPONEX_PISTOL_SHOOT_HIT" then
			MasterySystem.GrantWeaponSkillExperience(source, target, "LLWEAPONEX_Pistol")
		elseif status == "LLWEAPONEX_HANDCROSSBOW_HIT" then
			MasterySystem.GrantWeaponSkillExperience(source, target, "LLWEAPONEX_HandCrossbow")
		end
	end
end

RegisterStatusListener("Applied", "LLWEAPONEX_PISTOL_SHOOT_HIT", GrantMasteryExperienceFromStatus)
RegisterStatusListener("Applied", "LLWEAPONEX_HANDCROSSBOW_HIT", GrantMasteryExperienceFromStatus)

StatusManager.Register.Removed("All", function (target, status, source, statusType, statusEvent)
	StatusTurnHandler.RemoveTurnEndStatus(target, status, true)
end)

local function InvokeEndTurnStatusRemovedCallbacks(target, status, source)
	local callbacks = _listeners.EndTurnStatusRemoved[status]
	if callbacks ~= nil then
		for i,callback in pairs(callbacks) do
			local s,err = xpcall(callback, debug.traceback, target, status, source)
			if not s then
				Ext.PrintError(err)
			end
		end
	end
end

function StatusTurnHandler.RemoveTurnEndStatusesFromSource(fromSource, matchStatuses, targetUUID, wasRemoved)
	if targetUUID ~= nil then
		local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[targetUUID]
		if turnEndData ~= nil then
			for status,source in pairs(turnEndData) do
				if source == fromSource then
					if matchStatuses == nil or (matchStatuses ~= nil and type(matchStatuses) == "table" and matchStatuses[status] == true) then
						if wasRemoved == true or HasActiveStatus(targetUUID, status) == 1 then
							GameHelpers.Status.Remove(targetUUID, status)
							InvokeEndTurnStatusRemovedCallbacks(targetUUID, status, source)
						end
						turnEndData[status] = nil
					end
				end
			end
		end
	else
		for target,turnEndData in pairs(PersistentVars.StatusData.RemoveOnTurnEnd) do
			for status,source in pairs(turnEndData) do
				if source == fromSource then
					if matchStatuses == nil or (matchStatuses ~= nil and type(matchStatuses) == "table" and matchStatuses[status] == true) then
						if HasActiveStatus(target, status) == 1 then
							GameHelpers.Status.Remove(target, status)
							InvokeEndTurnStatusRemovedCallbacks(target, status, source)
						end
						turnEndData[status] = nil
					end
				end
			end
		end
	end
end

---@param activeTurnCharacter CharacterParam
---@param status string
---@param source CharacterParam|nil
---@param target CharacterParam|nil If set, the status will be removed from the target instead of the activeTurnCharacter.
function StatusTurnHandler.SaveTurnEndStatus(activeTurnCharacter, status, source, target)
	local activeGUID = GameHelpers.GetUUID(activeTurnCharacter)
	local sourceGUID = GameHelpers.GetUUID(source)
	local targetGUID = GameHelpers.GetUUID(target)
	if PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID] == nil then
		PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID] = {}
	end
	PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID][status] = {
		Source = sourceGUID or activeGUID,
		Target = targetGUID or activeGUID
	}
end

---@param activeTurnCharacter CharacterParam
function StatusTurnHandler.RemoveAllTurnEndStatuses(activeTurnCharacter)
	local activeGUID = GameHelpers.GetUUID(activeTurnCharacter)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID]
	if turnEndData ~= nil then
		for status,data in pairs(turnEndData) do
			if GameHelpers.ObjectExists(data.Target) then
				GameHelpers.Status.Remove(data.Target, status)
			end
			InvokeEndTurnStatusRemovedCallbacks(activeGUID, status, data.Source, data.Target)
		end
		PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID] = nil
	end
end

---@param activeTurnCharacter CharacterParam
---@param status string
---@param wasRemoved boolean
function StatusTurnHandler.RemoveTurnEndStatus(activeTurnCharacter, status, wasRemoved)
	local activeGUID = GameHelpers.GetUUID(activeTurnCharacter)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID]
	if turnEndData ~= nil then
		local data = turnEndData[status]
		if data then
			if GameHelpers.ObjectExists(data.Target) then
				GameHelpers.Status.Remove(data.Target, status)
			end
			InvokeEndTurnStatusRemovedCallbacks(activeGUID, status, data.Source, data.Target)
			PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID][status] = nil
			if not Common.TableHasAnyEntry(turnEndData) then
				PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID] = nil
			end
		end
	end
end

---@param activeTurnCharacter CharacterParam
function StatusTurnHandler.RemoveAllInactiveStatuses(activeTurnCharacter)
	local activeGUID = GameHelpers.GetUUID(activeTurnCharacter)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID]
	if turnEndData ~= nil then
		for status,data in pairs(turnEndData) do
			if not GameHelpers.ObjectExists(data.Target) or not GameHelpers.Status.IsActive(data.Target, status) then
				InvokeEndTurnStatusRemovedCallbacks(activeGUID, status, data.Source, data.Target)
				PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID][status] = nil
			end
		end
		if not Common.TableHasAnyEntry(turnEndData) then
			PersistentVars.StatusData.RemoveOnTurnEnd[activeGUID] = nil
		end
	end
end
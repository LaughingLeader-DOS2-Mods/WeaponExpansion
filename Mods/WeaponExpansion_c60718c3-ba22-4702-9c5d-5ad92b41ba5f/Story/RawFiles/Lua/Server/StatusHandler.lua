if StatusTurnHandler == nil then
	StatusTurnHandler = {}
end

local _listeners = {
    ---@type table<string, fun(target:string, status:string, source:string):void>
    EndTurnStatusRemoved = {},
    ---@type table<string, table<string, EquipmentChangedCallback>>
    EquipmentChanged = {
        Template = {},
        Tag = {}
    }
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

local function OnStatusRemoved(target, status, source, statusType)
	StatusTurnHandler.RemoveTurnEndStatus(target, status, true)
end

RegisterStatusListener("Removed", "All", OnStatusRemoved)

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

function StatusTurnHandler.SaveTurnEndStatus(uuid, status, source)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[uuid] or {}
	turnEndData[status] = source or ""
	PersistentVars.StatusData.RemoveOnTurnEnd[uuid] = turnEndData
end

function StatusTurnHandler.RemoveAllTurnEndStatuses(uuid)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[uuid]
	if turnEndData ~= nil then
		for status,source in pairs(turnEndData) do
			if HasActiveStatus(uuid, status) == 1 then
				GameHelpers.Status.Remove(uuid, status)
			end
			InvokeEndTurnStatusRemovedCallbacks(uuid, status, source)
		end
		PersistentVars.StatusData.RemoveOnTurnEnd[uuid] = nil
	end
end

function StatusTurnHandler.RemoveTurnEndStatus(uuid, status, wasRemoved)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[uuid]
	if turnEndData ~= nil then
		if type(status) == "table" then
			for i,v in pairs(status) do
				local source = turnEndData[v] or ""
				if HasActiveStatus(uuid, v) == 1 then
					GameHelpers.Status.Remove(uuid, v)
					InvokeEndTurnStatusRemovedCallbacks(uuid, v, source)
				end
				turnEndData[v] = nil
			end
		else
			local source = turnEndData[status] or ""
			if wasRemoved == true or HasActiveStatus(uuid, status) == 1 then
				GameHelpers.Status.Remove(uuid, status)
				InvokeEndTurnStatusRemovedCallbacks(uuid, status, source)
			end
			turnEndData[status] = nil
		end
		if not Common.TableHasAnyEntry(turnEndData) then
			PersistentVars.StatusData.RemoveOnTurnEnd[uuid] = nil
		end
	end
end

function StatusTurnHandler.RemoveAllInactiveStatuses(uuid)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[uuid]
	if turnEndData ~= nil then
		for status,source in pairs(turnEndData) do
			if HasActiveStatus(uuid, status) == 0 then
				InvokeEndTurnStatusRemovedCallbacks(uuid, status, source)
				turnEndData[status] = nil
			end
		end
		if not Common.TableHasAnyEntry(turnEndData) then
			PersistentVars.StatusData.RemoveOnTurnEnd[uuid] = nil
		end
	end
end
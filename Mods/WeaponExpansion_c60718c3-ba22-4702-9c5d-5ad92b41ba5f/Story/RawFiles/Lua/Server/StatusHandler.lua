if StatusManager == nil then
	StatusManager = {}
end

---@param target string
---@param source string
---@param item EsvItem
local function ApplyRuneExtraProperties(target, source, item)
	local runes = ExtenderHelpers.GetRuneBoosts(item.Stats)
	if #runes > 0 then
		for i,runeEntry in pairs(runes) do
			for attribute,boost in pairs(runeEntry.Boosts) do
				if boost ~= nil and boost ~= "" then
					---@type StatProperty[]
					local extraProperties = Ext.StatGetAttribute(boost, "ExtraProperties")
					if extraProperties ~= nil then
						for i,v in pairs(extraProperties) do
							if v.Type == "Status" then
								if v.StatusChance < 1.0 then
									local statusObject = {
										StatusId = v.Action,
										StatusType = Ext.StatGetAttribute(v.Action, "StatusType"),
										ForceStatus = false,
										StatusSourceHandle = source,
										TargetHandle = target,
										CanEnterChance = math.tointeger(v.StatusChance * 100)
									}
									local chance = Game.Math.StatusGetEnterChance(statusObject, true)
									local roll = Ext.Random(0,100)
									if roll <= chance then
										ApplyStatus(target, v.Action, v.Duration, 0, source)
									end
								else
									ApplyStatus(target, v.Action, v.Duration, 0, source)
								end
							elseif v.Type == "SurfaceTransform" then
								local x,y,z = GetPosition(target)
								TransformSurfaceAtPosition(x, y, z, v.Action, "Ground", 1.0, 6.0, source)
							end
						end
					end
				end
			end
		end
	end
end

local function OnStatusApplied(target, status, source)
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
	if not StringHelpers.IsNullOrEmpty(source) and ObjectIsCharacter(source) == 1 then
		if status == "LLWEAPONEX_PISTOL_SHOOT_HIT" then
			local items = GameHelpers.Item.FindTaggedEquipment(source, "LLWEAPONEX_Pistol")
			if items ~= nil then
				for slot,v in pairs(items) do
					ApplyRuneExtraProperties(target, source, Ext.GetItem(v))
				end
			end
			MasterySystem.GrantWeaponSkillExperience(source, target, "LLWEAPONEX_Pistol")
		elseif status == "LLWEAPONEX_HANDCROSSBOW_HIT" then
			local items = GameHelpers.Item.FindTaggedEquipment(source, "LLWEAPONEX_HandCrossbow")
			if items ~= nil then
				for slot,v in pairs(items) do
					ApplyRuneExtraProperties(target, source, Ext.GetItem(v))
				end
			end
			MasterySystem.GrantWeaponSkillExperience(source, target, "LLWEAPONEX_HandCrossbow")
		end
	end
	local callbacks = Listeners.StatusApplied[status]
	if callbacks ~= nil then
		for i,callback in pairs(callbacks) do
			local b,err = xpcall(callback, debug.traceback, target, status, source)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", OnStatusApplied)
RegisterProtectedOsirisListener("ItemStatusChange", 3, "after", OnStatusApplied)

local function OnNRDStatusAttempt(target, status, handle, source)
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
	local callbacks = Listeners.StatusAttempt[status]
	if callbacks ~= nil then
		for i,callback in pairs(callbacks) do
			local s,err = xpcall(callback, debug.traceback, target, status, handle, source)
			if not s then
				Ext.PrintError(err)
			end
		end
	end
end

RegisterProtectedOsirisListener("NRD_OnStatusAttempt", 4, "after", OnNRDStatusAttempt)

local function OnStatusRemoved(target, status, source)
	target = StringHelpers.GetUUID(target)
	local callbacks = Listeners.StatusRemoved[status]
	if callbacks ~= nil then
		for i,callback in pairs(callbacks) do
			local b,err = xpcall(callback, debug.traceback, target, status)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", OnStatusRemoved)
RegisterProtectedOsirisListener("ItemStatusRemoved", 3, "after", OnStatusRemoved)

function StatusManager.RemoveTurnEndStatusesFromSource(fromSource, matchStatuses, targetUUID)
	if targetUUID ~= nil then
		local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[targetUUID]
		if turnEndData ~= nil then
			for status,source in pairs(turnEndData) do
				if source == fromSource then
					if matchStatuses == nil or (matchStatuses ~= nil and type(matchStatuses) == "table" and matchStatuses[status] == true) then
						if HasActiveStatus(uuid, status) == 1 then
							RemoveStatus(uuid, status)
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
						if HasActiveStatus(uuid, status) == 1 then
							RemoveStatus(uuid, status)
						end
						turnEndData[status] = nil
					end
				end
			end
		end
	end
end

function StatusManager.RemoveAllTurnEndStatuses(uuid)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[uuid]
	if turnEndData ~= nil then
		for status,source in pairs(turnEndData) do
			if HasActiveStatus(uuid, status) == 1 then
				RemoveStatus(uuid, status)
			end
		end
		PersistentVars.StatusData.RemoveOnTurnEnd[uuid] = nil
	end
end

function StatusManager.SaveTurnEndStatus(uuid, status, source)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[uuid] or {}
	turnEndData[status] = source or ""
	PersistentVars.StatusData.RemoveOnTurnEnd[uuid] = turnEndData
end

function StatusManager.RemoveTurnEndStatus(uuid, status)
	local turnEndData = PersistentVars.StatusData.RemoveOnTurnEnd[uuid]
	if turnEndData ~= nil then
		turnEndData[status] = nil
		if not Common.TableHasAnyEntry(turnEndData) then
			PersistentVars.StatusData.RemoveOnTurnEnd[uuid] = nil
		end
	end
end
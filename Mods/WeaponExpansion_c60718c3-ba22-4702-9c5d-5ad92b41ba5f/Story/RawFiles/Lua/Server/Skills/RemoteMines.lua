RegisterStatusListener("StatusApplied", "LLWEAPONEX_REMOTEMINE_DETONATE", function(target, status, source)
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
	local items = nil
	if ObjectIsCharacter(target) == 1 then
		items = Ext.GetCharacter(target):GetInventoryItems()
	elseif ObjectIsItem(target) == 1 then
		items = Ext.GetItem(target):GetInventoryItems()
	end
	if items ~= nil and #items > 0 then
		local max = Ext.ExtraData.LLWEAPONEX_RemoteCharge_MaxInventoryDetonation or 5
		if Settings.Global:FlagEquals("LLWEAPONEX_RemoteChargeDetonationCountDisabled", true) then
			max = 99
		end
		if max > 0 then
			local totalDetonated = 0
			local mines = {}
			for _,uuid in pairs(items) do
				local item = Ext.GetItem(uuid)
				if item ~= nil and item:HasTag("LLWEAPONEX_RemoteMine") and not item:HasTag("LLWEAPONEX_RemoteMine_WorldOnly") then
					table.insert(mines, item.MyGuid)
				end
			end
			if #mines > 0 then
				if PersistentVars.SkillData.RemoteMineDetonation[target] == nil then
					PersistentVars.SkillData.RemoteMineDetonation[target] = {}
				end
				PersistentVars.SkillData.RemoteMineDetonation[target][source] = {
					Mines = mines,
					Remaining = max
				}
				LeaderLib.StartTimer("LLWEAPONEX_OnDetonationTimer", 50, source, target)
			end
		end
	end
end)

local function OnDetonationTimer(timerData)
	local source = timerData[1]
	local target = timerData[2]
	if source ~= nil and target ~= nil then
		local data = PersistentVars.SkillData.RemoteMineDetonation[target]
		if data ~= nil then
			local minesData = data[source]
			if minesData ~= nil then
				if minesData.Remaining > 0 then
					local detonated = false
					local attempts = 0
					while not detonated and attempts < 99 and #minesData.Mines > 0 do
						local rnd = Ext.Random(1,#minesData.Mines)
						local mineUUID = minesData.Mines[rnd]
						if mineUUID ~= nil then
							local item = Ext.GetItem(mineUUID)
							if item and item.Amount > 0 then
								local skill = GetVarFixedString(mineUUID, "LLWEAPONEX_Mine_Skill")
								if StringHelpers.IsNullOrEmpty(CharacterGetEquippedWeapon(source)) then
									skill = GetVarFixedString(mineUUID, "LLWEAPONEX_Mine_Skill_NoWeapon")
								end
								local x,y,z = GetPosition(target)
								minesData.Remaining = minesData.Remaining - 1
								GameHelpers.ExplodeProjectile(source, {x,y,z}, skill)
								detonated = true
								item.Amount = item.Amount - 1
								if item.Amount <= 0 then
									ItemDestroy(item.MyGuid)
								end
							else
								minesData.Mines[rnd] = nil
							end
						end
						attempts = attempts + 1
					end

					if minesData.Remaining > 0 and #minesData.Mines > 0 then
						LeaderLib.StartTimer("LLWEAPONEX_OnDetonationTimer", 500, source, target)
					else
						data[source] = nil
						if not Common.TableHasAnyEntry(data) then
							PersistentVars.SkillData.RemoteMineDetonation[target] = nil
						end
					end
				end
			end
		end
	end
end

OnTimerFinished["LLWEAPONEX_OnDetonationTimer"] = OnDetonationTimer
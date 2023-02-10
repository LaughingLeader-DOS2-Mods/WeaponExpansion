if not Vars.IsClient then
	EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
		GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_BANNER_RALLY_DIVINEORDER")
	end, {MatchArgs={Tag="LLWEAPONEX_Banner_DivineOrder_Equipped", Equipped=false}})

	EquipmentManager.Events.EquipmentChanged:Subscribe(function (e)
		GameHelpers.Status.Remove(e.Character, "LLWEAPONEX_BANNER_RALLY_DWARVES")
	end, {MatchArgs={Tag="LLWEAPONEX_Banner_LoneWolves_Equipped", Equipped=false}})

	--#region Rally

	SkillManager.Register.Cast({"Dome_LLWEAPONEX_Banner_Rally_DivineOrder", "Dome_LLWEAPONEX_Banner_Rally_Dwarves"}, function (e)
		local template = Config.Skill.BannerRally.Templates[e.Skill]
		if template then
			local x,y,z,b = GameHelpers.Grid.GetValidPositionInRadius(e.Data:GetSkillTargetPosition(), 8)
			local bannerGUID = nil
			if not b then
				bannerGUID = CreateItemTemplateAtPosition(template, 0, 0, 0)
			else
				bannerGUID = CreateItemTemplateAtPosition(template, x, y, z)
			end
			if not StringHelpers.IsNullOrEmpty(bannerGUID) then
				local banner = GameHelpers.GetItem(bannerGUID, "EsvItem")
				if banner then
					GameHelpers.Status.Apply(banner, "LLWEAPONEX_BANNER_RALLY_ITEM_LIFETIME", GameHelpers.GetExtraData("LLWEAPONEX_Banner_Rally_BannerFallbackDuration", 30), true, e.Character)
					PlayAnimation(bannerGUID, "spawn", "")
					GameHelpers.Utils.SetPosition(banner, {x,y,z})

					if PersistentVars.SkillData.RallyPartyMembers[e.CharacterGUID] == nil then
						PersistentVars.SkillData.RallyPartyMembers[e.CharacterGUID] = {}
					end

					local statusId = Config.Skill.BannerRally.SkillToStatus[e.Skill]

					if GameHelpers.Character.IsPlayer(e.Character) then
						for player in GameHelpers.Character.GetPlayers() do
							if player.MyGuid ~= e.CharacterGUID and CharacterIsInPartyWith(e.CharacterGUID, player.MyGuid) == 1 then
								CharacterAddSkill(player.MyGuid, "Shout_LLWEAPONEX_Banner_Rally_Teleport", 1)
								PersistentVars.SkillData.RallyPartyMembers[e.CharacterGUID][player.MyGuid] = statusId
							end
						end
					end
				end
			end
		end
	end)

	---@param target EsvCharacter
	---@return vec3|nil
	local function _GetRallyTeleportPosition(target)
		local rallyOwner = nil
		for ownerGUID,data in pairs(PersistentVars.SkillData.BannerRally) do
			local status = data.PartyMembers[target.MyGuid]
			if status then
				for bannerGUID,id in pairs(data.Banners) do
					if id == status then
						local pos = GameHelpers.Math.GetPosition(bannerGUID)
						if pos then
							data.PartyMembers[target.MyGuid] = nil
							return pos
						end
					end
				end
			end
		end
	end

	SkillManager.Register.Cast("Shout_LLWEAPONEX_Banner_Rally_Teleport", function (e)
		local pos = _GetRallyTeleportPosition(e.Character)
		if pos then
			CharacterRemoveSkill(e.CharacterGUID, "Shout_LLWEAPONEX_Banner_Rally_Teleport")
			local x,y,z,b = GameHelpers.Grid.GetValidPositionInRadius(pos, 6.0)
			if b then
				Osi.LeaderLib_Behavior_TeleportTo(e.CharacterGUID, x, y, z)
			end
		end
	end)

	StatusManager.Subscribe.Applied({"LLWEAPONEX_BANNER_RALLY_DIVINEORDER", "LLWEAPONEX_BANNER_RALLY_DWARVES"}, function (e)
		if not GameHelpers.Character.IsInCombat(e.Target) and e.Status.CurrentLifeTime > 0 then
			local bonus = GameHelpers.GetExtraData("LLWEAPONEX_Banner_Rally_OutOfCombatDurationBonus", 6.0)
			if bonus ~= 0 then
				e.Status.CurrentLifeTime = e.Status.CurrentLifeTime + bonus
				e.Status.RequestClientSync = true
			end
		end
	end)

	---@param owner GUID
	---@param statusId string
	local function _RemoveRallyData(owner, statusId)
		local data = PersistentVars.SkillData.BannerRally[owner]
		if data then
			for guid,id in pairs(data.Banners) do
				if ObjectExists(guid) == 1 then
					if id == statusId then
						PlayAnimation(guid, "destruction", "LLWEAPONEX_Banner_DestroyBanner")
						data.Banners[guid] = nil
					end
				else
					data.Banners[guid] = nil
				end
			end
			for guid,id in pairs(data.PartyMembers) do
				if ObjectExists(guid) == 1 then
					if id == statusId then
						CharacterRemoveSkill(guid, "Shout_LLWEAPONEX_Banner_Rally_Teleport")
						data.PartyMembers[guid] = nil
					end
				else
					data.PartyMembers[guid] = nil
				end
			end
			if not Common.TableHasAnyEntry(data.Banners) then
				PersistentVars.SkillData.BannerRally[owner] = nil
			end
		end
	end

	StatusManager.Subscribe.Removed({"LLWEAPONEX_BANNER_RALLY_DIVINEORDER", "LLWEAPONEX_BANNER_RALLY_DWARVES"}, function (e)
		_RemoveRallyData(e.TargetGUID, e.StatusId)
	end)

	Events.ObjectEvent:Subscribe(function (e)
		ItemRemove(e.ObjectGUID1)
	end, {MatchArgs={Event="LLWEAPONEX_Banner_DestroyBanner"}})

	--#endregion
end
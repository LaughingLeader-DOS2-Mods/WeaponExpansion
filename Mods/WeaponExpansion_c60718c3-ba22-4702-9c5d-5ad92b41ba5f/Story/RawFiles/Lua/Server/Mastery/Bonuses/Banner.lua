MasteryBonusManager.RegisterSkillListener({"Shout_Whirlwind", "Shout_EnemyWhirlwind"}, {"BANNER_VACUUM"}, function(bonuses, skill, char, state, hitData)
	if state == SKILL_STATE.HIT and hitData.Success then
		local worldBannerEntry = Osi.DB_LLWEAPONEX_Skills_Temp_RallyBanner:Get(char, nil)
		if worldBannerEntry ~= nil and #worldBannerEntry > 0 then
			local worldBanner = worldBannerEntry[1][2]
			if worldBanner ~= nil and ObjectExists(worldBanner) == 1 then
				local dist = GetDistanceTo(char, worldBanner)
				local skillDist = Ext.StatGetAttribute(skill, "AreaRadius")
				local addWeaponRange = Ext.StatGetAttribute(skill, "AddWeaponRange") == "Yes"
				if addWeaponRange then
					local banners = GameHelpers.Item.FindTaggedEquipment(char, "LLWEAPONEX_Banner")
					if #banners > 0 then
						local banner = Ext.GetItem(banners[1])
						skillDist = skillDist + (banner.Stats.WeaponRange/100)
					end
				end
				if dist <= skillDist + 0.5 then
					--NRD_CreateGameObjectMove([in](GUIDSTRING)_TargetObject, [in](REAL)_X, [in](REAL)_Y, [in](REAL)_Z, [in](STRING)_BeamEffectName, [in](CHARACTERGUID)_CasterCharacter, [out](INTEGER64)_GameActionHandle)
					local dist2 = GetDistanceTo(worldBanner, hitData.Target)
					local x,y,z = GetPosition(worldBanner)
					local tx,ty,tz = GetPosition(hitData.Target)
					local dir = math.sqrt((tx - x)^2 + (tz - z)^2)
					x = x + dir * (dist2 * 0.2)
					z = z + dir * (dist2 * 0.2)
					local fx,fy,fz = FindValidPosition(x,y,z, 4.0, hitData.Target)
					local handle = NRD_CreateGameObjectMove(hitData.Target, fx, fy, fz, "", char)
				end
			end
		end
	end
end)

---@param target string
---@param status string
---@param source string
---@param bonuses table<string,table<string,boolean>>
MasteryBonusManager.RegisterStatusListener("HARMONY", {"BANNER_RALLYINGCRY"}, function(target, status, source, bonuses)
	if (ObjectIsCharacter(target) == 1 
	and not GameHelpers.Status.IsDisabled(target, true)
	and NRD_ObjectHasStatusType(target, "DISARMED") == 0
	and bonuses.BANNER_RALLYINGCRY[source] == true) then
		local range = 1.0
		local weapon = CharacterGetEquippedWeapon(target)
		if weapon ~= nil then
			range = Ext.GetItem(weapon).Stats.WeaponRange / 100
		end

		local targets = {}

		for i,v in pairs(Ext.GetCharacter(target):GetNearbyCharacters(range)) do
			if CharacterIsEnemy(target, v) == 1 then
				table.insert(targets, v)
			end
		end

		if #targets > 0 then
			local attackTarget = Common.GetRandomTableEntry(targets)
			CharacterAttack(target, attackTarget)
		end
	end
end)
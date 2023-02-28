local _registeredStatusListener = false
--These statuses use two separate statuses in order to grant bonus weapon damage for two different types

---@param e OnStatusAppliedEventArgs
local function _OnComboBonusWeaponStatusApplied(e)
	local duration = e.Status.CurrentLifeTime
	if duration ~= 0 then
		GameHelpers.Status.Apply(e.Target, {e.StatusId .. "_DAMAGE1", e.StatusId .. "_DAMAGE2"}, duration, true, e.Source or e.Target)
	end
end

---@param e OnStatusRemovedEventArgs
local function _OnComboBonusWeaponStatusRemoved(e)
	GameHelpers.Status.Remove(e.Target, {e.StatusId .. "_DAMAGE1", e.StatusId .. "_DAMAGE2"})
end

Events.Initialized:Subscribe(function (e)
	if not _registeredStatusListener then
		StatusManager.Subscribe.Applied(Config.Runeblades.ComboBonusWeaponStatuses, _OnComboBonusWeaponStatusApplied)
		StatusManager.Subscribe.Removed(Config.Runeblades.ComboBonusWeaponStatuses, _OnComboBonusWeaponStatusRemoved)
		_registeredStatusListener = true
	end
end)

StatusManager.Subscribe.Removed("LLWEAPONEX_ACTIVATE_RUNEBLADE_CHAOS", function (e)
	--Set in LLWEAPONEX_Runeblades_Chaos.gameScript
	ObjectClearFlag(e.TargetGUID, "LLWEAPONEX_ChaosRune_PreserveSurface", 0)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_PREVENT_DOUBLE_HITS", function (e)
	Timer.StartObjectTimer("LLWEAPONEX_PreventDoubleHits_Clear", e.Target, 500)
end)

Timer.Subscribe("LLWEAPONEX_PreventDoubleHits_Clear", function (e)
	GameHelpers.Status.Remove(e.Data.UUID, "LLWEAPONEX_PREVENT_DOUBLE_HITS")
end)

--Prevents the heatburst sound effect from playing too often
local _justPlayedHeatBurstSpreadSound = false
local _justPlayedHeatBurstCheckSound = false

Config.Runeblades.HeatBurst = {
	SpreadSound = "Skill_Fire_Cast_AoE_Air_Fire",
	CheckSound = "Skill_Fire_Cast_Target_Totem_Fire",
}

StatusManager.Subscribe.Applied("LLWEAPONEX_RUNEBLADE_HEATBURST_SPREAD", function (e)
	if not _justPlayedHeatBurstSpreadSound then
		GameHelpers.Audio.PlaySound(e.Target, Config.Runeblades.HeatBurst.SpreadSound)
		_justPlayedHeatBurstSpreadSound = true
		Timer.StartOneshot("LLWEAPONEX_Runeblade_Heatburst_ClearSoundBlocking", 800, function (e)
			_justPlayedHeatBurstSpreadSound = false
		end)
	end
end)

Events.ObjectEvent:Subscribe(function (e)
	if not _justPlayedHeatBurstCheckSound then
		GameHelpers.Audio.PlaySound(e.ObjectGUID1, Config.Runeblades.HeatBurst.CheckSound)
		_justPlayedHeatBurstCheckSound = true
		Timer.StartOneshot("LLWEAPONEX_Runeblade_Heatburst_ClearSoundBlocking2", 800, function (e)
			_justPlayedHeatBurstCheckSound = false
		end)
	end
end, {MatchArgs={Event="LLWEAPONEX_Runeblade_PlayHeatBurstCheckSound"}})
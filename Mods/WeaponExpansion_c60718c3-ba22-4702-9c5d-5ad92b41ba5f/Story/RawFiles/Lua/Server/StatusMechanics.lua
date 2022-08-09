StatusManager.Subscribe.Applied("LLWEAPONEX_INTERRUPT", function (e)
	GameHelpers.Status.Apply(e.Target, {"MUTED", "DISARMED"}, 0, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_DIZZY", function (e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) and e.Target.AnimationOverride == "" then
		ObjectSetFlag(e.TargetGUID, "PlayAnim_Loop_stilldrunk", 0)
	end
end)

StatusManager.Subscribe.Removed("LLWEAPONEX_DIZZY", function (e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) and e.Target.AnimationOverride == "stilldrunk" then
		CharacterSetAnimationOverride(e.TargetGUID, "")
	end
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_WARCHARGE_BONUS", function (e)
	GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_WARCHARGE_DAMAGEBOOST", 12, false, e.Source)
end)

StatusManager.Subscribe.BeforeAttempt("BURNING", function (e)
	if e.Status.CurrentLifeTime > 0 and e.Target:GetStatus("LLWEAPONEX_TARRED") then
		e.Status.CurrentLifeTime = e.Status.CurrentLifeTime + 6.0
		e.Status.LifeTime = e.Status.LifeTime + 6.0
		e.Status.ForceStatus = true
	end
end)

SkillConfiguration.RandomGroundSurfaces = {"Fire", "Water", "WaterFrozen", "WaterElectrified", "Blood", "BloodFrozen", "BloodElectrified", "Poison", "Oil"}

StatusManager.Subscribe.Applied("LLWEAPONEX_RANDOM_SURFACE_SMALL", function (e)
	local surface = Common.GetRandomTableEntry(SkillConfiguration.RandomGroundSurfaces)
	GameHelpers.Surface.CreateSurface(e.Target.WorldPos, surface, 1.0, e.Status.CurrentLifeTime, e.Source and e.Source.Handle or nil, true)
	if e.Status.CurrentLifeTime ~= 0 then
		GameHelpers.Status.Remove(e.Target, "LLWEAPONEX_RANDOM_SURFACE_SMALL")
	end
end)

SkillConfiguration.TormentDebuff = {
	LastRollEnd = -1,
	---@type table<string, {Min:number, Max:number, Duration:number}>
	Statuses = {},
}

local function AddTormentDebuff(statusId, chance, duration)
	local min = SkillConfiguration.TormentDebuff.LastRollEnd+1
	local max = min + chance * 100
	SkillConfiguration.TormentDebuff.Statuses[statusId] = {Duration = duration or 0, Min=min, Max=max}
end

AddTormentDebuff("LLWEAPONEX_CORPSE_EXPLOSION_EXPLODE", 2)
AddTormentDebuff("CURSED", 5, 6)
AddTormentDebuff("ENTANGLED", 5, 6)
AddTormentDebuff("DISEASED", 5, 6)
AddTormentDebuff("SLOWED", 5, 6)
AddTormentDebuff("WEAK", 5, 6)
AddTormentDebuff("LLWEAPONEX_RUPTURE", 10, 0)
AddTormentDebuff("LLWEAPONEX_SOUL_BURN_PROC", 10, 0)
AddTormentDebuff("LLWEAPONEX_MAGIC_KNOCKDOWN_CHECK", 10, 6)
AddTormentDebuff("LLWEAPONEX_MAGIC_CRIPPLED_CHECK", 15, 6)
AddTormentDebuff("LLWEAPONEX_MAGIC_BLEEDING_CHECK", 28, 6)

StatusManager.Subscribe.Applied("LLWEAPONEX_TORMENT", function (e)
	local roll = Ext.Utils.Random(0, SkillConfiguration.TormentDebuff.LastRollEnd)
	for statusId,data in pairs(SkillConfiguration.TormentDebuff.Statuses) do
		if roll >= data.Min and roll <= data.Max then
			GameHelpers.Status.Apply(e.Target, statusId, data.Duration, e.Source)
		end
	end
end)

Events.OnBasicAttackStart:Subscribe(function (e)
	local concussion = e.Attacker:GetStatus("LLWEAPONEX_CONCUSSION")
	if concussion then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_Concussion_FumbleChance", 10)
		if chance > 0 and GameHelpers.Math.Roll(chance) then
			local source = nil
			if GameHelpers.IsValidHandle(concussion.StatusSourceHandle) then
				source = GameHelpers.TryGetObject(concussion.StatusSourceHandle)
			end
			GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_FUMBLE", 0, true, source)
		end
	end
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_FUMBLE", function (e)
	if GameHelpers.Ext.ObjectIsCharacter(e.Target) then
		GameHelpers.ClearActionQueue(e.TargetGUID, false)
		PlayAnimation(e.TargetGUID, "hit", "")
	end
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_DRAGONS_BANE", function (e)
	GameHelpers.Status.Apply(e.Target, "KNOCKED_DOWN", 6.0, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_MAGIC_KNOCKDOWN_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "KNOCKED_DOWN", e.Status.CurrentLifeTime, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_MAGIC_BLEEDING_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "BLEEDING", e.Status.CurrentLifeTime, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_MAGIC_CRIPPLED_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "CRIPPLED", e.Status.CurrentLifeTime, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_PHYSICAL_BLIND_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "BLIND", e.Status.CurrentLifeTime, true, e.Source)
end)

StatusManager.Subscribe.Applied("LLWEAPONEX_PHYSICAL_WEAK_CHECK", function (e)
	GameHelpers.Status.Apply(e.Target, "WEAK", e.Status.CurrentLifeTime, true, e.Source)
end)

--[[ StatusManager.Subscribe.Applied("LLWEAPONEX_BLOCK_HEALING", function (e)
	CharacterStatusText(e.Target, "LLWEAPONEX_StatusText_BlockedHealing")
	EffectManager.PlayEffect("LLWEAPONEX_FX_Status_BlockHealing_Hit_01", e.Target, {Bone="Dummy_FrontFX"})
end) ]]
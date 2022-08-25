if not Vars.IsClient then
	--region Scattershot Skill Bonus
	SkillManager.Register.Hit("Projectile_LLWEAPONEX_Blunderbuss_Scattershot", function (e)
		if e.Data.Success then
			local GUID = e.Data.Target
			if PersistentVars.SkillData.ScattershotHits[GUID] == nil then
				PersistentVars.SkillData.ScattershotHits[GUID] = {
					Hits = 0,
					Source = e.Character.MyGuid
				}
			end
			local hitCountData = PersistentVars.SkillData.ScattershotHits[GUID]
			hitCountData.Hits = hitCountData.Hits + 1
			--If all 3 bullets hit the same target, knock them back 4m and deal additional damage
			Timer.Cancel("LLWEAPONEX_Blunderbuss_ClearScattershotHits", e.Data.Target)
			if hitCountData.Hits == 3 then
				GameHelpers.Utils.ForceMoveObject(e.Data.TargetObject, {Source=e.Character, DistanceMultiplier = 4, Skill = e.Skill, ID = "LLWEAPONEX_Blunderbuss_ScattershotBonus"})
				PersistentVars.SkillData.ScattershotHits[GUID] = nil
			else
				Timer.StartObjectTimer("LLWEAPONEX_Blunderbuss_ClearScattershotHits", e.Data.Target, 500)
			end
		end
	end)

	Events.ForceMoveFinished:Subscribe(function (e)
		EffectManager.PlayEffectAt("LLWEAPONEX_FX_Skills_Scattershot_Impact_BonusDamage_01", e.Target.WorldPos)
		GameHelpers.Damage.ApplySkillDamage(e.Source, e.Target, "Projectile_LLWEAPONEX_Blunderbuss_Scattershot_BonusDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
	end, {MatchArgs={ID = "LLWEAPONEX_Blunderbuss_ScattershotBonus"}})

	Timer.Subscribe("LLWEAPONEX_Blunderbuss_ClearScattershotHits", function (e)
		if e.Data.UUID then
			PersistentVars.SkillData.ScattershotHits[e.Data.UUID] = nil
		end
	end)
	--endregion

	Events.OnWeaponTagHit:Subscribe(function (e)
		GameHelpers.Skill.Explode(e.Target, "Projectile_LLWEAPONEX_Blunderbuss_Shot_Explode", e.Attacker, {EnemiesOnly=true})
	end, {MatchArgs={Tag="LLWEAPONEX_Blunderbuss_Equipped"}})

	SkillManager.Register.Cast("Zone_LLWEAPONEX_Blunderbuss_Cannonball", function (e)
		local distMult = e.Data.SkillData.Range + 0.5
		local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(e.Character, distMult)
		Timer.StartObjectTimer("LLWEAPONEX_Cannonball_Explode", e.Character, 500, {Target=pos})
	end)

	Timer.Subscribe("LLWEAPONEX_Cannonball_Explode", function (e)
		if e.Data.UUID and e.Data.Target then
			GameHelpers.Skill.Explode(e.Data.Target, "Projectile_LLWEAPONEX_Blunderbuss_Cannonball_Explode", e.Data.Object)
		end
	end)

	Events.ObjectEvent:Subscribe(function (e)
		if not PersistentVars.SkillData.BlunderbussDuds[e.ObjectGUID1] then
			PersistentVars.SkillData.BlunderbussDuds[e.ObjectGUID1] = {}
		end
		table.insert(PersistentVars.SkillData.BlunderbussDuds[e.ObjectGUID1], e.ObjectGUID2)
		if Osi.LeaderLib_Combat_QRY_IsActiveTurn(e.ObjectGUID1) then
			SetTag(e.ObjectGUID1, "LLWEAPONEX_Dud_SkipNextTurnEnd")
		end
	end, {MatchArgs={EventType="CharacterItemEvent", Event="LLWEAPONEX_DelayedExplosive_Initialized"}})

	Events.ObjectEvent:Subscribe(function (e)
		local duds = PersistentVars.SkillData.BlunderbussDuds[e.ObjectGUID1]
		if duds then
			local nextDuds = {}
			local len = 0
			for _,v in pairs(duds) do
				if ObjectExists(v) == 1 and v ~= e.ObjectGUID2 then
					len = len + 1
					nextDuds[len] = v
				end
			end
			if len > 0 then
				PersistentVars.SkillData.BlunderbussDuds[e.ObjectGUID1] = nextDuds
			else
				PersistentVars.SkillData.BlunderbussDuds[e.ObjectGUID1] = nil
			end
		end
	end, {MatchArgs={EventType="CharacterItemEvent", Event="LLWEAPONEX_DelayedExplosive_Finished"}})

	Events.OnTurnEnded:Subscribe(function (e)
		if e.Object:HasTag("LLWEAPONEX_Dud_SkipNextTurnEnd") then
			ClearTag(e.ObjectGUID, "LLWEAPONEX_Dud_SkipNextTurnEnd")
		else
			local duds = PersistentVars.SkillData.BlunderbussDuds[e.ObjectGUID]
			if duds then
				for _,dud in pairs(duds) do
					SetStoryEvent(dud, "LLWEAPONEX_DelayedExplosive_Tick")
				end
			end
		end
	end)

	StatusManager.Subscribe.Removed("COMBAT", function (e)
		local duds = PersistentVars.SkillData.BlunderbussDuds[e.TargetGUID]
		if duds and not GameHelpers.Character.IsInCombat(e.Target) then
			for _,dud in pairs(duds) do
				SetStoryEvent(dud, "LLWEAPONEX_DelayedExplosive_Explode")
			end
			PersistentVars.SkillData.BlunderbussDuds[e.TargetGUID] = nil
		end
	end)
end

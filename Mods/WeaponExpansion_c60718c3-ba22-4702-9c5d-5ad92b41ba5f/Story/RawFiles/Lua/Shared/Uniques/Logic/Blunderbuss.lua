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
end

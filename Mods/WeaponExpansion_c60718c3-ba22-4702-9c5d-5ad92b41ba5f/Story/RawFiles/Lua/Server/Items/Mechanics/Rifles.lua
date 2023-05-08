StatusManager.Subscribe.Applied("LLWEAPONEX_FIREARM_SHOOT_EXPLOSION_FX", function (e)
	if e.Target then
		local _TAGS = GameHelpers.GetAllTags(e.Target, true, true)
		if _TAGS.LLWEAPONEX_Blunderbuss_Equipped then
			GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_FIREARM_SHOOT_EXPLOSION_FX_BLUNDERBUSS", 0, true)
		elseif _TAGS.LLWEAPONEX_Firearm_Equipped then
			GameHelpers.Status.Apply(e.Target, "LLWEAPONEX_FIREARM_SHOOT_EXPLOSION_FX_RIFLE", 0, true)
		end
	end
end)

SkillManager.Subscribe.Cast({"Projectile_LLWEAPONEX_Firearm_Multishot", "Projectile_LLWEAPONEX_Firearm_Multishot_Enemy"}, function (e)
	local variance = string.format("%s%s%s", e.CharacterGUID, Ext.Utils.MonotonicTime(), Ext.Utils.Random())
	Timer.StartUniqueTimer("LLWEAPONEX_Firearms_PlayBarrageExplosions", variance.."1", 150, {UUID=e.CharacterGUID})
	Timer.StartUniqueTimer("LLWEAPONEX_Firearms_PlayBarrageExplosions", variance.."2", 225, {UUID=e.CharacterGUID})
end)

Timer.Subscribe("LLWEAPONEX_Firearms_PlayBarrageExplosions", function (e)
	local object = e.Data.Object
	if object then
		local _TAGS = GameHelpers.GetAllTags(object, true, true)
		if _TAGS.LLWEAPONEX_Blunderbuss_Equipped then
			GameHelpers.Status.Apply(object, "LLWEAPONEX_FIREARM_SHOOT_EXPLOSION_FX_BLUNDERBUSS", 0, true)
		elseif _TAGS.LLWEAPONEX_Firearm_Equipped then
			GameHelpers.Status.Apply(object, "LLWEAPONEX_FIREARM_SHOOT_EXPLOSION_FX_RIFLE", 0, true)
		end
	end
end)

StatusManager.Subscribe.Applied({"LLWEAPONEX_BULLET_HIT", "LLWEAPONEX_PISTOL_SHOOT_HIT"}, function (e)
	PlayBulletImpact(e.Target)
end)
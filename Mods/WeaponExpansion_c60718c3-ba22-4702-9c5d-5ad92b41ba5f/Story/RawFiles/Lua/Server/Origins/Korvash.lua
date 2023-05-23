

SkillManager.Register.Cast("Projectile_LLWEAPONEX_DarkFireball", function (e)
	PersistentVars.SkillData.DarkFireballCount[e.CharacterGUID] = 0
	UpdateDarkFireballSkill(e.CharacterGUID)
	GameHelpers.Data.SyncSharedData(nil,nil,true)
end)

---@param charGUID Guid
function UpdateDarkFireballSkill(charGUID)
	local killCount = PersistentVars.SkillData.DarkFireballCount[charGUID] or 0
	if killCount >= 1 then
		local rangeBonusMult = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_RangePerCount", 1.0)
		local radiusBonusMult = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_ExplosionRadiusPerCount", 0.4)
		--local damageBonusMult = GameHelpers.GetExtraData("LLWEAPONEX_DarkFireball_DamageMultPerCount", 15)
	
		local nextRange = math.min(16, math.floor(6 + (rangeBonusMult * killCount)))
		local nextRadius = math.min(8, math.floor(1 + (radiusBonusMult * killCount)))
		--local nextDamageMult = math.min(200, math.floor(1 + (damageBonusMult * killCount)))
	
		local stat = Ext.Stats.Get("Projectile_LLWEAPONEX_DarkFireball", nil, false)
		stat.TargetRadius = nextRange
		stat.AreaRadius = nextRadius
		stat.ExplodeRadius = nextRadius
		--stat["Damage Multiplier"] = nextDamageMult

		if killCount >= 5 then
			stat.Template = "9bdb7e9c-02ce-4f2f-9e7b-463e3771af9c"
		end

		Ext.Stats.Sync("Projectile_LLWEAPONEX_DarkFireball", true)
	else
		local stat = Ext.Stats.Get("Projectile_LLWEAPONEX_DarkFireball", nil, false)
		--stat["Damage Multiplier"] = 10
		stat.TargetRadius = 6
		stat.AreaRadius = 1
		stat.ExplodeRadius = 1
		stat.Template = "f3af4ac9-567c-4ac8-8976-ec9c7bc8260d"
		Ext.Stats.Sync("Projectile_LLWEAPONEX_DarkFireball", true)
	end
end

Ext.RegisterConsoleCommand("llweaponex_darkfireballtest", function(call, amount)
	PersistentVars.SkillData.DarkFireballCount = tonumber(amount)
	UpdateDarkFireballSkill(Origin.Korvash)
	GameHelpers.Data.SyncSharedData(nil,nil,true)
end)


local LadyCMoreColors = "db07c22c-8935-3848-2366-7827b70c6030"

function CC_CheckKorvashColor(characterId)
	local character = GameHelpers.GetCharacter(characterId)
	if character then
		local id = GameHelpers.GetUserID(character)
		if id ~= nil and character.PlayerCustomData ~= nil then
			local nextColor = OriginColors.Korvash.Default
			if Ext.Mod.IsModLoaded(LadyCMoreColors) then
				nextColor = OriginColors.Korvash.LadyC
			end
			if character.PlayerCustomData.SkinColor ~= nextColor then
				GameHelpers.Net.PostToUser(id, "LLWEAPONEX_FixLizardSkin", "")
			end
		end
	end
end

Ext.RegisterNetListener("LLWEAPONEX_CC_CheckKorvashColor", function(cmd, characterId)
	CC_CheckKorvashColor(tonumber(characterId))
end)
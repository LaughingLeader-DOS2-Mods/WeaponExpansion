Skills.Params.OmniboltBonusDamageSkills = {"Projectile_SkyShot", "Projectile_EnemySkyShot"}

if not Vars.IsClient then
	local registeredListeners = false
	--Defer listener registration in case a mod changes Skills.Params.OmniboltBonusDamageSkills 
	Events.Initialized:Subscribe(function (e)
		if not registeredListeners and Common.TableLength(Skills.Params.OmniboltBonusDamageSkills) > 0 then
			SkillManager.Register.Hit(Skills.Params.OmniboltBonusDamageSkills, function(e)
				if e.Data.Success and GameHelpers.CharacterOrEquipmentHasTag(e.Character, "LLWEAPONEX_Omnibolt_Equipped") then
					GameHelpers.Skill.Explode(e.Data.Target, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", e.Character)
				end
			end)
			SkillManager.Register.Cast(Skills.Params.OmniboltBonusDamageSkills, function(e)
				if GameHelpers.CharacterOrEquipmentHasTag(e.Character, "LLWEAPONEX_Omnibolt_Equipped") then
					e.Data:ForEach(function (target, targetType, skillData)
						local x,y,z = GameHelpers.Math.GetPosition(target, true)
						Timer.Start("LLWEAPONEX_OmniboltLightningStrike", 750, {
							Pos={x,y,z},
							Source=e.Character.MyGuid
						})
					end, e.Data.TargetMode.All)
				end
			end)
			registeredListeners = true
		end
	end)

	Timer.Subscribe("LLWEAPONEX_OmniboltLightningStrike", function(e)
		if e.Data.Object and e.Data.Position then
			GameHelpers.Skill.Explode(e.Data.Position, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", e.Data.Object, {EnemiesOnly = true})
		end
	end)

	AttackManager.OnWeaponTagHit.Register("LLWEAPONEX_Omnibolt_Equipped", function(tag, attacker, target, data, targetIsObject, skill)
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_Omnibolt_LightningChance", 70, true)
		if chance >= 100 then
			GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", attacker, {EnemiesOnly = true})
		elseif chance > 0 and GameHelpers.Math.Roll(chance) then
			GameHelpers.Skill.Explode(target, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", attacker, {EnemiesOnly = true})
		end
	end, false)
else
	--Tags.ExtraProperties.LLWEAPONEX_Omnibolt_Equipped = true
	local bonusText = Classes.TranslatedString:CreateFromKey("LLWEAPONEX_Omnibolt_Equipped_SkillBonus", "<font color='#C7A758'>[Key:WPN_UNIQUE_LLWEAPONEX_Greatbow_Lightning_A_DisplayName:Omnibolt, Heaven's Wrath]</font><br><font color='#33FF22'>Summon a lightning strike, dealing an additional [SkillDamage:Projectile_LLWEAPONEX_Greatbow_LightningStrike].<font>", {AutoReplacePlaceholders = false})
	Tags.SkillBonusText.LLWEAPONEX_Omnibolt_Equipped = function(character, skill, tag, tooltip)
		if TableHelpers.HasValue(Skills.Params.OmniboltBonusDamageSkills, skill) then
			return bonusText.Value
		end
	end
end
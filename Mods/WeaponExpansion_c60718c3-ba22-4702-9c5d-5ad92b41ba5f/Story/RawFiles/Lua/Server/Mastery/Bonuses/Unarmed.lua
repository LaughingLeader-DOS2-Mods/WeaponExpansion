MasteryBonusManager.RegisterSkillListener({"Target_PetrifyingTouch", "Target_EnemyPetrifyingTouch"}, {"PETRIFYING_SLAM"}, function(bonuses, skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		PlayEffect(char, "RS3_FX_Char_Creatures_Condor_Cast_Warrior_01", "Dummy_R_HandFX")
		PlayEffect(char, "RS3_FX_Char_Creatures_Condor_Cast_Warrior_01", "Dummy_L_HandFX")
	elseif state == SKILL_STATE.HIT and skillData.Success then
		GameHelpers.ExplodeProjectile(char, skillData.Target, "Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage")
		local forceDistance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_PetrifyingTouch_KnockbackDistance", 4.0)
		if forceDistance > 0 then
			local character = Ext.GetCharacter(char)
			local x,y,z = GetPosition(skillData.Target)
			PlayEffectAtPosition("RS3_FX_Skills_Void_Power_Attack_Impact_01",x,y,z)
			PlayEffect(skillData.Target, "RS3_FX_Skills_Warrior_Impact_Weapon_01", "Dummy_BodyFX")
			local pos = character.Stats.Position
			local rot = character.Stats.Rotation
			local forwardVector = {
				-rot[7] * forceDistance,
				0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
				-rot[9] * forceDistance,
			}
			x = pos[1] + forwardVector[1]
			--y = pos[2] + forwardVector[2]
			z = pos[3] + forwardVector[3]
			local tx,ty,tz = FindValidPosition(x,y,z, 2.0, skillData.Target)
			local actionHandle = NRD_CreateGameObjectMove(skillData.Target, tx,ty,tz, "", char)
		end
	end
end)


---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function SuckerPunchBonus(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["SUCKER_PUNCH_COMBO"] == true then
			ApplyStatus(char, "LLWEAPONEX_WS_RAPIER_SUCKERCOMBO1", 12.0, 0, char)
		end
	elseif state == SKILL_STATE.HIT and skillData.Success then
		local target = skillData.Target
		local bonuses = MasteryBonusManager.GetMasteryBonuses(char, skill)
		if bonuses["SUCKER_PUNCH_COMBO"] == true then
			if HasActiveStatus(target, "KNOCKED_DOWN") == 1 then
				local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_PetrifyingTouch_KnockbackDistance", 4.0)
				if Ext.Random(0,100) <= chance then
					local handle = NRD_StatusGetHandle(target, "KNOCKED_DOWN")
					if handle ~= nil then
						local duration = NRD_StatusGetReal(target, handle, "CurrentLifeTime")
						local lastTurns = math.floor(duration / 6)
						duration = duration + 6.0
						local nextTurns = math.floor(duration / 6)
						NRD_StatusSetReal(target, handle, "CurrentLifeTime", duration)
						local text = Ext.GetTranslatedStringFromKey("LLWEAPONEX_StatusText_StatusExtended")
						if text == nil then
							text = "<font color='#99FF22' size='22'><p align='center'>[1] Extended!</p></font><p align='center'>[2] -> [3]</p>"
						end
						text = text:gsub("%[1%]", Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute("KNOCKED_DOWN", "DisplayName")))
						text = text:gsub("%[2%]", lastTurns)
						text = text:gsub("%[3%]", nextTurns)
						if ObjectIsCharacter(target) == 1 then
							CharacterStatusText(target, text)
						else
							DisplayText(target, text)
						end
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Target_SingleHandedAttack", SuckerPunchBonus)
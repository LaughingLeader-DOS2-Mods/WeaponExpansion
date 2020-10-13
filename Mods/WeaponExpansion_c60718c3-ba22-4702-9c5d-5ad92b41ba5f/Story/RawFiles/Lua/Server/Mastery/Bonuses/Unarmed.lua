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

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
HitHandler.RegisterOnHit("LLWEAPONEX_Unarmed", function(target,source,damage,handle)
	
end)

---@param skill string
---@param char string
---@param state SkillState
---@param data HitData
local function AddUnarmedExperienceForSkill(skill, char, state, data)
	if state == SKILL_STATE.HIT and data.Success then
		if IsPlayer(char) then
			MasterySystem.GrantWeaponSkillExperience(char, data.Target, "LLWEAPONEX_Unarmed")
		end
	end
end

local UnarmedSkills = {
	"Target_SingleHandedAttack",
	"Target_LLWEAPONEX_SinglehandedAttack",
	"Target_PetrifyingTouch",
}

for _,skill in pairs(UnarmedSkills) do
	RegisterSkillListener(skill, AddUnarmedExperienceForSkill)
end

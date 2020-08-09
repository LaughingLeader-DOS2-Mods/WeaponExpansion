
local throwingKnifeBonuses = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData SkillEventData|HitData
local function ThrowingKnifeBonus(bonuses, skill, char, state, skillData)
	--LeaderLib.PrintDebug("[MasteryBonuses:ThrowingKnife] char(",char,") state(",state,") skillData("..Ext.JsonStringify(skillData)..")")
	if state ~= SKILL_STATE.PREPARE then
		local procSet = ObjectGetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus") == 1
		if state == SKILL_STATE.USED then
			if hasMastery and not procSet then 
				local roll = Ext.Random(1,100)
				local chance = GameHelpers.GetExtraData("LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance", 25)
				if chance == nil or chance < 0 then chance = 25 end
				LeaderLib.PrintDebug("LLWEAPONEX_ThrowingKnife_ActivateBonus|",roll, "/", chance)
				if roll <= chance then
					if skillData.ID == SkillEventData.ID then
						if skillData.TotalTargetObjects > 0 then
							local x,y,z = GetPosition(skillData.TargetObjects[1])
							SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
						elseif skillData.TotalTargetPositions > 0 then
							local x,y,z = table.unpack(skillData.TargetPositions[1])
							SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
						end
						ObjectSetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
					end
				end
			end
		elseif state == SKILL_STATE.CAST then
			if procSet then
				Mods.LeaderLib.StartTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", 250, char)
			end
		elseif state == SKILL_STATE.HIT then
			if procSet and skillData.ID == HitData.ID then
				Mods.LeaderLib.CancelTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", char)
				local explodeSkill = throwingKnifeBonuses[Ext.Random(1,2)]
				GameHelpers.ExplodeProjectile(char, target, explodeSkill)
				ObjectClearFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
			end
		end
	end
end

MasteryBonusManager.RegisterSkillListener({"Projectile_ThrowingKnife", "Projectile_EnemyThrowingKnife"}, {"BONUS_DAGGER"}, ThrowingKnifeBonus)

local function ThrowingKnifeDelayedProc(funcParams)
	local char = funcParams[1]
	if char ~= nil and ObjectGetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus") == 1 then
		local x,y,z = GetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition")
		local explodeSkill = throwingKnifeBonuses[Ext.Random(1,2)]
		local level = CharacterGetLevel(char)
		NRD_ProjectilePrepareLaunch()
		NRD_ProjectileSetString("SkillId", explodeSkill)
		NRD_ProjectileSetInt("CasterLevel", level)
		NRD_ProjectileSetGuidString("Caster", char)
		NRD_ProjectileSetGuidString("Source", char)
		NRD_ProjectileSetVector3("SourcePosition", x,y,z)
		NRD_ProjectileSetVector3("HitObjectPosition", x,y,z)
		NRD_ProjectileSetVector3("TargetPosition", x,y,z)
		NRD_ProjectileLaunch()
		ObjectClearFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
	else
		LeaderLib.PrintDebug("ThrowingKnifeDelayedProc params: "..LeaderLib.Common.Dump(funcParams))
	end
end

OnTimerFinished["LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus"] = ThrowingKnifeDelayedProc
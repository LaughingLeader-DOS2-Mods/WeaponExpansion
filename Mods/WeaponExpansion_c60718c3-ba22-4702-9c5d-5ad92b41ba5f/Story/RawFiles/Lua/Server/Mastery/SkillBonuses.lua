SKILL_STATE = LeaderLib.SKILL_STATE

local function ExplodeProjectile(source,target,level,skill)
	NRD_ProjectilePrepareLaunch()
	NRD_ProjectileSetString("SkillId", skill)
	NRD_ProjectileSetInt("CasterLevel", level)
	NRD_ProjectileSetGuidString("Caster", source)
	NRD_ProjectileSetGuidString("Source", source)
	NRD_ProjectileSetGuidString("SourcePosition", target)
	NRD_ProjectileSetGuidString("HitObject", target)
	NRD_ProjectileSetGuidString("HitObjectPosition", target)
	NRD_ProjectileSetGuidString("TargetPosition", target)
	NRD_ProjectileLaunch()
end

local throwingKnifeBonuses = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

local function ThrowingKnifeBonus(char, state, funcParams)
	--LeaderLib.PrintDebug("[MasteryBonuses:ThrowingKnife] char(",char,") state(",state,") funcParams("..Ext.JsonStringify(funcParams)..")")
	local hasMastery = false
	local data = Mastery.Params.SkillData["Projectile_ThrowingKnife"]
	if data ~= nil and data.Tags ~= nil then
		local character = Ext.GetCharacter(char)
		for tagName,tagData in pairs(data.Tags) do
			if HasMasteryRequirement(character, tagName) then
				hasMastery = true
				break
			end
		end
	end
	if hasMastery then
		local procSet = ObjectGetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus") == 1
		if state == SKILL_STATE.USED then
			if hasMastery and not procSet then 
				local roll = Ext.Random(1,100)
				local chance = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance", 25)
				if chance == nil or chance < 0 then chance = 25 end
				LeaderLib.PrintDebug("LLWEAPONEX_ThrowingKnife_ActivateBonus|",roll, "/", chance)
				if roll <= chance then
					-- Position
					if #funcParams == 3 then
						local x = funcParams[1]
						local y = funcParams[2]
						local z = funcParams[3]
						SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
					elseif funcParams[1] ~= nil then
						local x,y,z = GetPosition(funcParams[1])
						SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
					end
					ObjectSetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
				end
			end
		elseif state == SKILL_STATE.CAST then
			if procSet then
				Mods.LeaderLib.StartTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", 250, char)
			end
		elseif state == SKILL_STATE.HIT then
			if procSet then
				local target = funcParams[1]
				if target ~= nil then
					Mods.LeaderLib.CancelTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", char)
					local explodeSkill = throwingKnifeBonuses[Ext.Random(1,2)]
					local level = CharacterGetLevel(char)
					ExplodeProjectile(char, target, level, explodeSkill)
				end
				ObjectClearFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
			end
		end
	end
end

LeaderLib.RegisterSkillListener("Projectile_ThrowingKnife", ThrowingKnifeBonus)
LeaderLib.RegisterSkillListener("Projectile_EnemyThrowingKnife", ThrowingKnifeBonus)

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

local function CripplingBlowBonus(char, state, funcParams)
	LeaderLib.PrintDebug("[MasteryBonuses:CripplingBlow] char(",char,") state(",state,") funcParams("..Ext.JsonStringify(funcParams)..")")
	if state == SKILL_STATE.HIT then
		local character = Ext.GetCharacter(char)
		local hasMasteries = {}
		local data = Mastery.Params.SkillData["Target_CripplingBlow"]
		if data ~= nil and data.Tags ~= nil then
			for tagName,tagData in pairs(data.Tags) do
				if HasMasteryRequirement(character, tagName) then
					hasMasteries[tagData.ID] = true
				end
			end
		end
		LeaderLib.PrintDebug(LeaderLib.Common.Dump(hasMasteries))
		local target = funcParams[1]
		if target ~= nil then
			if hasMasteries["SUNDER"] == true then
				local duration = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_CripplingBlow_SunderDuration", 6.0)
				if HasActiveStatus(target, "LLWEAPONEX_MASTERYBONUS_SUNDER") == 1 then
					local handle = NRD_StatusGetHandle(target, "LLWEAPONEX_MASTERYBONUS_SUNDER")
					NRD_StatusSetReal(target, handle, "CurrentLifeTime", duration)
				else
					ApplyStatus(target, "LLWEAPONEX_MASTERYBONUS_SUNDER", duration, 0, char)
				end
			end
			if hasMasteries["BONUSDAMAGE"] == true then
				if LeaderLib.HasStatusType(target, {"INCAPACITATED", "KNOCKED_DOWN"}) then
					local level = CharacterGetLevel(char)
					ExplodeProjectile(char, target, level, "Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage")
					
					-- local targetPos = {[1] = x, [2] = y, [3] = z}
					--local x,y,z = GetPosition(target)					-- local skill = Skills.PrepareSkillProperties("Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage")
					-- local damageList = Game.Math.GetSkillDamage(skill, character.Stats, false, false, character.Stats.Position, targetPos, character.Stats.Level, 0)
					-- damageList:ConvertDamageType("Piercing")
					-- for i,damage in pairs(damageList:ToTable()) do
					-- 	ApplyDamage(target, damage.Amount, "Piercing", char)
					-- end
				else
					LeaderLib.PrintDebug("[WeaponExpansion:MasteryBonuses:CripplingBlowBonus] Target is not disabled.")
				end
			end
		end
	end
end

LeaderLib.RegisterSkillListener("Target_CripplingBlow", CripplingBlowBonus)
LeaderLib.RegisterSkillListener("Target_EnemyCripplingBlow", CripplingBlowBonus)

local elementalWeakness = {
	Air = "LLWEAPONEX_WEAKNESS_AIR",
	Chaos = "LLWEAPONEX_WEAKNESS_CHAOS",
	Earth = "LLWEAPONEX_WEAKNESS_EARTH",
	Fire = "LLWEAPONEX_WEAKNESS_FIRE",
	Poison = "LLWEAPONEX_WEAKNESS_POISON",
	Water = "LLWEAPONEX_WEAKNESS_WATER",
	Piercing = "LLWEAPONEX_WEAKNESS_PIERCING",
	--Shadow = "LLWEAPONEX_WEAKNESS_SHADOW",
	--Physical = "LLWEAPONEX_WEAKNESS_Physical",
}

local function WhirlwindBonus(char, state, funcParams)
	LeaderLib.PrintDebug("[MasteryBonuses:Whirlwind] char(",char,") state(",state,") funcParams("..Ext.JsonStringify(funcParams)..")")
	if state == SKILL_STATE.HIT then
		local character = Ext.GetCharacter(char)
		local hasMasteries = {}
		local data = Mastery.Params.SkillData["Shout_Whirlwind"]
		if data ~= nil and data.Tags ~= nil then
			for tagName,tagData in pairs(data.Tags) do
				if HasMasteryRequirement(character, tagName) then
					hasMasteries[tagData.ID] = true
				end
			end
		end
		local target = funcParams[1]
		if target ~= nil then
			if hasMasteries["RUPTURE"] == true then
				local bleedingTurns = GetStatusTurns(target, "BLEEDING")
				if bleedingTurns ~= nil and bleedingTurns > 0 then
					local level = CharacterGetLevel(char)
					for i=bleedingTurns,1,-1 do
						ExplodeProjectile(char, target, level, "Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding")
					end
					if ObjectIsCharacter(target) then
						local text = Text.RupteredWound.Value
						if bleedingTurns > 1 then
							text = text:gsub("%[1%]", "x"..tostring(bleedingTurns))
						else
							text = text:gsub("%[1%]", "")
						end
						CharacterStatusText(target, text)
					end
					LeaderLib.PrintDebug("[MasteryBonuses:WhirlwindBonus] Exploded (",bleedingTurns,") rupture projectiles on ("..target..").")
				end
			end
			if hasMasteries["ELEMENTAL_DEBUFF"] == true then
				local duration = LeaderLib.Game.GetExtraData("LLWEAPONEX_MasteryBonus_ElementalWeaknessDuration", 6.0)
				local weaponuuid = CharacterGetEquippedWeapon(char)
				--local damageType = Ext.StatGetAttribute(NRD_ItemGetStatsId(weapon), "Damage Type")
				local weapon = Ext.GetItem(weaponuuid)
				local stats = weapon.DynamicStats
				for i, stat in pairs(stats) do
					if stat.StatsType == "Weapon" and stat.DamageType ~= "None" then
						local status = elementalWeakness[stat.DamageType]
						if status ~= nil then
							ApplyStatus(target, status, duration, 0, char)
						end
					end
				end
			end
		end
	end
end
LeaderLib.RegisterSkillListener("Shout_Whirlwind", WhirlwindBonus)
LeaderLib.RegisterSkillListener("Shout_EnemyWhirlwind", WhirlwindBonus)

local function FleshSacrificeBonus(char, state, funcParams)
	if state == SKILL_STATE.CAST then
		local character = Ext.GetCharacter(char)
		local hasMasteries = {}
		local data = Mastery.Params.SkillData["Shout_FleshSacrifice"]
		if data ~= nil and data.Tags ~= nil then
			for tagName,tagData in pairs(data.Tags) do
				if HasMasteryRequirement(character, tagName) then
					hasMasteries[tagData.ID] = true
				end
			end
			if hasMasteries["BLOOD_EMPOWER"] == true then
				---@return string[]
				local party = LeaderLib.Game.GetParty(char, true, true, false, false)
				if #party > 0 then
					for i,partyMember in pairs(party) do
						local surfaceGround = GetSurfaceGroundAt(partyMember)
						local surfaceCloud = GetSurfaceCloudAt(partyMember)
						if string.find(surfaceCloud, "Blood") or string.find(surfaceCloud, "Blood") then
							ApplyStatus(partyMember, "LLWEAPONEX_BLOOD_EMPOWERED", 6.0, 0, char)
						end
					end
				end

			end
		end
	end
end
LeaderLib.RegisterSkillListener("Shout_FleshSacrifice", FleshSacrificeBonus)
LeaderLib.RegisterSkillListener("Shout_EnemyFleshSacrifice", FleshSacrificeBonus)
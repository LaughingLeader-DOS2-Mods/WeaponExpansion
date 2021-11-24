local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData

local warChargeStatuses = {
	"LLWEAPONEX_WARCHARGE_DAMAGEBOOST",
	"LLWEAPONEX_WARCHARGE_BONUS",
	"LLWEAPONEX_WARCHARGE01",
	"LLWEAPONEX_WARCHARGE02",
	"LLWEAPONEX_WARCHARGE03",
	"LLWEAPONEX_WARCHARGE04",
	"LLWEAPONEX_WARCHARGE05",
	"LLWEAPONEX_WARCHARGE06",
	"LLWEAPONEX_WARCHARGE07",
	"LLWEAPONEX_WARCHARGE08",
	"LLWEAPONEX_WARCHARGE09",
	"LLWEAPONEX_WARCHARGE10",
}

Mastery.Variables.Bonuses.WarChargeStatuses = warChargeStatuses

local inspireCleanseStatuses = {
	FEAR = "#7F00FF",
	MADNESS = "#D040D0",
	SLEEPING = "#7D71D9",
}

Mastery.Variables.Bonuses.BannerInspireCleanseStatuses = inspireCleanseStatuses

MasteryBonusManager.AddRankBonuses(MasteryID.Banner, 1, {
	rb:Create("BANNER_WARCHARGE", {
		Skills = MasteryBonusManager.Vars.RushSkills,
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Rush", "If under the effects of <font color='#FFCE58'>War Charge</font>, deal <font color='#33FF00'>[ExtraData:LLWEAPONEX_MB_Banner_WarCharge_DamageBoost]% more damage on hit</font> and gain <font color='#7D71D9'>[Key:HASTED_DisplayName]</font> after rushing.")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.CAST then
			local hasStatus = false
			for i,status in pairs(warChargeStatuses) do
				if HasActiveStatus(char, status) == 1 then
					hasStatus = true
					break
				end
			end
			if hasStatus then
				Timer.StartObjectTimer("LLWEAPONEX_WarCharge_ApplyHasted", char, 1000)
			end
		elseif state == SKILL_STATE.HIT and data.Success then
			local hasStatus = false
			for i,status in pairs(warChargeStatuses) do
				if HasActiveStatus(char, status) == 1 then
					hasStatus = true
					break
				end
			end
			if hasStatus then
				local bonusMultiplier = GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_WarCharge_DamageBoost", 25.0)
				if bonusMultiplier > 0 then
					data:MultiplyDamage(1 + (bonusMultiplier * 0.01))
				end
			end
		end
	end),

	rb:Create("BANNER_INSPIRE", {
		Skills = {"Shout_InspireStart", "Shout_EnemyInspire"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Encourage", "<font color='#FFCE58'>Fear, Madness, and Sleep are cleansed from encouraged allies.</font>"),
		Statuses = {"ENCOURAGED"},
		DisableStatusTooltip = true
	}):RegisterStatusListener("Applied", function(bonuses, target, status, source, statusType)
		if bonuses.BANNER_INSPIRE[source] == true then
			local cleansed = {}
			for status,color in pairs(inspireCleanseStatuses) do
				if HasActiveStatus(target, status) == 1 then
					RemoveStatus(target, status)
					cleansed[#cleansed+1] = string.format("<font color='%s'>%s</font>", color, Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(status, "DisplayName")))
				end
			end
			if #cleansed > 0 then
				--PlayBeamEffect(source, target, "RS3_FX_GP_Status_Retaliation_Beam_01", "Dummy_R_HandFX", "Dummy_BodyFX")
				ApplyStatus(target, "LLWEAPONEX_ENCOURAGED_CLEANSE_BEAM_FX", 0.0, 1, source)
				local text = Ext.GetTranslatedStringFromKey("LLWEAPONEX_StatusText_Encourage_Cleansed"):gsub("%[1%]", Common.StringJoin("/", cleansed))
				CharacterStatusText(target,text)
			end
		end
	end)
})

if not Vars.IsClient then
	Timer.RegisterListener("LLWEAPONEX_WarCharge_ApplyHasted", function(timerName, target)
		ApplyStatus(target, "HASTED", 6.0, 0, target)
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Banner, 2, {
	rb:Create("BANNER_RALLYINGCRY", {
		Skills = {"Target_Harmony", "Target_EnemyHarmony"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_RallyingCry", "<font color='#88FF33'>Affected allies will basic attack the nearest enemy within range.</font>"),
		Statuses = {"HARMONY"},
		DisableStatusTooltip = true
	}):RegisterStatusListener("Applied", function(bonuses, target, status, source, statusType)
		if (ObjectIsCharacter(target) == 1 
		and not GameHelpers.Status.IsDisabled(target, true)
		and NRD_ObjectHasStatusType(target, "DISARMED") == 0
		and bonuses.BANNER_RALLYINGCRY[source] == true) then
			local range = 1.0
			local weapon = CharacterGetEquippedWeapon(target)
			if weapon ~= nil then
				range = Ext.GetItem(weapon).Stats.WeaponRange / 100
			end

			local targets = {}

			for i,v in pairs(Ext.GetCharacter(target):GetNearbyCharacters(range)) do
				if CharacterIsEnemy(target, v) == 1 then
					table.insert(targets, v)
				end
			end

			if #targets > 0 then
				local attackTarget = Common.GetRandomTableEntry(targets)
				CharacterAttack(target, attackTarget)
			end
		end
	end),

	rb:Create("BANNER_GUARDIAN_ANGEL", {
		Skills = {"Shout_GuardianAngel", "Shout_EnemyGuardianAngel"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_GuardianAngelSkill", "<font color='#00FFFF'>If an ally protected by Guardian Angel dies, automatically resurrect them at the start of your turn.</font>"),
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_GuardianAngelStatus", "<font color='#00FFFF'>If killed, character will be resurrected by the Guardian when their turn starts.</font>"),
		Statuses = {"GUARDIAN_ANGEL"},
	}):RegisterStatusListener("Applied", function(bonuses, target, status, source, statusType)
		if bonuses.BANNER_GUARDIAN_ANGEL[source] == true then
			ObjectSetFlag(target, "LLWEAPONEX_Banner_GuardianAngel_Active", 0)
		end
	end):RegisterStatusListener("Removed", function(bonuses, target, status, source, statusType)
		ObjectClearFlag(target, "LLWEAPONEX_Banner_GuardianAngel_Active", 0)
	end):RegisterOsirisListener("CharacterPrecogDying", 1, "after", function(char)
		if ObjectGetFlag(char, "LLWEAPONEX_Banner_GuardianAngel_Active") == 1 then
			ObjectClearFlag(char, "LLWEAPONEX_Banner_GuardianAngel_Active", 0)
			local character = GameHelpers.GetCharacter(char)
			if character then
				local status = character:GetStatus("GUARDIAN_ANGEL")
				if status and status.StatusSourceHandle then
					local sourceCharacter = GameHelpers.GetCharacter(status.StatusSourceHandle)
					if sourceCharacter then
						if MasteryBonusManager.HasMasteryBonus(sourceCharacter, "BANNER_GUARDIAN_ANGEL") then
							if PersistentVars.MasteryMechanics.GuardianAngelResurrect == nil then
								PersistentVars.MasteryMechanics.GuardianAngelResurrect = {}
							end
							PersistentVars.MasteryMechanics.GuardianAngelResurrect[char] = sourceCharacter.MyGuid
						end
					end
				end
			end
		end
	end)
})

if not Vars.IsClient then
	RegisterListener("TurnDelayed", function(uuid)
		local statusSource = nil
		local target = GameHelpers.GetCharacter(uuid)
		if target then
			local auraStatus = target:GetStatus("LLWEAPONEX_BANNER_RALLY_DIVINEORDER_AURABONUS") or target:GetStatus("LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS")
			if auraStatus then
				statusSource = auraStatus.StatusSourceHandle
			end
			if statusSource then
				statusSource = GameHelpers.GetCharacter(statusSource)
				if statusSource and MasteryBonusManager.HasMasteryBonus(statusSource.MyGuid, "BANNER_PROTECTION") then
					ApplyStatus(uuid, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION", 6.0, 0, uuid)
				end
			end
		end
	end)
	
	local function CheckLeadershipBonus(char)
		if HasActiveStatus(char, "LEADERSHIP") == 1 and GameHelpers.Character.IsPlayer(char) then
			local character = GameHelpers.GetCharacter(char)
			if character then
				local status = character:GetStatus("LEADERSHIP")
				if status then
					local bonusChance = 0
					local bonusSource = nil
		
					--Check the source of Leadership first
					local source = GameHelpers.GetCharacter(status.StatusSourceHandle)
					if source ~= nil then
						if MasteryBonusManager.HasMasteryBonus(source, "BANNER_LEADERSHIP") then
							bonusChance = math.ceil(GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_LeadershipInspirationChance2", 50))
							bonusSource = source.MyGuid
						end
					end
		
					--Try to get allied characters with Leadership in range, 
					--in case there's multiple party members with Leadership, but the status source doesn't have banner mastery.
					if bonusChance == 0 then
						local leadershipDistance = GameHelpers.GetExtraData("LeadershipRange", 8)
						local combatid = CombatGetIDForCharacter(char)
						for ally in GameHelpers.Combat.GetCharacters(combatid, "Ally") do
							if MasteryBonusManager.HasMasteryBonus(ally.MyGuid, "BANNER_LEADERSHIP") 
							and ally.Stats.Leadership > 0
							and GameHelpers.Math.GetDistance(ally.WorldPos, character.WorldPos) <= leadershipDistance
							then
								bonusChance = math.ceil(GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_LeadershipInspirationChance", 25))
								bonusSource = ally.MyGuid
							end
						end
					end
		
					if bonusChance > 0 then
						if Ext.Round(1,100) <= bonusChance then
							ApplyStatus(char, "LLWEAPONEX_MASTERYBONUS_BANNER_LEADERSHIPBONUS", 6.0, 0, bonusSource)
						end
					end
				end
			end
		end
	end

	Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "after", function(char)
		local char = StringHelpers.GetUUID(char)
		if HasActiveStatus(char, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION") == 1 then
			RemoveStatus(char, "LLWEAPONEX_BANNER_TURNDELAYPROTECTION")
		end
		if PersistentVars.MasteryMechanics.GuardianAngelResurrect ~= nil and #PersistentVars.MasteryMechanics.GuardianAngelResurrect > 0 then
			for deadChar,v in pairs(PersistentVars.MasteryMechanics.GuardianAngelResurrect) do
				if v == char then
					if CharacterIsDead(deadChar) == 1 then
						CharacterResurrect(deadChar)
					else
						PersistentVars.MasteryMechanics.GuardianAngelResurrect[deadChar] = nil
					end
				end
			end
		end
		CheckLeadershipBonus(char)
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Banner, 3, {
	rb:Create("BANNER_WHIRLWIND", {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Whirlwind", "<font color='#00CCAA'>If near an active banner, enemies hit are pulled towards the banner.</font>")
	}):RegisterSkillListener(function(bonuses, skill, char, state, data)
		if state == SKILL_STATE.HIT and data.Success then
			local worldBannerEntry = Osi.DB_LLWEAPONEX_Skills_Temp_RallyBanner:Get(char, nil)
			if worldBannerEntry ~= nil and #worldBannerEntry > 0 then
				local worldBanner = worldBannerEntry[1][2]
				if worldBanner ~= nil and ObjectExists(worldBanner) == 1 then
					local dist = GetDistanceTo(char, worldBanner)
					local skillDist = Ext.StatGetAttribute(skill, "AreaRadius")
					local addWeaponRange = Ext.StatGetAttribute(skill, "AddWeaponRange") == "Yes"
					if addWeaponRange then
						local banners = GameHelpers.Item.FindTaggedEquipment(char, "LLWEAPONEX_Banner")
						if #banners > 0 then
							local banner = Ext.GetItem(banners[1])
							skillDist = skillDist + (banner.Stats.WeaponRange/100)
						end
					end
					if dist <= skillDist + 0.5 then
						--NRD_CreateGameObjectMove([in](GUIDSTRING)_TargetObject, [in](REAL)_X, [in](REAL)_Y, [in](REAL)_Z, [in](STRING)_BeamEffectName, [in](CHARACTERGUID)_CasterCharacter, [out](INTEGER64)_GameActionHandle)
						local dist2 = GetDistanceTo(worldBanner, data.Target)
						local x,y,z = GetPosition(worldBanner)
						local tx,ty,tz = GetPosition(data.Target)
						local dir = math.sqrt((tx - x)^2 + (tz - z)^2)
						x = x + dir * (dist2 * 0.2)
						z = z + dir * (dist2 * 0.2)
						local fx,fy,fz = FindValidPosition(x,y,z, 4.0, data.Target)
						local handle = NRD_CreateGameObjectMove(data.Target, fx, fy, fz, "", char)
					end
				end
			end
		end
	end),

	---@see CheckLeadershipBonus
	rb:Create("BANNER_LEADERSHIP", {
		Statuses = {"LEADERSHIP"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_Leadership", "<font color='#00FFFF'>[Special:LLWEAPONEX_MB_Banner_LeadershipInspirationChance]% chance to gain <font color='#11FF88'>[Key:LLWEAPONEX_MASTERYBONUS_BANNER_LEADERSHIPBONUS_DisplayName]</font> on turn start if within [ExtraData:LeadershipRange]m range of a [Key:LLWEAPONEX_Banner] wielder.</font>"),
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_Banner_Mastery3", true),
		OnGetTooltip = function(bonus, skillOrStatus, character, isStatus, status)
			--Appending "Empowered by x's Banner" if Leadership is from a Banner user
			if status then
				local source = GameHelpers.TryGetObject(status.StatusSourceHandle)
				if source and GameHelpers.CharacterOrEquipmentHasTag(source, "LLWEAPONEX_Banner_Mastery3") or Vars.LeaderDebugMode then
					return string.format("%s<br>%s", bonus.Tooltip.Value, Text.MasteryBonusParams.BannerLeadershipSource:ReplacePlaceholders(source.DisplayName))
				end
			end
		end
	})
})

if Vars.IsClient then
	TooltipHandler.SpecialParamFunctions.LLWEAPONEX_MB_Banner_LeadershipInspirationChance = function(param, statCharacter)
		local baseBonusChance = math.ceil(GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_LeadershipInspirationChance", 25))
		if statCharacter.Character then
			local status = statCharacter.Character:GetStatus("LEADERSHIP")
			if status then
				local bonusChance = 0
				local bonusSource = nil
	
				--Check the source of Leadership first
				local source = GameHelpers.GetCharacter(status.StatusSourceHandle)
				if source ~= nil then
					if MasteryBonusManager.HasMasteryBonus(source, "BANNER_LEADERSHIP") then
						bonusChance = math.ceil(GameHelpers.GetExtraData("LLWEAPONEX_MB_Banner_LeadershipInspirationChance2", 50))
						bonusSource = source.MyGuid
					end
				end
	
				if bonusChance == 0 then
					bonusChance = baseBonusChance
				end
	
				return tostring(bonusChance)
			end
		end
		return tostring(baseBonusChance)
	end
end

MasteryBonusManager.AddRankBonuses(MasteryID.Banner, 4, {
	rb:Create("BANNER_PROTECTION", {
		Skills = {"Dome_LLWEAPONEX_Banner_Rally_Dwarves", "Dome_LLWEAPONEX_Banner_Rally_DivineOrder"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_BannerAuraProtection", "<font color='#33FF33'>When near a placed banner, allies cannot be flanked, and turn delaying reduces damage taken by [Stats:Stats_LLWEAPONEX_Banner_TurnDelayProtection:FireResistance]% until the turn occurs.</font>"),
		Statuses = {"LLWEAPONEX_BANNER_RALLY_DIVINEORDER_AURABONUS", "LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS"},
		StatusTooltip = ts:CreateFromKey("LLWEAPONEX_MB_Banner_BannerAuraStatusProtection","<font color='#C9AA58'>Immune to Flanking</font><br><font color='#33FF33'>Turn delaying reduces damage taken by [Stats:Stats_LLWEAPONEX_Banner_TurnDelayProtection:FireResistance]%.</font>"),
		GetIsTooltipActive = rb.DefaultStatusTagCheck("LLWEAPONEX_Banner_Mastery4", true)
	}):RegisterStatusBeforeAttemptListener(function(bonuses, target, status, source, handle, statusType)
		local statusSource = nil
		local auraStatus = target:GetStatus("LLWEAPONEX_BANNER_RALLY_DIVINEORDER_AURABONUS") or target:GetStatus("LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS")
		if auraStatus then
			statusSource = auraStatus.StatusSourceHandle
		end
		if statusSource then
			statusSource = GameHelpers.GetCharacter(statusSource)
			if statusSource and bonuses.BANNER_PROTECTION[statusSource.MyGuid] then
				--Block Flanking
				return false
			end
		end
	end, "FLANKING"),
})
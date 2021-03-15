Mastery.Params = {
	SkillData = {},
	StatusData = {},
	UI = {}
}

---@type TranslatedString
local ts = LeaderLib.Classes["TranslatedString"]

local RUSH_SKILLS = {"Rush_BatteringRam", "Rush_BullRush", "Rush_EnemyBatteringRam", "Rush_EnemyBullRush"}
local BASIC_ATTACK = {"ActionAttackGround"}

local ELEMENTAL_WEAKNESS_BASE = Ext.Require("Shared/Data/MasteryData_ElementalWeakness.lua")

---@class MasteryBonusData
---@field Skills string[]|string|nil
---@field Param TranslatedString
---@field NamePrefix TranslatedString|string|nil

Mastery.BonusID = {}
Mastery.Bonuses = {
LLWEAPONEX_Axe_Mastery1 = {
	AXE_BONUSDAMAGE = {
		Skills = {"Target_CripplingBlow", "Target_EnemyCripplingBlow"},
		Param = ts:Create("h46875020ge016g4eccg94ecgc9f5233c07fd","<font color='#F19824'>If the target is disabled, deal an additional [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage].</font>"),
		NamePrefix = "<font color='#DD4444'>Executioner's</font>"
	},
	AXE_EXECUTIONER = {
		Skills = BASIC_ATTACK,
		Param = ts:Create("h32749b80g4544g449egb4e5g1e4bd9ce04c3","Axes deal [ExtraData:LLWEAPONEX_MasteryBonus_Hit_Axe_ProneDamageBonus]% more damage to targets that are [Key:KNOCKED_DOWN_DisplayName]."),
	},
},
LLWEAPONEX_Axe_Mastery2 = {
	AXE_VULNERABLE = {
		Skills = {"MultiStrike_BlinkStrike", "MultiStrike_EnemyBlinkStrike"},
		Param = ts:Create("h173b9449ge0c5g4f29g86f4g01124907841b","Each target hit becomes <font color='#F13324'>Vulnerable</font>. If hit again, <font color='#F13324'>Vulnerable</font> is removed and the target takes [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_VulnerableDamage].<br><font color='#F1CC00'><font color='#F13324'>Vulnerable</font> is removed when your turn ends.</font>"),
	},
	AXE_SAVAGE = {
		Skills = BASIC_ATTACK,
		Param = ts:Create("h29991fbcg6968g4feeg9a60gcc8c04fdbd73","Attack of Opportunities deal [ExtraData:LLWEAPONEX_MasteryBonus_Hit_Axe_AttackOfOpportunityMaxDamageBonus]% more damage, in proportion to the target's missing vitality."),
	}
},
LLWEAPONEX_Axe_Mastery3 = {
	AXE_SPINNING = {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Param = ts:Create("h0f83aa9ag475bg4ddfgb546gbb83d237b44e", "Spin an additional 1-3 times, dealing reduced damage each spin."),
	},
},
LLWEAPONEX_Axe_Mastery4 = {
	AXE_CLEAVE = {
		Skills = {"Target_Flurry", "Target_EnemyFlurry"},
		Param = ts:Create("he478deedg980eg4c61gaacdga2cfc8b63b8a","Each hit cleaves up to [Stats:Cone_LLWEAPONEX_MasteryBonus_Axe_FlurryCleave:Range]m away in a [Stats:Cone_LLWEAPONEX_MasteryBonus_Axe_FlurryCleave:Angle] degree cone, dealing [SkillDamage:Cone_LLWEAPONEX_MasteryBonus_Axe_FlurryCleave].")
	},
	AXE_SCOUNDREL = {
		Param = ts:Create("h4f01d52ag5c84g42d8gae3dgaf3f477bcc18","Axes can now be used with Scoundrel skills."),
	},
},
LLWEAPONEX_Axe_Mastery5 = {},
LLWEAPONEX_Banner_Mastery1 = {
	BANNER_INSPIRE = {
		Skills = {"Shout_InspireStart", "Shout_EnemyInspire"},
		Param = ts:Create("h4190e997g6776g46a5gbff1g711a310c6d38","<font color='#FFCE58'>Fear, Madness, and Sleep are cleansed from encouraged allies.</font>")
	},
	BANNER_WARCHARGE = {
		Skills = RUSH_SKILLS,
		Param = ts:Create("h3c34bca6gc080g4de4gae5eg4909ad60ecc8","If under the effects of <font color='#FFCE58'>War Charge</font>, deal [ExtraData:LLWEAPONEX_MasteryBonus_WarChargeDamageBoost]% more damage and gain <font color='#7D71D9'>[Key:HASTED_DisplayName]</font> after rushing."),
	}
},
LLWEAPONEX_Banner_Mastery2 = {
	BANNER_RALLYINGCRY = {
		Skills = {"Target_Harmony", "Target_EnemyHarmony"},
		Param = ts:Create("h6d1e0bbbgc61bg4fbbg85b8g0f9f759d3cd9","<font color='#88FF33'>Affected allies will basic attack the nearest enemy within range.</font>")
	},
	BANNER_GUARDIAN_ANGEL = {
		Skills = {"Shout_GuardianAngel", "Shout_EnemyGuardianAngel"},
		Param = ts:Create("h1d57a248gbe88g4143g8cb5g1b4ab6d7c44c","<font color='#00FFFF'>If an ally protected by Guardian Angel dies, automatically resurrect them at the start of your turn.</font>"),
		StatusParam = {
			Statuses = {"GUARDIAN_ANGEL"},
			Param = ts:Create("hb8e7b768gac05g4835g9e6fg4f75b52cfb66","<font color='#00FFFF'>If killed, character will be resurrected by the Guardian when their turn starts.</font>"),
			Active = {Value = "LLWEAPONEX_Banner_GuardianAngel_Active", Type = "Tag"}
		}
	},
},
LLWEAPONEX_Banner_Mastery3 = {
	BANNER_VACUUM = {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Param = ts:Create("h5b135257gec07g49f8gbf25g69df1d282001","<font color='#00CCAA'>If near an active banner, enemies hit are pulled towards the banner.</font>")
	},
	BANNER_LEADERSHIP = {
		StatusParam = {
			Statuses = {"LEADERSHIP"},
			Param = ts:Create("hdcab69c9gc26ag4c53gb624gbba1c5f13ee2", "Allies within [ExtraData:LeadershipRange]m affected by <font color='#11FF44'>Leadership</font> have a [ExtraData:LLWEAPONEX_MasteryBonus_Banner_LeadershipInspirationChance]% chance to gain <font color='#11FF88'>Inspiration</font> on their turn. If <font color='#11FF44'>Leadership</font> is from you, this chance is increased to [ExtraData:LLWEAPONEX_MasteryBonus_Banner_LeadershipInspirationChance2]%."),
			Active = {Value = "LLWEAPONEX_Banner_Mastery3", Type = "Tag", Source=true}
		}
	}
},
LLWEAPONEX_Banner_Mastery4 = {
	BANNER_PROTECTION = {
		Skills = {"Dome_LLWEAPONEX_Banner_Rally_Dwarves", "Dome_LLWEAPONEX_Banner_Rally_DivineOrder"},
		Param = ts:Create("h57237b97gfe3bg437aga094g1d91268f9fc5","<font color='#33FF33'>When near a placed banner, allies cannot be flanked, and turn delaying reduces damage taken by [Stats:Stats_LLWEAPONEX_Banner_TurnDelayProtection:FireResistance]% until the turn occurs.</font>"),
		StatusParam = {
			Statuses = {"LLWEAPONEX_BANNER_RALLY_DIVINEORDER_AURABONUS", "LLWEAPONEX_BANNER_RALLY_DWARVES_AURABONUS"},
			Param = ts:Create("hb5b69849g6862g4db5gaa63gd4dd69e56a9d","<font color='#C9AA58'>Immune to Flanking</font><br><font color='#33FF33'>Turn delaying reduces damage taken by [Stats:Stats_LLWEAPONEX_Banner_TurnDelayProtection:FireResistance]%.</font>"),
			Active = {Value = "LLWEAPONEX_Banner_Mastery4", Type = "Tag", Source=true}
		}
	}
},
LLWEAPONEX_Banner_Mastery5 = {},
LLWEAPONEX_BattleBook_Mastery1 = {
	BOOK_CONCUSSION = {
		Skills = BASIC_ATTACK,
		Param = ts:Create("h36b6a824g20a5g42acga0efg69102b1f801f", "<font color='#99AACC'>Basic attacks have a [ExtraData:LLWEAPONEX_MasteryBonus_Hit_BattleBook_ConcussionChance]% chance to give the target a Concussion for [ExtraData:LLWEAPONEX_MasteryBonus_Hit_BattleBook_ConcussionTurns] turn(s).</font>"),
	}
},
LLWEAPONEX_BattleBook_Mastery2 = {},
LLWEAPONEX_BattleBook_Mastery3 = {},
LLWEAPONEX_BattleBook_Mastery4 = {},
LLWEAPONEX_BattleBook_Mastery5 = {},
LLWEAPONEX_Bludgeon_Mastery1 = {
	RUSH_DIZZY = {
		Skills = RUSH_SKILLS,
		Param = ts:Create("h9831ecc7g21feg403cg9bd6ga0bab3f7eb9c", "Become a thundering force of will when rushing, <font color='#FFCE58'>knocking enemies aside</font> with a <font color='#F19824'>[ExtraData:LLWEAPONEX_MasteryBonus_RushDizzyChance]% chance to apply Dizzy for [ExtraData:LLWEAPONEX_MasteryBonus_RushDizzyTurns] turn(s)</font>.")
	}
},
LLWEAPONEX_Bludgeon_Mastery2 = {
	BLUDGEON_SUNDER = {
		Skills = {"Target_CripplingBlow","Target_EnemyCripplingBlow"},
		Param = ts:Create("h1eb09384g6bfeg4cdaga83fgc408d86cfee4","<font color='#F19824'>Sunder the armor of hit targets, reducing max <font color='#AE9F95'>[Handle:h1feadc00g239ag430bgac99g7b5f3605a1c1:Physical Armour]</font>/<font color='#4197E2'>[Handle:h50eb8e33g82edg412eg9886gec19ca591254:Magic Armour]</font> by <font color='#AE9F95'>[Stats:Stats_LLWEAPONEX_MasteryBonus_Sunder:ArmorBoost]%</font>/<font color='#4197E2'>[Stats:Stats_LLWEAPONEX_MasteryBonus_Sunder:MagicArmorBoost]%</font></font> for [ExtraData:LLWEAPONEX_MasteryBonus_CripplingBlow_SunderTurns] turn(s).</font>"),
		NamePrefix = "<font color='#F19824'>Sundering</font>"
	}
},
LLWEAPONEX_Bludgeon_Mastery3 = {
	BLUDGEON_GROUNDQUAKE = {
		Skills = {"Cone_GroundSmash","Cone_EnemyGroundSmash"},
		Param = ts:Create("h06eacec9g1d7fg46cagba45g3cde5062c8a8","A <font color='#F19824'>localized quake</font> is created where your weapon contacts the ground, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake] to enemies in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Bludgeon_Quake:ExplodeRadius]m radius.</font>"),
	}
},
LLWEAPONEX_Bludgeon_Mastery4 = {},
LLWEAPONEX_Bludgeon_Mastery5 = {},
LLWEAPONEX_Bow_Mastery1 = {
	BOW_DOUBLE_SHOT = {
		Skills = {"Projectile_PinDown", "Projectile_EnemyPinDown"},
		Param = ts:Create("h651d4f13ge5ddg4111g871cgf92fab041bd4","Shoot a <font color='#00FFAA'>second arrow</font> at a nearby enemy for [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_PinDown_BonusShot].<br><font color='#F19824'>If no enemies are nearby, the bonus arrow will fire at the original target.</font>")
	}
},
LLWEAPONEX_Bow_Mastery2 = {
	BOW_ASSASSINATE_MARKED = {
		Skills = {"Projectile_Snipe", "Projectile_EnemySnipe"},
		Param = ts:Create("hcf6a97abge09ag4075g9ecbg7595d841b33f","If the target is <font color='#FF3300'>Marked</font>, deal a <font color='#33FF33'>guaranteed critical hit</font> and bypass dodging/blocking. The mark is cleansed after hit."),
		StatusParam = {
			Statuses = {"MARKED"},
			Param = ts:Create("h7896d84dg032dg4651g9452g911a2b272668","<font color='#33FF00'>Character is vulnerable to a critical hit from [Key:Projectile_Snipe_DisplayName].</font>"),
			Active = {Value = "LLWEAPONEX_Bow_Mastery2", Type = "Tag", Source=true}
		}
	}
},
LLWEAPONEX_Bow_Mastery3 = {},
LLWEAPONEX_Bow_Mastery4 = {},
LLWEAPONEX_Bow_Mastery5 = {},
LLWEAPONEX_Crossbow_Mastery1 = {},
LLWEAPONEX_Crossbow_Mastery2 = {},
LLWEAPONEX_Crossbow_Mastery3 = {},
LLWEAPONEX_Crossbow_Mastery4 = {},
LLWEAPONEX_Crossbow_Mastery5 = {},
LLWEAPONEX_Dagger_Mastery1 = {
	DAGGER_THROWINGKNIFE = {
		Skills = {"Projectile_ThrowingKnife", "Projectile_EnemyThrowingKnife"},
		Param = ts:Create("hea8e7051gfc68g4d9dgaba8g7c871bbd4056","<font color='#F19824'>The knife thrown has a <font color='#CC33FF'>[ExtraData:LLWEAPONEX_MasteryBonus_ThrowingKnife_Chance]%</font> to be <font color='#00FFAA'>coated in poison or explosive oil</font>, dealing [SkillDamage:Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive] or [SkillDamage:Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison] on hit.</font>"),
	}
},
LLWEAPONEX_Dagger_Mastery2 = {},
LLWEAPONEX_Dagger_Mastery3 = {},
LLWEAPONEX_Dagger_Mastery4 = {},
LLWEAPONEX_Dagger_Mastery5 = {},
LLWEAPONEX_DualShields_Mastery1 = {},
LLWEAPONEX_DualShields_Mastery2 = {},
LLWEAPONEX_DualShields_Mastery3 = {},
LLWEAPONEX_DualShields_Mastery4 = {},
LLWEAPONEX_DualShields_Mastery5 = {},
LLWEAPONEX_Firearm_Mastery1 = {
	FIREARM_TACTICAL_RETREAT = {
		Skills = {"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"},
		Param = ts:Create("h6b4f5697g12aeg4ccdgba8bgccff2ba9aa56","<font color='#00FF99'>After jumping, your next action's AP cost is reduced by [Stats:Stats_LLWEAPONEX_MasteryBonus_Firearm_Retreat:APCostBoost].</font>")
	},
},
LLWEAPONEX_Firearm_Mastery2 = {},
LLWEAPONEX_Firearm_Mastery3 = {},
LLWEAPONEX_Firearm_Mastery4 = {},
LLWEAPONEX_Firearm_Mastery5 = {},
LLWEAPONEX_Greatbow_Mastery1 = {
	GREATBOW_RICOCHET = {
		Skills = {"Projectile_Ricochet", "Projectile_EnemyRicochet"},
		Param = ts:Create("h803a2376g5729g4d56g8c47gd7156ee5d348","<font color='#F19824'>Eat hit deals [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet] in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Greatbow_Ricochet:ExplodeRadius]m radius around the target.</font>")
	},
},
LLWEAPONEX_Greatbow_Mastery2 = {},
LLWEAPONEX_Greatbow_Mastery3 = {},
LLWEAPONEX_Greatbow_Mastery4 = {},
LLWEAPONEX_Greatbow_Mastery5 = {},
LLWEAPONEX_HandCrossbow_Mastery1 = {
	HANDCROSSBOW_JUMP_MARKING = {
		Skills = {"Jump_TacticalRetreat", "Jump_EnemyTacticalRetreat"},
		Param = ts:Create("h6939fc3dgf4b0g45abg9362g5a9d5c04654c","Automatically apply [Key:MARKED_DisplayName] to [ExtraData:LLWEAPONEX_MasteryBonus_TacticalRetreat_MaxMarkedTargets] target(s) max in a [ExtraData:LLWEAPONEX_MasteryBonus_TacticalRetreat_MarkingRadius]m radius when jumping away.")
	},
	WHIRLWIND_BOLTS = {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Param = ts:Create("h665d9b1age332g4988gb57cgd1357c4c9af2","<font color='#F19824'>While spinning, shoot [ExtraData:LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MinTargets]-[ExtraData:LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_MaxTargets] enemies in a [Stats:Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_FindTarget:ExplodeRadius]m radius, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Whirlwind_HandCrossbow_Shoot:LLWEAPONEX_HandCrossbow_ShootDamage].</font>"),
	}
},
LLWEAPONEX_HandCrossbow_Mastery2 = {},
LLWEAPONEX_HandCrossbow_Mastery3 = {},
LLWEAPONEX_HandCrossbow_Mastery4 = {},
LLWEAPONEX_HandCrossbow_Mastery5 = {},
LLWEAPONEX_Katana_Mastery1 = {
	--KATANA_COMBO = {},
	KATANA_VAULT = {
		Skills = {"MultiStrike_Vault", "MultiStrike_EnemyVault"},
		Param = ts:Create("h78ab607fgbbb0g46adgb3f9g271749a251bf","<font color='#F19966'>After teleporting, your next basic attack or weapon skill will deal +[ExtraData:LLWEAPONEX_MasteryBonus_Katana_VaultDamageBonus]% additional damage.</font>"),
	},
},
LLWEAPONEX_Katana_Mastery2 = {},
LLWEAPONEX_Katana_Mastery3 = {},
LLWEAPONEX_Katana_Mastery4 = {},
LLWEAPONEX_Katana_Mastery5 = {},
LLWEAPONEX_Pistol_Mastery1 = {
	PISTOL_ADRENALINE = {
		Skills = {"Shout_Adrenaline", "Shout_EnemyAdrenaline"},
		Param = ts:Create("h1bd0f691g9646g4b28g932fg3ebd8377ca0e","Gain hyper-focus, increasing the <font color='#33FF00'>damage of the next shot of your pistol by [ExtraData:LLWEAPONEX_MasteryBonus_Adrenaline_PistolDamageBoost]%</font>."),
		StatusParam = {
			Statuses = {"ADRENALINE"},
			Param = ts:Create("hb6293431g0ad9g45bbg9334gb81365e8f2ca","<font color='#33FF00'>Your next pistol shot will deal [ExtraData:LLWEAPONEX_MasteryBonus_Adrenaline_PistolDamageBoost]% more damage.</font>"),
			Active = {Value = "LLWEAPONEX_Pistol_Adrenaline_Active", Type = "Tag"}
		}
	},
	PISTOL_CLOAKEDJUMP = {
		Skills = {"Jump_CloakAndDagger", "Jump_EnemyCloakAndDagger"},
		Param = ts:Create("h62876a23g9b5cg4463g99dfg41e1192b02ab","Automatically reload your pistol when jumping.<br>When landing, apply [Key:MARKED_DisplayName] to the closest enemy within [ExtraData:LLWEAPONEX_MasteryBonus_CloakAndDagger_MarkingRadius]m ([ExtraData:LLWEAPONEX_MasteryBonus_CloakAndDagger_MaxMarkedTargets] target(s) max).<br>Shooting targets [Key:MARKED_DisplayName] this way, with your pistol, guarantees one critical hit until you end your turn.")
	}
},
LLWEAPONEX_Pistol_Mastery2 = {},
LLWEAPONEX_Pistol_Mastery3 = {},
LLWEAPONEX_Pistol_Mastery4 = {},
LLWEAPONEX_Pistol_Mastery5 = {},
LLWEAPONEX_Polearm_Mastery1 = {},
LLWEAPONEX_Polearm_Mastery2 = {},
LLWEAPONEX_Polearm_Mastery3 = {},
LLWEAPONEX_Polearm_Mastery4 = {},
LLWEAPONEX_Polearm_Mastery5 = {},
LLWEAPONEX_Quarterstaff_Mastery1 = {},
LLWEAPONEX_Quarterstaff_Mastery2 = {},
LLWEAPONEX_Quarterstaff_Mastery3 = {},
LLWEAPONEX_Quarterstaff_Mastery4 = {},
LLWEAPONEX_Quarterstaff_Mastery5 = {},
LLWEAPONEX_Rapier_Mastery1 = {
	SUCKER_PUNCH_COMBO = {
		Skills = {"Target_SingleHandedAttack", "Target_LLWEAPONEX_SinglehandedAttack"},
		Param = ts:Create("hd40f14d5g4946g4462gac7bga35fda61ed27","Gain a follow-up combo skill ([Key:Target_LLWEAPONEX_Rapier_SuckerCombo1_DisplayName]) after punching a target.<br><font color='#99FF22' size='22'>[ExtraData:LLWEAPONEX_MasteryBonus_SuckerPunch_KnockdownTurnExtensionChance]% chance to increase Knockdown by 1 turn.</font>")
	}
},
LLWEAPONEX_Rapier_Mastery2 = {},
LLWEAPONEX_Rapier_Mastery3 = {},
LLWEAPONEX_Rapier_Mastery4 = {},
LLWEAPONEX_Rapier_Mastery5 = {},
LLWEAPONEX_Runeblade_Mastery1 = {},
LLWEAPONEX_Runeblade_Mastery2 = {},
LLWEAPONEX_Runeblade_Mastery3 = {},
LLWEAPONEX_Runeblade_Mastery4 = {},
LLWEAPONEX_Runeblade_Mastery5 = {},
LLWEAPONEX_Scythe_Mastery1 = {
	SCYTHE_RUPTURE = {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Param = ts:Create("h5ca24bfeg14f5g437fg92fag4708f87547de","<font color='#DC143C'>Rupture</font> the wounds of <font color='#FF0000'>Bleeding</font> targets, dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_WhirlwindRuptureBleeding] for each turn of <font color='#FF0000'>Bleeding</font> remaining.")
	}
},
LLWEAPONEX_Scythe_Mastery2 = {},
LLWEAPONEX_Scythe_Mastery3 = {},
LLWEAPONEX_Scythe_Mastery4 = {},
LLWEAPONEX_Scythe_Mastery5 = {},
LLWEAPONEX_Shield_Mastery1 = {
	GUARANTEED_BLOCK = {
		Skills = {"Shout_RecoverArmour"},
		Param = ts:Create("h6a284017g342dg4809gab69g6e77bddaf8c2","Damage from the next direct hit taken is reduced by <font color='#33FF00'>[ExtraData:LLWEAPONEX_MasteryBonus_RecoverArmour_DamageReduction]%</font>."),
	}
},
LLWEAPONEX_Shield_Mastery2 = {},
LLWEAPONEX_Shield_Mastery3 = {},
LLWEAPONEX_Shield_Mastery4 = {},
LLWEAPONEX_Shield_Mastery5 = {},
LLWEAPONEX_Staff_Mastery1 = {
	ELEMENTAL_WEAKNESS = {
		Skills = {"Shout_Whirlwind", "Shout_EnemyWhirlwind"},
		Param = ELEMENTAL_WEAKNESS_BASE.Param,
		GetParam = ELEMENTAL_WEAKNESS_BASE.GetParam,
	}
},
LLWEAPONEX_Staff_Mastery2 = {},
LLWEAPONEX_Staff_Mastery3 = {},
LLWEAPONEX_Staff_Mastery4 = {},
LLWEAPONEX_Staff_Mastery5 = {},
LLWEAPONEX_Sword_Mastery1 = {},
LLWEAPONEX_Sword_Mastery2 = {},
LLWEAPONEX_Sword_Mastery3 = {},
LLWEAPONEX_Sword_Mastery4 = {},
LLWEAPONEX_Sword_Mastery5 = {},
LLWEAPONEX_ThrowingAbility_Mastery1 = {},
LLWEAPONEX_ThrowingAbility_Mastery2 = {},
LLWEAPONEX_ThrowingAbility_Mastery3 = {},
LLWEAPONEX_ThrowingAbility_Mastery4 = {},
LLWEAPONEX_ThrowingAbility_Mastery5 = {},
LLWEAPONEX_Unarmed_Mastery1 = {
	PETRIFYING_SLAM = {
		Skills = {"Target_PetrifyingTouch", "Target_EnemyPetrifyingTouch"},
		Param = ts:Create("h01468f79gd9b2g4479ga596g8a68e07c39e7","<font color='#FFCE58'>Slam the target with your palm, knocking them back [ExtraData:LLWEAPONEX_MasteryBonus_PetrifyingTouch_KnockbackDistance]m and dealing [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_PetrifyingTouchBonusDamage].</font>")
	}
},
LLWEAPONEX_Unarmed_Mastery2 = {},
LLWEAPONEX_Unarmed_Mastery3 = {},
LLWEAPONEX_Unarmed_Mastery4 = {},
LLWEAPONEX_Unarmed_Mastery5 = {},
LLWEAPONEX_Wand_Mastery1 = {
	ELEMENTAL_WEAKNESS = {
		Skills = {"Target_LLWEAPONEX_BasicAttack"},
		Param = ELEMENTAL_WEAKNESS_BASE.Param,
		GetParam = ELEMENTAL_WEAKNESS_BASE.GetParam,
	},
	BLOOD_EMPOWER = {
		Skills = {"Shout_FleshSacrifice", "Shout_EnemyFleshSacrifice"},
		Param = ts:Create("h0ad1536cg0e74g46dag8e1egc15967242d14","<font color='#CC33FF'>Allies standing on <font color='#F13324'>blood surfaces</font> or in <font color='#F13324'>blood clouds</font> gain a [Stats:Stats_LLWEAPONEX_BloodEmpowered:DamageBoost]% damage bonus.</font>")
	}
},
LLWEAPONEX_Wand_Mastery2 = {},
LLWEAPONEX_Wand_Mastery3 = {},
LLWEAPONEX_Wand_Mastery4 = {},
LLWEAPONEX_Wand_Mastery5 = {},
}

local BonusIDEntry = MasteryDataClasses.BonusIDEntry

function Mastery.InitBonusIdentifiers()
	for tag,tbl in pairs(Mastery.Bonuses) do
		for bonusName,bonusEntry in pairs(tbl) do
			if Mastery.BonusID[bonusName] == nil then
				Mastery.BonusID[bonusName] = BonusIDEntry:Create(bonusName)
			end
			Mastery.BonusID[bonusName].Tags[tag] = bonusEntry
			if bonusEntry.Skills ~= nil then
				for i,v in pairs(bonusEntry.Skills) do
					if Mastery.Params.SkillData[v] == nil then
						Mastery.Params.SkillData[v] = {
							Tags = {}
						}
					end
					Mastery.Params.SkillData[v].Tags[tag] = bonusEntry
				end
			end
			if bonusEntry.StatusParam ~= nil then
				for i,v in pairs(bonusEntry.StatusParam.Statuses) do
					if Mastery.Params.StatusData[v] == nil then
						Mastery.Params.StatusData[v] = {
							Tags = {}
						}
					end
					Mastery.Params.StatusData[v].Tags[tag] = bonusEntry.StatusParam
				end
			end
		end
	end
end
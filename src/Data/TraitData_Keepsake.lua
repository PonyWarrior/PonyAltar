local textfile = rom.path.combine(rom.paths.Content, 'Game/Text/en/TraitText.en.sjson')

local ids_to_descriptions = {
	ForceZeusBoonKeepsake = "While you have {$Keywords.ReserveMana} Magick{!Icons.Mana}, your {$Keywords.Omega} use {#ManaFormat}{$TooltipData.ExtractData.ManaDelta:F} {#Prev}less Magick{!Icons.Mana}.",
	ForceZeusBoonKeepsake_Inactive = "While you have {$Keywords.ReserveMana} Magick{!Icons.Mana}, your {$Keywords.Omega} use {#ManaFormat}{$TooltipData.ExtractData.ManaDelta:F} {#Prev}less Magick{!Icons.Mana}.",

	ForcePoseidonBoonKeepsake = "Slain enemies drop {#MoneyFormatBold}+{$TooltipData.ExtractData.TooltipHeal:F} {!Icons.Currency}{#Prev}.",
	ForcePoseidonBoonKeepsake_Inactive = "Slain enemies drop {#MoneyFormatBold}+{$TooltipData.ExtractData.TooltipHeal:F} {!Icons.Currency}{#Prev}.",

	ForceApolloBoonKeepsake = "Extends the invulnerability period of your {$Keywords.Dash} by {#AltUpgradeFormat}{$TooltipData.ExtractData.TooltipMultiplier:F}{#Prev}.",
	ForceApolloBoonKeepsake_Inactive = "Extends the invulnerability period of your {$Keywords.Dash} by {#AltUpgradeFormat}{$TooltipData.ExtractData.TooltipMultiplier:F}{#Prev}.",

	ForceHestiaBoonKeepsake = "All your damage is increased by {#AltUpgradeFormat}{$TooltipData.ExtractData.TooltipDamage:F} {#Prev}, but you have {#PenaltyFormat}{$TooltipData.ExtractData.HealthPenalty:P}{#Prev}{!Icons.HealthDown}.",
	ForceHestiaBoonKeepsake_Inactive = "All your damage is increased by {#AltUpgradeFormat}{$TooltipData.ExtractData.TooltipDamage:F} {#Prev}, but you have {#PenaltyFormat}{$TooltipData.ExtractData.HealthPenalty:P}{#Prev}{!Icons.HealthDown}.",

	ForceHephaestusBoonKeepsake = "You gain {#AltUpgradeFormat}{$TooltipData.ExtractData.TooltipArmor:F} {#Prev} of all {!Icons.HealthUp} rewards as {!Icons.ArmorTotal}.",
	ForceHephaestusBoonKeepsake_Inactive = "You gain {#AltUpgradeFormat}{$TooltipData.ExtractData.TooltipArmor:F} {#Prev} of all {!Icons.HealthUp} rewards as {!Icons.ArmorTotal}.",

	ForceAphroditeBoonKeepsake = "Increases your chances to receive a {$Keywords.GodBoon} of higher {$Keywords.Rarity}. {#RareFormat}Rare {#Prev}{#AltUpgradeFormat}{$TooltipData.ExtractData.RareBonus:P} {#Prev}, {#EpicFormat}Epic {#Prev}{#AltUpgradeFormat}{$TooltipData.ExtractData.EpicBonus:P} {#Prev}and {#DuoFormat}Duo {#Prev}{#AltUpgradeFormat}{$TooltipData.ExtractData.DuoBonus:P} {#Prev}.",
	ForceAphroditeBoonKeepsake_Inactive = "Increases your chances to receive a {$Keywords.GodBoon} of higher {$Keywords.Rarity}. {#RareFormat}Rare {#Prev}{#AltUpgradeFormat}{$TooltipData.ExtractData.RareBonus:P} {#Prev}, {#EpicFormat}Epic {#Prev}{#AltUpgradeFormat}{$TooltipData.ExtractData.EpicBonus:P} {#Prev}and {#DuoFormat}Duo {#Prev}{#AltUpgradeFormat}{$TooltipData.ExtractData.DuoBonus:P} {#Prev}.",

	ForceDemeterBoonKeepsake = "While under {#BoldFormatGraft}{$TooltipData.ExtractData.Health:F}{#Prev}{!Icons.Health}, your {$Keywords.Omega} use {#ManaFormat}{$TooltipData.ExtractData.ManaDelta:F} {#Prev}less Magick{!Icons.Mana}.",
	ForceDemeterBoonKeepsake_Inactive = "While under {#BoldFormatGraft}{$TooltipData.ExtractData.Health:F}{#Prev}{!Icons.Health}, your {$Keywords.Omega} use {#ManaFormat}{$TooltipData.ExtractData.ManaDelta:F} {#Prev}less Magick{!Icons.Mana}.",

	ForceHeraBoonKeepsake = "Your {$Keywords.Attack} and {$Keywords.Special} each deal {#AltUpgradeFormat}{$TooltipData.ExtractData.TooltipBonus:P} {#Prev}damage while not empowered by a {$Keywords.GodBoon}.",
	ForceHeraBoonKeepsake_Inactive = "Your {$Keywords.Attack} and {$Keywords.Special} each deal {#AltUpgradeFormat}{$TooltipData.ExtractData.TooltipBonus:P} {#Prev}damage while not empowered by a {$Keywords.GodBoon}.",
}

sjson.hook(textfile, function(sjsonData)
	for _, v in ipairs(sjsonData.Texts) do
		local description = ids_to_descriptions[v.Id]
		if description then v.Description = description end
	end
end)

Keepsakes = {
	BaseBoonUpgradeKeepsake =
	{
		InheritFrom = { "GiftTrait" },
		DoesNotAutomaticallyExpire = true,
		RarityLevels = {
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 2,
			},
			Epic =
			{
				Multiplier = 3,
			},
			Heroic =
			{
				Multiplier = 4,
			},
		}
	},
	AltarBoon = {
		Name = "AltarBoon",
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "GUI\\Screens\\Codex\\Icon-Unseen",
		Slot = "Altar",
		Hidden = true,
		-- ForceBoonName = "",
		RarityUpgradeData =
		{
			LootName = "",
			Uses = 1,
			MaxRarity = 1,
		},
		Uses = 1,
	},
	ForceZeusBoonKeepsake =
	{
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "Keepsake_46",
		EquipSound = "/SFX/Menu Sounds/KeepsakeZeusRing",
		InRackTitle = "ForceZeusBoonKeepsake_Rack",
		ManaCostModifiers =
		{
			WeaponNames = WeaponSets.HeroAllWeapons,
			ManaCostMultiplierWhilePrimed = { BaseValue = 0.9 },
			ReportValues = { ReportedManaCost = "ManaCostMultiplierWhilePrimed" }
		},
		ExtractValues =
		{
			{
				Key = "ReportedManaCost",
				ExtractAs = "ManaDelta",
				Format = "PercentDelta",
			},
		},
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 0.89,
			},
			Epic =
			{
				Multiplier = 0.78,
			},
			Heroic =
			{
				Multiplier = 0.67,
			}
		},
		EquipVoiceLines =
		{
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				SuccessiveChanceToPlay = 0.2,
				Cooldowns =
				{
					{ Name = "MelinoeAnyQuipSpeech" },
				},

				{ Cue = "/VO/Melinoe_3190", Text = "The Bangle." },
			},
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				RandomRemaining = true,
				ChanceToPlay = 0.25,
				Source = { LineHistoryName = "NPC_Zeus_01", SubtitleColor = Color.ZeusVoice },
				GameStateRequirements =
				{
					{
						PathTrue = { "GameState", "TextLinesRecord", "ZeusGift03" },
					},
				},
				Cooldowns =
				{
					{ Name = "KeepsakeGiverSpeechPlayedRecently", Time = 90 },
				},
				{ Cue = "/VO/ZeusKeepsake_0184", Text = "Young lady." },
				{ Cue = "/VO/ZeusKeepsake_0185", Text = "Melinoë." },
			},
			[3] = GlobalVoiceLines.AwardSelectedVoiceLines,
		},
		SignOffData =
		{
			{
				Text = "SignoffZeus",
			},
		},
	},
	ForcePoseidonBoonKeepsake =
	{
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "Keepsake_48",
		EquipSound = "/SFX/Menu Sounds/KeepsakePoseidonShell",
		InRackTitle = "ForcePoseidonBoonKeepsake_Rack",
		KillMoneyMultiplier = { BaseValue = 1 },
		ExtractValues =
		{
			{
				Key = "KillMoneyMultiplier",
				ExtractAs = "TooltipHeal",
				Format = "Percent"
			},
		},
		EquipVoiceLines =
		{
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				SuccessiveChanceToPlay = 0.2,
				Cooldowns =
				{
					{ Name = "MelinoeAnyQuipSpeech" },
				},

				{ Cue = "/VO/Melinoe_3192", Text = "The Sea." },
			},
			[2] = GlobalVoiceLines.AwardSelectedVoiceLines,
		},
		SignOffData =
		{
			{
				Text = "SignoffPoseidon",
			},
		},
	},
	ForceApolloBoonKeepsake =
	{
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "Keepsake_50",
		EquipSound = "/SFX/Menu Sounds/KeepsakeDionysusCup",
		InRackTitle = "ForceApolloBoonKeepsake_Rack",
		TooltipMultiplier = { BaseValue = 1.2 },
		PropertyChanges = {
			{
				WeaponName = "WeaponBlink",
				EffectName = "RushWeaponInvulnerable",
				EffectProperty = "Duration",
				BaseValue = 1.2,
				ChangeType = "Multiply",
				ExcludeLinked = true,
			},
			{
				WeaponName = "WeaponBlink",
				EffectName = "RushWeaponInvulnerableCharge",
				EffectProperty = "Duration",
				BaseValue = 1.2,
				ChangeType = "Multiply",
				ExcludeLinked = true,
			},
		},
		ExtractValues =
		{
			{
				Key = "TooltipMultiplier",
				ExtractAs = "TooltipMultiplier",
				Format = "PercentDelta",
			},
		},
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.125,
			},
			Epic =
			{
				Multiplier = 1.25,
			},
			Heroic =
			{
				Multiplier = 1.375,
			}
		},
		EquipVoiceLines =
		{
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				SuccessiveChanceToPlay = 0.2,
				Cooldowns =
				{
					{ Name = "MelinoeAnyQuipSpeech" },
				},

				{ Cue = "/VO/Melinoe_3193", Text = "The Hope." },
			},
			[2] = GlobalVoiceLines.AwardSelectedVoiceLines,
		},
		SignOffData =
		{
			{
				Text = "SignoffApollo",
			},
		},
	},
	ForceHestiaBoonKeepsake =
	{
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "Keepsake_53",
		EquipSound = "/SFX/Menu Sounds/KeepsakeAthenaOwl",
		InRackTitle = "ForceHestiaBoonKeepsake_Rack",
		MaxHealthMultiplier = 0.80,
		AddOutgoingDamageModifiers =
		{
			ValidWeapons = WeaponSets.HeroAllWeapons,
			ValidWeaponMultiplier = { BaseValue = 1.05 },
			ReportValues =
			{
				ReportedDamageBonus = "ValidWeaponMultiplier",
			}
		},
		PropertyChanges =
		{
			{
				LuaProperty = "MaxHealth",
				ChangeValue = 0.80,
				ChangeType = "Multiply",
				SourceIsMultiplier = true,
				MaintainDelta = true,
				ReportValues = { ReportedHealthPenalty = "ChangeValue" }
			},
		},
		ExtractValues =
		{
			{
				Key = "ReportedDamageBonus",
				ExtractAs = "TooltipDamage",
				Format = "PercentDelta",
			},
			{
				Key = "ReportedHealthPenalty",
				ExtractAs = "HealthPenalty",
				Format = "PercentDelta",
				SkipAutoExtract = true,
			},
		},
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.05,
			},
			Epic =
			{
				Multiplier = 1.1,
			},
			Heroic =
			{
				Multiplier = 1.15,
			}
		},
		EquipVoiceLines =
		{
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				SuccessiveChanceToPlay = 0.2,
				Cooldowns =
				{
					{ Name = "MelinoeAnyQuipSpeech" },
				},

				{ Cue = "/VO/Melinoe_3197", Text = "The Ember." },
			},
			[2] = GlobalVoiceLines.AwardSelectedVoiceLines,
		},
		SignOffData =
		{
			{
				Text = "SignoffHestia",
			},
		},
	},
	ForceHephaestusBoonKeepsake =
	{
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "Keepsake_52",
		EquipSound = "/SFX/Menu Sounds/KeepsakeZeusRing",
		InRackTitle = "ForceHephaestusBoonKeepsake_Rack",
		HealingToArmor = { BaseValue = 0.2 },
		ExtractValues =
		{
			{
				Key = "HealingToArmor",
				ExtractAs = "TooltipArmor",
				Format = "Percent",
			},
		},
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.75,
			},
			Epic =
			{
				Multiplier = 2.5,
			},
			Heroic =
			{
				Multiplier = 3.75,
			}
		},
		EquipVoiceLines =
		{
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				SuccessiveChanceToPlay = 0.2,
				Cooldowns =
				{
					{ Name = "MelinoeAnyQuipSpeech" },
				},

				{ Cue = "/VO/Melinoe_3196", Text = "The Shard." },
			},
			[2] = GlobalVoiceLines.AwardSelectedVoiceLines,
		},
		SignOffData =
		{
			{
				Text = "SignoffHephaestus",
			},
		},
	},
	ForceDemeterBoonKeepsake =
	{
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "Keepsake_49",
		EquipSound = "/SFX/Menu Sounds/KeepsakeDemeterHorn",
		InRackTitle = "ForceDemeterBoonKeepsake_Rack",
		ManaCostModifiers =
		{
			LowHealthThreshold = 0.5,
			WeaponNames = WeaponSets.HeroAllWeapons,
			ManaCostMultiplierWhileLowHealth = { BaseValue = 0.6 },
			ReportValues = {
				ReportedManaCost = "ManaCostMultiplierWhileLowHealth",
				ReportedThreshold = "LowHealthThreshold",
			}
		},
		ExtractValues =
		{
			{
				Key = "ReportedManaCost",
				ExtractAs = "ManaDelta",
				Format = "PercentDelta",
			},
			{
				Key = "ReportedThreshold",
				ExtractAs = "Health",
				Format = "Percent",
			},
		},
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 0.67,
			},
			Epic =
			{
				Multiplier = 0.33,
			},
			Heroic =
			{
				Multiplier = 0.0,
			}
		},
		EquipVoiceLines =
		{
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				SuccessiveChanceToPlay = 0.2,
				Cooldowns =
				{
					{ Name = "MelinoeAnyQuipSpeech" },
				},

				{ Cue = "/VO/Melinoe_3194", Text = "The Sheaf." },
			},
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				RandomRemaining = true,
				ChanceToPlay = 0.25,
				Source = { LineHistoryName = "NPC_Demeter_01", SubtitleColor = Color.DemeterVoice },
				GameStateRequirements =
				{
					{
						PathTrue = { "GameState", "TextLinesRecord", "DemeterGift03" },
					},
				},
				Cooldowns =
				{
					{ Name = "KeepsakeGiverSpeechPlayedRecently", Time = 90 },
				},
				{ Cue = "/VO/DemeterKeepsake_0153", Text = "Granddaughter." },
				{ Cue = "/VO/DemeterKeepsake_0155", Text = "Melinoë." },
			},
			[3] = GlobalVoiceLines.AwardSelectedVoiceLines,
		},
		SignOffData =
		{
			{
				Text = "SignoffDemeter",
			},
		},
	},
	ForceAphroditeBoonKeepsake =
	{
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "Keepsake_51",
		EquipSound = "/SFX/Menu Sounds/KeepsakeAphroditeRose",
		InRackTitle = "ForceAphroditeBoonKeepsake_Rack",
		RarityBonus =
		{
			Rare = { BaseValue = 0.10 },
			Epic = { BaseValue = 0.034 },
			Duo = { BaseValue = 0.02 },
			ReportValues = {
				ReportedRareRarityBonus = "Rare",
				ReportedEpicRarityBonus = "Epic",
				ReportedDuoRarityBonus = "Duo",
			}

		},
		ExtractValues =
		{
			{
				Key = "ReportedRareRarityBonus",
				ExtractAs = "RareBonus",
				Format = "Percent",
			},
			{
				Key = "ReportedEpicRarityBonus",
				ExtractAs = "EpicBonus",
				Format = "Percent",
			},
			{
				Key = "ReportedDuoRarityBonus",
				ExtractAs = "DuoBonus",
				Format = "Percent",
			},
		},
		EquipVoiceLines =
		{
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				SuccessiveChanceToPlay = 0.2,
				Cooldowns =
				{
					{ Name = "MelinoeAnyQuipSpeech" },
				},

				{ Cue = "/VO/Melinoe_3195", Text = "The Mirror." },
			},
			[2] = GlobalVoiceLines.AwardSelectedVoiceLines,
		},
		SignOffData =
		{
			{
				Text = "SignoffAphrodite",
			},
		},
	},
	ForceHeraBoonKeepsake =
	{
		InheritFrom = { "BaseBoonUpgradeKeepsake" },
		Icon = "Keepsake_47",
		EquipSound = "/SFX/Menu Sounds/KeepsakeAthenaOwl",
		InRackTitle = "ForceHeraBoonKeepsake_Rack",
		-- TooltipMultiplier = { BaseValue = 1.5 },
		-- VisualActivationRequirements = 
		-- {
		-- 	{
		-- 		{
		-- 			PathFalse = { "CurrentRun", "Hero", "SlottedTraits", "Melee" },
		-- 		},
		-- 	},
		-- 	{
		-- 		{
		-- 			PathFalse = { "CurrentRun", "Hero", "SlottedTraits", "Secondary" },
		-- 		},
		-- 	},

		-- },
		AddOutgoingDamageModifiers =
		{
			EmptySlotMultiplier = {
				BaseValue = 1.5,
				SourceIsMultiplier = true,
			},
			EmptySlotValidData =
			{
				--Ranged = WeaponSets.HeroNonPhysicalWeapons,
				Melee = WeaponSets.HeroPrimaryWeapons,
				Secondary = WeaponSets.HeroSecondaryWeapons,
			},
			ReportValues = { ReportedWeaponMultiplier = "EmptySlotMultiplier"},
		},
		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.5,
			},
			Epic =
			{
				Multiplier = 2.0,
			},
			Heroic =
			{
				Multiplier = 2.5,
			}
		},
		ExtractValues =
		{
			{
				Key = "ReportedWeaponMultiplier",
				ExtractAs = "TooltipBonus",
				Format = "PercentDelta",
			},
		},
		EquipVoiceLines =
		{
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				SuccessiveChanceToPlay = 0.2,
				Cooldowns =
				{
					{ Name = "MelinoeAnyQuipSpeech" },
				},

				{ Cue = "/VO/Melinoe_3191", Text = "The Fan." },
			},
			{
				PreLineWait = 0.3,
				BreakIfPlayed = true,
				RandomRemaining = true,
				ChanceToPlay = 0.25,
				Source = { LineHistoryName = "NPC_Hera_01", SubtitleColor = Color.HeraVoice },
				GameStateRequirements =
				{
					{
						PathTrue = { "GameState", "TextLinesRecord", "HeraGift03" },
					},
				},
				Cooldowns =
				{
					{ Name = "KeepsakeGiverSpeechPlayedRecently", Time = 90 },
				},
				{ Cue = "/VO/HeraKeepsake_0160", Text = "Yes, my dear?" },
				{ Cue = "/VO/HeraKeepsake_0161", Text = "Regards." },
			},
			[3] = GlobalVoiceLines.AwardSelectedVoiceLines,
		},
		SignOffData =
		{
			{
				Text = "SignoffHera",
			},
		},
	},
}

for key, keepsake in pairs(Keepsakes) do
	TraitData[key] = keepsake
end

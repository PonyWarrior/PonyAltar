---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

mod = modutil.mod.Mod.Register(_PLUGIN.guid)

table.insert(HubRoomData.Hub_PreRun.StartUnthreadedEvents,
	{
		FunctionName = _PLUGIN.guid .. '.' .. 'SpawnAltar'
	})

ModUtil.Table.Merge(ScreenData, {
	PonyAltar = {
		Components = {},
		OpenSound = "/SFX/Menu Sounds/HadesLocationTextAppear",
		Name = "PonyAltar",
		RowStartX = 145,
		RowStartY = ScreenCenterY,
		IncrementX = 190,
		ItemOrder = {
			"ZeusGift01",
			"PoseidonGift01",
			"ApolloGift01",
			"AphroditeGift01",
			"DemeterGift01",
			"HephaestusGift01",
			"HestiaGift01",
			"HeraGift01",
			"ChaosGift01",
			"SeleneGift01",
			"ArtemisGift01",
			"AthenaGift01",
		},

		ComponentData =
		{
			DefaultGroup = "Combat_Menu_TraitTray",
			UseNativeScreenCenter = true,
			Order = {
				"BackgroundTint",
				"Background"
			},

			BackgroundTint =
			{
				Graphic = "rectangle01",
				GroupName = "Combat_Menu",
				Scale = 10,
				X = ScreenCenterX,
				Y = ScreenCenterY,
			},

			Background =
			{
				AnimationName = "Box_FullScreen",
				GroupName = "Combat_Menu",
				X = ScreenCenterX,
				Y = ScreenCenterY,
				Scale = 1.15,
				Text = "Altar of the Gods",
				TextArgs =
				{
					FontSize = 32,
					Width = 750,
					OffsetY = -(ScreenCenterY * 0.825),
					Color = Color.White,
					Font = "P22UndergroundSCHeavy",
					ShadowBlur = 0,
					ShadowColor = { 0, 0, 0, 0 },
					ShadowOffset = { 0, 3 },
				},

				Children =
				{
					CloseButton =
					{
						Graphic = "ButtonClose",
						GroupName = "Combat_Menu_TraitTray",
						Scale = 0.7,
						OffsetX = 0,
						OffsetY = ScreenCenterY - 70,
						Data =
						{
							OnPressedFunctionName = _PLUGIN.guid .. '.' .. 'ClosePonyAltar',
							ControlHotkeys = { "Cancel", },
						},
					},
				}
			},
		}
	}
})

local BoonColors = {
	Color.BoonPatchCommon,
	Color.BoonPatchRare,
	Color.BoonPatchEpic,
	Color.BoonPatchHeroic
}

function mod.SpawnAltar()
	local unlocked = true
	if unlocked then
		-- Card altar
		local spawnId = 589766
		local altar = DeepCopyTable(ObstacleData.GiftRack)
		altar.OnUsedFunctionName = _PLUGIN.guid .. '.' .. 'OpenAltarMenu'
		altar.ObjectId = SpawnObstacle({
			Name = "GiftRack",
			Group = "Standing",
			DestinationId = spawnId,
			AttachedTable =
				altar,
			OffsetX = 1050,
			OffsetY = 300
		})
		altar.ActivateIds = { altar.ObjectId }
		SetScale({ Id = altar.ObjectId, Fraction = 0.1 })
		SetupObstacle(altar)
		AddToGroup({ Id = altar.ObjectId, Name = "PonyAltar.Altar" })
	end
end

function mod.OpenAltarMenu()
	if IsScreenOpen("PonyAltar") then
		return
	end

	local screen = DeepCopyTable(ScreenData.PonyAltar)
	screen.SelectedGod = mod.Data.SelectedGod or "No God selected"
	local components = screen.Components
	local children = screen.ComponentData.Background.Children
	HideCombatUI(screen.Name)
	OnScreenOpened(screen)
	CreateScreenFromData(screen, screen.ComponentData)

	components.GodTextbox = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray" })
	Attach({ Id = components.GodTextbox.Id, DestinationId = components.Background.Id, OffsetX = 0, OffsetY = 300 })
	CreateTextBox({
		Id = components.GodTextbox.Id,
		Text = screen.SelectedGod,
		FontSize = 22,
		OffsetX = 0,
		OffsetY = 0,
		Width = 720,
		Color = Color.White,
		Font = "P22UndergroundSCMedium",
		ShadowBlur = 0,
		ShadowColor = { 0, 0, 0, 1 },
		ShadowOffset = { 0, 2 },
		Justification = "Center"
	})

	-- SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
	SetColor({ Id = components.BackgroundTint.Id, Color = Color.Black })
	SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })

	-- wait(0.3)

	--Display
	local index = 0
	local rowOffset = 300
	local columnOffset = 190
	local boonsPerRow = 9
	local rowsPerPage = 99
	local rowoffsetX = 200
	local rowoffsetY = 350

	for _, value in ipairs(screen.ItemOrder) do
		if GameState.TextLinesRecord[value] then
			local godName = string.gsub(value, "Gift01", "")
			local upgradeName = godName .. "Upgrade"
			local key = "God" .. index
			local buttonKey = "Button" .. index
			local fraction = 0.1
			local keepsakeTraitName = "Force" .. godName .. "BoonKeepsake"
			if godName == "Selene" then
				upgradeName = "SpellDrop"
				keepsakeTraitName = "SpellTalentKeepsake"
			elseif godName == "Artemis" then
				upgradeName = "NPC_Artemis_01"
				keepsakeTraitName = "LowHealthCritKeepsake"
			elseif godName == "Athena" then
				upgradeName = "NPC_Athena_01"
				keepsakeTraitName = "AthenaEncounterKeepsake"
			elseif godName == "Chaos" then
				upgradeName = "TrialUpgrade"
				keepsakeTraitName = "RandomBlessingKeepsake"
			end

			if CurrentRun.Hero.IsDead or CurrentRun.TraitCache[upgradeName] == nil then
				local rowIndex = math.floor(index / boonsPerRow)
				local offsetX = rowoffsetX + columnOffset * (index % boonsPerRow)
				local offsetY = rowoffsetY + rowOffset * (rowIndex % rowsPerPage)
				local level = GetKeepsakeLevel(keepsakeTraitName)
				index = index + 1


				components[buttonKey] = CreateScreenComponent({
					Name = "ButtonDefault",
					-- X = screen.RowStartX + 200,
					-- Y = screen.RowStartY - 500,
					Scale = 1.0,
					Group = "Combat_Menu_TraitTray",
					Color = BoonColors[level]
				})
				components[buttonKey].Image = key
				components[buttonKey].God = upgradeName
				components[buttonKey].Level = level
				components[buttonKey].Index = index
				SetScaleX({ Id = components[buttonKey].Id, Fraction = 0.69 })
				SetScaleY({ Id = components[buttonKey].Id, Fraction = 3.8 })
				components[key] = CreateScreenComponent({
					Name = "BlankObstacle",
					-- X = screen.RowStartX + 200,
					-- Y = screen.RowStartY - 500,
					Scale = 1.2,
					Group = "Combat_Menu_TraitTray"
				})

				SetThingProperty({ Property = "Ambient", Value = 0.0, DestinationId = components[key].Id })
				components[buttonKey].OnPressedFunctionName = mod.SelectGod
				fraction = 1.0

				SetAlpha({ Ids = { components[key].Id, components[buttonKey].Id }, Fraction = 0 })
				SetAlpha({ Ids = { components[key].Id, components[buttonKey].Id }, Fraction = fraction, Duration = 0.9 })
				SetAnimation({ DestinationId = components[key].Id, Name = "Codex_Portrait_" .. godName, Scale = 0.4 })
				local delay = RandomFloat(0.1, 0.5)
				Move({
					Ids = { components[key].Id, components[buttonKey].Id },
					OffsetX = offsetX,
					OffsetY = offsetY,
					Duration = delay
				})
			end
		end
	end
	--

	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	screen.KeepOpen = true
	HandleScreenInput(screen)
end

function mod.ClosePonyAltar(screen)
	ShowCombatUI(screen.Name)
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	OnScreenCloseStarted(screen)
	CloseScreen(GetAllIds(screen.Components), 0.15)
	OnScreenCloseFinished(screen)
	notifyExistingWaiters("PonyAltar")
end

function mod.SelectGod(screen, button)
	if mod.Data.SelectedGod ~= nil and mod.Data.SelectedGod == button.God then
		local color = BoonColors[1]
		ModifyTextBox({ Id = screen.Components.GodTextbox.Id, Text = "No God selected", Color = color })
		mod.UnequipAltarBoon()
		mod.Data.SelectedGod = nil
		mod.Data.RarifyLevel = nil
		mod.Data.RarifyUsesLeft = nil
		mod.Data.ForceBoonUsesLeft = nil
	else
		local color = BoonColors[button.Level]
		ModifyTextBox({ Id = screen.Components.GodTextbox.Id, Text = button.God, Color = color })
		mod.UnequipAltarBoon()
		mod.Data.SelectedGod = button.God
		mod.Data.RarifyLevel = button.Level
		mod.Data.RarifyUsesLeft = 1
		mod.Data.ForceBoonUsesLeft = 1
		mod.EquipAltarBoon()
	end
end

function mod.IsNewGameFirstRun()
	return IsEmpty(GameState.UseRecord)
end

function mod.EquipAltarBoon()
	if not mod.IsNewGameFirstRun() and mod.Data.SelectedGod ~= nil then
		if HeroHasTrait("AltarBoon") then
			mod.UnequipAltarBoon()
		end
		local altarTrait = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = "AltarBoon" })
		if mod.Data.SelectedGod ~= "SpellDrop" and mod.Data.SelectedGod ~= "NPC_Artemis_01" and mod.Data.SelectedGod ~= "NPC_Athena_01" and mod.Data.SelectedGod ~= "TrialUpgrade" then
			altarTrait.ForceBoonName = mod.Data.SelectedGod
			altarTrait.RarityUpgradeData.LootName = mod.Data.SelectedGod
			altarTrait.RarityUpgradeData.MaxRarity = mod.Data.RarifyLevel
			AddTraitToHero({ TraitData = altarTrait, SkipNewTraitHighlight = true })
		elseif mod.Data.SelectedGod == "SpellDrop" then

		elseif mod.Data.SelectedGod == "NPC_Artemis_01" or mod.Data.SelectedGod == "NPC_Athena_01" then

		elseif mod.Data.SelectedGod == "TrialUpgrade" then
			altarTrait.RarityUpgradeData.LootName = mod.Data.SelectedGod
			altarTrait.RarityUpgradeData.MaxRarity = mod.Data.RarifyLevel
			altarTrait.ForceSecretDoor = true
			altarTrait.RemainingUses = 1

			AddTraitToHero({ TraitData = altarTrait, SkipNewTraitHighlight = true })
		end
		if not CurrentRun.Hero.IsDead then
			CurrentRun.TraitCache[mod.Data.SelectedGod] = CurrentRun.TraitCache[mod.Data.SelectedGod] or 1
		end
	end
end

function mod.UnequipAltarBoon()
	for key, trait in pairs(CurrentRun.Hero.Traits) do
		if trait.Slot ~= nil and trait.Slot == "Altar" then
			RemoveTrait(CurrentRun.Hero, trait.Name)
		end
	end
end

function mod.CheckHephaestusKeepsake(health)
	if HeroHasTrait("ForceHephaestusBoonKeepsake") and health then
		local mult = GetTotalHeroTraitValue("HealingToArmor")
		local armor = health * mult
		print("Added " .. armor .. " from " .. health .. " health")
		AddArmor(armor)
	end
end

ModUtil.Path.Wrap("EquipLastAwardTrait", function(base, ...)
	base(...)
	mod.EquipAltarBoon()
end, mod)

ModUtil.Path.Wrap("EquipMetaUpgrades", function(base, ...)
	base(...)
	mod.EquipAltarBoon()
end, mod)

ModUtil.Path.Override("GetManaCost", function(weaponData, useRequiredMana, args)
	args = args or {}
	local weaponName = weaponData.Name
	local manaCost = 0
	local requiredMana = 0
	local isExWeapon = false
	if args.ManaCostOverride then
		isExWeapon = true
	end
	if WeaponData[weaponName] and WeaponData[weaponName].ManaCost and not Contains(WeaponSets.HeroSpellWeapons, weaponName) then
		isExWeapon = true
	end

	if useRequiredMana then
		requiredMana = weaponData.RequiredMana or 0
	end

	manaCost = args.ManaCostOverride or weaponData.ManaCost or requiredMana
	local manaModifiers = GetHeroTraitValues("ManaCostModifiers")
	local manaMultiplier = 1
	for i, data in pairs(manaModifiers) do
		local validWeapon = data.WeaponNamesLookup == nil or data.WeaponNamesLookup[weaponData.Name]
		local validEx = data.ExWeapons == nil or isExWeapon
		if validWeapon and validEx then
			if data.ManaCostAdd then
				manaCost = manaCost + data.ManaCostAdd
			end
			if data.ManaCostAddPerCast then
				manaCost = manaCost + data.ManaCostAddPerCast * MapState.ExCastCount
			end
			if data.ManaCostMultiplier then
				manaMultiplier = manaMultiplier * data.ManaCostMultiplier
			end
			--MOD START
			if data.ManaCostMultiplierWhilePrimed and CurrentRun.Hero.ReserveManaSources then
				manaMultiplier = manaMultiplier * data.ManaCostMultiplierWhilePrimed
			end
			if data.ManaCostMultiplierWhileLowHealth and (CurrentRun.Hero.Health / CurrentRun.Hero.MaxHealth) <= data.LowHealthThreshold then
				manaMultiplier = manaMultiplier * data.ManaCostMultiplierWhileLowHealth
			end
			--MOD END
		end
	end
	manaCost = manaCost * manaMultiplier

	if useRequiredMana and requiredMana > manaCost then
		return round(requiredMana)
	end

	return round(manaCost)
end, mod)

ModUtil.Path.Context.Wrap("CheckMoneyDrop", function()
	ModUtil.Path.Wrap("GetTotalHeroTraitValue", function(base, a, ...)
		if a == "KillMoneyMultiplier" then
			return base(a, ...)
		end
		return base(a, ...) + GetTotalHeroTraitValue("KillMoneyMultiplier")
	end, mod)
end, mod)

ModUtil.Path.Override("AddMaxHealth", function(healthGained, source, args)
	args = args or {}
	if args.Thread then
		args.Thread = false
		thread(AddMaxHealth, healthGained, source, args)
		return
	end
	local startingHealth = CurrentRun.Hero.MaxHealth
	wait(args.Delay)
	healthGained = round(healthGained)
	local traitName = "RoomRewardMaxHealthTrait"
	if args.NoHealing then
		traitName = "RoomRewardEmptyMaxHealthTrait"
	end

	local healthTraitData = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = traitName })	
	healthTraitData.PropertyChanges[1].ChangeValue = healthGained
	--MOD START
	mod.CheckHephaestusKeepsake(healthGained)
	--MOD END
	AddTraitToHero({ TraitData = healthTraitData })
	healthGained = round(healthGained * GetTotalHeroTraitValue("MaxHealthMultiplier", { IsMultiplier = true }))
	if not (args.Silent) then
		MaxHealthIncreaseText({ MaxHealthGained = CurrentRun.Hero.MaxHealth - startingHealth, SpecialText =
		"MaxHealthIncrease" })
	end
end)

local requirements = {
	{
		PathFalse = { "CurrentRun", "UseRecord", "SpellDrop" },
	},
}

ModUtil.Path.Wrap("SetupRoomReward", function(base, currentRun, room, previouslyChosenRewards, args)
	if not mod.IsNewGameFirstRun() and not room.ForceLootName and mod.Data.SelectedGod ~= nil and mod.Data.SelectedGod == "SpellDrop" and mod.Data.ForceBoonUsesLeft > 0 then
		local rewardname = "SpellDrop"
		if not IsGameStateEligible(CurrentRun, requirements) then
			rewardname = "TalentDrop"
		end
		room.ChosenRewardType = rewardname
		room.RewardStoreName = "RunProgress"
		room.ForceLootName = "SpellDrop"
		mod.Data.ForceBoonUsesLeft = 0
	end
	base(currentRun, room, previouslyChosenRewards, args)
end)

ModUtil.Path.Wrap("ChooseEncounter", function(base, currentRun, room, args)
	if not mod.IsNewGameFirstRun() and mod.Data.SelectedGod ~= nil and mod.Data.SelectedGod == "NPC_Artemis_01" and mod.Data.ForceBoonUsesLeft > 0 then
		local roomSetName = ""
		if room.NextRoomSet then
			roomSetName = GetRandomValue(room.NextRoomSet)
		elseif room.RoomSetName then
			roomSetName = room.RoomSetName
		end
		if roomSetName == "G" or roomSetName == "N" or roomSetName == "F" then
			if not room.Name:find("Opening") and not room.Name:find("Intro") then
				print("Forcing Artemis")
				game.ForceNextEncounter = "ArtemisCombat" .. roomSetName
				mod.Data.ForceBoonUsesLeft = 0
			end
		end
	elseif mod.Data.SelectedGod ~= nil and mod.Data.SelectedGod == "NPC_Athena_01" and mod.Data.ForceBoonUsesLeft > 0 then
		local roomSetName = ""
		if room.NextRoomSet then
			roomSetName = GetRandomValue(room.NextRoomSet)
		elseif room.RoomSetName then
			roomSetName = room.RoomSetName
		end
		if roomSetName == "P" then
			if not room.Name:find("Opening") and not room.Name:find("Intro") then
				print("Forcing Athena")
				game.ForceNextEncounter = "AthenaCombat" .. roomSetName
				mod.Data.ForceBoonUsesLeft = 0
			end
		end
	end
	return base(currentRun, room, args)
end)

ModUtil.Path.Wrap("KeepsakeScreenClose", function(base, ...)
	base(...)
	mod.OpenAltarMenu()
end)

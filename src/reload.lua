---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.

local AresWeaponHitCount = {
    	["WeaponStaffSwing"] = config.Ares.StaffHits,
		["WeaponAxe"] = config.Ares.AxeHits,
		["WeaponDagger"] = config.Ares.DaggerHits,
		["WeaponTorch"] = config.Ares.TorchHits,
		["WeaponLob"] = config.Ares.SkullHits,
		["WeaponSuit"] = config.Ares.SuitHits,
}

function mod.CheckAresWound(args, attacker, victim, triggerArgs)
    --Pretty ghetto but works, @todo make that properly
    if EffectData.AresBloodyWound == nil then
        EffectData.AresBloodyWound = {
            EffectName = "AresBloodyWound",
            Vfx = "WeaponKitDarkThirst",
            DataProperties = {
                Duration = config.Ares.Duration,
                IsVulnerabilityEffect = config.Ares.BloodyWoundOrigination,
                Active = true
            }
        }
    end
    if HasEffect({ Id = victim.ObjectId, EffectName = "AresBloodyWound" })then
        return
    end

     if attacker == CurrentRun.Hero and not victim.IsDead and not victim.CannotDieFromDamage and victim.HealthBuffer == nil then

        local threshold = AresWeaponHitCount[GetEquippedWeapon()]

        if victim.AresHitCount == nil then
            victim.AresHitCount = 1
            return
        elseif victim.AresHitCount < threshold then
            victim.AresHitCount = victim.AresHitCount + 1
        end

        if victim.AresHitCount >= threshold  then
            mod.DoAresWound(args, attacker, victim, triggerArgs)
        end
    end
end

function mod.DoAresWound(args, attacker, victim, triggerArgs)
    local effectData = EffectData.AresBloodyWound
    if victim.IsBoss then
        effectData.DataProperties.Duration = config.Ares.BossDuration
        victim.AresHitCount = 0
    end
    PlaySound({ Name = "/SFX/AresCritical", Id = victim.ObjectId })
    local offsetY = victim.HealthBarOffsetY or ConstantsData.DefaultHealthBarOffsetY
    thread( InCombatText, victim.ObjectId, "Wounded!", 0.3, {OffsetY = offsetY + 36, FontSize = 24, SkipFlash = true, SkipRise = true, SkipShadow = true, FadeDuration = 0.1 })
    ApplyEffect( { DestinationId = victim.ObjectId, Id = CurrentRun.Hero.ObjectId, EffectName = effectData.EffectName, DataProperties = effectData.DataProperties, Vfx = effectData.Vfx})
end

function mod.DoAthenaLastStand(functionArgs, triggerArgs)
    if not CurrentRun.CurrentRoom.Encounter.EncounterType == "Boss"then
        CreateProjectileFromUnit({ Name = "AthenaLandingNova", Id = CurrentRun.Hero.ObjectId, })
        for id, enemy in pairs( ShallowCopyTable(RequiredKillEnemies)) do
            if not enemy.IsDead and not enemy.CannotDieFromDamage and enemy.MaxHealth ~= 999999 then
                thread( DisplayDamageText, enemy, { DamageAmount = 9999, SourceProjectile = "Athena", IsCrit = true } )
                thread( Kill, enemy, { BlockRespawns = true } )
                waitUnmodified(0.01)
            end
        end
    else
        CreateProjectileFromUnit({ Name = "AthenaLandingNova", Id = CurrentRun.Hero.ObjectId, DamageMultiplier = 0 })
        for id, enemy in pairs( ShallowCopyTable(ActiveEnemies)) do
            if not enemy.IsDead and not enemy.CannotDieFromDamage and enemy.MaxHealth ~= 999999 then
                if not enemy.IsBoss then
                    thread( DisplayDamageText, enemy, { DamageAmount = 9999, SourceProjectile = "Athena", IsCrit = true } )
                    thread( Kill, enemy, { BlockRespawns = true } )
                else
                    local damage = 0
                    if enemy.AthenaLastStandOccured then
                        damage = (enemy.MaxHealth * functionArgs.BossDamage) * 0.33
                    else
                        damage = enemy.MaxHealth * functionArgs.BossDamage
                        enemy.AthenaLastStandOccured = true
                    end
                    Damage( enemy, { AttackerTable = CurrentRun.Hero, AttackerId = CurrentRun.Hero.ObjectId, DamageAmount = damage, Silent = false})
                end
            end
        end
    end
    PlaySound({ Name = "/SFX/AthenaWrathHolyShield", Id = CurrentRun.Hero.ObjectId })
end

function mod.SeleneKeepsake(hero, args)
    if CurrentRun.Hero.IsDead or CurrentRun.CurrentRoom == nil or args == nil then
        return
    end
    --somehow RunOnce isn't respected
    if CurrentRun.CurrentRoom.MoonPhased then
        return
    else
        CurrentRun.CurrentRoom.MoonPhased = true
    end

    if CurrentRun.MoonPhase == nil then
        local rng = GetGlobalRng()
        CurrentRun.MoonPhase = rng:Random(1, 8)
    end

    local moonTrait = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = "Moon_" .. CurrentRun.MoonPhase, Rarity = GetRarityKey(args.BlessingRarity) })
    AddTraitToHero({ TraitData = moonTrait })
    thread(mod.SeleneKeepsakePresentation, moonTrait.Name)
    CurrentRun.MoonPhase = CurrentRun.MoonPhase + 1

    if CurrentRun.MoonPhase > 8 then
        CurrentRun.MoonPhase = 1
    end
end

function mod.SeleneKeepsakePresentation(name)
	if CurrentRun.CurrentRoom.BiomeStartRoom then
		wait( CurrentRun.CurrentRoom.IntroSequenceDuration or 0.1 )
	end
    PlaySound({ Name = "/SFX/Menu Sounds/KeepsakeSeleneMoonbeam" })
	thread( InCombatTextArgs, { TargetId= CurrentRun.Hero.ObjectId, Text = "ChaosKeepsake_NewChoice", SkipRise = false, SkipFlash = false, Duration = 1.5, ShadowScaleX = 1.2, LuaKey = "TempTextData", 
	LuaValue = { NewName = name }})
end

function mod.MoonInvisibility(unit, args, triggerArgs)
	if not CheckCooldown( "MoonInvisibility", args.Cooldown ) then
		return
	end
	local dataProperties = DeepCopyTable( EffectData[args.EffectName].EffectData )
	dataProperties.Duration = args.Duration
	ApplyEffect({ DestinationId = CurrentRun.Hero.ObjectId, Id = CurrentRun.Hero.ObjectId, EffectName = args.EffectName, DataProperties = dataProperties })
	thread( HadesInvisibility )
end

function mod.CheckMoonInvisibility(args, attacker, victim, triggerArgs)
    if attacker == CurrentRun.Hero then
        if HasEffect({ Id = CurrentRun.Hero.ObjectId, EffectName = "HadesInvisible" }) then
            ClearEffect({ Id = CurrentRun.Hero.ObjectId, Name = "HadesInvisible" })
            TriggerCooldown("MoonInvisibility")
        end
    end
end

local elementTable = {
    [1] = "AirEssence",
    [2] = "FireEssence",
    [3] = "EarthEssence",
    [4] = "WaterEssence"
}

function mod.DemeterKeepsake(traitData, args)
    local rng = GetGlobalRng()
    local elements = {}
    for i = 1, args.ItemCount do
        local random = rng:Random(1, 4)
        local traitName = elementTable[random]
        local elementTrait = GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = traitName})
        AddTraitToHero({ TraitData = elementTrait, SkipActivatedTraitUpdate = true })
        table.insert(elements, traitName)
    end

    local elementIconSpacing = 80
    local numElements = TableLength(elements)
    local elementOffsetX = elementIconSpacing * -0.5 * (numElements - 1)

    for _, element in pairs(elements) do
        thread( InCombatTextArgs, { TargetId = CurrentRun.Hero.ObjectId, Text = "ElementGranted_CombatText", ShadowScaleX = 1.5, SkipRise = true, SkipFlash = false,
        Duration = 1.8, OffsetX = elementOffsetX, OffsetY = 80, LuaKey = "TempTextData", LuaValue = { Name = element } } )
        elementOffsetX = elementOffsetX + elementIconSpacing
    end

end

function mod.SetupMoonShield(hero, args)
    if MapState.BossShieldTriggers == 0 then
        MapState.BossShieldTriggers = args.ShieldHits
        MapState.BossShieldFx = args.ShieldFx
        CreateAnimation({ Name = args.ShieldFx, DestinationId = CurrentRun.Hero.ObjectId })
    end
end

function mod.SetupMoonBlast(hero, args)
    thread(mod.DoMoonBlast, hero, args)
end

function mod.DoMoonBlast(hero, args)
    wait(args.Delay)
    local nearestEnemyTargetIds = GetClosestIds({ Id = CurrentRun.Hero.ObjectId, DestinationName = "EnemyTeam", IgnoreInvulnerable = true, IgnoreHomingIneligible = true, Distance = 9999 })
    local targetId = GetFirstKey(nearestEnemyTargetIds)
    local dataProperties = {
        Fuse = 4,
        Damage = args.Damage,
        DamageRadius = args.Radius
    }
    CreateProjectileFromUnit({ Name = "ProjectileSpellMeteor", Id = CurrentRun.Hero.ObjectId, DestinationId = targetId, DataProperties = dataProperties })
end

function mod.CanHeraPurge(reward)
    if not reward.GodLoot or reward.SpeakerName == "Hera" or (reward.ResourceCosts ~= nil and HasResourceCost( reward.ResourceCosts )) or GetTotalHeroTraitValue( "HeraBoonConversionUses" ) <= 0 then
        return false
    end
    reward.GoldConversionEligible = false
    reward.UseTextTalkAndSpecial = "UseLootAndPurge"
    reward.UseTextTalkGiftAndSpecial = "UseLootGiftAndPurge"
    return true
end

function mod.CanSpecialInteract_wrap(base, source)
    if mod.CanHeraPurge(source) then
        return true
    else
        return base(source)
    end
end

function mod.SetupHestiaKeepsake(hero, args)
    thread(mod.DoHestiaKeepsake, hero, args)
end

function mod.DoHestiaKeepsake(hero, args)
    wait(args.Delay)
    local dataProperties = {
        DamageRadius = 450,

    }

    for i = 1, args.ProjectileAmount do
        wait(1)
        CreateProjectileFromUnit({ Name = "DevotionHestiaFire", Id = CurrentRun.Hero.ObjectId, FireFromTarget = true, DataProperties = dataProperties })
    end

end
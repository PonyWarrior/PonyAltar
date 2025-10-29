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
        CurrentRun.MoonPhase = 1
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
	local dataProperties = DeepCopyTable( EffectData[args.EffectName].EffectData )
	dataProperties.Duration = args.Duration
	ApplyEffect({ DestinationId = CurrentRun.Hero.ObjectId, Id = CurrentRun.Hero.ObjectId, EffectName = args.EffectName, DataProperties = dataProperties })
	thread( HadesInvisibility )
end

function mod.CheckMoonInvisibility(args, attacker, victim, triggerArgs)
    if attacker == CurrentRun.Hero then
        if HasEffect({ Id = CurrentRun.Hero.ObjectId, EffectName = "HadesInvisible" }) then
            ClearEffect({ Id = CurrentRun.Hero.ObjectId, Name = "HadesInvisible" })
        end
    end
end
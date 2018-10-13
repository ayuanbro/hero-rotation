--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, HR = ...;
  -- HeroLib
  local HL = HeroLib;
  local Cache = HeroCache;
  local Unit = HL.Unit;
  local Player = Unit.Player;
  local Target = Unit.Target;
  local Spell = HL.Spell;
  local Item = HL.Item;
  local Enemies = HL.Enemies;
  -- Lua
  local pairs = pairs;
  -- File Locals
  HR.Commons = {};
  local Commons = {};
  HR.Commons.Everyone = Commons;
  local Settings = HR.GUISettings.General;


--- ============================ CONTENT ============================
  -- Is the current target valid ?
  function Commons.TargetIsValid ()
    return Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost();
  end

  do
    local AoEInsensibleUnit = {
      --- Legion
        ----- Dungeons (7.0 Patch) -----
        --- Mythic+ Affixes
          -- Fel Explosives (7.2 Patch)
          [120651] = true
    }
    local function AoEIsAllowed ()
      return not HR.AoEON() or AoEInsensibleUnit[Target:NPCID()];
    end
    function Commons.GetPlayerEnemiesCount (Distance, AoESpell)
      if AoEIsAllowed() then return 1; end
      return #HL.Enemies.Player(Distance, AoESpell)
    end
    function Commons.GetPetEnemiesCount (Distance)
      if AoEIsAllowed() then return 1; end
      return #HL.Enemies.Pet(Distance)
    end
  end

  function Commons.GetPlayerEnemies (Distance, AoESpell)
    return HL.Enemies.Player(Distance, AoESpell)
  end
  function Commons.GetPetEnemies (Distance)
    return HL.Enemies.Pet(Distance)
  end

  -- Is the current unit valid during cycle ?
  function Commons.UnitIsCycleValid (Unit, BestUnitTTD, TimeToDieOffset)
    return not Unit:IsFacingBlacklisted() and not Unit:IsUserCycleBlacklisted() and (not BestUnitTTD or Unit:FilteredTimeToDie(">", BestUnitTTD, TimeToDieOffset));
  end

  -- Is it worth to DoT the unit ?
  function Commons.CanDoTUnit (Unit, HealthThreshold)
    return Unit:Health() >= HealthThreshold or Unit:IsDummy();
  end

  -- Interrupt
  function Commons.Interrupt (Range, Spell, Setting, StunSpells)
    if Settings.InterruptEnabled and Target:IsInterruptible() and Target:IsInRange(Range) then
      if Spell:IsCastable() then
        if HR.Cast(Spell, Setting) then return "Cast " .. Spell:Name() .. " (Interrupt)"; end
      elseif Settings.InterruptWithStun and Target:CanBeStunned() then
        if StunSpells then
          for i = 1, #StunSpells do
            if StunSpells[i][1]:IsCastable() and StunSpells[i][3]() then
              if HR.Cast(StunSpells[i][1]) then return StunSpells[i][2]; end
            end
          end
        end
      end
    end
  end

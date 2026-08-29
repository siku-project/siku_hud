local FULL_STAMINA <const> = 99
local lingerUntil = 0

--- Collects the player vitals and forwards what changed.
---@return nil
local function collectVitals()
  local ped <const> = PlayerPedId()
  local player <const> = PlayerId()

  local maxHealth <const> = GetEntityMaxHealth(ped) - 100
  local health = 0

  if maxHealth > 0 then
    health = HudClampPercent(((GetEntityHealth(ped) - 100) / maxHealth) * 100)
  end

  local stamina <const> = HudClampPercent(100 - GetPlayerSprintStaminaRemaining(player))
  local now <const> = GetGameTimer()

  if stamina < FULL_STAMINA then
    lingerUntil = now + HudConfig.staminaLinger
  end

  local oxygen <const> =
    HudClampPercent((GetPlayerUnderwaterTimeRemaining(player) / HudConfig.underwaterCapacity) * 100)

  local patch <const> = HudBuildPatch(HudState.vitals, {
    health = health,
    armor = HudClampPercent(GetPedArmour(ped)),
    hunger = HudStatuses.hunger,
    thirst = HudStatuses.thirst,
    stamina = stamina,
    staminaActive = now < lingerUntil,
    oxygen = oxygen,
    oxygenActive = IsPedSwimmingUnderWater(ped),
  })

  if patch then
    HudPush('setVitals', patch)
  end
end

Siku.timers.setInterval(HudConfig.intervals.vitals, collectVitals)

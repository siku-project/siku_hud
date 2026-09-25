local DEFAULT_TANK_VOLUME <const> = 65.0
local RPM_STEP <const> = 50
local MPS_TO_KMH <const> = 3.6

local statesSignature = ''

--- Builds the normalized state entries the cluster panel renders.
---@param vehicle number The vehicle entity.
---@param engineOn boolean Whether the engine is running.
---@param lightsMode string 'off', 'on' or 'high'.
---@return table states The ordered state entries.
local function buildStates(vehicle, engineOn, lightsMode)
  local states = {}

  if not HudConfig.seatbeltExemptClasses[GetVehicleClass(vehicle)] then
    states[#states + 1] = {
      id = 'seatbelt',
      icon = 'mdi-seatbelt',
      label = 'hud.seatbelt',
      value = HudSeatbelt and 'hud.state.buckled' or 'hud.state.unbuckled',
      tone = HudSeatbelt and 'positive' or 'warning',
    }
  end

  states[#states + 1] = {
    id = 'engine',
    icon = 'mdi-engine-outline',
    label = 'hud.engine',
    value = engineOn and 'hud.state.on' or 'hud.state.off',
    tone = engineOn and 'positive' or 'warning',
  }

  states[#states + 1] = {
    id = 'lights',
    icon = 'mdi-car-light-dimmed',
    label = 'hud.lights',
    value = ('hud.state.%s'):format(lightsMode),
    tone = lightsMode == 'off' and 'neutral' or 'accent',
  }

  return states
end

--- Reduces state entries to a comparable signature.
---@param states table The state entries.
---@return string signature The concatenated identity of the entries.
local function signatureOf(states)
  local parts = {}

  for index = 1, #states do
    local entry <const> = states[index]
    parts[index] = ('%s=%s:%s'):format(entry.id, entry.value, entry.tone)
  end

  return table.concat(parts, '|')
end

--- The values the cluster shows for a seat: the whole telemetry from the
--- driver seat, only the presence from any other, since a passenger has
--- no dial to read.
---@param vehicle number The vehicle entity.
---@param driver boolean Whether the character holds the wheel.
---@return table incoming The collected values.
local function collectTelemetry(vehicle, driver)
  if not driver then
    return { active = true, driver = false }
  end

  local gearIndex <const> = GetVehicleCurrentGear(vehicle)
  local tank = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume')

  if tank <= 0 then
    tank = DEFAULT_TANK_VOLUME
  end

  return {
    active = true,
    driver = true,
    speed = math.floor(GetEntitySpeed(vehicle) * MPS_TO_KMH + 0.5),
    gear = gearIndex == 0 and 'R' or tostring(gearIndex),
    rpm = math.floor(GetVehicleCurrentRpm(vehicle) * RPM_STEP + 0.5) / RPM_STEP,
    fuel = HudClampPercent((GetVehicleFuelLevel(vehicle) / tank) * 100),
    engineTemp = math.floor(GetVehicleEngineTemperature(vehicle) + 0.5),
  }
end

--- Collects the vehicle telemetry and forwards what changed.
---@return nil
local function collectVehicle()
  local ped <const> = PlayerPedId()
  local vehicle <const> = GetVehiclePedIsIn(ped, false)

  if vehicle == 0 then
    ResetSeatbelt()

    if HudState.vehicle.active then
      HudState.vehicle.active = false
      statesSignature = ''
      HudPush('setVehicle', { active = false })
    end

    return
  end

  local engineOn <const> = GetIsVehicleEngineRunning(vehicle)
  local _, lightsOn <const>, highBeams <const> = GetVehicleLightsState(vehicle)
  local lightsMode <const> = highBeams == 1 and 'high' or (lightsOn == 1 and 'on' or 'off')
  local driver <const> = GetPedInVehicleSeat(vehicle, -1) == ped

  local patch = HudBuildPatch(HudState.vehicle, collectTelemetry(vehicle, driver))

  local states <const> = buildStates(vehicle, engineOn, lightsMode)
  local signature <const> = signatureOf(states)

  if signature ~= statesSignature then
    statesSignature = signature
    HudState.vehicle.states = states
    patch = patch or {}
    patch.states = states
  end

  if patch then
    HudPush('setVehicle', patch)
  end
end

Siku.timers.setInterval(HudConfig.intervals.vehicle, collectVehicle)

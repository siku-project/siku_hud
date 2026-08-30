local WINDSCREEN_FLAG <const> = 32

--- Applies the buckled state to the ped and the cluster: a buckled
--- character no longer flies through the windscreen.
---@param buckled boolean Whether the seatbelt is on.
---@return nil
local function applySeatbelt(buckled)
  HudSeatbelt = buckled
  SetPedConfigFlag(PlayerPedId(), WINDSCREEN_FLAG, not buckled)
end

--- Unbuckles when the character is no longer seated in a vehicle that
--- wears a belt. Called by the vehicle collector on exit.
---@return nil
function ResetSeatbelt()
  if HudSeatbelt then
    applySeatbelt(false)
  end
end

--- The vehicle the character drives or rides, when its class wears a belt.
---@param requireDriver boolean Whether the driver seat is required.
---@return number? vehicle The vehicle, or nil.
local function beltedVehicle(requireDriver)
  local ped <const> = PlayerPedId()
  local vehicle <const> = GetVehiclePedIsIn(ped, false)

  if vehicle == 0 then
    return nil
  end

  if requireDriver and GetPedInVehicleSeat(vehicle, -1) ~= ped then
    return nil
  end

  return vehicle
end

Siku.keybind.add({
  name = 'siku_hud_seatbelt',
  description = T('keybind_seatbelt'),
  defaultKey = HudConfig.keybinds.seatbelt,
  onPressed = function()
    local vehicle <const> = beltedVehicle(false)

    if not vehicle or HudConfig.seatbeltExemptClasses[GetVehicleClass(vehicle)] then
      return
    end

    applySeatbelt(not HudSeatbelt)
  end,
})

Siku.keybind.add({
  name = 'siku_hud_engine',
  description = T('keybind_engine'),
  defaultKey = HudConfig.keybinds.engine,
  onPressed = function()
    local vehicle <const> = beltedVehicle(true)

    if not vehicle then
      return
    end

    SetVehicleEngineOn(vehicle, not GetIsVehicleEngineRunning(vehicle), false, true)
  end,
})

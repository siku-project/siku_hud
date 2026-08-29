local CARDINALS <const> = { 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW' }
local FALLBACK_WEATHER <const> = { icon = 'clear', temperature = 18 }

local weatherByHash = {}

for name, entry in pairs(HudConfig.weather) do
  weatherByHash[joaat(name)] = entry
end

--- Resolves the current weather into its icon key and temperature.
---@return table entry The configured weather entry.
local function resolveWeather()
  return weatherByHash[GetPrevWeatherTypeHashName()] or FALLBACK_WEATHER
end

--- Collects the player position context and forwards what changed.
---@return nil
local function collectLocation()
  local ped <const> = PlayerPedId()
  local coords <const> = GetEntityCoords(ped)

  local heading <const> = math.floor((360 - GetEntityHeading(ped)) % 360 + 0.5) % 360
  local cardinal <const> = CARDINALS[(math.floor(heading / 45 + 0.5) % 8) + 1]

  local streetHash <const> = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
  local weather <const> = resolveWeather()

  local patch <const> = HudBuildPatch(HudState.location, {
    cardinal = cardinal,
    heading = heading,
    street = GetStreetNameFromHashKey(streetHash),
    zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z)),
    time = ('%02d:%02d'):format(GetClockHours(), GetClockMinutes()),
    weather = weather.icon,
    temperature = weather.temperature,
  })

  if patch then
    HudPush('setLocation', patch)
  end
end

Siku.timers.setInterval(HudConfig.intervals.location, collectLocation)

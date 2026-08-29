HudConfig = {
  --- Intervals
  ---
  --- How often each collector reads the game state, in milliseconds. A
  --- collector only forwards to the interface what actually changed, so
  --- these drive native reads, not NUI traffic.
  intervals = {
    vitals = 250,
    location = 750,
    vehicle = 120,
    voice = 200,
  },

  --- Stamina linger
  ---
  --- How long the stamina gauge stays visible after it is back to full,
  --- in milliseconds.
  staminaLinger = 1500,

  --- Underwater capacity
  ---
  --- The breath duration a full oxygen gauge represents, in seconds.
  underwaterCapacity = 10.0,

  --- Seatbelt exempt classes
  ---
  --- Vehicle classes whose cluster never shows a seatbelt state.
  --- 8: motorcycles, 13: cycles, 14: boats, 15: helicopters, 16: planes.
  seatbeltExemptClasses = {
    [8] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
  },

  --- Default voice
  ---
  --- What the voice card shows until a voice resource takes over through
  --- the SetVoice export.
  voice = {
    mode = 'normal',
    range = 8,
  },

  --- Weather
  ---
  --- Maps every game weather type to the icon key the interface knows and
  --- an ambient temperature to display.
  weather = {
    CLEAR = { icon = 'clear', temperature = 21 },
    EXTRASUNNY = { icon = 'extrasunny', temperature = 27 },
    CLOUDS = { icon = 'cloudy', temperature = 16 },
    OVERCAST = { icon = 'overcast', temperature = 13 },
    SMOG = { icon = 'smog', temperature = 18 },
    FOGGY = { icon = 'fog', temperature = 9 },
    RAIN = { icon = 'rain', temperature = 11 },
    CLEARING = { icon = 'drizzle', temperature = 12 },
    THUNDER = { icon = 'thunder', temperature = 10 },
    NEUTRAL = { icon = 'clear', temperature = 18 },
    SNOW = { icon = 'snow', temperature = -2 },
    SNOWLIGHT = { icon = 'snow', temperature = 0 },
    BLIZZARD = { icon = 'blizzard', temperature = -8 },
    XMAS = { icon = 'snow', temperature = -5 },
    HALLOWEEN = { icon = 'halloween', temperature = 12 },
  },
}

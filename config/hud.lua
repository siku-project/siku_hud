HudConfig = {
  --- Customization
  ---
  --- What a player may personalize through /hud, and the base every
  --- preference is an override of. The server stays authoritative: a
  --- component disabled here never renders, never shows up in the
  --- interface, and its stored preferences are ignored.
  customization = {
    --- Bounds every per-component scale is clamped into.
    scale = { min = 0.7, max = 1.4 },

    --- How often dirty preferences are written to the database, in
    --- milliseconds. They are also written when the player disconnects
    --- and when the resource stops.
    saveInterval = 300000,

    --- The look every component starts with. Colors only apply to the
    --- components that declare the color capability.
    defaults = {
      scale = 1.0,
      colorMode = 'gradient',
      primary = '#69ceff',
      secondary = '#a18cff',
    },

    --- One entry per HUD component. `x` and `y` are the default top-left
    --- position as a fraction of the screen, `color` whether its accent
    --- may be recolored, `order` the row it takes in the interface.
    components = {
      health = { enabled = true, color = true, order = 1, x = 0.014, y = 0.715 },
      hunger = { enabled = true, color = true, order = 2, x = 0.052, y = 0.715 },
      thirst = { enabled = true, color = true, order = 3, x = 0.09, y = 0.715 },
      armor = { enabled = true, color = true, order = 4, x = 0.128, y = 0.715 },
      stamina = { enabled = true, color = true, order = 5, x = 0.166, y = 0.715 },
      oxygen = { enabled = true, color = true, order = 6, x = 0.204, y = 0.715 },
      location = { enabled = true, color = false, order = 7, x = 0.014, y = 0.785 },
      voice = { enabled = true, color = true, order = 8, x = 0.168, y = 0.869 },
      radio = { enabled = true, color = true, order = 9, x = 0.168, y = 0.925 },
      vehicle = { enabled = true, color = true, order = 10, x = 0.752, y = 0.695 },
    },
  },

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

  --- Keybinds
  ---
  --- Default keys, shown in the GTA keybind settings where every player
  --- can rebind them. `seatbelt` toggles the belt in a vehicle whose class
  --- wears one; `engine` starts or stops the engine from the driver seat.
  keybinds = {
    seatbelt = 'B',
    engine = 'L',
  },

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

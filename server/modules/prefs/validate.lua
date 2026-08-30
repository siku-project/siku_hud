local COLOR_MODES <const> = {
  solid = true,
  gradient = true,
}

--- Normalizes a color to lowercase #rrggbb, refusing anything else.
---@param value any The raw color.
---@return string? color The normalized color, or nil.
local function readColor(value)
  if type(value) ~= 'string' then
    return nil
  end

  local color <const> = value:lower()

  return color:match('^#%x%x%x%x%x%x$') and color or nil
end

--- Clamps a fraction of the screen into what stays visible.
---@param value any The raw coordinate.
---@return number? coordinate The clamped coordinate, or nil.
local function readFraction(value)
  if type(value) ~= 'number' or value ~= value then
    return nil
  end

  return math.min(0.98, math.max(0, value))
end

--- Rebuilds the preferences a client sent from what the configuration
--- actually allows. Unknown components, disabled components, foreign
--- fields and out-of-bounds values never reach the database: the result
--- is a sparse map of overrides the server vouches for.
---@param raw any The preferences the client sent.
---@return table prefs The sanitized sparse overrides.
function SanitizeHudPrefs(raw)
  local prefs <const> = {}

  if type(raw) ~= 'table' then
    return prefs
  end

  local limits <const> = HudConfig.customization.scale

  for id, definition in pairs(HudConfig.customization.components) do
    local entry <const> = raw[id]

    if definition.enabled and type(entry) == 'table' then
      local clean = nil

      if type(entry.scale) == 'number' and entry.scale == entry.scale then
        clean = clean or {}
        clean.scale = math.min(limits.max, math.max(limits.min, entry.scale))
        clean.scale = math.floor(clean.scale * 100 + 0.5) / 100
      end

      local x <const> = readFraction(entry.x)
      local y <const> = readFraction(entry.y)

      if x and y then
        clean = clean or {}
        clean.x = math.floor(x * 10000 + 0.5) / 10000
        clean.y = math.floor(y * 10000 + 0.5) / 10000
      end

      if definition.color then
        if COLOR_MODES[entry.colorMode] then
          clean = clean or {}
          clean.colorMode = entry.colorMode
        end

        local primary <const> = readColor(entry.primary)

        if primary then
          clean = clean or {}
          clean.primary = primary
        end

        local secondary <const> = readColor(entry.secondary)

        if secondary then
          clean = clean or {}
          clean.secondary = secondary
        end
      end

      prefs[id] = clean
    end
  end

  return prefs
end

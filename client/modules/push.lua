HudState = {
  visible = true,
  vitals = {},
  location = {},
  voice = {
    active = true,
    talking = false,
    mode = HudConfig.voice.mode,
    range = HudConfig.voice.range,
  },
  radio = {
    active = false,
    channel = '',
    label = '',
    transmitting = false,
  },
  vehicle = {
    active = false,
  },
}

HudStatuses = {
  hunger = 100,
  thirst = 100,
}

HudSeatbelt = false

--- Sends a HUD action and its payload to the interface.
---@param action string The NUI action suffix.
---@param payload table The payload to forward.
function HudPush(action, payload)
  SendNUIMessage({
    action = ('siku_hud:nui:%s'):format(action),
    payload = payload,
  })
end

--- Merges the collected values into a cached slice and returns what changed.
---@param slice table The cached slice to update.
---@param incoming table The freshly collected values.
---@return table? patch The changed keys, or nil when nothing moved.
function HudBuildPatch(slice, incoming)
  local patch = nil

  for key, value in pairs(incoming) do
    if slice[key] ~= value then
      patch = patch or {}
      patch[key] = value
      slice[key] = value
    end
  end

  return patch
end

--- Clamps a value into a whole percentage.
---@param value number The raw value.
---@return number percent The rounded value, 0 to 100.
function HudClampPercent(value)
  return math.min(100, math.max(0, math.floor(value + 0.5)))
end

local STATUS_NAMES <const> = {
  hunger = true,
  thirst = true,
}

local VOICE_MODES <const> = {
  whisper = true,
  normal = true,
  shout = true,
}

--- Sets an external status shown by the vitals cluster.
---@param name string 'hunger' or 'thirst'.
---@param value number The percentage, 0 to 100.
---@return boolean applied Whether the status was accepted.
local function setStatus(name, value)
  if not STATUS_NAMES[name] or type(value) ~= 'number' then
    return false
  end

  HudStatuses[name] = HudClampPercent(value)

  local patch <const> = HudBuildPatch(HudState.vitals, { [name] = HudStatuses[name] })

  if patch then
    HudPush('setVitals', patch)
  end

  return true
end

--- Updates the voice card shown near the minimap.
---@param data table Any of: mode ('whisper', 'normal', 'shout'), range (meters), active.
---@return boolean applied Whether the update was accepted.
local function setVoice(data)
  if type(data) ~= 'table' then
    return false
  end

  local incoming = {}

  if VOICE_MODES[data.mode] then
    incoming.mode = data.mode
  end

  if type(data.range) == 'number' and data.range > 0 then
    incoming.range = math.floor(data.range + 0.5)
  end

  if type(data.active) == 'boolean' then
    incoming.active = data.active
  end

  local patch <const> = HudBuildPatch(HudState.voice, incoming)

  if patch then
    HudPush('setVoice', patch)
  end

  return true
end

--- Updates the radio block shown near the minimap.
---@param data table Any of: active, channel, label, transmitting.
---@return boolean applied Whether the update was accepted.
local function setRadio(data)
  if type(data) ~= 'table' then
    return false
  end

  local incoming = {}

  if type(data.active) == 'boolean' then
    incoming.active = data.active
  end

  if type(data.channel) == 'string' or type(data.channel) == 'number' then
    incoming.channel = tostring(data.channel)
  end

  if type(data.label) == 'string' then
    incoming.label = data.label
  end

  if type(data.transmitting) == 'boolean' then
    incoming.transmitting = data.transmitting
  end

  local patch <const> = HudBuildPatch(HudState.radio, incoming)

  if patch then
    HudPush('setRadio', patch)
  end

  return true
end

--- Sets the seatbelt state shown by the vehicle cluster.
---@param buckled boolean Whether the seatbelt is buckled.
---@return nil
local function setSeatbelt(buckled)
  HudSeatbelt = buckled == true
end

--- Shows or hides the whole HUD.
---@param visible boolean Whether the HUD is shown.
---@return nil
local function setVisible(visible)
  HudState.visible = visible == true
  HudPush('setVisible', { visible = HudState.visible })
end

exports('SetStatus', setStatus)
exports('SetVoice', setVoice)
exports('SetRadio', setRadio)
exports('SetSeatbelt', setSeatbelt)
exports('SetVisible', setVisible)

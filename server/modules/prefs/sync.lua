--- Builds what the interface needs to customize a HUD: the enabled
--- components with their server defaults, the bounds, and the stored
--- overrides of the player. Disabled components are simply absent, so
--- nothing downstream can show or resurrect them.
---@param sessionId number The player server id.
---@return table payload The customization payload.
local function buildPayload(sessionId)
  local customization <const> = HudConfig.customization
  local defaults <const> = customization.defaults
  local components <const> = {}

  for id, definition in pairs(customization.components) do
    if definition.enabled then
      components[#components + 1] = {
        id = id,
        order = definition.order,
        color = definition.color == true,
        defaults = {
          x = definition.x,
          y = definition.y,
          scale = defaults.scale,
          colorMode = defaults.colorMode,
          primary = defaults.primary,
          secondary = defaults.secondary,
        },
      }
    end
  end

  table.sort(components, function(a, b)
    return a.order < b.order
  end)

  local state <const> = GetHudPrefsState(sessionId)

  return {
    limits = { scaleMin = customization.scale.min, scaleMax = customization.scale.max },
    components = components,
    prefs = state and state.prefs or {},
  }
end

--- Sends the customization payload to a client.
---@param sessionId number The player server id.
---@return nil
function PushCustomization(sessionId)
  TriggerClientEvent('siku_hud:client:setCustomization', sessionId, buildPayload(sessionId))
end

RegisterNetEvent('siku_hud:server:requestCustomization', function()
  PushCustomization(source)
end)

RegisterNetEvent('siku_hud:server:savePrefs', function(raw)
  local sessionId <const> = source
  local prefs <const> = SanitizeHudPrefs(raw)

  if StoreHudPrefs(sessionId, prefs) then
    PushCustomization(sessionId)
  end
end)

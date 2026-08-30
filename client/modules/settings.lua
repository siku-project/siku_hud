RegisterNetEvent('siku_hud:client:openSettings', function()
  SetNuiFocus(true, true)
  HudPush('openSettings', {})
end)

RegisterNetEvent('siku_hud:client:setCustomization', function(payload)
  if type(payload) ~= 'table' then
    return
  end

  HudPush('setCustomization', payload)
end)

RegisterNUICallback('siku_hud:nui:settingsClosed', function(_, cb)
  SetNuiFocus(false, false)
  cb({})
end)

RegisterNUICallback('siku_hud:nui:savePrefs', function(data, cb)
  if type(data) == 'table' and type(data.prefs) == 'table' then
    TriggerServerEvent('siku_hud:server:savePrefs', data.prefs)
  end

  cb({})
end)

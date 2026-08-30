--- Pushes the active language and its translations to the NUI.
---@return nil
local function sendLocale()
  SendNUIMessage({
    action = 'siku_hud:nui:setLocale',
    locale = {
      language = TranslationConfig.language,
      translations = Siku.locale.translations(),
    },
  })
end

RegisterNUICallback('siku_hud:nui:ready', function(_, cb)
  sendLocale()
  HudPush('setVisible', { visible = HudState.visible })
  HudPush('setVitals', HudState.vitals)
  HudPush('setLocation', HudState.location)
  HudPush('setVoice', HudState.voice)
  HudPush('setRadio', HudState.radio)
  HudPush('setVehicle', HudState.vehicle)
  TriggerServerEvent('siku_hud:server:requestCustomization')
  cb({})
end)

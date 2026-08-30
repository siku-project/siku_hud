Siku.command.register('hud', function(source)
  if source == 0 then
    return
  end

  TriggerClientEvent('siku_hud:client:openSettings', source)
end, {
  description = T('command_hud'),
})

--- Collects the talking state and forwards what changed.
---@return nil
local function collectVoice()
  local patch <const> = HudBuildPatch(HudState.voice, {
    talking = NetworkIsPlayerTalking(PlayerId()),
  })

  if patch then
    HudPush('setVoice', patch)
  end
end

Siku.timers.setInterval(HudConfig.intervals.voice, collectVoice)

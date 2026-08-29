import { MOCK_HUD_STATE } from '@/mock/hud'
import type { HudState } from '@/types/hud'

const clone = (): HudState => JSON.parse(JSON.stringify(MOCK_HUD_STATE)) as HudState

const onFoot = (): HudState => {
  const state = clone()
  state.vehicle.active = false
  state.radio.active = false
  return state
}

const sprint = (): HudState => {
  const state = onFoot()
  state.vitals.staminaActive = true
  state.vitals.stamina = 42
  return state
}

const diving = (): HudState => {
  const state = onFoot()
  state.vitals.oxygenActive = true
  state.vitals.oxygen = 61
  return state
}

const lowVitals = (): HudState => {
  const state = clone()
  state.vitals.health = 18
  state.vitals.hunger = 22
  state.vitals.thirst = 34
  state.vehicle.fuel = 12
  state.vehicle.engineTemp = 112
  state.voice.talking = true
  state.radio.transmitting = true
  return state
}

const bike = (): HudState => {
  const state = clone()
  state.vehicle.states = state.vehicle.states.filter((entry) => entry.id !== 'seatbelt')
  state.vehicle.gear = '3'
  state.vehicle.speed = 96
  return state
}

export const HUD_SCENARIOS: Record<string, () => HudState> = {
  full: clone,
  onfoot: onFoot,
  sprint,
  diving,
  lowvitals: lowVitals,
  bike,
}

export const resolveScenario = (name: string | null): HudState =>
  (HUD_SCENARIOS[name ?? 'full'] ?? clone)()

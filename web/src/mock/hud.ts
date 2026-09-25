import type { HudState } from '@/types/hud'

export const MOCK_HUD_STATE: HudState = {
  visible: true,
  vitals: {
    health: 100,
    armor: 100,
    hunger: 63,
    thirst: 55,
    stamina: 100,
    staminaActive: false,
    oxygen: 100,
    oxygenActive: false,
  },
  location: {
    cardinal: 'NW',
    heading: 324,
    street: 'Strawberry Avenue',
    zone: 'Strawberry',
    time: '21:47',
    weather: 'cloudy',
    temperature: 12,
  },
  voice: {
    active: true,
    talking: false,
    mode: 'normal',
    range: 8,
  },
  radio: {
    active: true,
    channel: '32',
    label: 'LSPO',
    transmitting: false,
  },
  vehicle: {
    active: true,
    driver: true,
    speed: 128,
    gear: '4',
    rpm: 0.52,
    fuel: 62,
    engineTemp: 92,
    states: [
      {
        id: 'seatbelt',
        icon: 'mdi-seatbelt',
        label: 'hud.seatbelt',
        value: 'hud.state.buckled',
        tone: 'positive',
      },
      {
        id: 'engine',
        icon: 'mdi-engine-outline',
        label: 'hud.engine',
        value: 'hud.state.on',
        tone: 'positive',
      },
      {
        id: 'lights',
        icon: 'mdi-car-light-dimmed',
        label: 'hud.lights',
        value: 'hud.state.auto',
        tone: 'neutral',
      },
    ],
  },
}

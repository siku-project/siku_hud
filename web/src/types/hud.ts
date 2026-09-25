export interface HudVitals {
  health: number
  armor: number
  hunger: number
  thirst: number
  stamina: number
  staminaActive: boolean
  oxygen: number
  oxygenActive: boolean
}

export interface HudLocation {
  cardinal: string
  heading: number
  street: string
  zone: string
  time: string
  weather: string
  temperature: number | null
}

export interface HudVoice {
  active: boolean
  talking: boolean
  mode: string
  range: number
}

export interface HudRadio {
  active: boolean
  channel: string
  label: string
  transmitting: boolean
}

export type VehicleStateTone = 'positive' | 'neutral' | 'accent' | 'warning'

export interface VehicleStateEntry {
  id: string
  icon: string
  label: string
  value: string
  tone: VehicleStateTone
}

export interface HudVehicle {
  active: boolean
  driver: boolean
  speed: number
  gear: string
  rpm: number
  fuel: number
  engineTemp: number
  states: VehicleStateEntry[]
}

export interface HudState {
  visible: boolean
  vitals: HudVitals
  location: HudLocation
  voice: HudVoice
  radio: HudRadio
  vehicle: HudVehicle
}

export const createHudDefaults = (): HudState => ({
  visible: true,
  vitals: {
    health: 100,
    armor: 0,
    hunger: 100,
    thirst: 100,
    stamina: 100,
    staminaActive: false,
    oxygen: 100,
    oxygenActive: false,
  },
  location: {
    cardinal: 'N',
    heading: 0,
    street: '',
    zone: '',
    time: '00:00',
    weather: 'clear',
    temperature: null,
  },
  voice: {
    active: true,
    talking: false,
    mode: 'normal',
    range: 8,
  },
  radio: {
    active: false,
    channel: '',
    label: '',
    transmitting: false,
  },
  vehicle: {
    active: false,
    driver: false,
    speed: 0,
    gear: 'N',
    rpm: 0,
    fuel: 0,
    engineTemp: 0,
    states: [],
  },
})

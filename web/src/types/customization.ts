export type HudComponentId =
  | 'health'
  | 'hunger'
  | 'thirst'
  | 'armor'
  | 'stamina'
  | 'oxygen'
  | 'location'
  | 'voice'
  | 'radio'
  | 'vehicle'

export type ColorMode = 'solid' | 'gradient'

export interface ComponentDefaults {
  x: number
  y: number
  scale: number
  colorMode: ColorMode
  primary: string
  secondary: string
}

export interface ServerComponent {
  id: HudComponentId
  order: number
  color: boolean
  defaults: ComponentDefaults
}

export interface ComponentPrefs {
  x?: number
  y?: number
  scale?: number
  colorMode?: ColorMode
  primary?: string
  secondary?: string
}

export type PrefsMap = Partial<Record<HudComponentId, ComponentPrefs>>

export interface ScaleLimits {
  scaleMin: number
  scaleMax: number
}

export interface CustomizationPayload {
  limits: ScaleLimits
  components: ServerComponent[]
  prefs: PrefsMap
}

export interface ResolvedComponent extends ComponentDefaults {
  id: HudComponentId
  color: boolean
}

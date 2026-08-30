import { loadDevPrefs } from '@/utils/prefs'
import type { CustomizationPayload, ServerComponent } from '@/types/customization'

/** Mirrors HudConfig.customization in config/hud.lua, for development only. */
const COMPONENTS: ServerComponent[] = (
  [
    ['health', 1, true, 0.014, 0.715],
    ['hunger', 2, true, 0.052, 0.715],
    ['thirst', 3, true, 0.09, 0.715],
    ['armor', 4, true, 0.128, 0.715],
    ['stamina', 5, true, 0.166, 0.715],
    ['oxygen', 6, true, 0.204, 0.715],
    ['location', 7, false, 0.014, 0.785],
    ['voice', 8, true, 0.168, 0.869],
    ['radio', 9, true, 0.168, 0.925],
    ['vehicle', 10, true, 0.752, 0.695],
  ] as const
).map(([id, order, color, x, y]) => ({
  id,
  order,
  color,
  defaults: {
    x,
    y,
    scale: 1,
    colorMode: 'gradient' as const,
    primary: '#69ceff',
    secondary: '#a18cff',
  },
}))

export const buildMockCustomization = (): CustomizationPayload => ({
  limits: { scaleMin: 0.7, scaleMax: 1.4 },
  components: COMPONENTS,
  prefs: loadDevPrefs(),
})

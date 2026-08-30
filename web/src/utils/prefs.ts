import { sendNuiCallback } from '@/utils/nui'
import type { PrefsMap } from '@/types/customization'

const STORAGE_KEY = 'siku_hud:prefs'

/** The overrides remembered by the browser, for development only. */
export const loadDevPrefs = (): PrefsMap => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    const parsed = raw ? (JSON.parse(raw) as unknown) : null

    return parsed && typeof parsed === 'object' ? (parsed as PrefsMap) : {}
  } catch {
    return {}
  }
}

/**
 * Hands the overrides to whoever persists them: localStorage in the
 * browser, the Lua server (which validates and owns the database) in game.
 */
export const persistPrefs = (prefs: PrefsMap): void => {
  if (import.meta.env.DEV) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(prefs))
    } catch {
      /* a blocked storage only costs the convenience */
    }

    return
  }

  void sendNuiCallback('siku_hud:nui:savePrefs', { prefs })
}

/** Tells the game the settings interface closed, so focus is released. */
export const notifySettingsClosed = (): void => {
  if (!import.meta.env.DEV) {
    void sendNuiCallback('siku_hud:nui:settingsClosed')
  }
}

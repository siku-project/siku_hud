import { useHudStore } from '@/stores/hud'
import { applyLocale, type LocalePayload } from '@/utils/locale'
import { sendNuiCallback } from '@/utils/nui'

interface NuiMessage {
  action?: string
  locale?: LocalePayload
  payload?: unknown
}

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null

export const initNuiBridge = (): (() => void) => {
  const store = useHudStore()

  const handleMessage = (event: MessageEvent<NuiMessage>): void => {
    const { action, locale, payload } = event.data ?? {}

    if (!action?.startsWith('siku_hud:nui:')) {
      return
    }

    if (action === 'siku_hud:nui:setLocale' && locale) {
      applyLocale(locale)
      return
    }

    if (!isRecord(payload)) {
      return
    }

    switch (action) {
      case 'siku_hud:nui:setVisible':
        store.setVisible(payload.visible === true)
        break
      case 'siku_hud:nui:setVitals':
        store.patchVitals(payload)
        break
      case 'siku_hud:nui:setLocation':
        store.patchLocation(payload)
        break
      case 'siku_hud:nui:setVoice':
        store.patchVoice(payload)
        break
      case 'siku_hud:nui:setRadio':
        store.patchRadio(payload)
        break
      case 'siku_hud:nui:setVehicle':
        store.patchVehicle(payload)
        break
    }
  }

  window.addEventListener('message', handleMessage)
  void sendNuiCallback('siku_hud:nui:ready')

  return () => {
    window.removeEventListener('message', handleMessage)
  }
}

import { ref } from 'vue'
import { defineStore } from 'pinia'

export type HudScreen = 'hidden' | 'main'

export const HUD_SCREENS: HudScreen[] = ['hidden', 'main']

export const useHudStore = defineStore('hud', () => {
  const screen = ref<HudScreen>('hidden')

  const setScreen = (next: HudScreen): void => {
    screen.value = next
  }

  const hide = (): void => {
    screen.value = 'hidden'
  }

  return { screen, setScreen, hide }
})

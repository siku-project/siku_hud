import { reactive, ref } from 'vue'
import { defineStore } from 'pinia'
import { createHudDefaults } from '@/types/hud'
import type { HudLocation, HudRadio, HudState, HudVehicle, HudVitals, HudVoice } from '@/types/hud'

export const useHudStore = defineStore('hud', () => {
  const defaults = createHudDefaults()

  const visible = ref(defaults.visible)
  const vitals = reactive<HudVitals>(defaults.vitals)
  const location = reactive<HudLocation>(defaults.location)
  const voice = reactive<HudVoice>(defaults.voice)
  const radio = reactive<HudRadio>(defaults.radio)
  const vehicle = reactive<HudVehicle>(defaults.vehicle)

  const setVisible = (next: boolean): void => {
    visible.value = next
  }

  const patchVitals = (patch: Partial<HudVitals>): void => {
    Object.assign(vitals, patch)
  }

  const patchLocation = (patch: Partial<HudLocation>): void => {
    Object.assign(location, patch)
  }

  const patchVoice = (patch: Partial<HudVoice>): void => {
    Object.assign(voice, patch)
  }

  const patchRadio = (patch: Partial<HudRadio>): void => {
    Object.assign(radio, patch)
  }

  const patchVehicle = (patch: Partial<HudVehicle>): void => {
    Object.assign(vehicle, patch)
  }

  const applyState = (state: HudState): void => {
    visible.value = state.visible
    Object.assign(vitals, state.vitals)
    Object.assign(location, state.location)
    Object.assign(voice, state.voice)
    Object.assign(radio, state.radio)
    Object.assign(vehicle, state.vehicle)
  }

  return {
    visible,
    vitals,
    location,
    voice,
    radio,
    vehicle,
    setVisible,
    patchVitals,
    patchLocation,
    patchVoice,
    patchRadio,
    patchVehicle,
    applyState,
  }
})

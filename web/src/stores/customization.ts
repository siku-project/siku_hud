import { computed, reactive, ref } from 'vue'
import { defineStore } from 'pinia'
import { notifySettingsClosed, persistPrefs } from '@/utils/prefs'
import type {
  ComponentPrefs,
  CustomizationPayload,
  HudComponentId,
  PrefsMap,
  ResolvedComponent,
  ScaleLimits,
  ServerComponent,
} from '@/types/customization'

const clonePrefs = (prefs: PrefsMap): PrefsMap => JSON.parse(JSON.stringify(prefs)) as PrefsMap

export const useCustomizationStore = defineStore('customization', () => {
  const components = ref<ServerComponent[]>([])
  const limits = ref<ScaleLimits>({ scaleMin: 0.7, scaleMax: 1.4 })
  const prefs = reactive<PrefsMap>({})

  const settingsOpen = ref(false)
  const editMode = ref(false)
  const selectedId = ref<HudComponentId | null>(null)
  const draggingId = ref<HudComponentId | null>(null)

  let editSnapshot: PrefsMap | null = null
  let dirty = false

  const byId = computed(() => {
    const map = {} as Partial<Record<HudComponentId, ServerComponent>>

    for (const component of components.value) {
      map[component.id] = component
    }

    return map
  })

  const resolved = computed(() => {
    const map = {} as Partial<Record<HudComponentId, ResolvedComponent>>

    for (const component of components.value) {
      const override: ComponentPrefs = prefs[component.id] ?? {}
      const colorAllowed = component.color

      map[component.id] = {
        id: component.id,
        color: colorAllowed,
        x: override.x ?? component.defaults.x,
        y: override.y ?? component.defaults.y,
        scale: clampScale(override.scale ?? component.defaults.scale),
        colorMode: colorAllowed
          ? (override.colorMode ?? component.defaults.colorMode)
          : component.defaults.colorMode,
        primary: colorAllowed
          ? (override.primary ?? component.defaults.primary)
          : component.defaults.primary,
        secondary: colorAllowed
          ? (override.secondary ?? component.defaults.secondary)
          : component.defaults.secondary,
      }
    }

    return map
  })

  const isEnabled = (id: HudComponentId): boolean => byId.value[id] !== undefined

  function clampScale(scale: number): number {
    return Math.min(limits.value.scaleMax, Math.max(limits.value.scaleMin, scale))
  }

  const applyPayload = (payload: CustomizationPayload): void => {
    components.value = payload.components
    limits.value = payload.limits

    for (const key of Object.keys(prefs) as HudComponentId[]) {
      delete prefs[key]
    }

    Object.assign(prefs, payload.prefs)
  }

  const setPref = (id: HudComponentId, patch: ComponentPrefs): void => {
    if (!isEnabled(id)) {
      return
    }

    prefs[id] = { ...prefs[id], ...patch }
    dirty = true
  }

  const resetComponent = (id: HudComponentId): void => {
    if (prefs[id]) {
      delete prefs[id]
      dirty = true
    }
  }

  const resetAll = (): void => {
    for (const key of Object.keys(prefs) as HudComponentId[]) {
      delete prefs[key]
    }

    dirty = true
  }

  const save = (): void => {
    if (dirty) {
      dirty = false
      persistPrefs(clonePrefs(prefs))
    }
  }

  const openSettings = (): void => {
    settingsOpen.value = true

    if (!selectedId.value) {
      selectedId.value = components.value[0]?.id ?? null
    }
  }

  const closeSettings = (): void => {
    settingsOpen.value = false
    editMode.value = false
    save()
    notifySettingsClosed()
  }

  const enterEdit = (): void => {
    editSnapshot = clonePrefs(prefs)
    editMode.value = true
  }

  const cancelEdit = (): void => {
    if (editSnapshot) {
      for (const key of Object.keys(prefs) as HudComponentId[]) {
        delete prefs[key]
      }

      Object.assign(prefs, editSnapshot)
      editSnapshot = null
    }

    editMode.value = false
    draggingId.value = null
  }

  const confirmEdit = (): void => {
    editSnapshot = null
    editMode.value = false
    draggingId.value = null
    dirty = true
    save()
  }

  return {
    components,
    limits,
    prefs,
    settingsOpen,
    editMode,
    selectedId,
    draggingId,
    resolved,
    isEnabled,
    applyPayload,
    setPref,
    resetComponent,
    resetAll,
    save,
    openSettings,
    closeSettings,
    enterEdit,
    cancelEdit,
    confirmEdit,
  }
})

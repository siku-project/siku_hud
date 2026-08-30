<script setup lang="ts">
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import LocationBar from '@/components/hud/LocationBar.vue'
import RadioCard from '@/components/hud/RadioCard.vue'
import VehicleCluster from '@/components/hud/VehicleCluster.vue'
import VitalRing from '@/components/hud/VitalRing.vue'
import VoiceCard from '@/components/hud/VoiceCard.vue'
import LayoutEditor from '@/components/settings/LayoutEditor.vue'
import SettingsPanel from '@/components/settings/SettingsPanel.vue'
import { useCustomizationStore } from '@/stores/customization'
import { useHudStore } from '@/stores/hud'
import type { HudComponentId } from '@/types/customization'
import type { CSSProperties } from 'vue'

const hud = useHudStore()
const custom = useCustomizationStore()

const { visible, vitals, voice, radio, vehicle } = storeToRefs(hud)
const { editMode, settingsOpen, draggingId, resolved } = storeToRefs(custom)

const VITAL_ICONS: Partial<Record<HudComponentId, string>> = {
  health: 'mdi-heart-outline',
  hunger: 'mdi-hamburger',
  thirst: 'mdi-water-outline',
  armor: 'mdi-shield-outline',
  stamina: 'mdi-run-fast',
  oxygen: 'mdi-lungs',
}

const VITAL_VALUES: Partial<Record<HudComponentId, () => number>> = {
  health: () => vitals.value.health,
  hunger: () => vitals.value.hunger,
  thirst: () => vitals.value.thirst,
  armor: () => vitals.value.armor,
  stamina: () => vitals.value.stamina,
  oxygen: () => vitals.value.oxygen,
}

const isShown = (id: HudComponentId): boolean => {
  if (editMode.value) {
    return true
  }

  const v = vitals.value

  switch (id) {
    case 'armor':
      return v.armor > 0
    case 'stamina':
      return v.staminaActive || v.stamina < 100
    case 'oxygen':
      return v.oxygenActive || v.oxygen < 100
    case 'voice':
      return voice.value.active
    case 'radio':
      return radio.value.active
    case 'vehicle':
      return vehicle.value.active
    default:
      return true
  }
}

const entries = computed(() =>
  custom.components.filter((component) => isShown(component.id)).map((component) => component.id),
)

const styleOf = (id: HudComponentId): CSSProperties => {
  const spec = resolved.value[id]

  if (!spec) {
    return {}
  }

  const secondary = spec.colorMode === 'solid' ? spec.primary : spec.secondary

  return {
    left: `${spec.x * 100}%`,
    top: `${spec.y * 100}%`,
    transform: `scale(${spec.scale})`,
    '--hud-grad-a': spec.primary,
    '--hud-grad-b': secondary,
  }
}

const startDrag = (id: HudComponentId, event: PointerEvent): void => {
  if (!editMode.value) {
    return
  }

  event.preventDefault()

  const element = event.currentTarget as HTMLElement
  const rect = element.getBoundingClientRect()
  const offsetX = event.clientX - rect.left
  const offsetY = event.clientY - rect.top

  custom.draggingId = id

  const move = (ev: PointerEvent): void => {
    const width = window.innerWidth
    const height = window.innerHeight

    const x = Math.min(1 - rect.width / width, Math.max(0, (ev.clientX - offsetX) / width))
    const y = Math.min(1 - rect.height / height, Math.max(0, (ev.clientY - offsetY) / height))

    custom.setPref(id, {
      x: Math.round(x * 10000) / 10000,
      y: Math.round(y * 10000) / 10000,
    })
  }

  const up = (): void => {
    custom.draggingId = null
    window.removeEventListener('pointermove', move)
    window.removeEventListener('pointerup', up)
  }

  window.addEventListener('pointermove', move)
  window.addEventListener('pointerup', up)
}
</script>

<template>
  <Transition name="hud-fade">
    <div v-if="visible" class="hud pointer-events-none fixed inset-0 select-none">
      <div v-if="editMode" class="hud__scrim" aria-hidden="true"></div>

      <TransitionGroup name="hud-pop">
        <div
          v-for="id in entries"
          :key="id"
          class="hud__item"
          :class="{
            'hud__item--editable': editMode,
            'hud__item--dim': editMode && draggingId !== null && draggingId !== id,
          }"
          :style="styleOf(id)"
          @pointerdown="startDrag(id, $event)"
        >
          <VitalRing
            v-if="VITAL_ICONS[id]"
            :icon="VITAL_ICONS[id] as string"
            :value="VITAL_VALUES[id]?.() ?? 0"
          />
          <LocationBar v-else-if="id === 'location'" />
          <VoiceCard v-else-if="id === 'voice'" />
          <RadioCard v-else-if="id === 'radio'" />
          <VehicleCluster v-else-if="id === 'vehicle'" :preview="editMode" />
        </div>
      </TransitionGroup>

      <LayoutEditor v-if="editMode" />
      <SettingsPanel v-else-if="settingsOpen" />
    </div>
  </Transition>
</template>

<style scoped>
.hud__scrim {
  position: absolute;
  inset: 0;
  background: rgba(9, 11, 18, 0.42);
}

.hud__item {
  position: absolute;
  transform-origin: top left;
}

.hud__item--editable {
  pointer-events: auto;
  cursor: grab;
}

.hud__item--editable:active {
  cursor: grabbing;
}

.hud__item--dim {
  opacity: 0.68;
}

.hud-fade-enter-active,
.hud-fade-leave-active {
  transition: opacity 0.25s ease;
}

.hud-fade-enter-from,
.hud-fade-leave-to {
  opacity: 0;
}

.hud-pop-enter-active,
.hud-pop-leave-active {
  transition:
    opacity 0.3s ease,
    transform 0.3s ease;
}

.hud-pop-enter-from,
.hud-pop-leave-to {
  opacity: 0;
}
</style>

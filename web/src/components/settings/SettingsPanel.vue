<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { storeToRefs } from 'pinia'
import { useI18n } from 'vue-i18n'
import ColorInput from '@/components/settings/ColorInput.vue'
import LocationBar from '@/components/hud/LocationBar.vue'
import RadioCard from '@/components/hud/RadioCard.vue'
import VehicleCluster from '@/components/hud/VehicleCluster.vue'
import VitalRing from '@/components/hud/VitalRing.vue'
import VoiceCard from '@/components/hud/VoiceCard.vue'
import { useCustomizationStore } from '@/stores/customization'
import { useHudStore } from '@/stores/hud'
import type { ColorMode, HudComponentId } from '@/types/customization'
import type { CSSProperties } from 'vue'

const { t } = useI18n()
const custom = useCustomizationStore()
const hud = useHudStore()
const { components, limits, selectedId, resolved } = storeToRefs(custom)

const confirmingReset = ref(false)

const COMPONENT_ICONS: Record<HudComponentId, string> = {
  health: 'mdi-heart-outline',
  hunger: 'mdi-hamburger',
  thirst: 'mdi-water-outline',
  armor: 'mdi-shield-outline',
  stamina: 'mdi-run-fast',
  oxygen: 'mdi-lungs',
  location: 'mdi-map-marker-outline',
  voice: 'mdi-microphone-outline',
  radio: 'mdi-radio-handheld',
  vehicle: 'mdi-speedometer',
}

const VITAL_VALUES: Partial<Record<HudComponentId, () => number>> = {
  health: () => hud.vitals.health,
  hunger: () => hud.vitals.hunger,
  thirst: () => hud.vitals.thirst,
  armor: () => hud.vitals.armor,
  stamina: () => hud.vitals.stamina,
  oxygen: () => hud.vitals.oxygen,
}

const PREVIEW_BASE: Partial<Record<HudComponentId, number>> = {
  vehicle: 0.48,
  location: 0.95,
}

const selected = computed(() =>
  selectedId.value ? (resolved.value[selectedId.value] ?? null) : null,
)

const previewValue = computed(() => {
  if (!selectedId.value) {
    return 75
  }

  const value = VITAL_VALUES[selectedId.value]?.() ?? 75

  return value > 0 ? value : 75
})

const previewStyle = computed<CSSProperties>(() => {
  const spec = selected.value

  if (!spec) {
    return {}
  }

  const base = PREVIEW_BASE[spec.id] ?? 1
  const secondary = spec.colorMode === 'solid' ? spec.primary : spec.secondary

  return {
    transform: `scale(${spec.scale * base})`,
    '--hud-grad-a': spec.primary,
    '--hud-grad-b': secondary,
  }
})

const scalePercent = computed(() =>
  selected.value ? `${Math.round(selected.value.scale * 100)}%` : '',
)

const scaleFill = computed(() => {
  if (!selected.value) {
    return '0%'
  }

  const { scaleMin, scaleMax } = limits.value

  return `${((selected.value.scale - scaleMin) / (scaleMax - scaleMin)) * 100}%`
})

const select = (id: HudComponentId): void => {
  selectedId.value = id
  confirmingReset.value = false
}

const setScale = (event: Event): void => {
  if (selectedId.value) {
    custom.setPref(selectedId.value, {
      scale: Number((event.target as HTMLInputElement).value) / 100,
    })
  }
}

const setColorMode = (mode: ColorMode): void => {
  if (selectedId.value) {
    custom.setPref(selectedId.value, { colorMode: mode })
  }
}

const setPrimary = (color: string): void => {
  if (selectedId.value) {
    custom.setPref(selectedId.value, { primary: color })
  }
}

const setSecondary = (color: string): void => {
  if (selectedId.value) {
    custom.setPref(selectedId.value, { secondary: color })
  }
}

const resetSelected = (): void => {
  if (selectedId.value) {
    custom.resetComponent(selectedId.value)
  }
}

const resetAll = (): void => {
  if (!confirmingReset.value) {
    confirmingReset.value = true
    return
  }

  confirmingReset.value = false
  custom.resetAll()
}

const handleKeydown = (event: KeyboardEvent): void => {
  if (event.key === 'Escape') {
    custom.closeSettings()
  }
}

onMounted(() => window.addEventListener('keydown', handleKeydown))
onBeforeUnmount(() => window.removeEventListener('keydown', handleKeydown))
</script>

<template>
  <div class="veil pointer-events-auto" @click.self="custom.closeSettings()">
    <section class="panel">
      <span class="panel__signature" aria-hidden="true"></span>

      <header class="panel__head">
        <div class="panel__brand">
          <span class="panel__mark" aria-hidden="true">
            <v-icon size="15" icon="mdi-tune-variant" />
          </span>
          <div>
            <h1 class="panel__title">{{ t('hud.settings.title') }}</h1>
            <p class="panel__subtitle">/hud</p>
          </div>
        </div>

        <button
          type="button"
          class="panel__close"
          :title="t('hud.settings.close')"
          @click="custom.closeSettings()"
        >
          <v-icon size="16" icon="mdi-close" />
        </button>
      </header>

      <div class="panel__body">
        <nav class="panel__nav">
          <button
            v-for="component in components"
            :key="component.id"
            type="button"
            class="item"
            :class="{ 'item--active': component.id === selectedId }"
            @click="select(component.id)"
          >
            <span class="item__rail" aria-hidden="true"></span>
            <v-icon size="15" :icon="COMPONENT_ICONS[component.id]" />
            <span class="item__label">{{ t(`hud.component.${component.id}`) }}</span>
          </button>
        </nav>

        <div v-if="selected" class="panel__main">
          <div class="preview">
            <div class="preview__stage" :style="previewStyle">
              <VitalRing
                v-if="VITAL_VALUES[selected.id]"
                :icon="COMPONENT_ICONS[selected.id]"
                :value="previewValue"
              />
              <LocationBar v-else-if="selected.id === 'location'" />
              <VoiceCard v-else-if="selected.id === 'voice'" />
              <RadioCard v-else-if="selected.id === 'radio'" />
              <VehicleCluster v-else-if="selected.id === 'vehicle'" preview />
            </div>
          </div>

          <div class="controls">
            <div class="field">
              <div class="field__row">
                <span class="field__label">{{ t('hud.settings.size') }}</span>
                <span class="field__value hud-num">{{ scalePercent }}</span>
              </div>
              <input
                type="range"
                class="range"
                :style="{ '--fill': scaleFill }"
                :min="Math.round(limits.scaleMin * 100)"
                :max="Math.round(limits.scaleMax * 100)"
                :value="Math.round(selected.scale * 100)"
                @input="setScale"
              />
            </div>

            <template v-if="selected.color">
              <div class="field">
                <span class="field__label">{{ t('hud.settings.color') }}</span>
                <div class="segmented">
                  <button
                    type="button"
                    class="segmented__item"
                    :class="{ 'segmented__item--active': selected.colorMode === 'solid' }"
                    @click="setColorMode('solid')"
                  >
                    {{ t('hud.settings.solid') }}
                  </button>
                  <button
                    type="button"
                    class="segmented__item"
                    :class="{ 'segmented__item--active': selected.colorMode === 'gradient' }"
                    @click="setColorMode('gradient')"
                  >
                    {{ t('hud.settings.gradient') }}
                  </button>
                </div>
              </div>

              <div class="colors">
                <ColorInput
                  :label="t('hud.settings.primary')"
                  :model-value="selected.primary"
                  @update:model-value="setPrimary"
                />
                <ColorInput
                  v-if="selected.colorMode === 'gradient'"
                  :label="t('hud.settings.secondary')"
                  :model-value="selected.secondary"
                  @update:model-value="setSecondary"
                />
              </div>
            </template>

            <div class="actions">
              <button type="button" class="btn btn--primary" @click="custom.enterEdit()">
                <v-icon size="14" icon="mdi-cursor-move" />
                {{ t('hud.settings.editPosition') }}
              </button>

              <button type="button" class="btn btn--ghost" @click="resetSelected">
                {{ t('hud.settings.resetComponent') }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <footer class="panel__foot">
        <button
          type="button"
          class="btn btn--ghost"
          :class="{ 'btn--danger': confirmingReset }"
          @click="resetAll"
        >
          {{ confirmingReset ? t('hud.settings.resetAllConfirm') : t('hud.settings.resetAll') }}
        </button>

        <button type="button" class="btn btn--close" @click="custom.closeSettings()">
          {{ t('hud.settings.close') }}
        </button>
      </footer>
    </section>
  </div>
</template>

<style scoped>
.veil {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(9, 11, 18, 0.6);
}

.panel {
  position: relative;
  display: flex;
  width: min(780px, calc(100vw - 64px));
  max-height: min(560px, calc(100vh - 64px));
  flex-direction: column;
  overflow: hidden;
  border: 1px solid #2a3447;
  border-radius: 14px;
  background: rgba(18, 22, 34, 0.98);
  box-shadow: 0 40px 90px -40px rgba(0, 0, 0, 0.95);
}

.panel__signature {
  position: absolute;
  inset-inline: 18%;
  top: 0;
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(105, 206, 255, 0.55),
    rgba(161, 140, 255, 0.5),
    transparent
  );
}

.panel__head {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid rgba(42, 52, 71, 0.8);
  padding: 16px 20px;
}

.panel__brand {
  display: flex;
  align-items: center;
  gap: 12px;
}

.panel__mark {
  display: flex;
  height: 32px;
  width: 32px;
  align-items: center;
  justify-content: center;
  border: 1px solid transparent;
  border-radius: 10px;
  background:
    linear-gradient(#191f2d, #191f2d) padding-box,
    linear-gradient(135deg, #69ceff, #a18cff) border-box;
  color: #f5f7fc;
}

.panel__title {
  font-size: 14.5px;
  font-weight: 600;
  letter-spacing: -0.01em;
  color: #f5f7fc;
}

.panel__subtitle {
  margin-top: 1px;
  font-size: 9.5px;
  font-weight: 500;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(164, 172, 188, 0.6);
}

.panel__close {
  display: flex;
  height: 28px;
  width: 28px;
  align-items: center;
  justify-content: center;
  border: 1px solid #2a3447;
  border-radius: 9px;
  background: rgba(25, 31, 45, 0.85);
  color: #a4acbc;
  transition:
    border-color 0.16s ease,
    color 0.16s ease;
}

.panel__close:hover {
  border-color: rgba(105, 206, 255, 0.4);
  color: #f5f7fc;
}

.panel__body {
  display: flex;
  min-height: 0;
  flex: 1;
}

.panel__nav {
  display: flex;
  width: 172px;
  flex-shrink: 0;
  flex-direction: column;
  gap: 2px;
  overflow-y: auto;
  border-right: 1px solid rgba(42, 52, 71, 0.8);
  padding: 12px 10px;
  scrollbar-width: thin;
}

.item {
  position: relative;
  display: flex;
  align-items: center;
  gap: 10px;
  overflow: hidden;
  border-radius: 9px;
  padding: 9px 12px;
  color: #a4acbc;
  transition:
    background 0.14s ease,
    color 0.14s ease;
}

.item__rail {
  position: absolute;
  left: 0;
  top: 50%;
  height: 0;
  width: 2.5px;
  background: linear-gradient(180deg, #69ceff, #a18cff);
  transform: translateY(-50%);
  transition: height 0.18s ease;
}

.item:hover {
  background: rgba(245, 247, 252, 0.04);
  color: #f5f7fc;
}

.item--active {
  background: rgba(25, 31, 45, 0.95);
  color: #f5f7fc;
}

.item--active .item__rail {
  height: 68%;
}

.item__label {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 11.5px;
  font-weight: 500;
}

.panel__main {
  display: flex;
  min-width: 0;
  flex: 1;
  flex-direction: column;
  gap: 15px;
  overflow-y: auto;
  padding: 16px 20px;
  scrollbar-width: thin;
}

.preview {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  min-height: 158px;
  overflow: hidden;
  border: 1px solid #2a3447;
  border-radius: 12px;
  background:
    radial-gradient(120% 140% at 50% 0%, rgba(105, 206, 255, 0.05) 0%, transparent 55%), #0c0f18;
}

.preview__stage {
  pointer-events: none;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.2s ease;
}

.controls {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.field__row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}

.field__label {
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: rgba(164, 172, 188, 0.7);
}

.field__value {
  font-size: 11px;
  font-variant-numeric: tabular-nums;
  color: #69ceff;
}

.range {
  width: 100%;
  height: 4px;
  appearance: none;
  border-radius: 9999px;
  background-color: rgba(42, 52, 71, 0.9);
  background-image: linear-gradient(90deg, #69ceff, #a18cff);
  background-repeat: no-repeat;
  background-size: var(--fill, 50%) 100%;
  cursor: pointer;
}

.range::-webkit-slider-thumb {
  appearance: none;
  height: 14px;
  width: 14px;
  border: 1px solid rgba(105, 206, 255, 0.6);
  border-radius: 9999px;
  background: #f5f7fc;
  box-shadow: 0 0 10px rgba(161, 140, 255, 0.6);
}

.segmented {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px;
  border: 1px solid #2a3447;
  border-radius: 10px;
  background: rgba(25, 31, 45, 0.7);
  padding: 4px;
}

.segmented__item {
  border: 1px solid transparent;
  border-radius: 7px;
  padding: 7px 0;
  font-size: 11.5px;
  font-weight: 500;
  color: rgba(164, 172, 188, 0.75);
  transition:
    background 0.16s ease,
    color 0.16s ease;
}

.segmented__item:hover {
  color: #f5f7fc;
}

.segmented__item--active {
  background:
    linear-gradient(rgba(25, 31, 45, 0.95), rgba(25, 31, 45, 0.95)) padding-box,
    linear-gradient(135deg, #69ceff, #a18cff) border-box;
  color: #f5f7fc;
}

.colors {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.actions {
  display: flex;
  gap: 10px;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  border-radius: 10px;
  padding: 10px 16px;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.06em;
  transition:
    background 0.16s ease,
    border-color 0.16s ease,
    color 0.16s ease;
}

.btn--primary {
  flex: 1;
  border: 1px solid rgba(105, 206, 255, 0.6);
  background: #69ceff;
  color: #090b12;
  box-shadow: 0 12px 28px -14px rgba(105, 206, 255, 0.6);
}

.btn--primary:hover {
  background: #8fdbff;
}

.btn--ghost {
  border: 1px solid #2a3447;
  background: rgba(25, 31, 45, 0.85);
  color: #a4acbc;
}

.btn--ghost:hover {
  border-color: #385064;
  color: #f5f7fc;
}

.btn--danger {
  border-color: rgba(255, 107, 120, 0.5);
  color: #ff6b78;
}

.btn--close {
  border: 1px solid #2a3447;
  background: transparent;
  color: rgba(164, 172, 188, 0.75);
}

.btn--close:hover {
  color: #f5f7fc;
}

.panel__foot {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: space-between;
  border-top: 1px solid rgba(42, 52, 71, 0.8);
  padding: 12px 20px;
}
</style>

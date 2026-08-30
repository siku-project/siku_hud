<script setup lang="ts">
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useI18n } from 'vue-i18n'
import SideGauge from '@/components/hud/SideGauge.vue'
import SpeedGauge from '@/components/hud/SpeedGauge.vue'
import VehicleStates from '@/components/hud/VehicleStates.vue'
import { useHudStore } from '@/stores/hud'
import type { VehicleStateEntry } from '@/types/hud'

const props = withDefaults(
  defineProps<{
    preview?: boolean
  }>(),
  {
    preview: false,
  },
)

const { t } = useI18n()
const { vehicle } = storeToRefs(useHudStore())

const PREVIEW_STATES: VehicleStateEntry[] = [
  {
    id: 'seatbelt',
    icon: 'mdi-seatbelt',
    label: 'hud.seatbelt',
    value: 'hud.state.buckled',
    tone: 'positive',
  },
  {
    id: 'engine',
    icon: 'mdi-engine-outline',
    label: 'hud.engine',
    value: 'hud.state.on',
    tone: 'positive',
  },
  {
    id: 'lights',
    icon: 'mdi-car-light-dimmed',
    label: 'hud.lights',
    value: 'hud.state.auto',
    tone: 'neutral',
  },
]

const states = computed(() =>
  props.preview && vehicle.value.states.length === 0 ? PREVIEW_STATES : vehicle.value.states,
)

const fuelTone = computed(() => {
  if (vehicle.value.fuel <= 15) {
    return 'alert'
  }

  if (vehicle.value.fuel <= 30) {
    return 'warn'
  }

  return 'gradient'
})

const tempValueTone = computed(() => {
  if (vehicle.value.engineTemp >= 115) {
    return 'alert'
  }

  if (vehicle.value.engineTemp >= 105) {
    return 'warn'
  }

  return 'dim'
})
</script>

<template>
  <div class="cluster">
    <div class="cluster__gauges">
      <SideGauge
        class="cluster__side cluster__side--left"
        side="left"
        icon="mdi-gas-station-outline"
        :ring-value="vehicle.fuel"
        :display="`${Math.round(vehicle.fuel)}%`"
        :label="t('hud.fuel')"
        marker-text="E"
        marker-tone="alert"
        :tone="fuelTone"
      />
      <SpeedGauge
        class="cluster__speedo"
        :speed="vehicle.speed"
        :gear="vehicle.gear"
        :rpm="vehicle.rpm"
      />
      <SideGauge
        class="cluster__side cluster__side--right"
        side="right"
        icon="mdi-thermometer"
        :ring-value="100"
        static-arc
        :display="`${Math.round(vehicle.engineTemp)}°C`"
        :value-tone="tempValueTone"
        :label="t('hud.engine')"
        marker-icon="mdi-coolant-temperature"
      />
    </div>

    <VehicleStates :states="states" />
  </div>
</template>

<style scoped>
.cluster {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 11px;
}

.cluster__gauges {
  display: flex;
  align-items: flex-end;
}

.cluster__speedo {
  z-index: 1;
}

.cluster__side--left {
  margin-right: -34px;
  margin-bottom: 2px;
}

.cluster__side--right {
  margin-left: -34px;
  margin-bottom: 2px;
}
</style>

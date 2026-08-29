<script setup lang="ts">
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useI18n } from 'vue-i18n'
import SideGauge from '@/components/hud/SideGauge.vue'
import SpeedGauge from '@/components/hud/SpeedGauge.vue'
import VehicleStates from '@/components/hud/VehicleStates.vue'
import { useHudStore } from '@/stores/hud'

const { t } = useI18n()
const { vehicle } = storeToRefs(useHudStore())

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
  <Transition name="cluster-pop">
    <div v-if="vehicle.active" class="cluster">
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

      <VehicleStates :states="vehicle.states" />
    </div>
  </Transition>
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

.cluster-pop-enter-active,
.cluster-pop-leave-active {
  transition:
    opacity 0.3s ease,
    transform 0.3s ease;
}

.cluster-pop-enter-from,
.cluster-pop-leave-to {
  opacity: 0;
  transform: translateY(12px);
}
</style>

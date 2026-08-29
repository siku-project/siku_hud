<script setup lang="ts">
import { storeToRefs } from 'pinia'
import LocationBar from '@/components/hud/LocationBar.vue'
import RadioCard from '@/components/hud/RadioCard.vue'
import VehicleCluster from '@/components/hud/VehicleCluster.vue'
import VitalsCluster from '@/components/hud/VitalsCluster.vue'
import VoiceCard from '@/components/hud/VoiceCard.vue'
import { useHudStore } from '@/stores/hud'

const { visible } = storeToRefs(useHudStore())
</script>

<template>
  <Transition name="hud-fade">
    <div v-if="visible" class="hud pointer-events-none fixed inset-0 select-none">
      <div class="hud__left">
        <VitalsCluster />
        <LocationBar />
      </div>

      <div class="hud__comms">
        <VoiceCard />
        <RadioCard />
      </div>

      <div class="hud__vehicle">
        <VehicleCluster />
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.hud__left {
  position: absolute;
  bottom: var(--hud-minimap-top);
  left: var(--hud-edge);
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 11px;
}

.hud__comms {
  position: absolute;
  bottom: var(--hud-bottom);
  left: var(--hud-minimap-right);
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.hud__vehicle {
  position: absolute;
  right: var(--hud-edge);
  bottom: var(--hud-bottom);
}

.hud-fade-enter-active,
.hud-fade-leave-active {
  transition: opacity 0.25s ease;
}

.hud-fade-enter-from,
.hud-fade-leave-to {
  opacity: 0;
}
</style>

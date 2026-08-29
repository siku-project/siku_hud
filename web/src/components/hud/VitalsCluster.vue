<script setup lang="ts">
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import VitalRing from '@/components/hud/VitalRing.vue'
import { useHudStore } from '@/stores/hud'

const { vitals } = storeToRefs(useHudStore())

const entries = computed(() => {
  const v = vitals.value

  return [
    { id: 'health', icon: 'mdi-heart-outline', value: v.health, shown: true },
    { id: 'hunger', icon: 'mdi-hamburger', value: v.hunger, shown: true },
    { id: 'thirst', icon: 'mdi-water-outline', value: v.thirst, shown: true },
    { id: 'armor', icon: 'mdi-shield-outline', value: v.armor, shown: v.armor > 0 },
    {
      id: 'stamina',
      icon: 'mdi-run-fast',
      value: v.stamina,
      shown: v.staminaActive || v.stamina < 100,
    },
    {
      id: 'oxygen',
      icon: 'mdi-lungs',
      value: v.oxygen,
      shown: v.oxygenActive || v.oxygen < 100,
    },
  ].filter((entry) => entry.shown)
})
</script>

<template>
  <TransitionGroup tag="div" name="vital-pop" class="vitals">
    <VitalRing v-for="entry in entries" :key="entry.id" :icon="entry.icon" :value="entry.value" />
  </TransitionGroup>
</template>

<style scoped>
.vitals {
  position: relative;
  display: flex;
  align-items: flex-end;
  gap: 9px;
}

.vital-pop-move,
.vital-pop-enter-active,
.vital-pop-leave-active {
  transition:
    opacity 0.3s ease,
    transform 0.3s ease;
}

.vital-pop-enter-from,
.vital-pop-leave-to {
  opacity: 0;
  transform: translateY(10px) scale(0.7);
}

.vital-pop-leave-active {
  position: absolute;
}
</style>

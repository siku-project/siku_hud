<script setup lang="ts">
import { computed } from 'vue'
import ArcGauge from '@/components/hud/ArcGauge.vue'

const props = defineProps<{
  icon: string
  value: number
}>()

const tone = computed(() => {
  if (props.value <= 20) {
    return 'alert'
  }

  if (props.value <= 35) {
    return 'warn'
  }

  return 'gradient'
})

const percent = computed(() => `${Math.round(props.value)}%`)
</script>

<template>
  <ArcGauge :value="value" :tone="tone" :size="64" :thickness="5.5" :arc="270">
    <v-icon class="vital__icon" size="17" :icon="icon" />

    <template #foot>
      <span class="vital__value hud-num">{{ percent }}</span>
    </template>
  </ArcGauge>
</template>

<style scoped>
.vital__icon {
  color: rgba(250, 252, 255, 0.98);
  filter: drop-shadow(0 1px 3px rgba(4, 6, 11, 0.95));
}

.vital__value {
  font-size: 10.5px;
  font-weight: 600;
  color: rgba(226, 233, 244, 0.94);
  text-shadow: 0 1px 3px rgba(4, 6, 11, 0.95);
}
</style>

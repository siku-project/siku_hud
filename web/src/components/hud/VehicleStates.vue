<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { VehicleStateEntry } from '@/types/hud'

defineProps<{
  states: VehicleStateEntry[]
}>()

const { t } = useI18n()
</script>

<template>
  <TransitionGroup v-if="states.length" tag="div" name="state-pop" class="states hud-panel">
    <div v-for="entry in states" :key="entry.id" class="states__item">
      <v-icon class="states__icon" size="17" :icon="entry.icon" />
      <span class="states__value" :class="`states__value--${entry.tone}`">
        {{ t(entry.value) }}
      </span>
    </div>
  </TransitionGroup>
</template>

<style scoped>
.states {
  display: flex;
  align-items: center;
  padding: 6px 4px;
}

.states__item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 3px 13px;
}

.states__item + .states__item {
  border-left: 1px solid var(--hud-border);
}

.states__icon {
  color: var(--hud-text-dim);
}

.states__value {
  font-size: 11px;
  font-weight: 600;
}

.states__value--positive {
  color: rgba(85, 214, 165, 0.85);
}

.states__value--neutral {
  color: var(--hud-text-dim);
}

.states__value--accent {
  color: rgba(105, 206, 255, 0.9);
}

.states__value--warning {
  color: rgba(255, 107, 120, 0.9);
}

.state-pop-move,
.state-pop-enter-active,
.state-pop-leave-active {
  transition:
    opacity 0.25s ease,
    transform 0.25s ease;
}

.state-pop-enter-from,
.state-pop-leave-to {
  opacity: 0;
  transform: scale(0.88);
}
</style>

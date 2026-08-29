<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useI18n } from 'vue-i18n'
import { useHudStore } from '@/stores/hud'

const { t } = useI18n()
const { radio } = storeToRefs(useHudStore())
</script>

<template>
  <Transition name="card-pop">
    <div v-if="radio.active" class="card hud-panel">
      <span class="card__tile" :class="{ 'card__tile--live': radio.transmitting }">
        <v-icon size="15" icon="mdi-radio-handheld" />
      </span>

      <div class="card__body">
        <span class="hud-caption">{{ t('hud.radio') }}</span>
        <span class="card__main">{{ t('hud.radioChannel', { channel: radio.channel }) }}</span>
        <span v-if="radio.label" class="card__sub">{{ radio.label }}</span>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.card {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 126px;
  padding: 8px 12px;
}

.card__tile {
  display: flex;
  height: 32px;
  width: 32px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--hud-border);
  border-radius: var(--hud-radius-sm);
  background: var(--hud-tile);
  color: var(--hud-text-dim);
  transition: color 0.16s ease;
}

.card__tile--live {
  border-color: transparent;
  background:
    linear-gradient(var(--hud-tile), var(--hud-tile)) padding-box,
    linear-gradient(135deg, var(--hud-cyan), var(--hud-violet)) border-box;
  color: var(--hud-violet);
  animation: tile-live 1.8s ease-in-out infinite;
}

.card__body {
  display: flex;
  min-width: 0;
  flex-direction: column;
  gap: 0;
}

.card__main {
  font-size: 12px;
  font-weight: 600;
  color: var(--hud-text);
}

.card__sub {
  font-size: 10px;
  color: var(--hud-text-faint);
}

@keyframes tile-live {
  0%,
  100% {
    box-shadow: 0 0 0 0 rgba(161, 140, 255, 0);
  }

  50% {
    box-shadow: 0 0 0 3px rgba(161, 140, 255, 0.1);
  }
}

.card-pop-enter-active,
.card-pop-leave-active {
  transition:
    opacity 0.25s ease,
    transform 0.25s ease;
}

.card-pop-enter-from,
.card-pop-leave-to {
  opacity: 0;
  transform: translateY(6px);
}
</style>

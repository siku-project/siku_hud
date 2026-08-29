<script setup lang="ts">
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useHudStore } from '@/stores/hud'
import { weatherIcon } from '@/utils/hud'

const { location } = storeToRefs(useHudStore())

const heading = computed(() => `${Math.round(location.value.heading)}°`)
const icon = computed(() => weatherIcon(location.value.weather))
const temperature = computed(() =>
  location.value.temperature === null ? null : `${Math.round(location.value.temperature)}°C`,
)
</script>

<template>
  <div class="bar hud-panel">
    <div class="bar__compass">
      <span class="bar__cardinal">{{ location.cardinal }}</span>
      <span class="bar__heading hud-num">{{ heading }}</span>
    </div>

    <span class="bar__sep" aria-hidden="true"></span>

    <div class="bar__place">
      <span class="bar__street">{{ location.street }}</span>
      <span v-if="location.zone" class="bar__zone">{{ location.zone }}</span>
    </div>

    <span class="bar__sep" aria-hidden="true"></span>

    <div class="bar__meta">
      <span class="bar__time hud-num">{{ location.time }}</span>
      <span class="bar__weather">
        <v-icon size="13" :icon="icon" />
        <span v-if="temperature" class="hud-num">{{ temperature }}</span>
      </span>
    </div>
  </div>
</template>

<style scoped>
.bar {
  display: flex;
  align-items: center;
  gap: 13px;
  width: max-content;
  min-width: 330px;
  padding: 9px 15px;
}

.bar__compass {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 34px;
}

.bar__cardinal {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0.04em;
  line-height: 1.1;
  color: var(--hud-text);
}

.bar__heading {
  font-size: 10px;
  font-weight: 500;
  color: var(--hud-text-faint);
}

.bar__sep {
  align-self: stretch;
  width: 1px;
  background: var(--hud-border);
}

.bar__place {
  display: flex;
  min-width: 0;
  flex: 1;
  flex-direction: column;
  gap: 1px;
}

.bar__street {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 13px;
  font-weight: 600;
  color: var(--hud-text);
}

.bar__zone {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 10.5px;
  color: var(--hud-text-faint);
}

.bar__meta {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 1px;
}

.bar__time {
  font-size: 13px;
  font-weight: 600;
  color: var(--hud-text);
}

.bar__weather {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 10.5px;
  color: var(--hud-text-faint);
}
</style>

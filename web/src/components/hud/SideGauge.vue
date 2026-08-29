<script setup lang="ts">
import { computed, useId } from 'vue'
import { clampPercent } from '@/utils/hud'

const props = withDefaults(
  defineProps<{
    side: 'left' | 'right'
    icon: string
    ringValue: number
    display: string
    label: string
    markerText?: string
    markerIcon?: string
    markerTone?: 'dim' | 'alert'
    tone?: 'gradient' | 'warn' | 'alert'
    valueTone?: 'bright' | 'dim' | 'warn' | 'alert'
    staticArc?: boolean
  }>(),
  {
    markerText: '',
    markerIcon: '',
    markerTone: 'dim',
    tone: 'gradient',
    valueTone: 'bright',
    staticArc: false,
  },
)

const gradientId = useId()

const value = computed(() => (props.staticArc ? 100 : clampPercent(props.ringValue)))

const stroke = computed(() => {
  if (props.tone === 'alert') {
    return 'var(--hud-alert)'
  }

  if (props.tone === 'warn') {
    return 'var(--hud-warn)'
  }

  return `url(#${gradientId})`
})
</script>

<template>
  <div class="side" :class="`side--${side}`">
    <svg class="side__shape" viewBox="0 0 100 110" aria-hidden="true">
      <defs>
        <linearGradient :id="gradientId" x1="0" y1="1" x2="0" y2="0">
          <stop offset="0%" stop-color="#69ceff" />
          <stop offset="100%" stop-color="#a18cff" />
        </linearGradient>
      </defs>

      <path
        d="M 30 100 A 59 59 0 0 1 30 8"
        fill="none"
        stroke="var(--hud-track)"
        stroke-width="2.4"
        stroke-linecap="round"
      />
      <path
        d="M 30 100 A 59 59 0 0 1 30 8"
        pathLength="100"
        fill="none"
        stroke="rgba(255, 107, 120, 0.85)"
        stroke-width="2.4"
        stroke-linecap="round"
        stroke-dasharray="4 100"
      />
      <path
        class="side__fill"
        d="M 30 100 A 59 59 0 0 1 30 8"
        pathLength="100"
        fill="none"
        :stroke="stroke"
        stroke-width="3"
        stroke-linecap="round"
        :stroke-dasharray="`${value} 100`"
      />
    </svg>

    <div class="side__body">
      <v-icon class="side__icon" size="34" :icon="icon" />
      <span class="side__value hud-num" :class="`side__value--${valueTone}`">{{ display }}</span>
      <span class="side__label">{{ label }}</span>
    </div>

    <span
      v-if="markerText"
      class="side__marker hud-num"
      :class="{ 'side__marker--alert': markerTone === 'alert' }"
    >
      {{ markerText }}
    </span>
    <v-icon v-else-if="markerIcon" class="side__marker" size="12" :icon="markerIcon" />
  </div>
</template>

<style scoped>
.side {
  position: relative;
  width: 138px;
  height: 152px;
  flex-shrink: 0;
}

.side__shape {
  width: 100%;
  height: 100%;
}

.side--right .side__shape {
  transform: scaleX(-1);
}

.side__fill {
  filter: drop-shadow(0 0 3px rgba(105, 206, 255, 0.5))
    drop-shadow(0 0 6px rgba(161, 140, 255, 0.3));
  transition:
    stroke-dasharray 0.35s ease,
    stroke 0.25s ease;
}

.side__body {
  position: absolute;
  top: 6%;
  bottom: 18%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.side--left .side__body {
  left: 16%;
  right: 8%;
}

.side--right .side__body {
  right: 16%;
  left: 8%;
}

.side__icon {
  margin-bottom: 5px;
  color: rgba(245, 247, 252, 0.94);
  filter: drop-shadow(0 1px 4px rgba(5, 8, 14, 0.95));
}

.side__value {
  font-size: 13.5px;
  font-weight: 600;
  text-shadow: 0 1px 4px rgba(5, 8, 14, 0.95);
  transition: color 0.2s ease;
}

.side__value--bright {
  color: var(--hud-text);
}

.side__value--dim {
  color: var(--hud-text-dim);
}

.side__value--warn {
  color: var(--hud-warn);
}

.side__value--alert {
  color: var(--hud-alert);
}

.side__label {
  font-size: 9.5px;
  color: var(--hud-text-dim);
  text-shadow: 0 1px 3px rgba(5, 8, 14, 0.95);
}

.side__marker {
  position: absolute;
  bottom: 1.5%;
  width: max-content;
  font-size: 10px;
  font-weight: 600;
  color: var(--hud-text-faint);
  text-shadow: 0 1px 3px rgba(5, 8, 14, 0.95);
}

.side--left .side__marker {
  left: 30%;
  transform: translateX(-50%);
}

.side--right .side__marker {
  right: 30%;
  transform: translateX(50%);
}

.side__marker--alert {
  color: rgba(255, 107, 120, 0.85);
}
</style>

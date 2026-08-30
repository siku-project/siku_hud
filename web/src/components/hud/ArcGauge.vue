<script setup lang="ts">
import { computed, useId } from 'vue'
import { clampPercent } from '@/utils/hud'

const props = withDefaults(
  defineProps<{
    value: number
    size?: number
    thickness?: number
    arc?: number
    tone?: 'gradient' | 'warn' | 'alert'
    backing?: boolean
  }>(),
  {
    size: 66,
    thickness: 5,
    arc: 270,
    tone: 'gradient',
    backing: true,
  },
)

const gradientId = useId()

const backingThickness = computed(() => props.thickness + 7)
const outerThickness = computed(() => (props.backing ? backingThickness.value : props.thickness))
const radius = computed(() => 50 - outerThickness.value / 2 - 0.5)
const circumference = computed(() => 2 * Math.PI * radius.value)
const visibleLength = computed(() => (circumference.value * props.arc) / 360)
const startAngle = computed(() => 90 + (360 - props.arc) / 2)

const arcDash = computed(() => `${visibleLength.value} ${circumference.value}`)
const fillDash = computed(
  () => `${(visibleLength.value * clampPercent(props.value)) / 100} ${circumference.value}`,
)

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
  <div class="gauge" :style="{ width: `${size}px`, height: `${size}px` }">
    <svg class="gauge__ring" viewBox="0 0 100 100" aria-hidden="true">
      <defs>
        <linearGradient :id="gradientId" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" style="stop-color: var(--hud-grad-a, #69ceff)" />
          <stop offset="100%" style="stop-color: var(--hud-grad-b, #a18cff)" />
        </linearGradient>
      </defs>

      <circle
        v-if="backing"
        cx="50"
        cy="50"
        :r="radius - thickness / 2 - 1"
        fill="rgba(10, 13, 21, 0.52)"
      />
      <circle
        v-if="backing"
        cx="50"
        cy="50"
        :r="radius"
        fill="none"
        stroke="var(--hud-ring-back)"
        :stroke-width="backingThickness"
        stroke-linecap="round"
        :stroke-dasharray="arcDash"
        :transform="`rotate(${startAngle} 50 50)`"
      />
      <circle
        cx="50"
        cy="50"
        :r="radius"
        fill="none"
        stroke="var(--hud-track)"
        :stroke-width="thickness"
        stroke-linecap="round"
        :stroke-dasharray="arcDash"
        :transform="`rotate(${startAngle} 50 50)`"
      />
      <circle
        class="gauge__fill"
        cx="50"
        cy="50"
        :r="radius"
        fill="none"
        :stroke="stroke"
        :stroke-width="thickness"
        stroke-linecap="round"
        :stroke-dasharray="fillDash"
        :transform="`rotate(${startAngle} 50 50)`"
      />
    </svg>

    <div class="gauge__center">
      <slot />
    </div>

    <div class="gauge__foot">
      <slot name="foot" />
    </div>
  </div>
</template>

<style scoped>
.gauge {
  position: relative;
  flex-shrink: 0;
}

.gauge__ring {
  width: 100%;
  height: 100%;
}

.gauge__fill {
  transition:
    stroke-dasharray 0.35s ease,
    stroke 0.25s ease;
}

.gauge__center {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.gauge__foot {
  position: absolute;
  bottom: -2%;
  left: 50%;
  transform: translateX(-50%);
}
</style>

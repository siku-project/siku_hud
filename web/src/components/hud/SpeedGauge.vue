<script setup lang="ts">
import { computed, useId } from 'vue'
import { useI18n } from 'vue-i18n'

const props = defineProps<{
  speed: number
  gear: string
  rpm: number
}>()

const { t } = useI18n()

const ARC = 270
const START = 135
const RING_RADIUS = 44.5
const RING_THICKNESS = 2.6
const FILL_THICKNESS = 3.4
const REDLINE_START = 0.75

const gradientId = useId()

const circumference = 2 * Math.PI * RING_RADIUS
const visibleLength = (circumference * ARC) / 360

const ringDash = `${visibleLength} ${circumference}`
const redDash = `${visibleLength * (1 - REDLINE_START)} ${circumference}`
const redRotation = START + ARC * REDLINE_START

const clampedRpm = computed(() => Math.min(1, Math.max(0, props.rpm)))
const fillDash = computed(() => `${visibleLength * clampedRpm.value} ${circumference}`)

const point = (angle: number, radius: number) => {
  const rad = (angle * Math.PI) / 180
  return { x: 50 + radius * Math.cos(rad), y: 50 + radius * Math.sin(rad) }
}

const majorTicks = computed(() =>
  Array.from({ length: 9 }, (_, index) => {
    const fraction = index / 8
    const angle = START + ARC * fraction
    return {
      index,
      red: fraction >= REDLINE_START,
      from: point(angle, 36.5),
      to: point(angle, 40.5),
      label: point(angle, 30.5),
    }
  }),
)

const minorTicks = computed(() => {
  const ticks = []

  for (let interval = 0; interval < 8; interval += 1) {
    for (let step = 1; step <= 3; step += 1) {
      const fraction = (interval + step / 4) / 8
      const angle = START + ARC * fraction
      ticks.push({
        id: `${interval}-${step}`,
        red: fraction >= REDLINE_START,
        from: point(angle, 38.8),
        to: point(angle, 40.5),
      })
    }
  }

  return ticks
})

const displaySpeed = computed(() => Math.round(props.speed))
</script>

<template>
  <div class="speedo hud-panel">
    <svg class="speedo__dial" viewBox="0 0 100 100" aria-hidden="true">
      <defs>
        <linearGradient :id="gradientId" x1="0" y1="1" x2="1" y2="0">
          <stop offset="0%" stop-color="#69ceff" />
          <stop offset="100%" stop-color="#a18cff" />
        </linearGradient>
      </defs>

      <circle
        cx="50"
        cy="50"
        r="48.6"
        fill="none"
        stroke="rgba(164, 172, 188, 0.14)"
        stroke-width="0.5"
      />
      <circle
        cx="50"
        cy="50"
        r="26.5"
        fill="none"
        stroke="rgba(164, 172, 188, 0.13)"
        stroke-width="0.6"
      />

      <circle
        cx="50"
        cy="50"
        :r="RING_RADIUS"
        fill="none"
        stroke="var(--hud-track)"
        :stroke-width="RING_THICKNESS"
        stroke-linecap="round"
        :stroke-dasharray="ringDash"
        :transform="`rotate(${START} 50 50)`"
      />
      <circle
        class="speedo__red"
        cx="50"
        cy="50"
        :r="RING_RADIUS"
        fill="none"
        stroke="#ff6b78"
        :stroke-width="RING_THICKNESS"
        stroke-linecap="round"
        :stroke-dasharray="redDash"
        :transform="`rotate(${redRotation} 50 50)`"
      />
      <circle
        class="speedo__fill"
        cx="50"
        cy="50"
        :r="RING_RADIUS"
        fill="none"
        :stroke="`url(#${gradientId})`"
        :stroke-width="FILL_THICKNESS"
        stroke-linecap="round"
        :stroke-dasharray="fillDash"
        :transform="`rotate(${START} 50 50)`"
      />

      <line
        v-for="tick in minorTicks"
        :key="`minor-${tick.id}`"
        :x1="tick.from.x"
        :y1="tick.from.y"
        :x2="tick.to.x"
        :y2="tick.to.y"
        :stroke="tick.red ? 'rgba(255, 107, 120, 0.65)' : 'rgba(164, 172, 188, 0.35)'"
        stroke-width="0.5"
      />
      <line
        v-for="tick in majorTicks"
        :key="`major-${tick.index}`"
        :x1="tick.from.x"
        :y1="tick.from.y"
        :x2="tick.to.x"
        :y2="tick.to.y"
        :stroke="tick.red ? 'rgba(255, 107, 120, 0.85)' : 'rgba(245, 247, 252, 0.6)'"
        stroke-width="1"
      />
      <text
        v-for="tick in majorTicks"
        :key="`label-${tick.index}`"
        :x="tick.label.x"
        :y="tick.label.y"
        class="speedo__tick"
        text-anchor="middle"
        dominant-baseline="central"
      >
        {{ tick.index }}
      </text>
    </svg>

    <div class="speedo__center">
      <span class="speedo__speed hud-num">{{ displaySpeed }}</span>
      <span class="speedo__unit">{{ t('hud.kmh') }}</span>
      <span class="speedo__gear hud-num">{{ gear }}</span>
    </div>

    <span class="speedo__caption hud-caption">{{ t('hud.speed') }}</span>
  </div>
</template>

<style scoped>
.speedo {
  position: relative;
  width: 240px;
  height: 240px;
  border-radius: 9999px;
  background: rgba(18, 22, 34, 0.84);
}

.speedo::before {
  content: none;
}

.speedo__dial {
  width: 100%;
  height: 100%;
}

.speedo__fill {
  filter: drop-shadow(0 0 3px rgba(105, 206, 255, 0.55))
    drop-shadow(0 0 6px rgba(161, 140, 255, 0.35));
  transition: stroke-dasharray 0.18s linear;
}

.speedo__red {
  filter: drop-shadow(0 0 3px rgba(255, 107, 120, 0.65));
}

.speedo__tick {
  font-size: 5.4px;
  font-weight: 500;
  fill: rgba(245, 247, 252, 0.82);
}

.speedo__center {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1px;
}

.speedo__speed {
  font-size: 46px;
  font-weight: 700;
  letter-spacing: -0.02em;
  line-height: 1;
  color: var(--hud-text);
  text-shadow:
    0 0 18px rgba(105, 206, 255, 0.3),
    0 0 26px rgba(161, 140, 255, 0.2);
}

.speedo__unit {
  font-size: 9px;
  font-weight: 600;
  letter-spacing: 0.28em;
  text-transform: uppercase;
  color: var(--hud-text-dim);
}

.speedo__gear {
  margin-top: 6px;
  font-size: 20px;
  font-weight: 600;
  color: var(--hud-cyan);
}

.speedo__caption {
  position: absolute;
  bottom: 8.5%;
  left: 50%;
  transform: translateX(-50%);
}
</style>

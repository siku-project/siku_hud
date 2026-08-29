<script setup lang="ts">
import { reactive, watch } from 'vue'
import { useHudStore } from '@/stores/hud'
import { headingToCardinal } from '@/utils/hud'
import type { VehicleStateEntry, VehicleStateTone } from '@/types/hud'

const store = useHudStore()

const vehiclePrefs = reactive({
  bike: false,
  seatbelt: true,
  engine: true,
  lights: 'auto',
})

const buildStates = (): VehicleStateEntry[] => {
  const states: VehicleStateEntry[] = []

  if (!vehiclePrefs.bike) {
    states.push({
      id: 'seatbelt',
      icon: 'mdi-seatbelt',
      label: 'hud.seatbelt',
      value: vehiclePrefs.seatbelt ? 'hud.state.buckled' : 'hud.state.unbuckled',
      tone: vehiclePrefs.seatbelt ? 'positive' : 'warning',
    })
  }

  states.push({
    id: 'engine',
    icon: 'mdi-engine-outline',
    label: 'hud.engine',
    value: vehiclePrefs.engine ? 'hud.state.on' : 'hud.state.off',
    tone: vehiclePrefs.engine ? 'positive' : 'warning',
  })

  const lightTones: Record<string, VehicleStateTone> = {
    off: 'neutral',
    on: 'accent',
    high: 'accent',
    auto: 'neutral',
  }

  states.push({
    id: 'lights',
    icon: 'mdi-car-light-dimmed',
    label: 'hud.lights',
    value: `hud.state.${vehiclePrefs.lights}`,
    tone: lightTones[vehiclePrefs.lights] ?? 'neutral',
  })

  return states
}

watch(vehiclePrefs, () => store.patchVehicle({ states: buildStates() }), { immediate: true })

const setHeading = (value: number): void => {
  store.patchLocation({ heading: value, cardinal: headingToCardinal(value) })
}
</script>

<template>
  <aside class="panel">
    <p class="panel__title">HUD DEBUG</p>

    <section class="panel__section">
      <p class="panel__label">Vitals</p>
      <label class="row">
        <span>Vie</span>
        <input
          type="range"
          min="0"
          max="100"
          :value="store.vitals.health"
          @input="store.patchVitals({ health: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row">
        <span>Armure</span>
        <input
          type="range"
          min="0"
          max="100"
          :value="store.vitals.armor"
          @input="store.patchVitals({ armor: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row">
        <span>Faim</span>
        <input
          type="range"
          min="0"
          max="100"
          :value="store.vitals.hunger"
          @input="store.patchVitals({ hunger: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row">
        <span>Soif</span>
        <input
          type="range"
          min="0"
          max="100"
          :value="store.vitals.thirst"
          @input="store.patchVitals({ thirst: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row">
        <span>Stamina</span>
        <input
          type="range"
          min="0"
          max="100"
          :value="store.vitals.stamina"
          @input="store.patchVitals({ stamina: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row row--check">
        <span>Stamina active</span>
        <input
          type="checkbox"
          :checked="store.vitals.staminaActive"
          @change="
            store.patchVitals({ staminaActive: ($event.target as HTMLInputElement).checked })
          "
        />
      </label>
      <label class="row">
        <span>Oxygène</span>
        <input
          type="range"
          min="0"
          max="100"
          :value="store.vitals.oxygen"
          @input="store.patchVitals({ oxygen: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row row--check">
        <span>Sous l'eau</span>
        <input
          type="checkbox"
          :checked="store.vitals.oxygenActive"
          @change="store.patchVitals({ oxygenActive: ($event.target as HTMLInputElement).checked })"
        />
      </label>
    </section>

    <section class="panel__section">
      <p class="panel__label">Localisation</p>
      <label class="row">
        <span>Heading</span>
        <input
          type="range"
          min="0"
          max="359"
          :value="store.location.heading"
          @input="setHeading(Number(($event.target as HTMLInputElement).value))"
        />
      </label>
      <label class="row">
        <span>Rue</span>
        <input
          type="text"
          :value="store.location.street"
          @input="store.patchLocation({ street: ($event.target as HTMLInputElement).value })"
        />
      </label>
      <label class="row">
        <span>Zone</span>
        <input
          type="text"
          :value="store.location.zone"
          @input="store.patchLocation({ zone: ($event.target as HTMLInputElement).value })"
        />
      </label>
      <label class="row">
        <span>Heure</span>
        <input
          type="text"
          :value="store.location.time"
          @input="store.patchLocation({ time: ($event.target as HTMLInputElement).value })"
        />
      </label>
      <label class="row">
        <span>Météo</span>
        <select
          :value="store.location.weather"
          @change="store.patchLocation({ weather: ($event.target as HTMLSelectElement).value })"
        >
          <option value="clear">Clair</option>
          <option value="cloudy">Nuageux</option>
          <option value="rain">Pluie</option>
          <option value="thunder">Orage</option>
          <option value="fog">Brouillard</option>
          <option value="snow">Neige</option>
        </select>
      </label>
      <label class="row">
        <span>Temp.</span>
        <input
          type="range"
          min="-10"
          max="40"
          :value="store.location.temperature ?? 12"
          @input="
            store.patchLocation({ temperature: Number(($event.target as HTMLInputElement).value) })
          "
        />
      </label>
    </section>

    <section class="panel__section">
      <p class="panel__label">Voix / Radio</p>
      <label class="row row--check">
        <span>Voix visible</span>
        <input
          type="checkbox"
          :checked="store.voice.active"
          @change="store.patchVoice({ active: ($event.target as HTMLInputElement).checked })"
        />
      </label>
      <label class="row row--check">
        <span>Parle</span>
        <input
          type="checkbox"
          :checked="store.voice.talking"
          @change="store.patchVoice({ talking: ($event.target as HTMLInputElement).checked })"
        />
      </label>
      <label class="row">
        <span>Mode</span>
        <select
          :value="store.voice.mode"
          @change="store.patchVoice({ mode: ($event.target as HTMLSelectElement).value })"
        >
          <option value="whisper">Murmure</option>
          <option value="normal">Normal</option>
          <option value="shout">Fort</option>
        </select>
      </label>
      <label class="row">
        <span>Portée</span>
        <input
          type="range"
          min="1"
          max="40"
          :value="store.voice.range"
          @input="store.patchVoice({ range: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row row--check">
        <span>Radio</span>
        <input
          type="checkbox"
          :checked="store.radio.active"
          @change="store.patchRadio({ active: ($event.target as HTMLInputElement).checked })"
        />
      </label>
      <label class="row row--check">
        <span>Transmet</span>
        <input
          type="checkbox"
          :checked="store.radio.transmitting"
          @change="store.patchRadio({ transmitting: ($event.target as HTMLInputElement).checked })"
        />
      </label>
    </section>

    <section class="panel__section">
      <p class="panel__label">Véhicule</p>
      <label class="row row--check">
        <span>En véhicule</span>
        <input
          type="checkbox"
          :checked="store.vehicle.active"
          @change="store.patchVehicle({ active: ($event.target as HTMLInputElement).checked })"
        />
      </label>
      <label class="row row--check">
        <span>Moto</span>
        <input v-model="vehiclePrefs.bike" type="checkbox" />
      </label>
      <label class="row">
        <span>Vitesse</span>
        <input
          type="range"
          min="0"
          max="320"
          :value="store.vehicle.speed"
          @input="store.patchVehicle({ speed: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row">
        <span>RPM</span>
        <input
          type="range"
          min="0"
          max="100"
          :value="store.vehicle.rpm * 100"
          @input="
            store.patchVehicle({ rpm: Number(($event.target as HTMLInputElement).value) / 100 })
          "
        />
      </label>
      <label class="row">
        <span>Rapport</span>
        <select
          :value="store.vehicle.gear"
          @change="store.patchVehicle({ gear: ($event.target as HTMLSelectElement).value })"
        >
          <option v-for="gear in ['R', 'N', '1', '2', '3', '4', '5', '6']" :key="gear">
            {{ gear }}
          </option>
        </select>
      </label>
      <label class="row">
        <span>Carburant</span>
        <input
          type="range"
          min="0"
          max="100"
          :value="store.vehicle.fuel"
          @input="store.patchVehicle({ fuel: Number(($event.target as HTMLInputElement).value) })"
        />
      </label>
      <label class="row">
        <span>Temp.</span>
        <input
          type="range"
          min="40"
          max="130"
          :value="store.vehicle.engineTemp"
          @input="
            store.patchVehicle({ engineTemp: Number(($event.target as HTMLInputElement).value) })
          "
        />
      </label>
      <label class="row row--check">
        <span>Ceinture</span>
        <input v-model="vehiclePrefs.seatbelt" type="checkbox" />
      </label>
      <label class="row row--check">
        <span>Moteur</span>
        <input v-model="vehiclePrefs.engine" type="checkbox" />
      </label>
      <label class="row">
        <span>Phares</span>
        <select v-model="vehiclePrefs.lights">
          <option value="off">Éteints</option>
          <option value="on">Allumés</option>
          <option value="high">Route</option>
          <option value="auto">Auto</option>
        </select>
      </label>
    </section>
  </aside>
</template>

<style scoped>
.panel {
  position: fixed;
  right: 12px;
  top: 64px;
  max-height: 56vh;
  z-index: 50;
  width: 232px;
  overflow-y: auto;
  border-radius: 12px;
  border: 1px solid rgba(42, 52, 71, 0.95);
  background: rgba(13, 16, 25, 0.96);
  padding: 14px;
  scrollbar-width: thin;
}

.panel__title {
  margin-bottom: 10px;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 0.24em;
  color: #69ceff;
}

.panel__section {
  display: flex;
  flex-direction: column;
  gap: 6px;
  border-top: 1px solid rgba(42, 52, 71, 0.7);
  padding: 10px 0;
}

.panel__label {
  font-size: 9.5px;
  font-weight: 600;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: rgba(164, 172, 188, 0.7);
}

.row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  font-size: 11px;
  color: #a4acbc;
}

.row input[type='range'] {
  width: 118px;
  accent-color: #69ceff;
}

.row input[type='text'],
.row select {
  width: 118px;
  border-radius: 6px;
  border: 1px solid rgba(42, 52, 71, 0.95);
  background: rgba(25, 31, 45, 0.9);
  padding: 3px 7px;
  font-size: 11px;
  color: #f5f7fc;
}

.row--check input {
  accent-color: #69ceff;
}
</style>

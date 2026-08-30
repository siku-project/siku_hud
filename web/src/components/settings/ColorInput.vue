<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  label: string
  modelValue: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const value = computed({
  get: () => props.modelValue,
  set: (next: string) => {
    if (/^#[0-9a-fA-F]{6}$/.test(next)) {
      emit('update:modelValue', next.toLowerCase())
    }
  },
})
</script>

<template>
  <label class="color">
    <span class="color__label">{{ label }}</span>
    <span class="color__well">
      <input v-model="value" type="color" class="color__input" />
      <span class="color__hex hud-num">{{ modelValue }}</span>
    </span>
  </label>
</template>

<style scoped>
.color {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}

.color__label {
  font-size: 11.5px;
  color: var(--hud-text-dim);
}

.color__well {
  display: flex;
  align-items: center;
  gap: 8px;
  border: 1px solid var(--hud-border);
  border-radius: 8px;
  background: var(--hud-tile);
  padding: 4px 9px 4px 4px;
}

.color__input {
  width: 26px;
  height: 22px;
  flex-shrink: 0;
  cursor: pointer;
  border: none;
  border-radius: 5px;
  background: none;
  padding: 0;
}

.color__input::-webkit-color-swatch-wrapper {
  padding: 0;
}

.color__input::-webkit-color-swatch {
  border: 1px solid var(--hud-border-strong);
  border-radius: 5px;
}

.color__hex {
  font-size: 11px;
  color: var(--hud-text);
  text-transform: lowercase;
}
</style>

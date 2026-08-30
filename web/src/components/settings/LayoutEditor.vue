<script setup lang="ts">
import { onBeforeUnmount, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useCustomizationStore } from '@/stores/customization'

const { t } = useI18n()
const custom = useCustomizationStore()

const handleKeydown = (event: KeyboardEvent): void => {
  if (event.key === 'Escape') {
    custom.cancelEdit()
  }
}

onMounted(() => window.addEventListener('keydown', handleKeydown))
onBeforeUnmount(() => window.removeEventListener('keydown', handleKeydown))
</script>

<template>
  <div class="editor">
    <button type="button" class="editor__btn editor__btn--ghost" @click="custom.cancelEdit()">
      {{ t('hud.edit.cancel') }}
    </button>

    <p class="editor__hint">{{ t('hud.edit.hint') }}</p>

    <button type="button" class="editor__btn editor__btn--primary" @click="custom.confirmEdit()">
      {{ t('hud.edit.confirm') }}
    </button>
  </div>
</template>

<style scoped>
.editor {
  position: absolute;
  inset-inline: 0;
  top: 0;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  padding: 18px 22px;
}

.editor__hint {
  pointer-events: none;
  margin-top: 9px;
  font-size: 11px;
  font-weight: 500;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(164, 172, 188, 0.85);
  text-shadow: 0 1px 3px rgba(5, 8, 14, 0.9);
}

.editor__btn {
  pointer-events: auto;
  border-radius: 10px;
  padding: 10px 24px;
  font-size: 11.5px;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  transition:
    background 0.16s ease,
    border-color 0.16s ease,
    color 0.16s ease;
}

.editor__btn--ghost {
  border: 1px solid var(--hud-border);
  background: var(--hud-bg);
  color: var(--hud-text-dim);
}

.editor__btn--ghost:hover {
  border-color: var(--hud-border-strong);
  color: var(--hud-text);
}

.editor__btn--primary {
  border: 1px solid rgba(105, 206, 255, 0.6);
  background: var(--hud-cyan);
  color: #090b12;
  box-shadow: 0 12px 28px -14px rgba(105, 206, 255, 0.6);
}

.editor__btn--primary:hover {
  background: #8fdbff;
}
</style>

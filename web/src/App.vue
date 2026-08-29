<script setup lang="ts">
import { computed, defineAsyncComponent, onBeforeUnmount, onMounted } from 'vue'
import type { Component } from 'vue'
import { storeToRefs } from 'pinia'
import MainView from './views/MainView.vue'
import { HUD_SCREENS, useHudStore } from './stores/hud'
import type { HudScreen } from './stores/hud'
import { applyLocale, type LocalePayload } from './utils/locale'
import { sendNuiCallback } from './utils/nui'

const BoilerplateView = import.meta.env.DEV
  ? defineAsyncComponent(() => import('./views/BoilerplateView.vue'))
  : null

const store = useHudStore()
const { screen } = storeToRefs(store)

const VIEWS: Partial<Record<HudScreen, Component>> = {
  main: MainView,
}

const activeView = computed<Component | null>(() => VIEWS[screen.value] ?? null)

interface NuiMessage {
  action?: string
  locale?: LocalePayload
  screen?: HudScreen
}

const handleMessage = (event: MessageEvent<NuiMessage>) => {
  if (event.data?.action === 'siku_hud:nui:setLocale' && event.data.locale) {
    applyLocale(event.data.locale)
  }

  if (
    event.data?.action === 'siku_hud:nui:setScreen' &&
    event.data.screen &&
    HUD_SCREENS.includes(event.data.screen)
  ) {
    store.setScreen(event.data.screen)
  }
}

onMounted(() => {
  window.addEventListener('message', handleMessage)
  sendNuiCallback('siku_hud:nui:ready')
})

onBeforeUnmount(() => {
  window.removeEventListener('message', handleMessage)
})
</script>

<template>
  <VApp>
    <component :is="BoilerplateView" v-if="BoilerplateView" />
    <Transition v-else name="screen-fade" mode="out-in">
      <component :is="activeView" v-if="activeView" :key="screen" />
    </Transition>
  </VApp>
</template>

<style>
.v-application,
.v-application__wrap {
  background: transparent !important;
}
</style>

<style scoped>
.screen-fade-enter-active,
.screen-fade-leave-active {
  transition: opacity 0.25s ease;
}

.screen-fade-enter-from,
.screen-fade-leave-to {
  opacity: 0;
}
</style>

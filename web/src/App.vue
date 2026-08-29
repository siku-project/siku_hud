<script setup lang="ts">
import { defineAsyncComponent, onBeforeUnmount, onMounted } from 'vue'
import HudView from './views/HudView.vue'
import { initNuiBridge } from './nui/bridge'

const BoilerplateView = import.meta.env.DEV
  ? defineAsyncComponent(() => import('./views/BoilerplateView.vue'))
  : null

let teardownBridge: (() => void) | null = null

onMounted(() => {
  teardownBridge = initNuiBridge()
})

onBeforeUnmount(() => {
  teardownBridge?.()
})
</script>

<template>
  <VApp>
    <component :is="BoilerplateView" v-if="BoilerplateView" />
    <HudView v-else />
  </VApp>
</template>

<style>
.v-application,
.v-application__wrap {
  background: transparent !important;
}
</style>

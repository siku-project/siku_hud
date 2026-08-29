<script setup lang="ts">
import { computed, ref } from 'vue'
import type { Component } from 'vue'
import DevTopBar from '@/components/boilerplate/DevTopBar.vue'
import DevFab from '@/components/boilerplate/DevFab.vue'
import DevViewSelector from '@/components/boilerplate/DevViewSelector.vue'
import HudDevPanel from '@/components/dev/HudDevPanel.vue'
import HudView from '@/views/HudView.vue'
import { resolveScenario } from '@/mock/scenarios'
import { useHudStore } from '@/stores/hud'
import backgroundUrl from '@/assets/boilerplate-background.jpg'

const params = new URLSearchParams(window.location.search)

useHudStore().applyState(resolveScenario(params.get('scenario')))

const showPanel = params.get('panel') !== '0'

const viewComponents: Record<string, Component> = {
  Hud: HudView,
}

const views: string[] = Object.keys(viewComponents)
const currentView = ref(params.get('view') ?? 'Hud')

const activeComponent = computed<Component | null>(() =>
  currentView.value !== 'none' ? (viewComponents[currentView.value] ?? null) : null,
)

const handleSelectView = (view: string) => {
  currentView.value = view
}
</script>

<template>
  <div
    class="fixed inset-0 h-full w-full bg-gray-900 bg-contain bg-center bg-no-repeat transition-all duration-300 md:bg-cover"
    :style="{ backgroundImage: `url(${backgroundUrl})` }"
  >
    <component :is="activeComponent" v-if="activeComponent" />

    <HudDevPanel v-if="showPanel && currentView === 'Hud'" />

    <DevTopBar />
    <DevFab :current-view="currentView" />
    <DevViewSelector :views="views" :current-view="currentView" @select-view="handleSelectView" />
  </div>
</template>

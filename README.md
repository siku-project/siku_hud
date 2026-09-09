# siku_hud

A modern, modular HUD for the SIKU ecosystem — delivering clean, responsive player vitals, navigation, voice, radio, and vehicle telemetry through a lightweight, customizable interface built for immersive FiveM roleplay experiences.

![Version](https://img.shields.io/badge/version-1.0.0-4785bd)
![FiveM](https://img.shields.io/badge/fx__version-cerulean-4785bd)
![Lua](https://img.shields.io/badge/Lua-5.4-4785bd)
![Vue](https://img.shields.io/badge/NUI-Vue%203-4785bd)

## Features

- **Aurora Slate interface** — a Vue 3 NUI on the SIKU art direction: dark slate surfaces, snow-white text, cold cyan accents and a restrained cyan → violet gradient reserved for progression and activity.
- **Vitals cluster** — small open-arc gauges (icon centered, percentage in the arc opening, no labels) for health, hunger, thirst, armor, stamina and oxygen, with amber and red thresholds when a value runs low.
- **Contextual visibility** — health, hunger and thirst never move; armor appears only above zero, stamina only while it is being used, oxygen only underwater, each with a fast, precise transition.
- **Navigation bar** — a compact panel above the native GTA minimap: cardinal and heading, current street and zone, in-game time, weather and ambient temperature. The minimap, GPS and routing stay native.
- **Voice and radio cards** — attached to the minimap cluster: microphone with mode and range, radio with channel and label. Talking and transmitting light a subtle animated gradient ring; the radio card disappears when inactive.
- **Vehicle cluster** — a chronograph-style speedometer (large numeric speed, KM/H, gear, RPM ring with redline), a fuel gauge and an engine temperature readout hugging the dial, and a compact states bar (seatbelt, engine, lights) built to accept more states later.
- **Semantic states** — buckled/running in soft success, lights in cold cyan, detached/off in warning; engine temperature stays muted until it is actually elevated or critical.
- **Performance-first protocol** — Lua collectors poll on fixed intervals and forward **only the keys that changed**; nothing is pushed to the NUI per frame.
- **Single state, single bridge** — one normalized HUD contract, one Pinia store, one NUI message listener; components never talk to FiveM directly.
- **External resource API** — hunger, thirst, voice, radio, seatbelt and visibility are all driven through exports, so `siku_status`, a voice resource or a fuel system plug in without touching this codebase.
- **Per-character customization** — `/hud` opens a centered Aurora Slate dashboard with a live preview: color (solid or two-color gradient), proportional size and drag-and-drop position for every component the server allows. Positions are stored as screen fractions, so a layout survives any resolution.
- **Server-first preferences** — the server configuration decides what exists; player preferences are sparse overrides validated server-side (known and enabled components only, clamped scales and positions, normalized colors), cached in memory and written to the database on switch, disconnect, stop and a periodic flush. Disabling a component server-side retires it everywhere, stored preferences included.
- **i18n pipeline** — the server language is pushed to the NUI at runtime (`fr` / `en`).

## Dependencies

| Resource | Required | Purpose |
|---|---|---|
| [`siku_core`](https://github.com/siku-project/siku_core) | Yes | Framework core: SDK, timers, locale, dependency guard. |
| [`siku_status`](https://github.com/siku-project/siku_status) | Yes | Owns hunger and thirst and feeds their values to the HUD. |

`siku_core` and `siku_status` must be started **before** `siku_hud`.

## Installation

### From a release (recommended)

Download the latest [release](https://github.com/siku-project/siku_hud/releases) zip and extract it into your server resources folder. The zip ships with the NUI **already built** (`web/dist` only) — no build step, ready to run.

> The release does not include the NUI source code. If you want to customize the interface, install from source instead.

### From source

The repository contains the full NUI source but **no build** (`web/dist` is not versioned) — you must build it yourself:

```bash
git clone git@github.com:siku-project/siku_hud.git
cd siku_hud/web
bun install
bun run build
```

### server.cfg

```cfg
ensure siku_core
ensure siku_status
ensure siku_hud
```

## Configuration

All options live in `config/` and are documented inline.

| File | Options |
|---|---|
| `config/hud.lua` | `customization` (per-component `enabled` / `color` / default position, scale bounds, default colors, save interval), `keybinds` (`seatbelt`, `engine`), `intervals` (vitals / location / vehicle / voice polling, ms), `staminaLinger`, `underwaterCapacity`, `seatbeltExemptClasses`, `voice` defaults (`mode`, `range`), `weather` (per weather type: interface icon key and displayed temperature) |
| `config/migration.lua` | The `hud_preferences` schema (one JSON row per character), applied through the core migration service |
| `config/translation.lua` | `language` (`fr` / `en`) |

### Commands

| Command | Purpose |
|---|---|
| `/hud` | Opens the customization dashboard: colors, sizes, positions, per-component and full reset. |

### Keybinds

| Key | Action |
|---|---|
| `B` | Buckles or unbuckles the seatbelt — only in a vehicle whose class wears one; a buckled character no longer flies through the windscreen, and the belt comes off on exit. |
| `L` | Starts or stops the engine, from the driver seat. |

Defaults live in `config/hud.lua` (`keybinds`) and every player can rebind them in the GTA keybind settings.

## API

Everything the HUD cannot read from the game itself arrives through client exports. Values are normalized, clamped and forwarded to the interface only when they change.

### Client exports

| Export | Arguments | Purpose |
|---|---|---|
| `SetStatus` | `name` (`'hunger'` / `'thirst'`), `value` (0–100) | Feeds the hunger and thirst gauges. Meant for `siku_status`. |
| `SetVoice` | `{ mode?, range?, active? }` | Updates the voice card. `mode`: `'whisper'` / `'normal'` / `'shout'`, `range` in meters, `active` shows or hides the card. |
| `SetRadio` | `{ active?, channel?, label?, transmitting? }` | Updates the radio card. The card only renders while `active`. |
| `SetSeatbelt` | `buckled` (boolean) | Sets the seatbelt state shown by the vehicle cluster. |
| `ShowHud` / `HideHud` | — | Shows or hides the whole interface **and the native minimap**. A screen taking over the display (character selection, introduction) calls these and gets a clean frame. |
| `IsHudVisible` | — | Whether the HUD is currently shown. |
| `SetVisible` | `visible` (boolean) | Same as `ShowHud` / `HideHud`, driven by a boolean. |

```lua
-- From a status resource
exports.siku_hud:SetStatus('hunger', 63)
exports.siku_hud:SetStatus('thirst', 55)

-- From a voice resource
exports.siku_hud:SetVoice({ mode = 'shout', range = 15 })

-- From a radio resource
exports.siku_hud:SetRadio({ active = true, channel = '32', label = 'LSPO' })
exports.siku_hud:SetRadio({ transmitting = true })

-- From a seatbelt script
exports.siku_hud:SetSeatbelt(true)
```

### What the HUD reads on its own

Health, armor, stamina and oxygen, position, street and zone, in-game clock and weather, and the full vehicle telemetry (speed, RPM, gear, fuel level, engine temperature, engine state, lights) are collected from natives by throttled client modules — no external resource needed.

### Contextual behavior

- The vehicle cluster appears when entering any vehicle and disappears on exit.
- The seatbelt state is not shown for motorcycles, cycles, boats, helicopters and planes (`seatbeltExemptClasses`).
- Hunger and thirst are owned by [`siku_status`](https://github.com/siku-project/siku_status): the HUD only displays what it receives through `SetStatus`.

## Translations

Interface strings live in `translations/fr.lua` and `translations/en.lua` (`web` block) and are pushed to the NUI at startup — a server owner edits one file, never two. The development mock mirrors the same keys and CI enforces parity.

## Development

The NUI lives in `web/` (Vue 3, Pinia, Tailwind, Vite — built with [bun](https://bun.sh)).

```bash
cd web
bun install
bun dev          # browser playground with mocked data and a debug panel
bun run build    # production build → web/dist
bun run check    # format + type-check + lint
```

In development the app boots into the HUD over a game screenshot, with a debug panel driving every value and state. Scenario presets are available through the URL: `?scenario=full|onfoot|sprint|diving|lowvitals|bike`, and `?panel=0` hides the panel. None of it ships in the production build.

```
siku_hud/
├── client/modules/    # push helper, exports, throttled collectors (vitals, location, vehicle, voice), NUI handshake
├── server/            # dependency guard
├── config/            # HUD behavior and language
├── translations/      # fr / en
└── web/               # Vue 3 NUI — types/ (contract), stores/ (state), nui/ (bridge), components/hud/, mock/ (dev only)
```

## Credits

Part of the [SIKU project](https://github.com/siku-project) — © Siku Studio.

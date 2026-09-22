local SCHEMA_VERSION <const> = 1
local UPSERT_QUERY <const> = table.concat({
  'INSERT INTO hud_preferences (character_id, preferences, schema_version)',
  'VALUES (?, ?, ?)',
  'ON DUPLICATE KEY UPDATE preferences = VALUES(preferences), schema_version = VALUES(schema_version)',
}, ' ')

--- Preferences live here first, keyed by character id, and only visit the
--- database on the way in and out: loaded when the character becomes
--- active, written when something is dirty — periodically, on character
--- switch, on disconnect and on resource stop. The entries are owned by
--- this resource rather than grafted onto the core player cache: what
--- crosses the export boundary is a copy, so a field written there would
--- never survive. Who plays which character is the core's knowledge, asked
--- back from its cache.
local states <const> = {}

--- The cached preferences of the character a session is playing.
---@param sessionId any The player server id.
---@return table? state The cache entry, or nil.
function GetHudPrefsState(sessionId)
  local characterId <const> = Siku.cache.getCurrentCharacterId(sessionId)

  if not characterId then
    return nil
  end

  return states[characterId]
end

--- Writes one entry to the database.
---@param state table The cache entry.
---@param await boolean? Whether to block until the write is done.
---@return nil
local function persist(state, await)
  state.dirty = false

  local parameters <const> = { state.characterId, json.encode(state.prefs), SCHEMA_VERSION }

  if await then
    MySQL.update.await(UPSERT_QUERY, parameters)

    return
  end

  MySQL.update(UPSERT_QUERY, parameters, function(affected)
    if not affected then
      Siku.print.error(
        ('Could not save the HUD preferences of character %d'):format(state.characterId)
      )
    end
  end)
end

--- Stores freshly validated preferences for a session, in memory only:
--- the periodic flush and the lifecycle saves take them to the database.
---@param sessionId number The player server id.
---@param prefs table The sanitized sparse overrides.
---@return boolean stored Whether a cache entry accepted them.
function StoreHudPrefs(sessionId, prefs)
  local state <const> = GetHudPrefsState(sessionId)

  if not state then
    return false
  end

  state.prefs = prefs
  state.dirty = true

  return true
end

--- Loads the preferences of a character, registering the cache entry
--- immediately and filling it when the row answers.
---@param sessionId number The player server id.
---@param characterId number The character id.
---@return nil
function LoadHudPrefs(sessionId, characterId)
  local state <const> = {
    characterId = characterId,
    prefs = {},
    dirty = false,
    loading = true,
  }

  states[characterId] = state

  MySQL.single(
    'SELECT preferences FROM hud_preferences WHERE character_id = ?',
    { characterId },
    function(row)
      if states[characterId] ~= state then
        return
      end

      if row then
        local ok <const>, stored <const> = pcall(json.decode, row.preferences)

        if ok and type(stored) == 'table' then
          state.prefs = SanitizeHudPrefs(stored)
        end
      end

      state.loading = false
      PushCustomization(sessionId)
    end
  )
end

--- Forgets a character that left play, writing what changed.
---@param characterId number The character id.
---@return nil
function ForgetHudPrefs(characterId)
  local state <const> = states[characterId]

  if not state then
    return
  end

  states[characterId] = nil

  if state.dirty and not state.loading then
    persist(state)
  end
end

--- Writes every dirty entry to the database.
---@param await boolean? Whether to block until the writes are done.
---@return nil
function FlushHudPrefs(await)
  for _, state in pairs(states) do
    if state.dirty and not state.loading then
      persist(state, await)
    end
  end
end

--- Rebuilds what a restart erased, for the players already in the world.
---@return nil
function RestoreConnectedSessions()
  Siku.cache.forEach(function(sessionId)
    local character <const> = Siku.cache.getCurrentCharacter(sessionId)

    if character and type(character.id) == 'number' then
      LoadHudPrefs(sessionId, character.id)
    end
  end)
end

AddEventHandler('siku:server:createCharacterInstance', function(sessionId, characterData)
  if type(sessionId) ~= 'number' or type(characterData) ~= 'table' then
    return
  end

  if type(characterData.id) ~= 'number' then
    return
  end

  LoadHudPrefs(sessionId, characterData.id)
end)

AddEventHandler('siku:server:releaseCharacterInstance', function(_, characterId)
  if type(characterId) ~= 'number' then
    return
  end

  ForgetHudPrefs(characterId)
end)

AddEventHandler('onResourceStop', function(resource)
  if resource ~= GetCurrentResourceName() then
    return
  end

  FlushHudPrefs(true)
end)

Siku.timers.setInterval(HudConfig.customization.saveInterval, function()
  FlushHudPrefs(false)
end)

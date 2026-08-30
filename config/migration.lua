MigrationConfig = {
  --- Whether this resource migrates its own schema on startup.
  enabled = true,

  --- Whether a schema whose version was already applied is still inspected
  --- for elements that went missing.
  detectMissing = true,

  --- Resources whose schema must be fully applied before this one runs.
  ---
  --- The preferences belong to characters, so the core schema has to exist
  --- first whatever the start order in server.cfg.
  dependencies = { 'siku_core' },

  schema = {
    --- Bump this whenever the tables below change.
    version = '1.0.0',

    tables = {
      --- One row per character. Preferences are a sparse JSON object of
      --- overrides keyed by component: the server configuration stays the
      --- base, so retuning it later never fights what players stored.
      --- schema_version says how that object is shaped.
      {
        name = 'hud_preferences',
        columns = {
          { name = 'character_id', type = 'INT', unsigned = true, primaryKey = true },
          { name = 'preferences', type = 'TEXT', notNull = true },
          { name = 'schema_version', type = 'SMALLINT', unsigned = true, notNull = true, default = 1 },
          {
            name = 'updated_at',
            type = 'TIMESTAMP',
            default = 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP',
          },
        },
        foreignKeys = {
          {
            column = 'character_id',
            references = { table = 'characters', column = 'id' },
            onDelete = 'CASCADE',
            onUpdate = 'CASCADE',
          },
        },
      },
    },
  },
}

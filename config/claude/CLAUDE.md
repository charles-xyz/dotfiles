## SQL

- Before choosing placeholder syntax for a `.sql` file, determine what executes it
  (psql, SQLAlchemy, psycopg, an ORM) and use a style that both the runtime and
  postgres-language-server accept. Ask if it's unclear.
- Default for Python data work: polars `read_database` on a SQLAlchemy connection, with
  `:name` placeholders in the `.sql` file and values passed via
  `execute_options={"parameters": {...}}`.
- Prefer standard tools and documented conventions. Don't write custom editor or tool
  workarounds; check the tool's docs, config and issues first.
- In application code, follow that codebase's existing query layer.

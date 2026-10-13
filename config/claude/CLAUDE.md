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

## Visual documentation default

- When asked for HTML or visual documentation, improve presentation only: use polished, project-appropriate typography, spacing, responsive navigation, and visualizations of existing content where useful. Avoid a generic Markdown-in-a-box or wall of cards; do not copy another company's branding.
- Preserve the source document's wording, tone, structure, facts, and level of detail. Do not rewrite, add, or remove content or introduce illustrative data unless explicitly requested. Use semantic accessible HTML and mobile/print styles, and prefer self-contained HTML/CSS. Keep ordinary repo docs in their canonical format; if HTML accompanies Markdown, leave Markdown as the editable source and link to it.
- Validate structure and links, and review the rendered page when possible; never claim visual parity without seeing it. Do not assume OpenAI uses OpenUI or add OpenUI (or any dependency) without verifying its fit and obtaining required approval. Follow project-specific UI rules.

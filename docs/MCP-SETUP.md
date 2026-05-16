# Подключение MCP-серверов дизайна

В офис встроены 4 MCP-сервера — они дают агенту-дизайнеру доступ к готовым библиотекам UI-компонентов (Magic UI, ReactBits, Aceternity UI, 21st.dev Magic).

## Как включить

1. Скопируй файл-шаблон в рабочий:
   ```
   cp .mcp.json.example .mcp.json
   ```

2. Открой `.mcp.json`. Три сервера (Magic UI, ReactBits, Aceternity UI) уже готовы — ничего делать не нужно, `npx` подтянет их сам при первом запуске.

3. Для `21st-magic` нужен бесплатный API-ключ:
   - зайди на https://21st.dev/magic/console
   - создай ключ
   - вставь его в `.mcp.json` вместо `YOUR_21ST_DEV_API_KEY_HERE` (поле `env.API_KEY`)

   Если ключ не вставить — остальные 3 сервера всё равно работают, не запустится только `21st-magic`.

4. Запускай Claude Code **из этой папки** (`templates/client-office/`) — project-scope `.mcp.json` подхватывается только когда CC открыт в папке, где лежит файл.

5. При первом старте CC спросит подтверждение на project-scope `.mcp.json` — соглашайся.

## Проверка

```
claude mcp list
```

Должны появиться: `magic-ui`, `reactbits`, `aceternity-ui`, `21st-magic`.

## Заметки

- `.mcp.json` — в `.gitignore` (содержит твой личный ключ, не коммитится). В репозитории живёт только `.mcp.json.example`.
- Magic UI и 21st.dev — официальные MCP от авторов библиотек. ReactBits и Aceternity UI — community-обёртки: работают и поддерживаются, но при изменении публичного реестра компонентов могут временно ломаться до апдейта мейнтейнера.

# Установка — чеклист

## Требования

- [ ] Claude Code установлен (`claude` работает в терминале)
- [ ] Git установлен
- [ ] Аккаунт Anthropic с API-ключом — https://console.anthropic.com
- [ ] Аккаунт Notion — https://notion.so

## 1. Создай Notion-страницу проекта

Зайди в Notion → создай новую страницу "Мой проект" (или как угодно). Скопируй URL страницы — понадобится в следующем шаге.

## 2. Заполни .env

```bash
cp .env.example .env
```

Открой `.env` и заполни:

```
ANTHROPIC_API_KEY=sk-ant-...
NOTION_PROFILE_URL=https://notion.so/...
GITHUB_USERNAME=твой-логин
CLIENT_NAME=Как тебя зовут
CLIENT_NICHE=Твоя ниша / сфера работы
```

`.env` не попадёт в git — он добавлен в `.gitignore`.

## 3. Подключи свой GitHub-репозиторий

Создай пустой репозиторий на GitHub (без README). Потом:

```bash
git remote set-url origin https://github.com/{{GITHUB_USERNAME}}/название-репо.git
git push -u origin main
```

## 4. Запусти онбординг

Открой Claude Code в папке проекта и напиши:

```
/setup
```

Агент пройдётся по вопросам, заменит плейсхолдеры в файлах и подготовит офис к работе.

## Готово

После `/setup` офис настроен. Начинай с `QUICK-START.md`.

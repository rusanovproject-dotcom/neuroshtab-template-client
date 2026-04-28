# Setup Алекса v2.0 — пошагово

> Standalone-гайд для тебя как владельца офиса. Алекс v2.0 — Internet-First пайплайн распаковки ЦА. Чтобы он работал на полной мощности, нужны 3 API-ключа и 2 MCP-сервера. Setup — **~25 минут**, стоимость **$0/мес** на Free tier.
>
> Все шаги обязательны для Level 2 (production-ready). Опциональные расширения — в конце документа, на потом.

---

## TL;DR — что делаем

| # | Что | Время | Получишь |
|---|-----|-------|----------|
| 1 | YouTube Data API v3 ключ | 5 мин | Поиск видео + статистика + комменты |
| 2 | SerpAPI ключ | 2 мин | Google PAA + Suggest + Trends |
| 3 | Telegram API_ID + API_HASH + session_string | 15-20 мин | Комменты Telegram-каналов |
| 4 | MCP youtube-transcript | 30 сек | Транскрипты длинных видео |
| 5 | MCP telegram (chigwell) | 5 мин | Полный доступ к Telegram через Pyrogram |

**Куда складываем ключи:** `~/.env` (один файл, оттуда читают все скиллы).

---

## Шаг 1 — YouTube Data API v3 (5 мин)

1. Зайди на https://console.cloud.google.com → залогинься гугл-аккаунтом
2. **Create new project** (если нет): кнопка вверху, имя `ai-office-alex` или любое
3. **APIs & Services → Library** → найди **«YouTube Data API v3»** → **Enable**
4. **APIs & Services → Credentials** → **Create credentials → API Key**
5. Скопируй ключ (формат `AIzaSy...`)

**Проверка работы:**
```bash
curl "https://www.googleapis.com/youtube/v3/search?part=snippet&q=test&key=ВСТАВЬ_КЛЮЧ" | head -20
```
Должен вернуть JSON со списком видео.

**Сохрани в `~/.env`:**
```bash
echo "YOUTUBE_API_KEY=AIzaSy..." >> ~/.env
```

---

## Шаг 2 — SerpAPI (2 мин)

1. Зайди на https://serpapi.com → **Sign Up** (можно через Google)
2. После логина → **Dashboard** → найди **API Key** (видно сразу)
3. Скопируй ключ

**Free tier — 100 запросов/мес.** Этого **не хватит** на распаковку 3 сегментов (~150 запросов на полный прогон). Варианты:
- **Сейчас:** возьми Free, Алекс будет аккуратно тратить — Trends только для hot-сегмента
- **Позже:** при 5+ клиентах в работе апгрейдни до **$50/мес Developer (5K запросов)**

**Проверка:**
```bash
curl "https://serpapi.com/search?engine=google&q=test&api_key=ВСТАВЬ_КЛЮЧ" | head -20
```

**Сохрани:**
```bash
echo "SERPAPI_KEY=..." >> ~/.env
```

---

## Шаг 3 — Telegram API + session_string (15-20 мин)

⚠️ **Самая токсичная точка setup.** Дольше остальных, но без неё Алекс не дотянется до комментов Telegram-каналов — а это 30-40% жира на русскоязычном рынке.

### 3.1 Получить API_ID и API_HASH

1. Зайди на https://my.telegram.org/auth → введи **номер телефона** (тот же что в Telegram)
2. Получи код в Telegram → введи
3. Перейди в **API development tools**
4. **Create new application:**
   - App title: `Alex Audience Research`
   - Short name: `alex-audience`
   - Platform: Desktop
   - Description: `Audience research tool for AI Office`
5. После создания — увидишь **api_id** (число типа `12345678`) и **api_hash** (32-символьная строка)

```bash
echo "TELEGRAM_API_ID=12345678" >> ~/.env
echo "TELEGRAM_API_HASH=abc123def456..." >> ~/.env
```

### 3.2 Сгенерировать session_string

Pyrogram требует **session_string** — одноразовая авторизация, дальше Алекс ходит без интерактива.

```bash
# Установи Pyrogram (если не стоит)
pip install pyrogram tgcrypto

# Сохрани скрипт во временный файл
cat > /tmp/gen_session.py << 'EOF'
from pyrogram import Client
import os

api_id = int(os.environ["TELEGRAM_API_ID"])
api_hash = os.environ["TELEGRAM_API_HASH"]

with Client("temp", api_id=api_id, api_hash=api_hash, in_memory=True) as app:
    print("\n\n=== SESSION_STRING (скопируй эту строку):")
    print(app.export_session_string())
EOF

# Запусти (введёт код из Telegram + 2FA если есть)
source ~/.env && python3 /tmp/gen_session.py
```

После phone code и 2FA — увидишь длинную base64-строку. **Скопируй её целиком.**

```bash
echo "TELEGRAM_SESSION_STRING=AwQ..." >> ~/.env
```

**Очисти временный файл:**
```bash
rm /tmp/gen_session.py
```

⚠️ **Безопасность:** session_string эквивалентен паролю. Не коммить `.env`. Никогда не передавай session_string третьим лицам — это полный доступ к твоему Telegram.

---

## Шаг 4 — MCP youtube-transcript (30 сек)

Транскрипты длинных видео без YouTube Data API quota.

```bash
claude mcp add --scope user youtube-transcript npx mcp-server-youtube-transcript
```

**Проверка:**
```bash
claude mcp list | grep youtube
```

Должна быть строка с `youtube-transcript` — connected.

---

## Шаг 5 — MCP telegram (chigwell/telegram-mcp) (5 мин)

Полный доступ к Telegram через Pyrogram (читать каналы, комменты, сообщения).

```bash
# Клонируем репозиторий
cd ~/workspace
git clone https://github.com/chigwell/telegram-mcp ~/.claude/mcp-servers/telegram-mcp

# Устанавливаем зависимости
cd ~/.claude/mcp-servers/telegram-mcp
pip install -r requirements.txt

# Регистрируем MCP в Claude Code
claude mcp add --scope user telegram-mcp \
  --env TELEGRAM_API_ID=$TELEGRAM_API_ID \
  --env TELEGRAM_API_HASH=$TELEGRAM_API_HASH \
  --env TELEGRAM_SESSION_STRING=$TELEGRAM_SESSION_STRING \
  python ~/.claude/mcp-servers/telegram-mcp/server.py
```

**Проверка:**
```bash
claude mcp list | grep telegram
```

Должна быть строка с `telegram-mcp` — connected.

⚠️ Если ошибка `connection failed` — проверь что session_string не истёк (раз в полгода Pyrogram может потребовать пере-авторизацию).

---

## Финальная проверка — всё ли в порядке

В новой сессии Claude Code:

```bash
# 1. Проверь .env
cat ~/.env | grep -E "(YOUTUBE|SERPAPI|TELEGRAM)" | wc -l
# Должно быть >= 5 строк

# 2. Проверь MCP
claude mcp list
# Должны быть youtube-transcript и telegram-mcp в списке connected

# 3. Запусти Алекса с тестом
# В Claude Code: «Алекс, протестируй setup — пройдись по всем источникам»
```

Алекс автоматически сделает env-grep + MCP-проверку и выдаст вердикт одной фразой:

> *«✅ YouTube — на полной мощности.
> ✅ SerpAPI — есть, лимит 100/мес — хватит на 1 сегмент целиком.
> ✅ Telegram — на полной мощности.
> ✅ MCP — оба коннекшна live.
> На 100% мощности, можем стартовать `/audience-stage`.»*

Если что-то ❌ — Алекс сам предложит починить через AskUserQuestion (один env-grep → один вердикт → одна развилка).

---

## Опциональные расширения (Level 3 — потом)

Не нужны для запуска. Подключай когда вырастешь до 5+ клиентов параллельно или захочешь более глубокий мининг.

| # | Что | Когда нужно | Где |
|---|-----|-------------|-----|
| 0.5 | **Bukvarix** регистрация (free key) | Семантическое ядро RU без Wordstat OAuth | https://www.bukvarix.com → Sign Up → API Key |
| 6 | **Yandex Wordstat OAuth** | Production-grade частотности RU. Approval 3+ дня. | https://yandex.ru/dev/wordstat/ |
| 7 | **TGStat API** | Скрининг тысяч TG-каналов по нишам | https://tgstat.ru/api |
| 8 | **Reddit API (PRAW)** | EN-инсайты на агентском масштабе | https://www.reddit.com/prefs/apps |
| 9 | **Python deps на хосте** | `pip install youtube-comment-downloader yt-dlp pytrends praw` | Глубокий мининг без MCP |

⚠️ **Bukvarix critical note:** публичный `&key=free` устарел в 2024. Нужна регистрация и **личный** free-ключ.

---

## FAQ — частые вопросы

**Q: Можно работать без Telegram?**
A: Да, но качество распаковки RU/CIS аудитории падает на 30-40%. Telegram-комменты — самый богатый источник дословной речи русскоязычной ЦА.

**Q: Что будет если Free лимит SerpAPI закончится в середине прогона?**
A: Алекс детектит это и переключается на Level 1 fallback (только WebSearch + WebFetch) — качество 5-6 из 10 вместо 8-9, но прогон не падает. После апгрейда SerpAPI — перезапустишь Phase B и докрутишь.

**Q: session_string истёк, что делать?**
A: Пере-генерируй (Шаг 3.2 выше) — обычно занимает 2 мин. Алекс при `connection failed` сам предложит это.

**Q: Можно ли коммитить `.env` в git?**
A: **Никогда.** Добавь в `.gitignore` если ещё нет:
```bash
echo ".env" >> ~/.gitignore
```

**Q: Где смотреть логи Алекса при работе?**
A: Все артефакты прогона лежат в `projects/<main>-audience/_state/` (детальный progress) + `intel/competitors-{slug}/` (что субагенты нашли). При проблеме — сначала туда.

---

## После setup

Закрой эту инструкцию, открой проект клиента в Claude Code, скажи Алексу:

> «Распакуй ЦА» / «Найди сегменты» / «Поехали»

Он запустит `/audience-stage` и проведёт через 4 фазы (Quick Capture → Internet Research → Validation → Awareness-lite). Время клиента в чате — 2-3 часа активной работы. Алекс работает в фоне 30-90 минут на сегмент.

Артефакт на выходе — `voice-of-segment.md` уровня VoC «Эксперт в потолке» + `segment-portrait.md` с цветовой схемой + `audience-report.html` для ментора.

**Всё. Пробуй.**

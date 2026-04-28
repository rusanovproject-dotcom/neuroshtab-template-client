# Phase B Internet Research — технический спек реализации

> Создано: 2026-04-28
> Источник: 3 research-субагента (YouTube + Telegram + Search/Forums)
> Назначение: переписать `/audience-internet-research` SKILL.md на реальные технологии вместо технических мифов
> Использовать: завтра при докрутке Skill 2 по P0

---

## TL;DR — что реально работает

| Источник | Главное решение | Альтернатива | Стоимость |
|----------|-----------------|--------------|-----------|
| **YouTube** | YouTube Data API v3 + `youtube-transcript-api` + `youtube-comment-downloader` | MCP `kimtaeyoon83/mcp-server-youtube-transcript` | $0 (10K units/день) |
| **Telegram (поиск каналов)** | TGStat API + Telega.io каталог + Google dork `site:t.me/s/` | Каталоги: tlgrm.ru, telegroom.ru | $0 free tier |
| **Telegram (комменты)** | Pyrogram `get_discussion_message()` через MTProto | MCP `chigwell/telegram-mcp` | $0 (но риск FLOOD_WAIT) |
| **Wordstat альтернативы** | Bukvarix free API + Yandex Wordstat OAuth | MCP `Yandex Wordstat MCP` | $0 |
| **Google PAA** | SerpAPI (100 free/мес) | DataForSEO ($0.0006/запрос) | $0-50/мес |
| **Forums** | vc.ru API (unofficial) + Habr API + Pikabu + DTF + WebSearch | MCP `Reddit MCP` (для EN) | $0 |

**Итого стартовый стек: $0/мес, потолок при росте: $50-100/мес для 5-10 клиентов.**

---

## YouTube research — полный спек

### Готовые MCP-серверы (Claude Code)

```bash
# Самый зрелый для транскриптов (npm)
claude mcp add --scope user youtube-transcript \
  npx mcp-server-youtube-transcript

# Альтернативы:
# - hancengiz/youtube-transcript-mcp
# - jkawamoto/mcp-youtube-transcript
# - ergut/youtube-transcript-mcp (remote, без install)
```

⚠️ Все готовые MCP делают **только транскрипты**. Под комменты + search MCP **не существует** — нужны Python библиотеки или прямой Data API call.

### Open-source библиотеки

```bash
# Без API ключа
pip install yt-dlp                          # 159k звёзд — метаданные + субтитры
pip install youtube-transcript-api          # 3.7k — транскрипты, форматы JSON/SRT/VTT
pip install youtube-comment-downloader      # 1.2k — комменты без API
pip install pytube                          # 12k — статистика
```

### YouTube Data API v3 — главный production путь

**Получение ключа (5 минут):**
1. https://console.cloud.google.com → New Project
2. Enable «YouTube Data API v3»
3. Credentials → Create API Key
4. Сохранить в `.env` как `YOUTUBE_API_KEY`

**Лимиты (бесплатно):**
- 10 000 units/день
- `search.list` — 100 units (≈100 поисков/день)
- `videos.list` — 1 unit
- `commentThreads.list` — 1 unit (можно 10K вызовов в день)

**Боевые curl-команды:**

```bash
# 1. Поиск 25 топовых видео по нише
curl "https://www.googleapis.com/youtube/v3/search?\
part=snippet&q=КЛЮЧ&type=video&maxResults=25&\
order=viewCount&key=$YOUTUBE_API_KEY"

# 2. Статистика по ID (engagement rate расчёт)
curl "https://www.googleapis.com/youtube/v3/videos?\
part=statistics,snippet&id=ID1,ID2,ID3&key=$YOUTUBE_API_KEY"

# 3. Топ-100 комментов под залётным видео
curl "https://www.googleapis.com/youtube/v3/commentThreads?\
part=snippet&videoId=ID&maxResults=100&\
order=relevance&key=$YOUTUBE_API_KEY"
```

⭐ **Маркетинговый фильтр:**
- order=relevance (не time) — топ согласного большинства
- Engagement rate = (likes + comments) / views × 100. Норма 4-5%, >7-9% — высокий, тема цепляет
- Залёт = views/days_since_published. >100K за 7 дней в нише где обычно 5-10K — сигнал боли
- AI-фильтр комментов: одинаковая длина 80-150, нет цифр/имён, общие фразы. Реальный VoC = специфика, мат, эмоции

### Python снипеты для глубокой разведки

```python
# Транскрипт без ключа
from youtube_transcript_api import YouTubeTranscriptApi
t = YouTubeTranscriptApi.get_transcript('VIDEO_ID', languages=['ru', 'en'])
text = " ".join([s['text'] for s in t])

# Топ-комменты без API ключа (но медленнее)
from youtube_comment_downloader import YoutubeCommentDownloader, SORT_BY_POPULAR
d = YoutubeCommentDownloader()
for c in d.get_comments_from_url(URL, sort_by=SORT_BY_POPULAR):
    if len(c['text']) > 50 and not is_ai_spam(c['text']):
        # сохрани в voice-of-customer.md
        ...
```

### 3 уровня глубины

- **Level 1 (без ключей):** WebSearch + WebFetch → только заголовки + view counts. Качество 3/10.
- **Level 2 (Data API v3):** + комменты + статистика + поиск. Качество 7/10. **Sweet spot.**
- **Level 3 (Python + transcripts):** + транскрипты длинных видео = голос авторов в нише. Качество 10/10.

**Production: Level 2 как база, Level 3 опционально для глубокой ниши.**

---

## Telegram research — полный спек

### Поиск каналов по нишам — 7 практических способов

1. **TGStat API** (`api.tgstat.ru`) — `searchChannels({query, category, country, language})`. **Главный для RU/CIS.** Категории, ERR, динамика подписчиков, similar channels.
2. **Telega.io каталог** (telega.io/catalog) — фильтр по нише + цена за пост = индикатор «жирности» аудитории.
3. **Google dork `site:t.me/s/ "ниша"`** — индексируются веб-превью каналов.
4. **Каталоги:** tlgrm.ru/channels, telegroom.ru, tgrow.ru, telegrator.ru — лучше для мелких ниш чем TGStat.
5. **In-Telegram боты:** `@SearcheeBot`, `@argosearchbot` — глобальный поиск по ключам.
6. **Reverse через конкурентов** — TGStat «similar channels» + «mentions» от известного игрока в нише.
7. **WebSearch `"лучшие телеграм каналы про X" site:vc.ru OR site:habr.com`**.

### Получение комментов под TG-постами

⚠️ **WebFetch `t.me/s/{channel}` даёт ТОЛЬКО посты + агрегаты реакций. Комменты НЕ доступны.** Проверено.

**Единственный путь — через MTProto SDK:**

```python
# Pyrogram (рекомендован — есть готовый метод)
from pyrogram import Client

async with Client("session", api_id, api_hash) as app:
    # Посты канала
    async for msg in app.get_chat_history("channel_name", limit=100):
        ...
    # ✅ Прямой метод для комментов (Telethon такого нет)
    discussion = await app.get_discussion_message("channel_name", post_id)
    async for reply in discussion.get_replies():
        print(reply.text)
```

**Получение API_ID/API_HASH:**
1. https://my.telegram.org/apps
2. Войти на телефон (1 заявка на номер)
3. Создать application → API_ID + API_HASH

**Лимиты:** ~30 запросов/мин, ≤1 msg/sec. При превышении — `FLOOD_WAIT_X` (ждать N секунд).

⚠️ **Серая зона ToS:** парсинг через MTProto = риск бана. **Использовать ОТДЕЛЬНЫЙ аккаунт на тестовом SIM**, не основной личный.

### Готовые MCP-серверы (на Telethon под капотом)

```bash
# Самый зрелый — full-featured
git clone https://github.com/chigwell/telegram-mcp
# Установка локальная, ключи в env

# Альтернативы:
# - dryeab/mcp-telegram (search, drafts, media)
# - antongsm/mcp-telegram (3 интерфейса MCP/CLI/HTTP)
# - l1v0n1/telegram-mcp-server (для Claude Desktop)
# - Muhammad18557/telegram-mcp (с SQLite кэшем)
```

### TGStat — каталог каналов

| Что даёт | Доступ |
|----------|--------|
| Каталог 5000+ каналов по 30+ категориям | API через https://api.tgstat.ru |
| Метрики: ERR, охват, динамика подписчиков | OAuth Bearer |
| Топ постов по реакциям/комментам/форвардам (агрегаты, не тексты комментов) | Запросы Search API |
| Similar channels от известного канала | Метод |
| Mentions конкретного канала по сети | Метод |

⚠️ Точные тарифы — на `tgstat.ru/p/prices` (UI блокирует ботов). Базовый поиск через UI каталога — бесплатно.

### 3 уровня глубины

- **Level 1 (WebSearch + t.me/s/):** только посты публичных каналов + агрегаты реакций. Поиск каналов через каталоги. Комменты — недоступно.
- **Level 2 (TGStat API):** + структурированный каталог по нишам + ERR + similar. Тексты комментов — недоступно через TGStat.
- **Level 3 (Pyrogram + API_ID):** полный доступ — посты + ВСЕ комменты через discussion group + участники групп.

**Production: Level 1 для скрининга → Level 2 для метрик → Level 3 для VoC из комментов.**

---

## Search/Wordstat/Forum — полный спек

### Wordstat альтернативы (RU)

| Сервис | Free | API | Подходит |
|--------|------|-----|----------|
| **Bukvarix** ([bukvarix.com/api.html](https://www.bukvarix.com/api.html)) | да, ключ `"free"` | до 100 строк/запрос, CSV первые 1000, формат `?format=csv` | **главный free-инструмент**, без регистрации |
| **Yandex Wordstat API** | бесплатно после OAuth approval | `/v1/topRequests` (топ за 30 дней + похожие) | production-уровень частотностей |
| **MegaIndex** | да, 37 функций | — | разовые проверки |
| **Mutagen.ru** | 10 запросов/день | — | конкурентность фразы |
| **Google Trends + pytrends** | бесплатно | unofficial Python wrapper, geo='RU' | сезонность RU |

### Google Suggest и PAA

**Google Suggest** — работает в 2026 через WebFetch:
```bash
curl "http://suggestqueries.google.com/complete/search?\
client=firefox&hl=ru&q={QUERY}"
```
Без CAPTCHA, бесплатно, JSON массив подсказок.

**Google PAA** — JavaScript-rendered, **WebFetch не возьмёт**. Пути:
1. **SerpAPI** (`engine=google`) — `related_questions` в JSON. **100 бесплатных/мес**, $50/мес = 5K.
2. **DataForSEO Standard Queue** — $0.0006/запрос. Минимум $50 депозит + $1 trial.
3. **ScrapingBee** — $1-5/1K SERP с JS-рендером.

### Forum research — какие живые в 2026

| Площадка | Состояние | Доступ |
|----------|-----------|--------|
| **vc.ru** | живой, B2B/SMB | unofficial API ([github.com/Alexander-Pervushin/vcru-api](https://github.com/Alexander-Pervushin)), методы comments/content. WebSearch `site:vc.ru "{боль}"` |
| **Habr.com** | живой, IT | официальный API (`habralab/habrahabr_api`), OAuth, `getCommentsForPost($post_id)` |
| **Pikabu.ru** | живой, бытовые | unofficial (`Blackwave-rt/pikabu`) — комменты с ID/рейтингом |
| **DTF.ru** | живой, гейминг/IT | `LightVolk/Dtf-Client-API` |
| **Дзен (dzen.ru)** | живой, массовый | парсинг через WebFetch |
| **Spark.ru** | живой, B2B стартапы | парсинг через WebFetch |

**Мёртвые / не использовать:** LiveJournal, mybusiness.ru, profilelab.ru, r/Russia (quarantined).

**EN (Reddit):**
- r/Entrepreneur (4M+), r/smallbusiness (2M+), r/marketing — активные
- Reddit API через PRAW — 100 req/min с OAuth, бесплатно для non-commercial

### MCP-серверы для Claude Code

```bash
# Главные для стека Алекса
claude mcp add --scope user serpapi-mcp           # github.com/serpapi/serpapi-mcp
claude mcp add --scope user yandex-wordstat-mcp   # glama.ai/mcp/servers/@altrnex
claude mcp add --scope user reddit-mcp            # composio.dev/toolkits/reddit
claude mcp add --scope user bukvarix-mcp          # LobeHub
```

### 3 уровня глубины

- **Level 1 (без ключей):** Bukvarix free + Google Suggest + WebSearch site:vc.ru/habr/pikabu + pytrends. Покрытие 60-70%, $0/мес.
- **Level 2 (SerpAPI 100 free/мес):** + Google PAA + related queries. **Рекомендуемый baseline.** $0-50/мес.
- **Level 3 (DataForSEO + Wordstat OAuth):** полный keyword research RU + конкурентные слова через домены. $50-100/мес для 5-10 клиентов.

---

## Финальный production стек для Алекса

```yaml
# .env
YOUTUBE_API_KEY: "..."          # 5 мин получить, бесплатно 10K units/день
SERPAPI_KEY: "..."              # 100 free/мес → $50/мес 5K
TELEGRAM_API_ID: "..."          # 1 заявка my.telegram.org
TELEGRAM_API_HASH: "..."
YANDEX_WORDSTAT_TOKEN: "..."    # OAuth approval Yandex (опционально)

# MCP servers (claude mcp add)
- youtube-transcript      # kimtaeyoon83 (npm)
- telegram-mcp           # chigwell (Pyrogram)
- serpapi-mcp            # serpapi/serpapi-mcp
- yandex-wordstat-mcp    # altrnex (опционально)
- reddit-mcp             # composio (для EN ниш)

# Python deps (для Level 3)
pip install youtube-transcript-api youtube-comment-downloader yt-dlp pyrogram pytrends praw

# Стоимость в месяц на 1 клиента: $0
# Стоимость на 5-10 клиентов: $50-100/мес (только SerpAPI)
```

---

## Что меняется в `/audience-internet-research` SKILL.md (правки P0)

### Субагент 1 (YouTube) — переписать целиком

❌ Убрать: «WebFetch секцию comments» (миф)
✅ Заменить на: 3-уровневый workflow (без ключа → Data API v3 → Python). Жёстко прописать что Level 2 минимум для production. Получение ключа за 5 мин.

### Субагент 2 (Forums) — расширить

❌ Убрать: «Telegram комменты через t.me/s/» (миф)
✅ Заменить на: Telegram = посты публичных каналов через t.me/s/, для комментов — через Pyrogram MCP (отдельный путь).
✅ Добавить: vc.ru API + Habr API + Pikabu API + DTF API + Дзен parsing + Spark.ru parsing.
✅ Расширить EN-площадки: Reddit через PRAW + конкретные сабреддиты.

### Субагент 3 (Search Queries) — переписать

❌ Убрать: «Wordstat через WebFetch» (CAPTCHA)
✅ Заменить на: **Bukvarix free API** (главный) + **Google Suggest через `suggestqueries.google.com`** (без ключа) + **SerpAPI для PAA** (100 free/мес).
✅ Опционально: Yandex Wordstat OAuth + DataForSEO для production.

### Новый Субагент 4a (Telegram Channel Discovery) — добавить отдельно

✅ Новый субагент специально для **поиска TG-каналов конкурентов в нише**:
- TGStat caller (через MCP или прямой API)
- Telega.io каталог через WebFetch
- Google dork + каталоги (tlgrm.ru, telegroom.ru)
- Output: `intel/{slug}/telegram-channels-map.md` — 20-30 каналов с подписчиками + ERR + ценник рекламы

### Match-методика — двойной критерий VALIDATED

❌ Старый: только `unique_sources ≥ 3 AND evidence ≥ 5`
✅ Новый: `(unique_sources ≥ 3 AND evidence ≥ 5) OR (unique_sources ≥ 2 AND evidence_weight ≥ 50)` где weight = sum(likes × source_quality_multiplier). Multiplier: vc.ru = 3, YouTube = 1, Reddit = 2, Wordstat = 5, Telegram = 4.
✅ Новая категория **🌟 GOLD** — цитата с >200 лайков на vc.ru / >500 на YouTube / >50 на Reddit, даже single source. Идёт в hero-блок.

---

## Acceptance criteria (обновлённые) реалистичные

| Метрика | Старый план | Реальный (после research) |
|---------|-------------|---------------------------|
| Время на сегмент | 30-60 мин | **60-90 мин** |
| Цитаты болей VALIDATED | 30+ | **20-25 в первом проходе** |
| YouTube комменты | 50+ | **50-100 (с Data API v3 + youtube-comment-downloader)** |
| Search queries | 30 с частотой | **20-30 (Bukvarix + Suggest)** |
| Telegram каналы | — | **20-30 (TGStat + Telega.io + dork)** |
| Forums цитаты | 30+ | **30-50 (vc.ru + Habr + Pikabu + DTF + Reddit)** |
| Конкуренты | 8-12 | **8-12 (с реальной проверкой через SimilarWeb)** |

---

## Sources (прямые ссылки)

### YouTube
- [YouTube Data API v3 docs](https://developers.google.com/youtube/v3/getting-started)
- [yt-dlp (159k stars)](https://github.com/yt-dlp/yt-dlp)
- [youtube-transcript-api (3.7k)](https://github.com/jdepoix/youtube-transcript-api)
- [youtube-comment-downloader (1.2k)](https://github.com/egbertbouman/youtube-comment-downloader)
- [kimtaeyoon83/mcp-server-youtube-transcript](https://github.com/kimtaeyoon83/mcp-server-youtube-transcript)

### Telegram
- [TGStat API docs](https://api.tgstat.ru/docs/ru/start/intro.html)
- [Pyrogram get_discussion_message](https://docs.pyrogram.org/api/methods/get_discussion_message)
- [chigwell/telegram-mcp](https://github.com/chigwell/telegram-mcp)
- [Telethon docs — chats and channels](https://docs.telethon.dev/en/stable/examples/chats-and-channels.html)
- [Telega.io catalog](https://telega.io/catalog)

### Search/Forums
- [Bukvarix API documentation](https://www.bukvarix.com/api.html)
- [Yandex Wordstat MCP](https://glama.ai/mcp/servers/@altrnex/yandex-wordstat-mcp)
- [SerpAPI Pricing](https://serpapi.com/pricing)
- [SerpAPI MCP server](https://github.com/serpapi/serpapi-mcp)
- [vc.ru API (Pervushin)](https://blog.fossko.ru/all/api-ot-platformy-vc-ru/)
- [Habr API client](https://github.com/habralab/habrahabr_api)
- [Pikabu Python client](https://github.com/Blackwave-rt/pikabu)
- [pytrends](https://github.com/GeneralMills/pytrends)

---

🚀 **Этот спек = готовый input для переписывания `/audience-internet-research` SKILL.md.** Завтра свежей головой → 1.5-2 часа на интеграцию правок в скилл.

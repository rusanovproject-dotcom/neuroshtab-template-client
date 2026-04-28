---
name: audience-internet-research
description: |
  Phase B пайплайна Stage 1 — глубокая разведка интернета по 1-3 целевым сегментам
  через 5 параллельных Task tool calls в одном assistant turn. Алекс уходит на 30-90
  минут в фоновую работу (клиент свободен), на выходе — жирный `voice-of-segment.md`
  × N с 30-50 цитатами болей дословно с источниками + 15-25 уникальных смысловых
  кластеров после семантической дедупликации (как VoC «Эксперт в потолке»).

  ПРИНЦИП: 80% портрета должны быть VALIDATED цитаты с интернета (3+ источника + 
  evidence_weight ≥50 OR 2+ источника при single GOLD-VIP). 20% — контекст клиента 
  из Phase A. ВСЁ ДОСЛОВНО, без перефразировки. Match-методика с двойным критерием.

  ПАРАЛЛЕЛИЗМ: 5 Task tool calls в одном turn (НЕ run_in_background — этого
  параметра у Task нет). Главный Алекс ждёт все 5 returns. UX impact: клиент видит
  «Алекс молчит 10-15 мин, потом выдаёт всё разом». Mitigation: разбить на 2 turn'а
  (1: YouTube + Forums, 2: Telegram + Search + Конкуренты, 3: БПСВ-синтез).

  КОГДА:
  - После Phase A (`/audience-quick-capture`), есть 1-3 гипотезы в hypotheses.md
  - Запуск из `/audience-stage` мета-оркестратора
  - Ручной запуск для повторной разведки (через 30+ дней)

  НЕ ИСПОЛЬЗОВАТЬ:
  - Если Phase A не закрыта (нет hypotheses.md с валидированными гипотезами)
  - Для одного добавочного факта — это `/revise-segment`

triggers:
  - audience internet research
  - интернет-разведка
  - phase b
  - копай интернет по сегментам
  - собери жирный VoC
---
---

🎙 **ГОЛОС:** прочитай `knowledge/voice.md` ПЕРЕД любой репликой клиенту. Слова «Шаг», «Pre-flight», «AskUserQuestion», «Phase», «Stage Lock», «гейт», «trigger», «mode» — **внутренняя структура для тебя**, в речи клиенту **НЕ произносить**. Стиль = живой партнёр-маркетолог с насмотренностью, не методолог из учебника. Если хоть в одной реплике появилось «Шаг 1 / Phase A / Pre-flight / 4 вопроса по одному» — это робот. Перепиши.


# `/audience-internet-research` — Phase B пайплайна (real tech)

📍 **Где это в пайплайне:** Phase B из 4 (Quick Capture → **Internet Research** → Validation → Awareness-lite).

> **Цель:** для каждой гипотезы сегмента из `hypotheses.md` собрать **жирный VoC с реального интернета** через 5 субагентов с реальной технологией (НЕ мифические WebFetch comments). На выходе — `voice-of-segment.md` × N сегментов готовый для валидации клиентом в Phase C.

> **Маркетинговая логика:** реальный голос ЦА живёт **в интернете**, не в голове клиента. Клиент дал контекст в Phase A — теперь Алекс **сам идёт за данными** через **Real APIs** (YouTube Data API + Pyrogram + SerpAPI + Bukvarix + WebSearch/WebFetch с реальными площадками).

---

## 1. Pre-flight checks (адаптивный по уровню окружения)

### 1.1 Env-grep — что есть в окружении

```bash
# Молча (без вопросов клиенту):
[ -n "$YOUTUBE_API_KEY" ] && lvl_yt=2 || lvl_yt=1
[ -n "$SERPAPI_KEY" ] && lvl_search=2 || lvl_search=1
[ -n "$TELEGRAM_API_ID" ] && lvl_tg=2 || lvl_tg=1
[ -n "$BUKVARIX_KEY" ] && have_bukvarix=1 || have_bukvarix=0
claude mcp list | grep -q youtube-transcript && have_yt_mcp=1 || have_yt_mcp=0
claude mcp list | grep -q telegram && have_tg_mcp=1 || have_tg_mcp=0

# Сводка для клиента ОДНОЙ фразой:
echo "✅ YouTube: на $(([ $lvl_yt -eq 2 ] && echo "100%" || echo "30%")) мощности"
echo "✅ Search: на $(([ $lvl_search -eq 2 ] && echo "90%" || echo "60%")) мощности"
echo "$([ $lvl_tg -eq 2 ] && echo "✅" || echo "❌") Telegram: $(([ $lvl_tg -eq 2 ] && echo "комменты доступны" || echo "только публичные посты"))"
```

### 1.2 ОДНА развилка через AskUserQuestion (НЕ мультиселект 7 опций)

```yaml
question: |
  📍 Phase B Internet Research. Сейчас сам проверил что у тебя есть:
  
  ✅ YouTube — на полной мощности (Data API + транскрипты)
  ⚠️ SerpAPI — нет ключа (без него Google PAA недоступен)
  ❌ Telegram — нет настройки (комменты TG-каналов недоступны)
  
  Без этих двух работаю на 60% от максимума. Что делаем?
multiSelect: false
options:
  - id: full_setup
    label: "🛠 Апгрейд (25 мин) — пошаговые инструкции"
  - id: partial_setup
    label: "🔧 Только SerpAPI (2 мин) — самое быстрое"
  - id: go_as_is
    label: "⏭ Поехали как есть"
  - id: explain
    label: "❓ Объясни что я теряю"
```

**Если `full_setup` или `partial_setup`** — Алекс выдаёт пошаговую инструкцию (одна за раз) + ждёт «готово» через follow-up + **сам пишет в `.env` через Write tool** когда клиент присылает ключ.

### 1.3 Wayfinding (после setup-развилки)

> *«📍 Phase B запущена для {N} сегментов. Я ухожу в интернет на 30-90 мин.*
>
> *Что делаю в фоне: 5 субагентов копают параллельно — YouTube + форумы + поисковые запросы + Telegram-каналы + конкуренты.*
>
> *Ты в это время свободен. Покажу прогресс через 2 промежуточных update'а.*
>
> *Поехали с {hot-slug} (это hot-сегмент)?»*

**Stop+wait.** Запускаем после явного «да».

---

## 2. Архитектура — 5 субагентов в 3 turn'ах (для промежуточного прогресса)

⚠️ **`run_in_background: true` для Task tool НЕ существует** (только для Bash). Параллелизм Task — это **5 calls в одном assistant turn**, главный Алекс ждёт все 5 returns.

**Mitigation для UX (промежуточный прогресс):**

```
Turn 1: Запустить параллельно через Task:
  - Subagent 1: YouTube Mining
  - Subagent 2: Forum/Community VoC
  → ждать оба return
  → wayfinding клиенту: «✅ 2 из 5 готовы. Запускаю Telegram + Search + Конкуренты»

Turn 2: Запустить параллельно:
  - Subagent 3: Telegram Channels + Comments
  - Subagent 4: Search Queries
  - Subagent 5: Конкурентная карта
  → ждать все return
  → wayfinding: «✅ 5 из 5 готовы. Запускаю БПСВ-синтез»

Turn 3: Запустить:
  - Subagent 6: БПСВ-синтезатор (читает все 5 файлов из intel/{slug}/)
  → return: voice-of-segment.md
```

Это даёт клиенту **2 промежуточных update'а** вместо одного 30-минутного молчания.

---

## 3. Промпт Субагента 1 — YouTube Mining (real tech)

⭐ **Адаптивный по уровню окружения:**

### Level 2 (есть YOUTUBE_API_KEY + MCP youtube-transcript) — SWEET SPOT

```
Ты — researcher YouTube для маркетинговой разведки.

КОНТЕКСТ:
- Сегмент: {title из гипотезы}
- Главная боль: {из materials Phase A}
- Регион: RU/CIS

ИНСТРУМЕНТЫ:
- $YOUTUBE_API_KEY (Data API v3, лимит 10K units/день, max_units_for_segment: 3000)
- MCP youtube-transcript (если установлен — fallback to youtube-transcript-api Python)

WORKFLOW:

Шаг 1 — search.list (3 запроса × 100 units = 300):
  curl "https://www.googleapis.com/youtube/v3/search?part=snippet&q={key1}&type=video&maxResults=25&order=viewCount&key=$YOUTUBE_API_KEY"
  
  3 query вариации: основная боль / синоним / конкурент в нише
  → 75 video IDs суммарно

Шаг 2 — videos.list (75 × 1 = 75 units):
  curl "https://www.googleapis.com/youtube/v3/videos?part=statistics,snippet&id=ID1,ID2,...&key=$YOUTUBE_API_KEY"
  → views, likes, comments_count, duration, publish_date

Шаг 3 — Фильтр залётных:
  views/days_since_published > 1000 (а не views > N)
  Engagement Rate (likes + comments) / views × 100 — норма 4-5%, > 7-9% = высокий
  Дата < 24 мес (контекст устарел)
  → топ-15 залетающих

Шаг 4 — commentThreads.list (15 × 1 = 15 units):
  curl "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=ID&maxResults=100&order=relevance&key=$YOUTUBE_API_KEY"
  ⚠️ order=relevance, НЕ time! Top согласного большинства.
  → 100 топ-комментов на топ-15 видео = до 1500 комментов

Шаг 5 — AI-фильтр комментов:
  Отбросить если:
  - Длина 80-150 символов с типичными паттернами «Great video!», «Amazing content», «As a X, I think»
  - Нет цифр / имён / специфики
  - Меньше 10 лайков
  - Аккаунт автора подписан < 1 года И > 100 комментов в день (бот)
  → ~300-500 валидных комментов

Шаг 6 — Транскрипты топ-5 видео (если есть MCP):
  ⚠️ youtube-transcript-api нестабилен с datacenter IP (issue #303, блок YouTube с конца 2024)
  Fallback если транскрипт недоступен: пропускаем, работаем по комментам
  
  for vid in top_5_by_engagement:
    transcript = MCP.get_transcript(vid)
    extract_phrases где спикер пересказывает клиентов / задаёт боль аудитории

Шаг 7 — Формирование output:
  intel/{slug}/youtube-cuts.md:
    ## Топ-15 залетающих заголовков (с view/days metric)
    | # | Заголовок дословно | views | days | views/day | engagement_rate | URL |
    
    ## Цитаты из комментов (50-150 валидированных)
    > "{дословно}" — @user (likes), видео #N, URL
    
    ## Топ-5 транскриптов (если доступны)
    [Извлечения с timestamps где спикер пересказывает боль]
    
    ## Архетипические сюжеты (мета-сюжеты повторяющиеся в 5+ видео)
    1. "Я пробовал X — не сработало" → нарратив для presell
    
    ## Лингво-маркеры (слова в 5+ заголовках)

ИТОГО units:  300 (search) + 75 (videos) + 15 (comments) = 390 units. Влезает с запасом.

ACCEPTANCE: 15 заголовков + 50-150 цитат комментов + 0-5 транскриптов (если повезло)
```

### Level 1 (нет YOUTUBE_API_KEY) — DEGRADED

```
WebSearch: site:youtube.com "{ниша}" "{боль}" → топ-20 заголовков с view counts
WebFetch на каждое видео-URL → метаданные (БЕЗ комментов, без транскриптов)
Output: youtube-cuts.md только с заголовками + предупреждение клиенту:
  "⚠️ Без YouTube Data API ключа собрал 30% от возможного.
   Установишь? Дам инструкцию за 5 минут (бесплатно)."
```

---

## 4. Промпт Субагента 2 — Forum/Community VoC

⭐ **Основной путь — WebSearch + WebFetch с реальными площадками 2026.**
⚠️ **Unofficial APIs (vcru-api, pikabu, dtf) — community libs, могут быть мёртвыми. Использовать как fallback, не как основной путь.**

```
Ты — researcher VoC из форумов и сообществ.

КОНТЕКСТ:
- Сегмент: {title}
- Главная боль из Phase A: {цитата клиента}
- Регион: RU/CIS

ЖИВЫЕ ПЛОЩАДКИ 2026:
- vc.ru — главный B2B/SMB. Метод: WebSearch site:vc.ru "{боль}" + WebFetch топ-10 статей с >100 комментов
- Habr.com — IT/AI/продуктивность. Метод: WebSearch site:habr.com "{ниша}" + WebFetch
- Pikabu.ru — бытовые ниши. Метод: WebSearch site:pikabu.ru "{боль}"
- DTF.ru — гейминг/IT/креативные индустрии. WebSearch site:dtf.ru
- Дзен (dzen.ru) — массовая аудитория. WebSearch site:dzen.ru
- Spark.ru — стартапы и малый бизнес. WebSearch site:spark.ru

EN-ПЛОЩАДКИ (для переноса инсайтов):
- r/Entrepreneur (4M+ subs)
- r/smallbusiness (2M+)
- r/marketing
- Метод: WebSearch site:reddit.com "{ниша} {боль}" → топ-постов с >100 upvotes

⚠️ НЕ использовать (мёртвые / шумные):
- LiveJournal — спам-фермы
- mybusiness.ru, profilelab.ru — низкая активность
- r/Russia — quarantined с 2022

WORKFLOW:

Шаг 1 — Поиск релевантных статей (по 3-5 запросов на каждой площадке):
  WebSearch site:vc.ru "{боль}" → 10 ссылок
  WebSearch site:habr.com "{ниша} проблема" → 10 ссылок
  ... (для каждой площадки)

Шаг 2 — WebFetch топ-10 наиболее обсуждаемых (по индикаторам в SERP — комменты, лайки):
  Извлечь:
  - Дословные цитаты из тела статьи (если автор сам ЦА)
  - Топ-комменты (>10 лайков) дословно
  - Имя автора + URL для атрибуции

Шаг 3 — Жёсткий фильтр мусора:
  ❌ Реклама в комментах
  ❌ AI-generated (повторяющиеся обороты "As a X, I think")
  ❌ Обобщения "все эксперты сегодня выгорают"
  ❌ Минимум 10 лайков на коммент
  ❌ Слово "ChatGPT" в тексте без контекста (промо-комменты)

Шаг 4 — Кластеризация по типам цитат:
  - Боль (что больно сейчас)
  - История (что пробовал — кейс или анти-кейс)
  - Желание (что хочется)
  - Возражение (почему не покупают / разочарованы в продукте конкурента)
  - Метафора (образный язык)

Шаг 5 — Output:
  intel/{slug}/community-voc.md
  - 30-50 цитат болей по подкатегориям с источниками (URL + автор + дата)
  - 10-15 желаний дословно
  - 15-25 возражений по типам
  - 10-15 метафор с источниками
  - Карта живых площадок где была находка

ACCEPTANCE: 30+ цитат болей + 10+ желаний + 15+ возражений + источники для каждого
```

⚠️ **Telegram — отдельный субагент 3** (комменты через t.me/s/ НЕДОСТУПНЫ, нужен Pyrogram).

---

## 5. Промпт Субагента 3 — Telegram Channels + Comments

⭐ **Адаптивный по уровню окружения:**

### Level 2 (есть TELEGRAM_API_ID + MCP telegram-mcp)

```
Ты — researcher Telegram-пространства.

ШАГИ:

Шаг 1 — Поиск каналов (без MCP, через WebFetch):
  - TGStat: WebFetch tgstat.com/categories → 30+ каналов в нише
  - Telega.io: WebFetch telega.io/catalog → фильтр по нише + цены за пост
  - Google dork: WebSearch site:t.me/s/ "{ниша}"
  - Каталоги: WebFetch tlgrm.ru/channels, telegroom.ru
  → Выборка 20-30 каналов с метриками (подписчики, ER если доступно, цена рекламы)

Шаг 2 — Анализ постов через t.me/s/ (бесплатно):
  Для топ-10 каналов:
    WebFetch https://t.me/s/{channel_username}
    Извлечь:
    - Топ-20 постов (текст + views + дата + agg реакции)
    - Описание канала + кол-во подписчиков
    ⚠️ КОММЕНТЫ ЗДЕСЬ НЕ ДОСТУПНЫ (только посты + агрегаты)

Шаг 3 — Комменты через MCP telegram-mcp (Pyrogram):
  ⚠️ Требует TELEGRAM_API_ID + session_string (получен через интерактивный setup)
  ⚠️ Лимит ≤30 запросов/мин, иначе FLOOD_WAIT
  ⚠️ Используем ОТДЕЛЬНЫЙ аккаунт (не основной), риск бана за parsing
  
  for channel in top_5_channels:
    use MCP tool: telegram.get_discussion_message(channel, post_id)
    → топ-30 комментов под топ-5 постов канала
    extract:
      - Дословный текст коммента
      - @author (или anon)
      - Likes/replies
      - Дата

Шаг 4 — Жёсткий фильтр:
  ❌ Реклама / промо-комменты
  ❌ AI-боты (повторяющиеся обороты)
  ❌ Минимум 5 лайков
  ❌ Минимум 30 символов длина
  ✅ Эмоция + специфика + цифры из жизни

Шаг 5 — Output:
  intel/{slug}/telegram-channels-map.md
  - 20-30 каналов с метриками (название, подписчики, ER, ценник рекламы как proxy «жирности»)
  - Цитаты постов (если показательные)
  - Цитаты комментов (если есть API) — 30-50 цитат

ACCEPTANCE: 20+ каналов карта + 30+ цитат комментов (если Level 2) или 20+ цитат постов (Level 1)
```

### Level 1 (нет TELEGRAM_API_ID) — DEGRADED

```
Только посты публичных каналов через WebFetch t.me/s/{channel}
Output: telegram-channels-map.md без комментов + предупреждение:
  "⚠️ Без Telegram API_ID собрал только посты публичных каналов.
   Комменты под постами — отдельная сущность Telegram (discussion groups),
   доступ только через Pyrogram. Установишь? Скринкаст инструкции 3 мин,
   но шаг my.telegram.org/apps занимает 15-20 минут с phone code."
```

---

## 6. Промпт Субагента 4 — Search Queries (real tech)

```
Ты — SEO-researcher для маркетинговой разведки.

ИНСТРУМЕНТЫ ПО УРОВНЯМ:

### Level 1 (без ключей):
1. Bukvarix free API ⚠️ (требует регистрацию с 2024, не публичный &key=free):
   curl "https://api.bukvarix.com/v1/keywords/?q={query}&key=$BUKVARIX_KEY&format=csv"
   → CSV до 1000 ключей с частотностью

2. Google Suggest напрямую (работает в 2026):
   curl "http://suggestqueries.google.com/complete/search?client=firefox&hl=ru&q={QUERY}"
   → JSON массив автодополнений

3. WebSearch для related queries в SERP

### Level 2 (есть SERPAPI_KEY):
1. Google PAA через SerpAPI:
   curl "https://serpapi.com/search.json?engine=google&q={query}&hl=ru&gl=ru&api_key=$SERPAPI_KEY"
   → related_questions блок (10-15 PAA-вопросов)

2. Google Trends:
   curl "https://serpapi.com/search.json?engine=google_trends&q={query}&geo=RU&api_key=$SERPAPI_KEY"
   ⚠️ Используем ТОЛЬКО для hot-сегмента (free 100/мес не хватит на 3 сегмента: 50×3=150)

3. Google Suggest расширенный (через SerpAPI engine=google_autocomplete)

### Level 3 (опционально):
- Yandex Wordstat OAuth (если есть YANDEX_WORDSTAT_TOKEN — запрос approval 3+ дней)
  api.wordstat.yandex.net/v1/topRequests — production-grade RU частотность

WORKFLOW:

Шаг 1 — 3-5 seed-запросов (вариации основной боли):
  base_query = "{главная боль из Phase A}"
  variants = ["{base}", "{синоним}", "{ниша} + {боль}", "как пробить {боль}", ...]

Шаг 2 — для каждой query:
  - Bukvarix → топ-50 ключей с частотностью
  - Google Suggest → 10 автодополнений
  - SerpAPI Google PAA → 10-15 related questions (если Level 2)

Шаг 3 — Анализ интента (4 типа):
  - Информационный («как разгрузить себя») → стадия Awareness
  - Транзакционный («купить курс по AI») → Solution-Aware
  - Навигационный («like центр отзывы») → Most-Aware
  - Сравнительный («like vs Аяз») → горячий, продаём здесь и сейчас (4-й интент добавлен)

Шаг 4 — Output:
  intel/{slug}/search-queries.md
  ## Топ-30 поисковых запросов с частотой (Bukvarix/Wordstat)
  | # | Запрос | Частота/мес | Тип интента |
  
  ## Google PAA (вопросы что люди реально спрашивают, если SerpAPI)
  
  ## Google Suggest (живые автодополнения)
  
  ## Анализ интента
  - Информационных: N% → нужен educational контент
  - Транзакционных: N% → готовы покупать, нужен прямой оффер
  - Сравнительных: N% → готовы сравнивать, нужны Х vs Y материалы
  
  ## Long-tail (запросы <500 частоты но сильным интентом)

ACCEPTANCE: 30 запросов с частотой + 10 PAA (Level 2) или 0 PAA (Level 1) + анализ интента
```

---

## 7. Промпт Субагента 5 — Конкурентная карта

```
Ты — конкурентный аналитик. Маркетинговая матрица Хормози.

ШАГИ:

Шаг 1 — Карта 8-12 конкурентов:
  - WebSearch "топ {ниша} 2024-2026" → известные игроки
  - Из Phase A: hypotheses.md → competitors_mentioned (что назвал клиент)
  - Lookup → расширить (с кем эти конкуренты конкурируют?)

Шаг 2 — WebFetch лендингов:
  Для каждого конкурента:
  - WebFetch his landing page → offer / price (если виден) / Named Mechanism / Risk Reversal / hero-блок дословно
  - Если price публично нет — пометить [price unknown], НЕ выкидывать

Шаг 3 — Реальные отзывы:
  - WebSearch "{бренд} отзывы" site:otzovik.com OR site:holod.media
  - WebSearch site:vc.ru/u/{author} комменты под статьями конкурентов (там реальные клиенты)
  - VK-страницы конкурентов (комменты с жалобами)

Шаг 4 — SimilarWeb проверка трафика (если работает через WebFetch):
  WebFetch similarweb.com/website/{domain}
  ⚠️ Cloudflare часто блокирует — fallback: пропустить если упало
  Бесплатный preview даёт rank + estimated visits = отделит работающих от инфо-фасадов

Шаг 5 — Whitespace map:
  Что никто из топ-12 НЕ закрывает (по жалобам в отзывах):
  - Готовая система vs «учить промтить»
  - Реальное 1-1 наставничество с гарантией
  - ...

Шаг 6 — Жёсткий фильтр Хормози:
  ✅ Только где есть деньги (продают, есть ценник публично или в отзывах)
  ❌ Эксперты «рассказывают об AI» без продукта
  ❌ Stub-агентства (нет кейсов / клиентов)

Шаг 7 — Output:
  intel/{slug}/competitors-map.md
  ## Матрица 8-12 конкурентов
  | # | Имя | Что | Цена | Dream Outcome дословно | Named Mechanism | Risk Reversal | Каналы | URL |
  
  ## Стратегические инсайты по каждому
  ### {Конкурент 1}
  - Уязвимости (из отзывов)
  - Что работает
  - Whitespace для нас
  
  ## Whitespace map (общая)
  
  ## Ценовые якоря рынка
  - Дёшево / средне / дорого / премиум
  
  ## Перенос инсайтов EN/EU → RU (если есть западные)

ACCEPTANCE: 8-12 конкурентов с полной матрицей + whitespace map + ценовые якоря
```

---

## 8. Промпт Субагента 6 — БПСВ-синтезатор (Match-методика)

⚠️ **Запускается ПОСЛЕ возврата субагентов 1-5 в отдельном turn.**

```
Ты — синтезатор маркетинговых данных. Match-методика для voice-of-segment.md.

INPUTS (явный контракт):
- intel/{slug}/youtube-cuts.md
- intel/{slug}/community-voc.md
- intel/{slug}/telegram-channels-map.md
- intel/{slug}/search-queries.md
- intel/{slug}/competitors-map.md
- inbox/_raw/ — материалы клиента из Phase A (5 категорий: cases / posts / transcripts / refusals / screenshots)

ALGORITHM:

Шаг 1 — Flat list всех цитат:
  Все цитаты из 6 source files в одну таблицу:
  | quote | source_file | source_url | type (боль/желание/возражение/метафора) | likes/views | source_type |
  
  source_type ∈ {client_material, youtube_comment, youtube_headline, youtube_transcript,
                 forum_post, forum_comment, telegram_post, telegram_comment,
                 search_query, competitor_landing, competitor_review}

Шаг 2 — Pair-by-pair semantic clustering:
  for each pair (cite_a, cite_b):
    if shared ≥ 2 семантических ключевых слова AND triggers одинаков:
      merge в один cluster
  
  Пример: 
    "топчусь на 200К" (vc.ru) 
    + "упёрся в потолок" (YouTube comment)
    + "плато дохода" (Wordstat) 
    → ОДИН cluster "потолок и застой"

Шаг 3 — evidence_count + unique_sources + evidence_weight:
  Для каждого cluster:
    evidence_count = количество цитат в cluster
    unique_sources = число РАЗНЫХ source_type (max 11 типов)
    evidence_weight = sum(likes × source_quality_multiplier)
  
  Source quality multipliers:
    vc.ru post = 3
    vc.ru comment = 3
    YouTube headline = 2
    YouTube comment = 1
    YouTube transcript = 4 (длинный материал = высокая ценность)
    Reddit post = 2
    Telegram post = 4
    Telegram comment = 4
    Search query / Wordstat = 5 (зеркало рыночного интента)
    Competitor landing = 2
    Competitor review (otzovik etc) = 3
    Client material = 2

Шаг 4 — Двойной критерий статуса:
  🟢 GOLD     = (unique_sources ≥ 3 AND evidence ≥ 5) OR (unique_sources ≥ 2 AND evidence_weight ≥ 50)
  🌟 GOLD-VIP = single source но >200 лайков на vc.ru / >500 на YouTube / >50 на Reddit
                (для hero-блока лендинга — внутренний скоринг, клиенту в portrait не показывается отдельно)
  🟡 SIGNAL   = unique_sources = 2 OR evidence = 3-4 (требует custdev)
  🔴 BACKLOG  = unique_sources = 1 (только клиент или один источник)

Шаг 5 — Bias check (по типу источника):
  YouTube comments → Problem-Aware self-selecting (sliver всей ЦА)
  Forums (vc.ru/Habr) → высокая социализация, рационализирующая аудитория
  Telegram comments → лояльные читатели каналов = эхо-камеры
  Reddit → молодая, англоязычная, технологически грамотная
  
  Помечать source-bias в каждом кластере, не смешивать как равные.

Шаг 6 — GATE: <8 GOLD кластеров → STOP, эскалация владельцу:
  if total_GOLD_clusters < 8:
    return:
      "Phase B вернула тонкий VoC ({N} GOLD кластеров вместо ≥8 ожидаемых).
       Это сигнал что: (а) субагенты копали не там / (б) ниша слишком узкая /
       (в) клиент дал недостаточно материалов в Phase A.
       
       3 варианта (через AskUserQuestion):
       a) Переделать Phase B с другими ключевыми словами
       b) Расширить гипотезу сегмента (вернуться в Phase A)
       c) Принять тонкий VoC и идти в Phase C с пометкой '⚠️ ограниченный'"
    
    Без этого gate тонкий VoC просочится в Phase C → клиент валидирует мусор.

Шаг 7 — Manual review топ-10:
  Алекс ВРУЧНУЮ читает топ-10 GOLD кластеров для проверки на синонимы.
  Если 3 цитаты «упёрся в потолок» — это 1 cluster, не 3.

Шаг 8 — Финальный output: voice-of-segment.md
  Структура ровно как VoC «Эксперт в потолке»:
  
  # VoC — {Имя сегмента}
  
  > Целевая ниша: ...
  > Источники: ...
  > Дата: 2026-MM-DD
  > Принцип: ВСЁ ДОСЛОВНО
  > Cluster count: 15-25 уникальных смысловых кластеров после dedupe из 30-50 сырых цитат
  
  ## Цитаты БОЛИ (по подкатегориям с цветами)
  ### Подкатегория 1
  1. 🟢 «{дословно}» — [источник + URL] — evidence: 5 sources / weight: 87
  2. 🟢 «...» — ...
  
  ## Цитаты ЖЕЛАНИЯ (10-15)
  ## Цитаты ВОЗРАЖЕНИЙ (15-25 по типам)
  ## Лингво × 5+ категорий
  ## Метафоры (10-15 с атрибуцией)
  ## Каналы и сообщества (Telegram + vc.ru + конференции)
  ## Конкуренты (5-10 с тарифами)
  ## Что покупают / на что подписаны (топ-10)
  ## Сводка от исследователя (250 слов)
    Главный паттерн боли (3-5 предложений)
    Три раны при попытке выйти
    Ключевые языковые маркеры для копи (20-30 слов)
    3 must-use цитаты на лендинге (для hero / proof / objections)

⚠️ Размер файла max 600 строк. Если больше — топ-30 болей по weight, остальное в _archive/full-voc-{date}.md.

ACCEPTANCE:
- 15-25 уникальных GOLD кластеров (после dedupe)
- 30-50 цитат болей дословно по подкатегориям
- 10-15 желаний / 15-25 возражений / 5+ категорий лингво / 10-15 метафор
- Каналы / 5-10 конкурентов / 250-словная сводка с 3 must-use
```

---

## 9. Acceptance criteria финальные (реалистичные)

| Метрика | Заявлено в начале | Реалистично после reviewer'ов |
|---------|-------------------|-------------------------------|
| Время на сегмент | 30-60 мин | **60-90 мин** |
| Уникальные GOLD кластеры | 30+ | **15-25** (после dedupe из 30-50 сырых) |
| YouTube комменты | 50+ | **50-150** (Level 2 с Data API) или **0** (Level 1) |
| YouTube транскрипты | 5+ | **0-5** (datacenter IP блок риск 50/50) |
| Search queries с частотой | 30 | **20-30** (Bukvarix + Suggest) |
| Google PAA | 15 | **10-15** (Level 2) или **0** (Level 1) |
| Telegram каналы | 20-30 | **20-30** (с метриками) |
| Telegram комменты | 30-50 | **30-50** (Level 2) или **0** (Level 1) |
| Forums цитаты | 30-50 | **30-50** (vc.ru + Habr + Pikabu + DTF + Reddit) |
| Конкуренты | 8-12 | **8-12** с матрицей |

**Если результат < acceptance — gate в субагенте 6 переводит в [partial] или эскалирует владельцу.**

---

## 10. Output Phase B

```
projects/<main>-audience/intel/{slug}/
  ├── youtube-cuts.md          (Subagent 1)
  ├── community-voc.md         (Subagent 2)
  ├── telegram-channels-map.md (Subagent 3)
  ├── search-queries.md        (Subagent 4)
  ├── competitors-map.md       (Subagent 5)
  └── voice-of-segment.md      ⭐ Subagent 6 финал
```

---

## 11. Anti-patterns

❌ **`run_in_background: true` для Task tool** — этого параметра не существует. Параллелизм = 5 Task в одном turn.
❌ **WebFetch t.me/s/ для комментов** — даёт только посты, не комменты. Комменты только через Pyrogram MCP.
❌ **Wordstat через WebFetch** — CAPTCHA блокирует. Использовать Bukvarix + Yandex Wordstat OAuth (Level 3).
❌ **Bukvarix `&key=free`** — публичный ключ закрыли в 2024, нужна регистрация.
❌ **Включить в финал HYPOTHESIS-цитаты** (только 1 источник) — это шум, портит качество.
❌ **Перефразировать цитаты для красоты** — теряем самое ценное (живой язык ЦА). Дословно или ничего.
❌ **Пропустить gate <8 GOLD** — тонкий VoC просочится в Phase C, клиент валидирует мусор.
❌ **Семантическая кластеризация без Шага 7 (manual review)** — рискуем 3 синонима как 3 кластера.

---

## 12. Память

**Перед задачей:**
- `grep` по `failures.md` на «Phase B / WebSearch / subagent timeout / API quota»

**После задачи:**
- Append в `memory.md`: какие источники дали жирные данные, какие пустые
- Patterns: типичные lingvo/конкуренты в нише
- Если фейл (subagent partial / API quota exhausted / GOLD <8) → `failures.md`

---

## 13. Связь с другими скиллами

- ⬅️ **Запускается из** `/audience-stage` после Phase A
- ⬅️ **Поглотил** `/competitors-research` (subagent 5) + `/segment-money-map` (subagent 4) + `/segment-hypotheses` (Phase A)
- ➡️ **Передаёт в** `/audience-validation` (Phase C)
- 🔄 **Re-run возможен** через 30+ дней (рынок меняется), старая папка `intel/{slug}/` → `_archive/YYYY-MM/`

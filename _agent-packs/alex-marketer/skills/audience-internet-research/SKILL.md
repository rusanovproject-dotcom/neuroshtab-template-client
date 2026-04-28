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

### 1.0 ⚠️ ОБЯЗАТЕЛЬНО ПЕРЕД ЗАПУСКОМ — прочитай 2 файла качества

**Без этого — Phase B соберёт "voice-of-pundit" вместо VoC. Реальный fail из апреля 2026.**

```bash
cat office/agents/alex-marketer/knowledge/voc-quality-rules.md  # что считать VoC
cat office/agents/alex-marketer/knowledge/voice.md              # как Алекс говорит клиенту
```

Эти файлы — **закон** для всех 5 субагентов. Каждый промпт субагента ниже **передаёт правила VoC внутрь**. БПСВ-синтезатор использует их как gate перед статусом GOLD.

**Жёсткий минимум который должен помнить Алекс:**

🟢 **VoC = первое лицо + конкретика + реальный человек** («Я психолог, веду 8 клиентов, блог пустой третий месяц...»)
🟠 **PUNDIT = аналитика про ЦА** («Перфекционизм — это латентная прокрастинация» — Шишов, бизнес-блогер) → НЕ в основную VoC
🔴 **STATISTIC = исследования** («73% психологов не публикуют посты») → отдельная секция «контекст рынка», не цитаты

**3 теста на каждой цитате (детали в `voc-quality-rules.md`):**
1. Первое лицо? («я», «у меня»)
2. Конкретика? (цифра, имя, событие)
3. Реальный человек, не пунди́т? (атрибуция к клиенту, не к аналитику)

3 из 3 = `gold_voc` | 2 из 3 = `signal_voc` | 1 или 0 = `pundit`/`statistic`/мусор.

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

⚠️ ⚠️ ⚠️ ОБЯЗАТЕЛЬНО ПЕРЕД РАБОТОЙ:
прочитай office/agents/alex-marketer/knowledge/voc-quality-rules.md
Это закон. VoC = первое лицо + конкретика + реальный человек.
PUNDIT (аналитика экспертов) и STATISTIC (исследования) — НЕ VoC.

КОНТЕКСТ:
- Сегмент: {title}
- Главная боль из Phase A: {цитата клиента}
- Регион: RU/CIS

ИЕРАРХИЯ ИСТОЧНИКОВ (НОВАЯ — после fail апреля 2026):

🥇 ПЕРВЫЙ ПРИОРИТЕТ — НИШЕВЫЕ ФОРУМЫ С ПЕРВЫМ ЛИЦОМ (multiplier 4):
- b17.ru — психологи (если ниша эксперта — психология/коучинг)
- profi.ru — обсуждения для специалистов разных ниш
- kursometr.ru — коучи и обучающие
- Reddit RU — r/ru_psychology, r/ru_marketing, нишевые сабреддиты
- Закрытые/полуоткрытые тематические Telegram-чаты
Метод: WebSearch + WebFetch. Цитаты — только из первого лица.

🥈 ВТОРОЙ ПРИОРИТЕТ — vc.ru/Habr/Pikabu/DTF С ФИЛЬТРАЦИЕЙ (multiplier 1-2):
- ✅ Берём: посты где автор САМ ЦА и пишет про СЕБЯ («Я психолог, у меня 200К/мес, 7 клиентов...») — multiplier 2
- ✅ Берём: топ-комменты под такими постами от ДРУГИХ ЦА (>10 лайков) — multiplier 2
- ❌ Игнорируем как VoC: аналитические посты экспертов про ЦА («Перфекционизм — это латентная прокрастинация») — это PUNDIT, multiplier 1, в pundit-analysis.md
- ❌ Игнорируем как VoC: обзоры рынка, прогнозы, тренды — это STATISTIC, multiplier 0

🥉 EN-площадки (для переноса инсайтов, multiplier 2):
- r/Entrepreneur (4M+) — ищем русскоязычных экспертов или близкие профили
- r/smallbusiness, r/marketing — нишевые threads
- Метод: WebSearch site:reddit.com "{ниша} {боль}" → топ-посты с >100 upvotes

⚠️ НЕ использовать (мёртвые / шумные):
- LiveJournal — спам-фермы
- mybusiness.ru, profilelab.ru — низкая активность
- r/Russia — quarantined с 2022

WORKFLOW:

Шаг 1 — Поиск релевантных площадок (приоритет нишевых форумов):
  WebSearch site:b17.ru "{боль}" → 10 тредов (если ниша подходит)
  WebSearch site:profi.ru "{ниша} {боль}" → 10 ссылок
  WebSearch site:kursometr.ru "{боль}" → 10 ссылок
  WebSearch site:reddit.com/r/{сабреддит} "{боль}"
  ПОТОМ: WebSearch site:vc.ru, site:habr.com, site:pikabu.ru как добавочный слой

Шаг 2 — WebFetch топ-10 обсуждаемых:
  Извлечь:
  - Дословные цитаты ОТ ПЕРВОГО ЛИЦА с конкретикой («Я ... у меня ... 200К/мес ...»)
  - Топ-комменты (>10 лайков) ОТ ПЕРВОГО ЛИЦА с конкретикой
  - Имя автора + URL для атрибуции
  - source_type: niche_forum | vc_post_client | vc_comment | reddit_post | etc

Шаг 3 — ЖЁСТКИЙ ФИЛЬТР (3 теста на каждой цитате):

  Тест 1 — Первое лицо?
    ✅ начинается с «я», «у меня», «мой», «когда я»
    ❌ начинается с «эксперты», «73%», «многие», «по данным», «согласно»

  Тест 2 — Конкретика?
    ✅ есть цифра/имя/событие/действие («200К/мес», «8 клиентов», «купил курс за 150К»)
    ❌ только обобщения («трудно», «много работы»)

  Тест 3 — Реальный человек, не пунди́т?
    ✅ автор — клиент ниши, говорит про СЕБЯ
    ❌ автор — журналист/аналитик/CEO большой компании пишет про РЫНОК

  Подсчёт:
    3 из 3 — citation.tag = "gold_voc" → в основной портрет
    2 из 3 — citation.tag = "signal_voc" → SIGNAL (валидируется в Phase C)
    1 или 0 из 3 — citation.tag = "pundit" или "statistic" → в pundit-analysis.md / market-stats.md

Шаг 3.5 — Дополнительный мусорный фильтр:
  ❌ Реклама в комментах
  ❌ AI-generated (повторяющиеся обороты "As a X, I think")
  ❌ Минимум 10 лайков на коммент (или other engagement signal)
  ❌ Слово "ChatGPT" в тексте без контекста (промо-комменты)

Шаг 4 — Кластеризация ТОЛЬКО gold_voc + signal_voc цитат по типам:
  - Боль (что больно сейчас)
  - История (что пробовал — кейс или анти-кейс)
  - Желание (что хочется)
  - Возражение (почему не покупают / разочарованы в продукте конкурента)
  - Метафора (образный язык)

Шаг 5 — Output (3 файла, не 1):
  intel/{slug}/community-voc.md           ← только gold_voc + signal_voc
    - 30-50 цитат болей по подкатегориям с источниками (URL + автор + дата)
    - 10-15 желаний дословно
    - 15-25 возражений по типам
    - 10-15 метафор с источниками
    - Карта живых площадок где была находка

  intel/{slug}/pundit-analysis.md         ← аналитика экспертов про ЦА (для контекста, НЕ VoC)
    - Цитаты с тегом "pundit" (5-15 наблюдений с пометкой автор-аналитик)
    - Использовать как фон, не как голос ЦА

  intel/{slug}/market-stats.md            ← статистика и исследования
    - Цифры рынка, % исследований
    - Использовать как контекст для лендинга/презентации

ACCEPTANCE:
- 30+ gold_voc цитат болей в community-voc.md (только первое лицо!)
- ≤30% цитат с одного source_type (диверсификация обязательна)
- pundit-analysis.md и market-stats.md заполнены отдельно (если pundit-цитаты найдены)
- Если gold_voc < 25 — STOP, эскалация: «копал не там, нужно сменить площадки»
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

## 7. Промпт Субагента 5 — Конкурентная карта + Comments-mining

```
Ты — конкурентный аналитик + comments-miner.

⚠️ ⚠️ ⚠️ ОБЯЗАТЕЛЬНО ПЕРЕД РАБОТОЙ:
прочитай office/agents/alex-marketer/knowledge/voc-quality-rules.md
Comments под контентом конкурентов = ВЫСШИЙ ПРИОРИТЕТ для VoC (multiplier 5).
Ты приносишь не только карту конкурентов, но и **дословные цитаты их клиентов**
из комментов под их видео/постами.

ШАГИ:

Шаг 1 — Карта 8-12 конкурентов:
  - WebSearch "топ {ниша} 2024-2026" → известные игроки
  - Из Phase A: hypotheses.md → competitors_mentioned (что назвал клиент)
  - Lookup → расширить (с кем эти конкуренты конкурируют?)

Шаг 2 — WebFetch лендингов:
  Для каждого конкурента:
  - WebFetch his landing page → offer / price (если виден) / Named Mechanism / Risk Reversal / hero-блок дословно
  - **Извлечь кейсы / отзывы / "до-после"** дословно с лендинга — это часто настоящие
    цитаты клиентов с именем и фотографией, multiplier 4
  - Если price публично нет — пометить [price unknown], НЕ выкидывать

Шаг 3 — ⭐ COMMENTS-MINING (ключевой источник VoC, не пропускать!):

  Для каждого из топ-5 конкурентов:

  3a. YouTube-канал конкурента:
    - WebSearch "{имя} youtube" → канал
    - Если есть YOUTUBE_API_KEY: API search videos by channel → топ-3 видео по views
    - Для каждого видео: API get comments → top-by-likes 30+ комментов
    - Если нет API: WebSearch "site:youtube.com/watch {имя_видео}" + WebFetch
    - **Фильтр:** комменты от первого лица с конкретикой («Я психолог, у меня 8 клиентов...»)
    - source_type: youtube_comment_competitor (multiplier 5)

  3b. Telegram-канал конкурента:
    - WebFetch t.me/{channel_name} → видны посты + ОБЫЧНО видны комменты на t.me/s/{channel}/{post_id}
    - Если есть Pyrogram MCP: API get_messages + replies → топ-комменты
    - **Фильтр:** комменты от первого лица с конкретикой
    - source_type: telegram_comment_competitor (multiplier 5)

  3c. Instagram (если конкурент там активен):
    - WebFetch instagram.com/{handle} → посты + видимые комменты
    - **Фильтр:** первое лицо + конкретика
    - source_type: instagram_comment_competitor (multiplier 5)

  3d. Отзывы на платформах:
    - WebSearch "{бренд} отзывы" site:otzovik.com OR site:irecommend.ru OR site:holod.media
    - VK-страницы конкурентов (комменты с жалобами)
    - source_type: competitor_review (multiplier 4)

  ⚠️ КРИТИЧНОЕ ПРАВИЛО: на этом шаге ты должен принести МИНИМУМ 30 перволичных
  цитат комментариев. Это **главный источник VoC** для финального портрета.
  Если меньше 30 — копай ещё в комментах других видео того же конкурента.

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
  
  ⚠️ ОБЯЗАТЕЛЬНО ПЕРЕД РАСЧЁТОМ — каждая цитата уже должна иметь tag из 3 тестов
  (gold_voc / signal_voc / pundit / statistic) — см. voc-quality-rules.md.
  В кластеризацию идут ТОЛЬКО gold_voc + signal_voc. Pundit и statistic — в отдельные файлы.

  Source quality multipliers (НОВАЯ ИЕРАРХИЯ — после fail апреля 2026):

  🥇 ВЫСШИЙ ПРИОРИТЕТ (это голос реальных клиентов конкурентов):
    YouTube comment под видео конкурента = 5
    Telegram comment в канале конкурента = 5
    Instagram comment под рилсом конкурента = 5
    Competitor review (Otzovik, irecommend) = 4
    Competitor case quote (на лендинге конкурента) = 4

  🥈 ВЫСОКИЙ (нишевые форумы где первое лицо):
    Niche forum post (b17, profi, kursometr) = 4
    Niche forum comment = 4
    Reddit post в нишевом сабреддите = 3
    Reddit comment = 3
    Telegram post в нишевом канале = 4

  🥉 СРЕДНИЙ (vc.ru/Habr — но осторожно):
    vc.ru post WHERE author_role == "client_not_analyst" = 2
    vc.ru comment WHERE first_person + concrete = 2
    Habr post WHERE author_role == "client_not_analyst" = 2
    Pikabu/DTF/Spark post с первым лицом = 2

  🔴 НИЗКИЙ (используется только если gold_voc < 25 после фильтра):
    vc.ru post WHERE author_role == "analyst/journalist" = 1 → idem PUNDIT
    Habr post-обзор = 1 → idem PUNDIT
    Search query / Wordstat = 3 (зеркало рыночного интента, не VoC сам по себе)

  🚫 НУЛЕВОЙ (вообще не VoC):
    Statistic / research (McKinsey, % опросов) = 0 → market-stats.md
    Wikipedia / encyclopedia = 0
    Промо-материалы конкурентов без отзывов клиентов = 0

  Client material (от Phase A) = 2 (контекст, не основа)

Шаг 4 — Двойной критерий статуса (только для gold_voc + signal_voc):
  🟢 GOLD     = (unique_sources ≥ 3 AND evidence ≥ 5) OR (unique_sources ≥ 2 AND evidence_weight ≥ 50)
                + obligatory: ≥80% цитат в кластере имеют tag = "gold_voc"
                (если в кластере 50/50 gold + signal — это SIGNAL, не GOLD)
  🌟 GOLD-VIP = single source но >500 лайков на YouTube / >200 на vc.ru / >50 на Reddit
                + obligatory: voice_type = "gold_voc" (не pundit с большим лайком)
                (для hero-блока лендинга — внутренний скоринг)
  🟡 SIGNAL   = unique_sources = 2 OR evidence = 3-4 (требует custdev в Phase C)
  🔴 BACKLOG  = unique_sources = 1 (только клиент или один источник)

⚠️ ⚠️ ⚠️ ОБЯЗАТЕЛЬНЫЙ GATE — перед формированием GOLD кластеров:
  gold_voc_count = count(citations where tag == "gold_voc")
  diversity_check = source_type который доминирует — должен быть < 50% от всего gold_voc

  if gold_voc_count < 25:
    STOP. Эскалация владельцу:
    «GOLD-VoC цитат мало (N=X из ≥25). Это значит копал не там — слишком много
     pundit/statistic. 3 варианта (через AskUserQuestion):
       a) Перезапустить субагентов 1+3+5 с фокусом на YouTube/TG/IG комменты
          конкурентов (+45 мин)
       b) Добавить нишевые форумы которых не было в первой сборке (b17 / profi
          / kursometr / нишевые Reddit-сабреддиты) (+30 мин)
       c) Принять тонкий VoC и идти в Phase C с пометкой "ограниченный"»

  if dominant_source_type > 50%:
    STOP. Эскалация:
    «Источники не диверсифицированы — {X}% цитат с одного типа источника
     ({source_type}). Это bias. Нужно докопать с других площадок чтобы
     {X} стало < 50%.»

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
❌ **Пропустить gate <25 gold_voc** — тонкий VoC просочится в Phase C, клиент валидирует мусор.
❌ **Семантическая кластеризация без Шага 7 (manual review)** — рискуем 3 синонима как 3 кластера.

🚨 🚨 🚨 **СОБИРАТЬ PUNDIT ВМЕСТО VoC** (главный fail апреля 2026):

❌ Принимать аналитические посты экспертов на vc.ru как «голос ЦА». Признаки PUNDIT:
   - Заголовок «Почему 73% психологов...» / «Перфекционизм — это латентная прокрастинация» — это аналитика, не голос
   - Автор — журналист / маркетолог-блогер / CEO большой компании
   - Тон рассуждающий, не жалующийся
   - Третье лицо или обобщения («предприниматели обычно», «эксперты считают»)

❌ Включать статистику (McKinsey, % опросов) как цитаты болей. Статистика → market-stats.md, не VoC.

❌ vc.ru-однобокость — если >50% цитат с одного source_type, это bias. Диверсификация источников ОБЯЗАТЕЛЬНА:
   - Минимум 30% gold_voc должны быть из comments под контентом конкурентов (YouTube/TG/IG)
   - Минимум 20% — из нишевых форумов (b17/profi/kursometr/Reddit-сабреддиты)
   - Не больше 50% — с одного типа источника

❌ Игнорировать комменты под видео конкурентов в YouTube — там **золотой пласт** реальных экспертов которые пишут про свои реальные боли в первом лице. Без этого источника Phase B неполная.

**Правило перед финалом:** прогони все цитаты через 3 теста (`voc-quality-rules.md` Шаг 3.5 Match-методики). Если gold_voc < 25 — STOP, эскалация, перекапывай с правильным фокусом.

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

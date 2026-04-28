# Audience — главный орган Stage 1

🧠 Здесь живёт всё что мы знаем о ЦА. Это **главная папка** Stage 1.

## Структура (наполняется работой Алекса)

```
audience/
├── INDEX.md                          (этот файл)
├── voice-of-customer.md              🔥 голос ЦА (цитаты с источниками — append only)
├── research/
│   └── transcripts/                  кастдев, опросы, выступления — сырые транскрипты
└── segments/                         создаётся при /audience-stage
    ├── NORTH-STAR.md                 ⭐ ТОП-3 сегмента — главный артефакт Stage 1
    ├── segments-map.md               backlog отвергнутых гипотез + 7-осевой scoring
    ├── _archive/                     отвергнутые сегменты с пояснением
    └── {slug}/                       папка на каждый ТОП-сегмент
        ├── segment-core.md           ядро + lingvo (4 правила) + Quotes & Vocabulary
        ├── segment-portrait.md       БПСВ + 7 блоков интервью + awareness (цвета 4)
        ├── voice-of-segment.md       30-50 цитат с источниками (Phase B)
        └── segment-observations.md   живые наблюдения (пятничная ревизия)
```

## Главные артефакты на выходе

1. **`segments/NORTH-STAR.md`** — одна страница с ТОП-3 сегментами + anti-avatar. Главный артефакт всей Stage 1.
2. **`segments/{slug}/segment-portrait.md`** × N — глубокая распаковка каждого сегмента + цветовая схема.
3. **`segments/{slug}/segment-core.md`** × N — рабочий one-pager сегмента + язык клиента + Hero-формула.
4. **`segments/{slug}/voice-of-segment.md`** × N — 30-50 цитат, лингво × 5 категорий, метафоры, конкуренты.
5. **`voice-of-customer.md`** — общий банк цитат с источниками и таймкодами.

## Скиллы (Алекс)

| Скилл | Когда | Output |
|-------|-------|--------|
| `/audience-stage` | Полная распаковка (Phase A→B→C→D) | NORTH-STAR + portrait + core + voice |
| `/audience-awareness-lite {slug}` | Углубление одного сегмента | `{slug}/segment-core.md` + Hero-формула |
| `/competitors-research` | Перед или после audience-stage | `intel/competitors-{slug}/` |
| `/revise-segment` | Пятница 16:00 | `segment-observations.md` → `segment-portrait.md` → `segment-core.md` |

## Связь с тестами

| Тег H | Обновляет |
|-------|-----------|
| `[ICP]` | `NORTH-STAR.md` |
| `[SEGMENT]` | `{slug}/segment-core.md` или `segment-portrait.md` |
| `[MESSAGE]` | `voice-of-customer.md` (как ссылка на цитату-якорь) |

## VoC — голос ЦА

`voice-of-customer.md` собирается из любых источников:
- Комментарии под постами и в чатах
- Реплики из транскриптов интервью / кастдев
- Скриншоты переписок с лидами
- Опросы и formы
- Цитаты из выступлений / подкастов

Каждая запись с указанием источника и (если применимо) таймкода. Append only — Алекс не перезаписывает старые цитаты.

## Что в этой папке НЕ хранится

- ❌ Продуктовые гипотезы (про оффер, цену, ladder) — это Stage 2
- ❌ Воронки и каналы — Stage 3
- ❌ Позиционирование и голос бренда — Stage 4
- ❌ Карточки клиентов с диагностиками — модуль `sales-meetings`

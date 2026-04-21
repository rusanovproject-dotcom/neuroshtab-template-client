# Brand References Catalog — 30 эталонных брендов

Каталог брендов для которых есть готовые DESIGN.md через `npx getdesign@latest add {slug}`. Источник: VoltAgent/awesome-design-md (MIT) + сервис getdesign.md.

**Как использовать:**
1. Клиент говорит «хочу как [название]» / «в стиле [бренд]»
2. Ищешь в таблице — есть ли бренд
3. Если есть → запускаешь skill `brand-reference` (он вызовет `npx getdesign@latest add {slug}`)
4. Если нет → skill `site-extract` (через dembrandt CLI)

**Slug** — то что подставляется в команду `npx getdesign@latest add {slug}`.

---

## AI / Dev Tools

| Бренд | slug | Стиль (1-2 строки) | Лучше для |
|-------|------|---------------------|-----------|
| **Claude** | `claude.ai` | тёплый off-white, охра акцент, serif-touches, «книжный AI» | AI-продукты с человеческим лицом |
| **Cursor** | `cursor` | dark, code-aesthetic, subtle glow, monospace touches | dev tools, AI-editors |
| **Vercel** | `vercel` | black/white максимальный контраст, monospace accents, clean grids | dev tools, deploy, hosting, tech brands |
| **Supabase** | `supabase` | dark + emerald-green accent, code-friendly, open-source вайб | DB, backend, dev tools |
| **Linear** | `linear.app` | ultra-minimal dark, фиолетовый accent, precision typography | project management, SaaS, tools |
| **PostHog** | `posthog` | dark dev-tool, orange accent, open-source energy | analytics, dev tools |
| **Sentry** | `sentry` | dark purple, serious developer-grade | monitoring, error tracking |
| **Replit** | `replit` | playful orange, dark canvas, коллаборативный вайб | coding education, online IDE |
| **Railway** | `railway` | ultra-minimal white+black, subtle color touches | infrastructure, deploy |
| **Anthropic** | `anthropic.com` | cream off-white, охра и coral, literary serif | AI research, thoughtful products |

## SaaS / Productivity

| Бренд | slug | Стиль | Лучше для |
|-------|------|-------|-----------|
| **Notion** | `notion` | clean white, soft shadows, comfortable reading, Inter-like | productivity, docs, knowledge base |
| **Airtable** | `airtable` | красочные accent chips + clean white, bento-style | database apps, CRM, organizers |
| **Intercom** | `intercom` | purple SaaS, conversational warmth | support, CRM, communication |
| **Cal.com** | `cal` | минимал scheduling, clean whites, subtle gradient | booking, scheduling, SaaS |
| **Zapier** | `zapier` | orange-first, friendly automation, approachable | automation, no-code, integrations |
| **Superhuman** | `superhuman` | premium black + red, sharp typography | premium productivity, email |
| **Slack** | `slack` | aubergine primary, playful accents | communication, teams |

## Design / Creative Tools

| Бренд | slug | Стиль | Лучше для |
|-------|------|-------|-----------|
| **Figma** | `figma` | component-first, multi-color accents, professional | design tools, SaaS |
| **Framer** | `framer` | motion-forward, dark creative, bold typography | design tools, portfolio, creative |
| **Webflow** | `webflow` | gradient rich, creative agency vibe | no-code, design, creative |
| **Lovable** | `lovable` | purple playful, AI-forward, soft | AI apps, vibe coding, startups |

## Fintech / Commerce

| Бренд | slug | Стиль | Лучше для |
|-------|------|-------|-----------|
| **Stripe** | `stripe` | purple gradient, weight-300 elegance, precision | fintech, payment, premium SaaS |
| **Revolut** | `revolut` | dark + neon, fintech-modern, bold | fintech, banking, consumer finance |
| **Wise** | `wise` | green-first, friendly, trust-focused | fintech, transfer, accessible finance |

## Premium Consumer / Media

| Бренд | slug | Стиль | Лучше для |
|-------|------|-------|-----------|
| **Apple** | `apple` | white space king, SF Pro, premium restraint | premium consumer, hardware, lifestyle |
| **Spotify** | `spotify` | black + neon green, bold typography, dark mode | media, entertainment, audio products |
| **Airbnb** | `airbnb` | warm photography, soft coral, hospitality | marketplace, travel, lifestyle |
| **Tesla** | `tesla` | ultra-minimal, white space, engineering aesthetic | EV, premium, tech hardware |

## Automotive / Aerospace

| Бренд | slug | Стиль | Лучше для |
|-------|------|-------|-----------|
| **BMW** | `bmw` | black/white/blue, precision luxury | automotive, premium hardware |
| **SpaceX** | `spacex` | black/white minimal, monospace, dramatic | tech, aerospace, hardware |

---

## Quick picks по задаче

**«Хочу дашборд в стиле SaaS»** → посмотри: Linear, Notion, Cal.com. Возьми один.

**«Хочу premium-лендинг без AI-слопа»** → Stripe, Apple, Tesla. Очень мало элементов, огромный воздух.

**«Хочу dev-tool с тёмной темой»** → Vercel, Cursor, Linear, Supabase.

**«Хочу warm+human AI-продукт»** → Claude / Anthropic. Off-white, serif touches, охра.

**«Хочу playful consumer-app»** → Spotify, Airbnb, Lovable, Replit.

**«Хочу fintech»** → Stripe (premium) / Revolut (modern) / Wise (friendly).

**«Хочу productivity / tool»** → Notion, Superhuman, Linear, Cal.com.

---

## Fallback

Если бренда нет в этом каталоге:
1. Попробовать через **site-extract** skill (`npx dembrandt {url}`)
2. Если сайт упал / npx недоступен — попроси клиента описать словами (mood, палитра, 3 пункта что цепляет)

---

## Что делает getdesign CLI

Команда `npx getdesign@latest add {slug}` создаёт в текущей директории файл `DESIGN.md` с 9 секциями (по стандарту Google Stitch):
1. Visual Theme
2. Color Palette
3. Typography Rules
4. Component Stylings
5. Layout Principles
6. Depth & Elevation
7. Do's and Don'ts
8. Responsive Behavior
9. **Agent Prompt Guide** ← эта секция встраивается в промт

---

*Источник: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (MIT License). Файлы доступны через [getdesign.md](https://getdesign.md) — сервис VoltAgent. Описания стилей составлены на основе публичных материалов брендов.*

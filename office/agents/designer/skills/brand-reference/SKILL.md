---
name: brand-reference
description: Загрузить готовую дизайн-систему известного бренда (Linear, Stripe, Vercel, Notion и др.) через getdesign CLI. Использовать когда клиент говорит "хочу как Linear / в стиле Stripe". TRIGGERS — "хочу как [бренд]", "в стиле [название]", "как у [сайт]", ссылка в каталоге brand-references-catalog.md.
---

# brand-reference — загрузка эталонного бренда

## Когда запускать
- Клиент: «хочу как Linear» / «в стиле Stripe» / «как Notion»
- Нужна проверенная дизайн-система топ-бренда как отправная точка

## Что делает
Использует CLI **getdesign.md** (источник: VoltAgent/awesome-design-md, MIT) — одной командой загружает готовый DESIGN.md любого из 69 эталонных брендов.

## Шаги

1. Открой `knowledge/brand-references-catalog.md` — найди нужный бренд и его slug
2. Если нет в каталоге — попробуй как есть или предложи `site-extract` для произвольного URL
3. Запусти: `npx getdesign@latest add {slug} --output knowledge/brand/{project}/references/{slug}.md`
4. Прочитай DESIGN.md
5. Покажи клиенту ключевые элементы (палитра, типографика, настроение)
6. Спроси: *«Берём как есть за основу Brand Book, или адаптируем под твою нишу?»*

## Примеры slug (полный список — brand-references-catalog.md)
- `linear` — Linear: dark, монохром + zinc, Inter, монументальная строгость
- `stripe` — Stripe: белый + иридисцент-градиенты, Söhne, финтех-премиум
- `vercel` — Vercel: чёрный/белый, Geist, минимализм с юмором

## Output
Готовый DESIGN.md лежит в `knowledge/brand/{project}/references/`. Дальше Designer использует его как базу для Brand Book клиента.

## Fallback
Если бренда нет в каталоге → `site-extract` через dembrandt CLI на URL бренда.

# Failures
> Пополняется после каждой сборки

---

## 2026-03-22: Перенаправления в references/

**What:** references/ в build-team содержали файлы-перенаправления ("Основная версия: knowledge/..."). Claude читал redirect, потом шёл в knowledge/ -- два шага вместо одного.
**Why:** Казалось что redirect лучше чем дублирование. Но на практике redirect = лишний шаг + путаница. Прямые пути в SKILL.md лучше.
**Fix:** Удалены references/, в SKILL.md прямые пути на knowledge/.

## 2026-03-22: DEPRECATED но всё ещё доступен

**What:** skills/architect/ помечен DEPRECATED.md, но файлы оставались на месте. Brahma провёл аудит именно по нему (устаревшей копии) и дал 62/100.
**Why:** Одна метка DEPRECATED недостаточна. Нужно удалять содержимое или заменять редиректом.
**Fix:** Удалены references/, scripts/, assets/. SKILL.md заменён на redirect.

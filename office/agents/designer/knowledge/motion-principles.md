# Motion Principles — библия анимаций для Designer

Дистиллят из LottieFiles/motion-design-skill (MIT). Цель — заменить «smooth animations» и «subtle transitions» в промтах на конкретные миллисекунды, easing-кривые и правила хореографии. Читай ДО того, как написать хоть одно слово про анимацию.

**Ключевое правило:** если в промте стоит «smooth / subtle / nice / flowing / elegant animations» — промт недописан. Открывай этот файл, бери цифры.

---

## 1. Timing — сколько длится что

### Базовые диапазоны по типу элемента

| Элемент | Duration | Почему |
|---------|----------|--------|
| Tooltip / badge / micro-feedback | **80-120ms** | быстрее = мерцание, медленнее = лаг |
| Button / icon hover, toggle | **120-180ms** | моментальный отклик на касание |
| Dropdown / accordion / tab | **200-300ms** | показать что именно двинулось |
| Modal / dialog / sheet | **300-400ms** | тяжёлый элемент, нужна масса |
| Page transition / hero reveal | **400-600ms** | смена контекста, дать глазу успеть |
| Onboarding / empty state story | **600-1200ms** | рассказ, не UI |

### Масштаб расстояния (distance-based scaling)

Чем дальше едет элемент — тем дольше. Множитель к базовому duration:
- 50px движение → **0.8×**
- 200px движение → **1.0×**
- 500px (половина экрана) → **1.5×**
- Full screen → **2.0×**

### Interactive feedback latency (жёсткие пределы)

| Событие | Max latency |
|---------|-------------|
| Hover response | **<100ms** |
| Tap feedback | **<150ms** |
| Drag initiation | **<50ms** |

Медленнее — воспринимается как лаг.

---

## 2. Easing — какие кривые брать

### Направление (строго)

```
entrance → ease-out          (быстрое начало, мягкое окончание)
exit     → ease-in           (мягкий старт, быстрый уход)
on-screen → ease-in-out       (плавно в обе стороны)
looping  → sine              (непрерывное дыхание)
linear progress / rotation → linear (только для прогресса и вращения)
```

**Никогда:** linear для spatial movement (движение позиции). Это мёртвая анимация.

### Стандартные cubic-bezier (готовые значения)

| Кривая | Значения | Когда |
|--------|----------|-------|
| MD3 Standard | `cubic-bezier(0.2, 0, 0, 1)` | on-screen motion, дефолт для UI |
| MD3 Emphasized | `cubic-bezier(0.05, 0.7, 0.1, 1)` | важные entrance (hero, modal) |
| MD3 Accelerate | `cubic-bezier(0.3, 0, 1, 1)` | exit, закрытие |
| Apple Default | `cubic-bezier(0.25, 0.1, 0.25, 1)` | спокойный премиум-стиль |
| Playful Back | `cubic-bezier(0.68, -0.55, 0.27, 1.55)` | с overshoot, «бумс» в конце |

### Spring (если стек поддерживает Framer Motion / Motion One)

- Standard feel: stiffness **250-350**, damping **18-24**
- Bouncy: stiffness 180, damping 12
- Stiff (premium, без колебаний): stiffness 400, damping 30

---

## 3. Motion Personality — 4 архетипа

Выбирай один архетип на проект и применяй консистентно. Определяется Brand Book (mood).

| Архетип | Duration | Easing | Overshoot | Keywords | Когда |
|---------|----------|--------|-----------|----------|-------|
| **Playful** | 150-300ms | ease-out-back | 10-20% | fun, whimsical, bouncy, cute | дети, геймификация, креатив |
| **Premium** | 350-600ms | cubic-bezier(0.4,0,0.2,1) | 0% | elegant, minimal, luxury, sophisticated | премиум-услуги, luxury, B2B enterprise |
| **Corporate** | 200-400ms | cubic-bezier(0.2,0,0,1) | 0-3% | clean, professional, dashboard | SaaS, fintech, B2B, dashboards |
| **Energetic** | 100-250ms | ease-out-expo | 15-30% | dynamic, bold, exciting | спорт, стартапы, бунтарский бренд |

**Дефолт:** Corporate для UI, Playful для иллюстраций.

---

## 4. Stagger — как пускать несколько элементов

### Паттерны

| Паттерн | Delay между элементами | Total | Когда |
|---------|------------------------|-------|-------|
| Micro cascade | 20-40ms | <200ms | маленькие списки, иконки |
| Standard | 50-100ms | <400ms | карточки, список постов (дефолт) |
| Dramatic | 100-200ms | <500ms | hero reveal, 3-4 главных элемента |

**Жёсткое правило:** total stagger duration **<500ms**. Дольше — скучно, теряется связность.

### Техники stagger

- **Sequential** — в порядке чтения (лево→право, верх→низ). Для списков и грид-лейаутов.
- **Center-out** — от центра наружу. Для hero-блоков.
- **Random** — варьирующий delay. Для «органики» (частицы, confetti).
- **Wave** — sine-прогрессия. Для data viz (графики, bars).
- **Reverse** — снизу вверх. Для exit и back-навигации.

**Правило:** все stagger-элементы используют **одну** easing-кривую. Варьируется только start time.

---

## 5. Хореография — правило 1/3

### Правило 1/3 для расстояния
> No motion travels >1/3 screen without an intermediate keyframe.

Если элемент летит через весь экран — разбей на 2 фазы: ease-out до 1/3, пауза или смена скорости, ease-in-out до конца.

### Правило 1/3 для одновременности
> Не более 1/3 элементов анимирует одновременно.

Если на экране 12 карточек — максимум 4 в движении. Остальные уже приехали или ещё ждут. Достигается через stagger.

### Three-phase formula

Любая сложная анимация = 3 фазы:
1. **Setup (20-30%)** — элементы заходят, сцена собирается
2. **Action (30-40%)** — главный момент, hero motion
3. **Resolution (30-40%)** — оседание, вторичные реакции, воздух

Пример: page entrance 600ms → setup 150ms, action 250ms, resolution 200ms.

### Паузы между блоками
- **100-200ms stillness** после resolution перед следующим motion-блоком.
- Если несколько элементов реагируют на один триггер — все стартуют **в течение 50ms** друг от друга (воспринимается как «одновременно»), но приземляются в разное время через stagger.

---

## 6. Disney-принципы (адаптированные для UI)

12 принципов Disney в параметрах для промта. Не все обязательны — бери те что подходят по Motion Personality.

### 1. Squash & Stretch
- Scale: **[1.2, 0.8]** для сжатия, **[0.85, 1.15]** для растяжения
- Impact 2-4 frames (**30-65ms**)
- Recovery 4-8 frames
- Объём сохраняется: ширина +20% → высота −20%

### 2. Anticipation
- Pre-action **100-200ms**, 10-20% амплитуды в ПРОТИВОположном направлении
- Кнопка сжимается на 3% перед раскрытием
- Карточка сдвигается на 5-10px назад перед полётом вперёд
- **Пропускать** для micro-feedback <150ms (не успеет восприняться)

### 3. Staging
- Второстепенные элементы: opacity **40-60%**, blur 2-4px
- Primary входит **100-200ms** ПОСЛЕ supporting content
- Одно главное действие на один timing beat

### 4. Straight Ahead vs Pose to Pose
- **Straight ahead** — частицы, ambient эффекты (живое, непредсказуемое)
- **Pose to pose** — UI-переходы, состояния (контролируемо)

### 5. Follow Through & Overlapping
- Второстепенные элементы отстают на **50-150ms**
- Trailing parts — offset **100-200ms**
- Spring с пониженной stiffness усиливает эффект

### 6. Slow In & Slow Out
- Entrance → ease-out
- Exit → ease-in
- On-screen → ease-in-out
- **Никогда** linear для spatial

### 7. Arcs
- Перпендикулярный offset **10-20px** в середине пути
- Corporate — 5px, Playful — 20px+
- Mechanical UIs могут использовать прямые пути намеренно

### 8. Secondary Action
- Amplitude 30-50% от primary
- Timing начинается **50-100ms** после primary
- Другая easing для контраста

### 9. Timing (переопределение базовых)
- Heavy (modals, pages): **400-800ms**
- Light (tooltips, toggles): **100-250ms**
- Happy mood: 200-400ms
- Urgent actions: 100-200ms
- **Entrance на 30-50% длиннее exit**

### 10. Exaggeration (по Motion Personality)
| Mood | Exaggeration |
|------|--------------|
| Premium | 0% |
| Corporate | 0-5% |
| Playful | 15-25% |
| Energetic | 20-30% |

- Scale overshoot: 10-30%
- Rotation: ±5-15°

### 11. Solid Drawing
- Консистентные пропорции в keyframes
- Scale + rotation вместе создают глубину
- Shadow ведёт себя по направлению света

### 12. Appeal
- Плавные кривые > резкие углы
- Консистентность personality важнее «интересности»
- Избегай: jerky motion, резкие стопы, uniform animation (одна и та же скорость везде)

---

## 7. 8-шаговый чеклист перед любой анимацией

Перед тем как писать анимационный параметр в промте — пройди:

1. **Emotional target?** — joy / calm / urgency / elegance
2. **Motion Personality?** — Playful / Premium / Corporate / Energetic (из Brand Book mood)
3. **Primary property?** — position / scale / rotation / opacity (обычно одно главное)
4. **Duration?** — из таблицы секции 1
5. **Easing family?** — entrance=decelerate / exit=accelerate
6. **Hero element?** — применяй staging (фокус + затемнение фона)
7. **Secondary + ambient layers?** — overlapping action + follow through
8. **1/3 rules?** — расстояние и одновременность

---

## 8. Как использовать в промте — шаблон

Вместо:
> «Add subtle smooth animations, nice transitions between sections.»

Пиши:
> «Motion personality: Corporate. Duration scale: 200-400ms. Easing: cubic-bezier(0.2, 0, 0, 1) for all on-screen motion. Stagger reveal for cards: 50ms delay sequential, fade+translateY 8px, ease-out 300ms. Hover on cards: scale 0.98→1, transition 120ms ease-out. Page entrance: hero fade+translateY 24px 400ms, then stagger supporting content 80ms between blocks, total <600ms. No linear easing for any spatial movement.»

Разница: первый — AI-слоп. Второй — промт которого достаточно чтобы результат был предсказуем.

---

## 9. Anti-patterns — чего не делать

- **Linear easing для движения позиции** → мёртво
- **Entrance и exit одной длительности** → exit должен быть 30-50% быстрее
- **>1/3 screen travel без keyframe** → ломает восприятие расстояния
- **>1/3 элементов одновременно в движении** → глаз не знает куда смотреть
- **Total stagger >500ms** → затягивает, теряется ритм
- **Overshoot для Premium-бренда** → режет эстетику
- **Uniform timing на весь лендинг** → всё плывёт одинаково, скука
- **Копипаст «smooth / nice / subtle» в промт** → недописано, переделай с числами

---

*Источник: [LottieFiles/motion-design-skill](https://github.com/LottieFiles/motion-design-skill) (MIT License). Адаптировано: дистиллят для промт-агента без кода, под Designer-агента.*

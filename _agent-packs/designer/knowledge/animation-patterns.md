---
title: "Справочник анимаций: Motion + GSAP — рабочие сниппеты"
updated: 2026-05-13
owner: Designer
---

# Справочник анимаций

Все сниппеты — рабочий код. Copy-paste в проект, адаптируй цвета/радиусы под Brand Book.

---

## 1. Entrance-анимации (Motion)

### Fade Up (основная для всего)
```tsx
"use client";
import { motion } from "motion/react";

export function FadeUp({ children, delay = 0 }: { children: React.ReactNode; delay?: number }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 24 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-100px" }}
      transition={{ duration: 0.6, delay, ease: [0.21, 0.47, 0.32, 0.98] }}
    >
      {children}
    </motion.div>
  );
}
```

### Scale In (для карточек, иконок)
```tsx
<motion.div
  initial={{ opacity: 0, scale: 0.9 }}
  whileInView={{ opacity: 1, scale: 1 }}
  viewport={{ once: true }}
  transition={{ duration: 0.5, ease: "easeOut" }}
/>
```

### Slide In (сбоку)
```tsx
// Слева
<motion.div
  initial={{ opacity: 0, x: -40 }}
  whileInView={{ opacity: 1, x: 0 }}
  viewport={{ once: true }}
  transition={{ duration: 0.6 }}
/>

// Справа
<motion.div
  initial={{ opacity: 0, x: 40 }}
  whileInView={{ opacity: 1, x: 0 }}
  viewport={{ once: true }}
  transition={{ duration: 0.6 }}
/>
```

### Blur Fade (premium появление)
```tsx
<motion.div
  initial={{ opacity: 0, y: 16, filter: "blur(8px)" }}
  whileInView={{ opacity: 1, y: 0, filter: "blur(0px)" }}
  viewport={{ once: true }}
  transition={{ duration: 0.7, ease: "easeOut" }}
/>
```

---

## 2. Stagger-анимации (списки, карточки)

### Stagger через variants
```tsx
"use client";
import { motion } from "motion/react";

const container = {
  hidden: {},
  show: {
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
};

const item = {
  hidden: { opacity: 0, y: 24 },
  show: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.5, ease: [0.21, 0.47, 0.32, 0.98] },
  },
};

export function StaggerList({ items }: { items: string[] }) {
  return (
    <motion.ul
      variants={container}
      initial="hidden"
      whileInView="show"
      viewport={{ once: true }}
      className="grid grid-cols-1 md:grid-cols-3 gap-6"
    >
      {items.map((text, i) => (
        <motion.li key={i} variants={item} className="p-6 rounded-2xl bg-white/45 backdrop-blur-xl border">
          {text}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

### Stagger цифр (для статистики)
```tsx
const numberContainer = {
  hidden: {},
  show: { transition: { staggerChildren: 0.15 } },
};

const numberItem = {
  hidden: { opacity: 0, scale: 0.5 },
  show: { opacity: 1, scale: 1, transition: { type: "spring", stiffness: 200 } },
};
```

---

## 3. Hover-анимации

### Подъём + тень (карточки)
```tsx
<motion.div
  whileHover={{ y: -4, boxShadow: "0 20px 40px rgba(0,0,0,0.08)" }}
  transition={{ duration: 0.2 }}
  className="p-6 rounded-2xl bg-white/45 backdrop-blur-xl border shadow-sm"
/>
```

### Scale + glow (кнопки)
```tsx
<motion.button
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  className="px-8 py-3 rounded-full bg-gradient-to-r from-indigo-500 to-purple-500 text-white
             hover:shadow-[0_0_30px_rgba(99,102,241,0.4)] transition-shadow"
/>
```

**Подмени цвета на палитру Brand Book пользователя.**

### Border glow (карточки)
```tsx
<motion.div
  whileHover={{ borderColor: "rgba(99,102,241,0.5)" }}
  className="p-6 rounded-2xl border transition-colors"
/>
```

### Magnetic button (тянется к курсору)
```tsx
"use client";
import { motion, useMotionValue, useSpring } from "motion/react";
import { useRef } from "react";

export function MagneticButton({ children }: { children: React.ReactNode }) {
  const ref = useRef<HTMLDivElement>(null);
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const springX = useSpring(x, { stiffness: 300, damping: 20 });
  const springY = useSpring(y, { stiffness: 300, damping: 20 });

  const handleMouse = (e: React.MouseEvent) => {
    const rect = ref.current?.getBoundingClientRect();
    if (!rect) return;
    x.set((e.clientX - rect.left - rect.width / 2) * 0.15);
    y.set((e.clientY - rect.top - rect.height / 2) * 0.15);
  };

  return (
    <motion.div
      ref={ref}
      onMouseMove={handleMouse}
      onMouseLeave={() => { x.set(0); y.set(0); }}
      style={{ x: springX, y: springY }}
    >
      {children}
    </motion.div>
  );
}
```

---

## 4. Scroll-анимации (GSAP)

### Базовый ScrollTrigger
```tsx
"use client";
import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export function ScrollSection() {
  const sectionRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;

    gsap.from(el.querySelectorAll(".animate-item"), {
      y: 60,
      opacity: 0,
      duration: 0.8,
      stagger: 0.15,
      ease: "power2.out",
      scrollTrigger: {
        trigger: el,
        start: "top 80%",
        end: "bottom 20%",
        toggleActions: "play none none none",
      },
    });

    return () => ScrollTrigger.getAll().forEach(t => t.kill());
  }, []);

  return <div ref={sectionRef}>...</div>;
}
```

### Pin секцию при скролле
```tsx
useEffect(() => {
  gsap.to(".pinned-content", {
    scrollTrigger: {
      trigger: ".pin-section",
      start: "top top",
      end: "+=200%",
      pin: true,
      scrub: 1,
    },
    x: "-200%", // Горизонтальный скролл пиннутой секции
  });
}, []);
```

### Parallax при скролле
```tsx
useEffect(() => {
  gsap.to(".parallax-bg", {
    y: "-30%",
    ease: "none",
    scrollTrigger: {
      trigger: ".parallax-section",
      start: "top bottom",
      end: "bottom top",
      scrub: true,
    },
  });
}, []);
```

### Scrub-анимация (прогресс привязан к скроллу)
```tsx
useEffect(() => {
  const tl = gsap.timeline({
    scrollTrigger: {
      trigger: ".scrub-section",
      start: "top center",
      end: "bottom center",
      scrub: 0.5,
    },
  });

  tl.from(".step-1", { opacity: 0, x: -50 })
    .from(".step-2", { opacity: 0, x: 50 })
    .from(".step-3", { opacity: 0, y: 50 });
}, []);
```

### Batch (много элементов)
```tsx
useEffect(() => {
  ScrollTrigger.batch(".batch-item", {
    onEnter: (batch) =>
      gsap.to(batch, { opacity: 1, y: 0, stagger: 0.1, duration: 0.5 }),
    start: "top 85%",
  });

  // Начальное состояние
  gsap.set(".batch-item", { opacity: 0, y: 40 });
}, []);
```

---

## 5. Lenis Smooth Scroll

### Подключение (layout.tsx или provider)
```tsx
"use client";
import { useEffect } from "react";
import Lenis from "lenis";

export function SmoothScrollProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      smoothWheel: true,
    });

    function raf(time: number) {
      lenis.raf(time);
      requestAnimationFrame(raf);
    }
    requestAnimationFrame(raf);

    // Синхронизация с GSAP ScrollTrigger
    lenis.on("scroll", ScrollTrigger.update);
    gsap.ticker.add((time) => lenis.raf(time * 1000));
    gsap.ticker.lagSmoothing(0);

    return () => lenis.destroy();
  }, []);

  return <>{children}</>;
}
```

---

## 6. Микро-интеракции

### Переключатель (toggle)
```tsx
<motion.div
  className="w-12 h-6 rounded-full bg-slate-200 p-1 cursor-pointer"
  onClick={() => setOn(!on)}
  animate={{ backgroundColor: on ? "#6366f1" : "#e2e8f0" }}
>
  <motion.div
    className="w-4 h-4 rounded-full bg-white"
    animate={{ x: on ? 24 : 0 }}
    transition={{ type: "spring", stiffness: 500, damping: 30 }}
  />
</motion.div>
```

### Loader (три точки)
```tsx
<motion.div className="flex gap-1">
  {[0, 1, 2].map((i) => (
    <motion.div
      key={i}
      className="w-2 h-2 rounded-full bg-indigo-500"
      animate={{ y: [0, -8, 0] }}
      transition={{ duration: 0.6, repeat: Infinity, delay: i * 0.15 }}
    />
  ))}
</motion.div>
```

### Page transition (App Router)
```tsx
// В layout или template:
<motion.div
  initial={{ opacity: 0, y: 8 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.3 }}
>
  {children}
</motion.div>
```

---

## 7. Когда что использовать

| Тип анимации | Инструмент | Почему |
|-------------|-----------|--------|
| Появление элемента | Motion `whileInView` | Декларативно, просто |
| Hover/tap | Motion `whileHover`/`whileTap` | Встроено |
| Stagger списков | Motion `variants` + `staggerChildren` | Чисто, переиспользуемо |
| Scroll-triggered | GSAP ScrollTrigger | Мощнее, timeline |
| Pin при скролле | GSAP ScrollTrigger `pin` | Только GSAP это умеет |
| Parallax | GSAP ScrollTrigger `scrub` | Привязка к скроллу |
| Smooth scroll | Lenis | Стандарт 2026 |
| Spring физика | Motion `type: "spring"` | Естественное движение |
| Complex timeline | GSAP `gsap.timeline()` | Последовательности |

## Easing

| Easing | Когда | Значение |
|--------|-------|----------|
| Custom bezier | Основной для всего | `[0.21, 0.47, 0.32, 0.98]` |
| easeOut | Входы | `"easeOut"` |
| Spring | Кнопки, интерактив | `{ type: "spring", stiffness: 300, damping: 25 }` |
| Power2.out | GSAP входы | `"power2.out"` |
| None | Scrub/parallax | `"none"` |

## Длительности

| Элемент | Duration |
|---------|----------|
| Hover | 0.2s |
| Button tap | 0.1s |
| Fade in | 0.5–0.7s |
| Slide in | 0.6s |
| Stagger delay | 0.1–0.15s |
| Page transition | 0.3s |
| Scroll section | 0.8–1.0s |

---

## Связка с `motion-principles.md`

Этот файл — **рабочие сниппеты**. Принципы хореографии, easing-кривые, правила «когда что двигается» — в `motion-principles.md`. Перед написанием анимации читай оба: сниппет даёт код, принципы дают смысл.

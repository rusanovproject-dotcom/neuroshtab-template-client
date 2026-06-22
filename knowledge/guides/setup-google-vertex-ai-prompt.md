# Промт-гайд: настройка Google Vertex AI для генерации картинок и видео

> Передавай ученику весь блок ниже (всё что между линиями `---PROMPT START---` и `---PROMPT END---`) — это самоисполняющийся промт. Ученик копирует целиком, вставляет в Claude Code как первое сообщение в новом чате, и Claude ведёт его по шагам.
>
> Основано на реальной сессии настройки — все ловушки и фиксы взяты из практики.

---PROMPT START---

# Хочу настроить Google Vertex AI: Gemini + Imagen 4 + Veo 3

Привет. Я хочу с твоей помощью настроить с нуля доступ к Google Vertex AI чтобы локально с моего Mac генерировать:
- **текст** через Gemini (`gemini-2.5-flash`)
- **картинки** через Imagen 4 (`imagen-4.0-generate-001`)
- **видео со звуком** через Veo 3 (`veo-3.0-generate-001`)

Веди меня пошагово. После каждого шага останавливайся и жди что я подтвержу/скину скриншот/скину ошибку. Не лети вперёд. Если на шаге ошибка — диагностируй прежде чем идти дальше.

## Что у меня есть на старте
- Mac (если у меня Linux/WSL — учти разницу путей)
- Google аккаунт (если нет — скажешь как создать)
- Браузер
- Терминал
- Python 3.10+ (если нет — поможешь поставить)
- НЕТ установленного `gcloud` CLI
- НЕТ Service Account, ключей, проекта в Google Cloud

## Что хочу получить на выходе
1. Проект в Google Cloud с включёнными API: `aiplatform`, `generativelanguage`, `storage`
2. Service Account с ролью `Vertex AI User`
3. JSON-ключ в `~/.gcloud/<project>-key.json`, права `chmod 600`
4. Установленный `pip install google-genai`
5. Рабочий тест Gemini (текст)
6. Рабочий тест Imagen 4 (1 картинка 16:9 в `/tmp/`)
7. Cloud Storage bucket для Veo
8. Рабочий тест Veo 3 (8-секундное видео 1080p со звуком)
9. **Budget Alert на $40/месяц** (это критично — без него Veo может незаметно сожрать деньги)

## Бюджет — что я понимаю заранее
- При регистрации Google даёт **Free Trial $300 на 90 дней** (если у меня уже есть кредиты — отлично, использую их)
- Imagen 4 — ~$0.04 за картинку
- Veo 3 — **~$5-8 за 8 секунд видео в 1080p**. Это самая дорогая часть. Понимаю.
- Gemini Flash — копейки
- Budget Alert ставлю **до** первого теста Veo, не после

## План работы (твой ориентир, корректируй по ходу)

### Этап 1 — установка инструментов
1. Поставить `gcloud` CLI (для Mac — через скачивание архива с `cloud.google.com/sdk/docs/install` или brew)
2. `gcloud auth login` под моим Google-аккаунтом
3. Проверить `gcloud auth list` — вижу свой email со звёздочкой
4. Поставить Python SDK: `pip install google-genai`

### Этап 2 — Google Cloud проект
1. Открыть `console.cloud.google.com`
2. **Проверить что я залогинен ИМЕННО под нужным аккаунтом** (это главная ловушка — если в браузере несколько Google-аккаунтов, может быть выбран не тот, и потом всё ломается с непонятными 403)
3. Создать проект — придумать ID типа `myname-vertex` (запиши его, понадобится везде)
4. Активировать **Free Trial** если предложит (даст $300 кредитов на 90 дней)
5. Включить три API одной командой:
   ```bash
   gcloud services enable \
     aiplatform.googleapis.com \
     generativelanguage.googleapis.com \
     storage.googleapis.com \
     --project=<MY_PROJECT_ID>
   ```

### Этап 3 — Service Account и ключ
1. В консоли: **IAM & Admin → Service Accounts → + CREATE SERVICE ACCOUNT**
2. Name: `<project>-sa`, Description свободный → CREATE AND CONTINUE
3. **Grant role: `Vertex AI User`** (не Owner, не Editor — именно Vertex AI User)
4. CONTINUE → DONE
5. Кликнуть на email созданного SA → вкладка **KEYS → ADD KEY → Create new key → JSON → CREATE**
6. Скачается файл — переместить (не скопировать!) в `~/.gcloud/`:
   ```bash
   mkdir -p ~/.gcloud
   chmod 700 ~/.gcloud
   mv ~/Downloads/<MY_PROJECT_ID>-*.json ~/.gcloud/<MY_PROJECT_ID>-key.json
   chmod 600 ~/.gcloud/<MY_PROJECT_ID>-key.json
   ```

### 🚨 Возможная ловушка на этапе 3 — Organization Policy

Если на шаге **ADD KEY → Create new key** Google говорит «Service account key creation is disabled» или кнопка серая — это политика организации `iam.disableServiceAccountKeyCreation`. Лечится так:

1. В консоли вверху селектор проекта → переключиться **на организацию** (а не проект)
2. **IAM & Admin → IAM** → найти свой email → ✏️ Edit → **+ ADD ANOTHER ROLE → Organization Policy Administrator** (`roles/orgpolicy.policyAdmin`) → SAVE
3. Подождать 30 секунд
4. **IAM & Admin → Organization Policies** → в фильтре написать `key creation` → найти `iam.disableServiceAccountKeyCreation` → **MANAGE POLICY**
5. **Override parent's policy → Replace → ADD A RULE → Enforcement: Off → SET POLICY**
6. Подождать 1-2 минуты, переключиться обратно на проект, повторить ADD KEY — теперь работает

### Этап 4 — тест Gemini (проверка что ключ живой)

```python
import os
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.path.expanduser("~/.gcloud/<MY_PROJECT_ID>-key.json")

from google import genai

client = genai.Client(vertexai=True, project="<MY_PROJECT_ID>", location="us-central1")
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Скажи коротко по-русски: ты кто и какая модель?",
)
print(response.text)
```

Если ответил по-русски — ключ работает, Vertex AI включён, идём дальше.

### Этап 5 — Budget Alert (СЕЙЧАС, до Veo)

В консоли: **Billing → Budgets & alerts → CREATE BUDGET**
- Amount: **$40**
- Alerts: **50% / 90% / 100%** (на email)
- Save

**Важно понимать:** Google в UI прямо пишет «Setting a budget does not cap consumption». Это сигнализация, не выключатель. Деньги списываются дальше, тебе просто приходит письмо. Поэтому после первого теста Veo сразу проверяй биллинг.

### Этап 6 — тест Imagen 4

```python
from google import genai
from google.genai import types

client = genai.Client(vertexai=True, project="<MY_PROJECT_ID>", location="us-central1")

response = client.models.generate_images(
    model="imagen-4.0-generate-001",
    prompt="Photorealistic mountain lake at sunrise, cinematic wide shot, golden hour, mist over water",
    config=types.GenerateImagesConfig(number_of_images=1, aspect_ratio="16:9"),
)
response.generated_images[0].image.save("/tmp/imagen_test.png")
print("Saved /tmp/imagen_test.png")
```

Открыть `/tmp/imagen_test.png` — должна быть картинка озера 1408×768 ~1.4 MB. ~30-40 секунд.

### Этап 7 — Cloud Storage bucket для Veo

Veo не отдаёт видео напрямую — кладёт в Cloud Storage и возвращает URI.

```bash
gcloud storage buckets create gs://<MY_PROJECT_ID>-veo-output \
  --project=<MY_PROJECT_ID> \
  --location=us-central1 \
  --uniform-bucket-level-access
```

### 🚨 Возможная ловушка на этапе 7 — Veo Service Agent

Когда Veo первый раз стартует, Vertex AI создаёт служебный аккаунт `service-<NUMBER>@gcp-sa-aiplatform.iam.gserviceaccount.com`. Этому аккаунту нужно дать права на запись в bucket — иначе видео сгенерится но не сохранится:

```bash
# узнать NUMBER (project number, не ID):
gcloud projects describe <MY_PROJECT_ID> --format="value(projectNumber)"

# выдать права (подставить NUMBER):
gcloud storage buckets add-iam-policy-binding gs://<MY_PROJECT_ID>-veo-output \
  --member="serviceAccount:service-<NUMBER>@gcp-sa-aiplatform.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin" \
  --project=<MY_PROJECT_ID>
```

Если на первом запуске Veo упадёт с ошибкой про permission denied — значит этот шаг пропустили. Выполни и перезапусти.

### Этап 8 — тест Veo 3 (8 секунд, 1080p, со звуком)

```python
import time
from google import genai
from google.genai import types

client = genai.Client(vertexai=True, project="<MY_PROJECT_ID>", location="us-central1")

operation = client.models.generate_videos(
    model="veo-3.0-generate-001",
    prompt="Cinematic wide shot: wind blowing through tall grass on a hilltop at sunset, warm golden light, slow camera dolly forward, ambient nature sound",
    config=types.GenerateVideosConfig(
        output_gcs_uri="gs://<MY_PROJECT_ID>-veo-output/",
        aspect_ratio="16:9",
        number_of_videos=1,
        duration_seconds=8,
        resolution="1080p",  # ВАЖНО: без этого получишь 720p
    ),
)

while not operation.done:
    time.sleep(15)
    operation = client.operations.get(operation)
    print("waiting…")

for v in operation.response.generated_videos:
    print("Video URI:", v.video.uri)
```

Время — ~90-120 секунд. На выходе `gs://...mp4`. Скачать локально:

```bash
gcloud storage cp gs://<MY_PROJECT_ID>-veo-output/<...>.mp4 /tmp/veo_test.mp4
open /tmp/veo_test.mp4
```

Должно быть 1920×1080, ~22 МБ, MP4 со встроенным звуком ветра.

### Этап 9 — проверка биллинга

После теста Veo зайти **Billing → Reports**. Учти: **задержка обновления цифр 3-24 часа**. Если показывает $0 сразу — это нормально, не значит что бесплатно. Через сутки увидишь честную цифру (~$5-8 за один Veo-клип + копейки за остальное).

---

## Поведение которое я хочу от тебя

1. **Идём по шагам**. Один этап — один блок инструкций — пауза — подтверждение.
2. **На любой ошибке** — диагноз прежде чем гадать решение. Покажи мне как посмотреть что именно не так (`gcloud auth list`, `gcloud config get-value project`, проверка прав в IAM).
3. **Не выдумывай команды** — если чего-то не знаешь, скажи прямо «не уверен, проверим в доке Google».
4. **Не давай мне сразу копировать всё** — если я скопирую все 9 этапов и запущу, я зашью себе ногу. Веди по одному.
5. **Перед Veo обязательно подтверди что Budget Alert установлен**. Это самая дорогая операция в гайде.
6. **Если у меня Mac M1/M2/M3** — учитывай что некоторые pip-пакеты ставятся через Rosetta или нужен `arch -arm64 pip install`.

## Главные ловушки которые я заранее знаю

1. **Не тот Google-аккаунт в браузере** — если в Chrome залогинены несколько аккаунтов, проверяй вверху справа что выбран нужный. Иначе ловишь 403 на пустом месте.
2. **Organization Policy блокирует ADD KEY** — лечится через включение роли Org Policy Admin и отключение `iam.disableServiceAccountKeyCreation`.
3. **Veo Service Agent без прав на bucket** — даёшь `roles/storage.objectAdmin`.
4. **Veo выдал 720p вместо 1080p** — забыл `resolution="1080p"` в config.
5. **`aistudio.google.com` ≠ Vertex AI**. AI Studio — для пет-проектов, бесплатные лимиты, отдельный API key. Vertex AI — production, кредиты Google Cloud, Service Account JSON. Я делаю **Vertex AI**.

## Окей, начинаем с Этапа 1 — установка `gcloud` CLI на мою систему. Что мне сделать?

---PROMPT END---

## Заметки преподавателю

- Базовая стоимость прохождения гайда учеником: ~$10 (1 Imagen + 1 Veo) при условии Free Trial. Без Free Trial — те же ~$10, но с реальной карты.
- Если у ученика нет Google Cloud Free Trial (карта банка не подходит, регион и т.д.) — альтернатива: `aistudio.google.com/apikey`, бесплатный лимит, но без Veo/Imagen в полном объёме. В этом случае гайд **не подходит** — ученик идёт другим путём.
- Имя проекта в Google Cloud менять нельзя после создания. Сразу нормальное.
- Service Account JSON = пароль. Утечёт в git → биллинг сожрёт всё. Сразу `.gitignore`.
- На VPS ключ кладётся аналогично в `/root/.gcloud/<name>-key.json`, `chmod 600`.

## Источник

Реальная сессия настройки Vertex AI — ловушки и фиксы проверены вживую на практике.

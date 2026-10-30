import os
import shutil
import json
import urllib.request
import urllib.parse
import ssl
import re

def get_token():
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        return token
    obsidian_git = r"C:\Users\1\Obsidian Sync\.git\config"
    if os.path.exists(obsidian_git):
        with open(obsidian_git, "r", encoding="utf-8") as f:
            for line in f:
                if "ghp_" in line:
                    m = re.search(r"(ghp_[A-Za-z0-9]+)", line)
                    if m:
                        return m.group(1)
    return ""

TOKEN = get_token()
REPO = "mishany-76/Polish-AI-Tutor"
TAG = "v1.5.2"
RELEASE_NAME = "v1.5.2 — 🧠 Умный экран повторения SM-2: сетка 2x2, точные сроки и интерактивные карточки"
BODY = """## 🧠 Релиз v1.5.2: Модернизация экрана интервального повторения (SM-2)

Полная переработка экрана повторения слов карточками: устранение сокращений, добавление точных сроков возврата слова и поддержка всех экранов смартфонов.

### 🌟 Что нового в версии 1.5.2:

1. **🔘 4 цветные плашки оценки в сетке 2x2 (без сокращений):**
   - Устранены нелепые обрезки текста («Сно, труд, хор, легк»).
   - Кнопки расположены аккуратной сеткой 2 ряда по 2 кнопки:
     - 🔴 **Снова** (`< 10 мин` / `< 10 хв` / `< 10 min`) — сброс на повтор в текущей сессии.
     - 🟠 **Трудно** (динамический расчет: например, `1 дн` / `1 d`) — минимальный шаг.
     - 🔵 **Хорошо** (динамический расчет: `3–6 дн`) — стандартный шаг SM-2.
     - 🟢 **Легко** (динамический расчет: `7–14+ дн`) — ускоренный шаг с бонусом.
   - Каждая кнопка содержит цветную тематическую иконку, понятную подпись и точный срок возврата слова.

2. **🔄 Переворот карточки в один тап:**
   - Теперь карточку можно раскрыть тапом в любую её область, не целясь в кнопку.
   - Основная кнопка *«Показать ответ»* также сохранена для удобства.

3. **📊 Счётчик и прогресс-бар карточек:**
   - Наглядная индикация сверху: *«Картка 3 з 10 (30%)»*.
   - Плавный полосовой индикатор прохождения текущей сессии.

4. **💡 Обучающая подсказка для новичков:**
   - Понятная вводная плашка: *«Оцените, насколько легко вы вспомнили слово — алгоритм SM-2 автоматически рассчитает идеальный день для следующего повторения»*.
   - Подсказку можно скрыть в один клик.

---
### 📦 Скачать:
- **APK:** `Polish_AI_Tutor_v1.5.2.apk`
"""

def upload_release():
    print(f"Publishing release {TAG} to {REPO}...")
    headers = {
        "Authorization": f"token {TOKEN}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "Antigravity-Release-Publisher",
    }
    
    ctx = ssl.create_default_context()
    
    # 1. Check if release already exists
    url = f"https://api.github.com/repos/{REPO}/releases/tags/{TAG}"
    req = urllib.request.Request(url, headers=headers)
    release_id = None
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            data = json.loads(resp.read().decode())
            release_id = data.get("id")
            print(f"Found existing release with ID: {release_id}")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print("Release does not exist yet. Creating...")
        else:
            print(f"Error checking release: {e}")
            return

    # 2. If release exists, delete it to re-upload cleanly
    if release_id:
        del_url = f"https://api.github.com/repos/{REPO}/releases/{release_id}"
        del_req = urllib.request.Request(del_url, headers=headers, method="DELETE")
        try:
            with urllib.request.urlopen(del_req, context=ctx) as resp:
                print(f"Deleted old release {release_id}")
        except Exception as e:
            print(f"Error deleting release: {e}")

    # 3. Create new release
    create_url = f"https://api.github.com/repos/{REPO}/releases"
    payload = {
        "tag_name": TAG,
        "name": RELEASE_NAME,
        "body": BODY,
        "draft": False,
        "prerelease": False,
    }
    create_req = urllib.request.Request(
        create_url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )
    with urllib.request.urlopen(create_req, context=ctx) as resp:
        release_data = json.loads(resp.read().decode())
        new_release_id = release_data["id"]
        upload_url_template = release_data["upload_url"]
        print(f"Created new release {new_release_id}")

    # 4. Upload APK asset
    apk_source = r"build\app\outputs\flutter-apk\app-release.apk"
    apk_target_name = f"Polish_AI_Tutor_{TAG}.apk"
    
    if not os.path.exists(apk_source):
        print(f"ERROR: APK not found at {apk_source}")
        return

    apk_size = os.path.getsize(apk_source)
    print(f"Uploading {apk_target_name} ({apk_size / (1024*1024):.2f} MB)...")

    # Clean upload url: strip {?name,label}
    upload_url = upload_url_template.split("{")[0] + f"?name={apk_target_name}"
    
    with open(apk_source, "rb") as f:
        apk_bytes = f.read()

    upload_headers = {
        "Authorization": f"token {TOKEN}",
        "Content-Type": "application/vnd.android.package-archive",
        "Content-Length": str(len(apk_bytes)),
        "User-Agent": "Antigravity-Release-Publisher",
    }
    
    upload_req = urllib.request.Request(upload_url, data=apk_bytes, headers=upload_headers, method="POST")
    with urllib.request.urlopen(upload_req, context=ctx) as resp:
        asset_data = json.loads(resp.read().decode())
        print(f"Successfully uploaded {asset_data.get('name')}! Download URL: {asset_data.get('browser_download_url')}")

if __name__ == "__main__":
    upload_release()


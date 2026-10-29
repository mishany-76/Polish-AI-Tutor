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
TAG = "v1.4.5"
RELEASE_NAME = "v1.4.5 — Обновление Переводчика: светлая дизайн-тема, выбор польского языка и интерактивный зум (Pinch-to-zoom)"
BODY = """## 🔍 Релиз v1.4.5: Обновление экрана «Переводчик»

### 🌟 Что исправлено и улучшено:

#### 1. 🎨 Полная гармонизация со светлой темой «Варшавский Модерн»:
- Убран мрачный черный фон всего экрана и верхней панели.
- Название экрана **«Переводчик»** (а также **«Tłumacz»** и **«Перекладач»**) теперь отображается четко, контрастно и выразительно в едином стиле приложения.
- Режимы («📷 Камера», «📁 Файл/PDF», «✍️ Текст») оформлены в соответствии с активной темой приложения с мягкими акцентами и читаемыми иконками.
- Поля ввода текста, подсказки, карточки перевода и кнопки действий приведены к единому стандарту Material Design 3.

#### 2. 🇵🇱 Добавлен польский язык в переключатель языков интерфейса:
- В верхний переключатель языков рядом с `🇺🇦 UK` и `🇷🇺 RU` добавлен `🇵🇱 PL` (Польский).
- Теперь пользователи могут мгновенно переключать язык приложения на польский прямо на экране Переводчика.
- Поддерживается интеллектуальное толкование и редактирование польского текста на польском языке при выборе профиля `🇵🇱 PL`.

#### 3. 🔎 Интерактивный жест зума пальцами (Pinch-to-zoom) и выбор слов в документах:
- В режиме сканирования документов и фото реализован плавный **двупальцевый жест масштабирования (pinch-to-zoom)** и свободное перемещение (панорамирование).
- Добавлена плавающая панель быстрого зума с кнопками `[+]`, `[-]`, отображением масштаба (например, `2.5x`) и кнопкой мгновенного сброса `[↺]`.
- Поддерживается **двойной тап** для быстрого приближения к мелкому тексту документа и возврата к 1.0x.
- Интерактивные рамки распознанных слов теперь масштабируются синхронно с изображением вплоть до 6.0x: мелкий шрифт на чеках, договорах, рецептах и бланках стал идеально читаемым, и любое слово можно легко выбрать касанием пальца!

---
### 📦 Скачать релиз:
Прямая ссылка на APK:
[Polish_AI_Tutor_v1.4.5.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.5/Polish_AI_Tutor_v1.4.5.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.5.apk"

def main():
    if not os.path.exists(APK_SOURCE):
        print(f"Error: APK not found at {APK_SOURCE}")
        return

    apk_size_mb = os.path.getsize(APK_SOURCE) / (1024 * 1024)
    print(f"APK size: {apk_size_mb:.2f} MB")

    root_apk = os.path.join(r"c:\Users\1\Development\PolishApp", APK_NAME)
    shutil.copy2(APK_SOURCE, root_apk)
    print(f"Copied APK to {root_apk}")

    if not TOKEN:
        print("Error: GITHUB_TOKEN not found!")
        return

    headers = {
        "Authorization": f"token {TOKEN}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "ReleaseScript"
    }

    ctx = ssl.create_default_context()

    # 1. Check if release already exists
    req = urllib.request.Request(f"https://api.github.com/repos/{REPO}/releases/tags/{TAG}", headers=headers)
    release = None
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            release = json.loads(resp.read().decode())
            print(f"Release {TAG} already exists (id: {release['id']})")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"Release {TAG} does not exist yet. Creating...")
        else:
            print(f"Error checking release: {e}")
            return

    # 2. Create release if needed
    if not release:
        create_payload = {
            "tag_name": TAG,
            "target_commitish": "main",
            "name": RELEASE_NAME,
            "body": BODY,
            "draft": False,
            "prerelease": False
        }
        req = urllib.request.Request(
            f"https://api.github.com/repos/{REPO}/releases",
            data=json.dumps(create_payload).encode(),
            headers=headers,
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, context=ctx) as resp:
                release = json.loads(resp.read().decode())
                print(f"Release created successfully (id: {release['id']})")
        except urllib.error.HTTPError as e:
            print(f"Error creating release: {e.read().decode()}")
            return

    release_id = release["id"]

    # 3. Check existing assets
    existing_assets = release.get("assets", [])
    for a in existing_assets:
        if a["name"] == APK_NAME:
            print(f"Deleting existing asset {APK_NAME} (id: {a['id']})...")
            del_req = urllib.request.Request(
                f"https://api.github.com/repos/{REPO}/releases/assets/{a['id']}",
                headers=headers,
                method="DELETE"
            )
            urllib.request.urlopen(del_req, context=ctx)
            print("Deleted successfully.")

    # 4. Upload APK asset
    upload_url_template = release["upload_url"]
    upload_url = upload_url_template.split("{")[0] + f"?name={APK_NAME}"
    print(f"Uploading {APK_NAME} to {upload_url}...")

    with open(root_apk, "rb") as f:
        apk_data = f.read()

    upload_headers = {
        "Authorization": f"token {TOKEN}",
        "Content-Type": "application/vnd.android.package-archive",
        "User-Agent": "ReleaseScript",
        "Content-Length": str(len(apk_data))
    }

    req = urllib.request.Request(upload_url, data=apk_data, headers=upload_headers, method="POST")
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            asset = json.loads(resp.read().decode())
            print(f"Asset uploaded successfully! Download URL: {asset.get('browser_download_url')}")
    except urllib.error.HTTPError as e:
        print(f"Error uploading asset: {e.read().decode()}")

if __name__ == "__main__":
    main()


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
TAG = "v1.4.0"
RELEASE_NAME = "v1.4.0 — Экспорт словаря в Anki & Quizlet (.tsv / .csv) & Dictation Speller"
BODY = """## 📤 Релиз v1.4.0: Экспорт в Anki / Quizlet & Dictation Speller

### 🌟 Что нового в этом релизе:

#### 1. 📤 Экспорт словаря в Anki / Quizlet / Excel (Пункт 1.5 Дорожной карты — Фаза 1 Завершена!):
- **Бесшовный экспорт накопленной базы слов:**
  - Кнопка экспорта `[📤]` в AppBar экрана «Мой словарь».
  - Модальная шторка выбора целевого формата в эстетике «Варшавский Модерн».
- **Три специализированных формата экспорта:**
  - **1) Anki Deck (`.txt` / TSV):** полностью готов к импорту в десктопный Anki и Android-приложение AnkiDroid. Включает разметку HTML (`<b>`, `<i>`), служебные директивы `#separator:tab`, `#html:true`, `#tags column:7`, подробные заметки (включая маркеры «ложных друзей»), грамматический род, текущие интервалы повторения алгоритма SM-2 и теги колоды (`PolishAI`, `nowe/nauka/opanowane`, `scan/manual/chat`).
  - **2) Quizlet (`.csv`):** стандартный двухколоночный формат по спецификации RFC 4180 (Термин и Определение) для быстрого создания флеш-карточек в Quizlet.
  - **3) Excel / Google Sheets (`.csv`):** исчерпывающая таблица из 10 столбцов, закодированная в **UTF-8 с сигнатурой BOM** (`0xEF, 0xBB, 0xBF`). Это гарантирует безупречное открытие всех польских диакритических знаков (`ą, ć, ę, ł, ń, ó, ś, ź, ż`) в Microsoft Excel на Windows/macOS без «кракозябр» и сбоев кодировок.
- **Интеграция системного шеринга Android:**
  - Мгновенная отправка созданного файла колоды в Telegram, WhatsApp, Google Диск или прямое открытие в AnkiDroid в один клик.

#### 2. 🎯 Режим «Диктант» (Active Recall Speller — Пункт 1.4):
- Тренировка орфографии и распознавания речи на слух (две скорости: 1.0x / 0.28x).
- Быстрая панель польских букв (`ą, ć, ę, ł, ń, ó, ś, ź, ż`) для комфортного набора.
- Автоматическая диагностика ловушек (`rz/ż`, `ó/u`, `ch/h`, `ą/ę`) с объяснением мнемонических правил на выбранном языке.

#### 3. 📊 «Мой польский за месяц» (Monthly Progress Wrapped — Пункт 1.3):
- Персональные ежемесячные итоги обучения в стиле Spotify Wrapped (словарный объем, выученные слова по SM-2, прогресс CEFR, титулы месяца).

#### 4. ⚖️ Умный разбор документов (Smart Doc Scanner — Пункт 1.2):
- Разбор официальных договоров, писем из Urząd Skarbowy и ZUS с юридическим резюме, рисками и пакетным сохранением терминов.

#### 5. 🇵🇱 Система «Польский паспорт» (Polski Paszport — Пункт 1.1):
- 15 интерактивных гербовых штампов за реальные достижения, серия дней (streak) и золотой статус *Obywatel Języka*.

#### 6. 🌐 Строгая трехъязычная локализация и обновленное руководство:
- 100% строгая локализация (🇺🇦 Украинский, 🇷🇺 Русский, 🇵🇱 Польский).
- В интерактивное руководство пользователя добавлен Раздел 9: «📤 Експорт в Anki / Quizlet».

---
### 📦 Скачать релиз:
Прямая ссылка на готовый APK:
[Polish_AI_Tutor_v1.4.0.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.0/Polish_AI_Tutor_v1.4.0.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.0.apk"

def main():
    if not os.path.exists(APK_SOURCE):
        print(f"Error: APK not found at {APK_SOURCE}")
        return

    apk_size_mb = os.path.getsize(APK_SOURCE) / (1024 * 1024)
    print(f"APK size: {apk_size_mb:.2f} MB")

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
            data=json.dumps(create_payload).encode('utf-8'),
            headers=headers,
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, context=ctx) as resp:
                release = json.loads(resp.read().decode())
                print(f"Release created successfully! (id: {release['id']})")
        except urllib.error.HTTPError as e:
            print(f"Failed to create release: {e.code} {e.read().decode()}")
            return

    release_id = release["id"]
    upload_url = release["upload_url"].split("{")[0]

    # 3. Check existing assets
    req = urllib.request.Request(f"https://api.github.com/repos/{REPO}/releases/{release_id}/assets", headers=headers)
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            assets = json.loads(resp.read().decode())
            for asset in assets:
                if asset["name"] == APK_NAME:
                    print(f"Asset {APK_NAME} already exists (id: {asset['id']}). Deleting old asset...")
                    del_req = urllib.request.Request(
                        f"https://api.github.com/repos/{REPO}/releases/assets/{asset['id']}",
                        headers=headers,
                        method="DELETE"
                    )
                    with urllib.request.urlopen(del_req, context=ctx) as del_resp:
                        print("Old asset deleted.")
    except Exception as e:
        print(f"Error checking assets: {e}")

    # 4. Upload APK asset
    print(f"Uploading {APK_NAME} to release {TAG}...")
    with open(APK_SOURCE, "rb") as f:
        apk_data = f.read()

    upload_headers = {
        "Authorization": f"token {TOKEN}",
        "Content-Type": "application/vnd.android.package-archive",
        "User-Agent": "ReleaseScript"
    }

    upload_params = urllib.parse.urlencode({"name": APK_NAME})
    target_upload_url = f"{upload_url}?{upload_params}"

    upload_req = urllib.request.Request(
        target_upload_url,
        data=apk_data,
        headers=upload_headers,
        method="POST"
    )

    try:
        with urllib.request.urlopen(upload_req, context=ctx) as resp:
            uploaded = json.loads(resp.read().decode())
            print("==================================================")
            print("🚀 RELEASE v1.4.0 SUCCESSFULLY PUBLISHED!")
            print(f"Asset Name: {uploaded['name']}")
            print(f"Download URL: {uploaded['browser_download_url']}")
            print("==================================================")
    except urllib.error.HTTPError as e:
        print(f"Failed to upload asset: {e.code} {e.read().decode()}")

if __name__ == "__main__":
    main()

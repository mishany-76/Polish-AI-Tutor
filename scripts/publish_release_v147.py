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
TAG = "v1.4.7"
RELEASE_NAME = "v1.4.7 — Внедрение фичи 2.3: «Мгновенный онбординг без барьеров» (Instant Frictionless Onboarding)"
BODY = """## 🚀 Релиз v1.4.7: Внедрение фичи 2.3 — «Мгновенный онбординг без барьеров» (Instant Frictionless Onboarding)

### 🌟 Что нового в версии 1.4.7:

#### 1. 👩‍🏫 Интерактивный диалог-знакомство с тьютором Kasia на 60 секунд:
- При первом запуске приложения вместо сухого дашборда открывается теплое персонализированное знакомство с тьютором Kasia без нудных туториалов и регистраций.
- **Шаг 1 (Знакомство):** Kasia тепло приветствует пользователя на польском языке (*«Cześć! Jestem Kasia — Twój osobisty nauczyciel języka polskiego 🇵🇱. Jak masz na imię?»*) с возможностью прослушивания произношения (TTS 🔊) и вводом имени.
- **Шаг 2 (Определение уровня):** выбор начальной точки:
  - 🟢 **Dopiero zaczynam (A0)** — с нуля / знаю только пару слов.
  - 🟡 **Znam podstawy (A1–A2)** — знаю основы, но хочу преодолеть языковой барьер.
  - 🔴 **Średniozaawansowany (B1+)** — шлифовка грамматики, подготовка к экзамену или работе.
- **Шаг 3 (Главная цель):** выбор целевого фокуса в Польше:
  - 🛒 **Жизнь и быт (Życie i zakupy)** — магазины, кафе, транспорт, повседневные разговоры.
  - 📄 **Ужонд и документы (Urząd i dokumenty)** — PESEL, карта побыту, банк, умовы, госорганы.
  - 💼 **Работа в Польше (Praca w Polsce)** — собеседования, общение с коллегами и шефом.
  - 🏆 **Сертификат B1 / Гражданство (Egzamin państwowy)** — подготовка к официальному экзамену.
- **Шаг 4 (Первая победа / First Win):**
  - Изучение первой польской фразы: *«Miło mi Cię poznać!»*.
  - Озвучивание диктором (TTS) и интерактивный ответ в один клик.
  - Автоматическая разблокировка первой печати в **«Польском паспорте»** и сохранение фразы в личный словарь пользователя!

#### 2. ⚡ Быстрый пропуск в 1 клик (Frictionless):
- На каждом экране доступна кнопка **«Pomiń / Пропустить»** в верхнем правом углу для пользователей, желающих сразу перейти к функционалу приложения.

#### 3. 👤 Персонализация главного экрана, паспорта и настроек:
- **LearnDashboard:** в шапке отображается теплое обращение (*«Cześć, Alex! 🇵🇱»*) с бейджем выбранной цели и уровня, а также кнопка быстрой корректировки целей.
- **Польский паспорт:** персональная карточка владельца паспорта на обложке (*«Alex · A1–A2 · Urząd i dokumenty»*).
- **Настройки:** добавлен блок «Мой профиль и цель» с кнопкой **«Пройти знакомство с Kasia заново»** для легкой смены целей в любой момент.

#### 4. 🛠️ Стабильность и архитектура:
- Все предыдущие функции (Ресторанное меню, Переводчик с зумом, Аудиотренажер, Ролевые диалоги, Диктант) сохранены в 100% работоспособности.
- Добавлены юнит-тесты на `UserProfile`, `UserProfileNotifier` и сохранение в SharedPreferences (все 41 тест проходят успешно).

---
### 📦 Скачать релиз:
Прямая ссылка на APK:
[Polish_AI_Tutor_v1.4.7.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.7/Polish_AI_Tutor_v1.4.7.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.7.apk"

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


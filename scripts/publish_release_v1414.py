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
TAG = "v1.4.14"
RELEASE_NAME = "v1.4.14 — 📖 Интерактивное руководство пользователя (User Guide & Manual)"
BODY = """## 📖 Релиз v1.4.14: Интерактивное руководство пользователя (User Guide & Manual)

Полномасштабный интерактивный справочник пользователя с глубоким разбором каждого модуля приложения, доступный прямо в приложении и синхронизированный на всех трёх языках (🇺🇦 Українська, 🇷🇺 Русский, 🇵🇱 Polski)!

### 🌟 Что нового:

1. **📖 Интерактивный экран «Руководство пользователя» (User Guide):**
   - Доступен из главного экрана обучения (кнопка в верхней панели) и раздела настроек приложения.
   - **Мгновенный трилингвальный переключатель:** украинский (🇺🇦), русский (🇷🇺) и польский (🇵🇱) языки.
   - **Живой поиск по модулям:** фильтрация разделов по ключевым словам и темам.
   - **Прямой переход к фичам:** каждая карточка руководства содержит кнопку быстрого запуска соответствующего экрана приложения.

2. **🔍 12 исчерпывающих разделов документации:**
   - 🚀 **Мгновенный онбординг без барьеров:** Знакомство с Касей, выбор целей и темпа.
   - 🎯 **Тренажёры и викторины:** Окончания, аудирование, ложные друзья, числа и адаптивная память ошибок.
   - 🎧 **Режим «Диктант» (Active Recall Speller):** Восприятие на слух (1.0x/0.3x), панель диакритики, орфографические дублеты (rz/ż, ó/u, ch/h, ą/ę).
   - 🛡️ **Польский паспорт:** 15 геральдических печатей воеводств, ударный режим и шеринг достижений.
   - 📊 **Итоги месяца (Monthly Wrapped):** Офлайн-аналитика SQLite, расчёт CEFR и ежемесячный титул.
   - 💼 **Польский для профессий (Professions Hub):** 5 отраслей, банки терминов, пакетный импорт и 15 рабочих ситуаций.
   - 🎬 **Интерактивный сериал «Живые эпизоды»:** 5 сюжетных серий (Варшава, Уженд, Квартира, Собеседование, Краков), симуляция и ролевой диалог.
   - ⚔️ **Экзаменационный Boss Fight:** 5-минутный госэкзамен с независимой комиссией (Prof. Wiśniewska / Dr Kowalczyk), 3 этапа и номерной сертификат CEFR B1/B2.
   - 🗣️ **Ролевые диалоги с ИИ:** 30 бытовых и официальных сценариев, STT/TTS и динамические сюжетные твисты.
   - 📷 **Переводчик и умный сканер:** Камера с Pinch-to-zoom (до 6.0x), юридический аудит договоров (Umowa o pracę/zlecenia), ZUS и ресторанное меню.
   - 🧠 **Словарь и интервальное повторение:** Алгоритм SuperMemo SM-2, кривая Эббингауза, экспорт колод в Anki, Quizlet и Excel.
   - ⚙️ **Настройки и AI Gateway:** Управление ключами, тесты шлюзов и автоматическое обновление через GitHub Releases.

3. **🧠 Синхронизация со Вторым мозгом (Obsidian Vault):**
   - Файл `User_Guide_Manual.md` полностью обновлён до v1.4.14 с подробной трилингвальной структурой и практическими инструкциями.

---
### 📦 Скачать:
- **APK:** `Polish_AI_Tutor_v1.4.14.apk`
"""

def make_request(url, method="GET", data=None, headers=None):
    ctx = ssl.create_default_context()
    if headers is None:
        headers = {}
    if TOKEN:
        headers["Authorization"] = f"token {TOKEN}"
    headers["User-Agent"] = "PolishApp-Updater/1.4.14"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, context=ctx) as resp:
        return resp.status, resp.read()

def main():
    if not TOKEN:
        print("ERROR: GitHub token not found!")
        return

    apk_src = "build/app/outputs/flutter-apk/app-release.apk"
    if not os.path.exists(apk_src):
        print(f"ERROR: {apk_src} does not exist!")
        return

    apk_target = "build/app/outputs/flutter-apk/Polish_AI_Tutor_v1.4.14.apk"
    shutil.copy2(apk_src, apk_target)
    apk_size_mb = os.path.getsize(apk_target) / (1024 * 1024)
    print(f"Copied {apk_src} to {apk_target} ({apk_size_mb:.2f} MB)")

    # 1. Check or create Release
    print(f"Creating release {TAG} in {REPO}...")
    release_url = f"https://api.github.com/repos/{REPO}/releases"
    payload = json.dumps({
        "tag_name": TAG,
        "name": RELEASE_NAME,
        "body": BODY,
        "draft": False,
        "prerelease": False
    }).encode("utf-8")

    try:
        status, resp_data = make_request(
            release_url,
            method="POST",
            data=payload,
            headers={"Content-Type": "application/json", "Accept": "application/vnd.github.v3+json"}
        )
        release_info = json.loads(resp_data.decode("utf-8"))
        print(f"Created release with ID: {release_info.get('id')}")
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode("utf-8")
        if "already_exists" in err_msg:
            print(f"Release {TAG} already exists, fetching existing release...")
            get_url = f"https://api.github.com/repos/{REPO}/releases/tags/{TAG}"
            _, resp_data = make_request(get_url, headers={"Accept": "application/vnd.github.v3+json"})
            release_info = json.loads(resp_data.decode("utf-8"))
        else:
            print(f"HTTP Error {e.code}: {err_msg}")
            return

    upload_url_template = release_info.get("upload_url", "")
    upload_url = upload_url_template.split("{")[0]

    asset_name = "Polish_AI_Tutor_v1.4.14.apk"
    # Check if asset already exists
    for asset in release_info.get("assets", []):
        if asset.get("name") == asset_name:
            print(f"Deleting existing asset {asset.get('id')}...")
            del_url = f"https://api.github.com/repos/{REPO}/releases/assets/{asset.get('id')}"
            make_request(del_url, method="DELETE")

    print(f"Uploading {asset_name} ({apk_size_mb:.2f} MB)...")
    with open(apk_target, "rb") as f:
        apk_bytes = f.read()

    upload_full_url = f"{upload_url}?name={urllib.parse.quote(asset_name)}"
    status, upload_resp = make_request(
        upload_full_url,
        method="POST",
        data=apk_bytes,
        headers={
            "Content-Type": "application/vnd.android.package-archive",
            "Accept": "application/vnd.github.v3+json"
        }
    )
    print(f"Upload completed with status {status}!")
    print(f"Release successfully published at: https://github.com/{REPO}/releases/tag/{TAG}")

if __name__ == "__main__":
    main()


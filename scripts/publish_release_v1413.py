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
TAG = "v1.4.13"
RELEASE_NAME = "v1.4.13 — 🏆 «Экзаменационный Boss Fight» (CEFR Assessment)"
BODY = """## 🏆 Релиз v1.4.13: «Экзаменационный Boss Fight» (CEFR Assessment)

Полноценная система государственной экзаменационной проверки практического владения польским языком с выдачей официального сертификата CEFR!

### 🌟 Что нового:

1. **🎓 Экзаменационный Boss Fight (CEFR Assessment):**
   - **Строгие экзаменаторы:** Выбор между проф. Эвой Вишневской (*Przewodnicząca Państwowej Komisji Egzaminacyjnej*) и д-ром Янушем Ковальчиком (*Egzaminator B1/B2*).
   - **Условия реального экзамена:** 5-минутный таймер, отсутствие подсказок и мгновенных переводов во время диалога для максимальной чистоты проверки.
   - **3 структурированных этапа:**
     1. *Autoprezentacja i plany:* Кто вы, откуда приехали, профессия и цели изучения польского языка.
     2. *Rozwiązanie sytuacji życiowej:* Решение проблемы на месте (уженд, банк, аренда квартиры, поликлиника).
     3. *Opinia i argumentacja:* Выражение личного мнения и аргументация (адаптация, традиции, жизнь в Польше).

2. **📜 Официальный электронный сертификат CEFR:**
   - Определение уровня владения языком (**A1, A2, B1, B2**).
   - Подробная разбивка баллов (до 100 баллов) по 4 ключевым компетенциям:
     * *Zasób słownictwa* (Словарный запас) — до 25 баллов
     * *Gramatyka i fleksja* (Грамматическая точность) — до 25 баллов
     * *Płynność i spójność* (Беглость и связность) — до 25 баллов
     * *Reakcja i zrozumienie* (Понимание и реакция на вопросы) — до 25 баллов
   - Развёрнутое заключение экзаменатора с выделением сильных сторон (*Mocne strony*) и зон для улучшения (*Do poprawy*).
   - Кнопка копирования и сохранения сертификата.

3. **📚 История и отслеживание прогресса:**
   - Сохранение всех предыдущих попыток с датами и баллами.
   - Отображение текущего лучшего уровня и сертификата прямо в Экзаменационном Хабе.

4. **🎯 Баннер «Экзаменационный Boss Fight» на Главном экране:**
   - Выдержан в едином дизайне («Варшавский Модерн», фирменный карминный акцент `#DC143C`, бейдж `CEFR A1–B2`).

---
### 📦 Скачать релиз:
Прямая ссылка на APK:
[Polish_AI_Tutor_v1.4.13.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.13/Polish_AI_Tutor_v1.4.13.apk)
"""

SOURCE_APK = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
TARGET_APK = rf"c:\Users\1\Development\PolishApp\Polish_AI_Tutor_{TAG}.apk"

def main():
    if not os.path.exists(SOURCE_APK):
        print(f"Error: {SOURCE_APK} not found!")
        return

    size_mb = os.path.getsize(SOURCE_APK) / (1024 * 1024)
    print(f"APK size: {size_mb:.2f} MB")
    shutil.copyfile(SOURCE_APK, TARGET_APK)
    print(f"Copied APK to {TARGET_APK}")

    if not TOKEN:
        print("Error: GitHub token not found!")
        return

    headers = {
        "Authorization": f"token {TOKEN}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "ReleaseScript"
    }

    ctx = ssl.create_default_context()

    # Проверяем, существует ли релиз
    req = urllib.request.Request(f"https://api.github.com/repos/{REPO}/releases/tags/{TAG}", headers=headers)
    release_id = None
    upload_url = None
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            data = json.loads(resp.read().decode())
            release_id = data["id"]
            upload_url = data["upload_url"].split("{")[0]
            print(f"Found existing release {TAG} (id: {release_id})")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"Release {TAG} does not exist yet. Creating...")
        else:
            print(f"HTTP error checking release: {e}")
            return

    if not release_id:
        payload = {
            "tag_name": TAG,
            "target_commitish": "main",
            "name": RELEASE_NAME,
            "body": BODY,
            "draft": False,
            "prerelease": False
        }
        create_req = urllib.request.Request(
            f"https://api.github.com/repos/{REPO}/releases",
            data=json.dumps(payload).encode(),
            headers=headers,
            method="POST"
        )
        try:
            with urllib.request.urlopen(create_req, context=ctx) as resp:
                data = json.loads(resp.read().decode())
                release_id = data["id"]
                upload_url = data["upload_url"].split("{")[0]
                print(f"Release created successfully (id: {release_id})")
        except urllib.error.HTTPError as e:
            print(f"Failed to create release: {e.read().decode()}")
            return

    # Загружаем APK asset
    asset_name = f"Polish_AI_Tutor_{TAG}.apk"
    upload_endpoint = f"{upload_url}?name={asset_name}"
    print(f"Uploading {asset_name} to {upload_endpoint}...")

    with open(TARGET_APK, "rb") as f:
        apk_bytes = f.read()

    upload_headers = {
        "Authorization": f"token {TOKEN}",
        "Content-Type": "application/vnd.android.package-archive",
        "User-Agent": "ReleaseScript",
        "Content-Length": str(len(apk_bytes))
    }

    upload_req = urllib.request.Request(
        upload_endpoint,
        data=apk_bytes,
        headers=upload_headers,
        method="POST"
    )

    try:
        with urllib.request.urlopen(upload_req, context=ctx) as resp:
            resp_data = json.loads(resp.read().decode())
            download_url = resp_data.get("browser_download_url")
            print(f"Asset uploaded successfully! Download URL: {download_url}")
    except urllib.error.HTTPError as e:
        print(f"Asset upload error: {e.code} - {e.read().decode()}")

if __name__ == "__main__":
    main()


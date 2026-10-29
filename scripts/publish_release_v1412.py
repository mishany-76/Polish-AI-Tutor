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
TAG = "v1.4.12"
RELEASE_NAME = "v1.4.12 — 🎬 «Живые эпизоды» (Story Mode / Сериал: Жизнь в Польше)"
BODY = """## 🎬 Релиз v1.4.12: «Живые эпизоды» (Story Mode / Сериал)

Полноценное сюжетное обучение в формате интерактивного сериала о реальной жизни экспата в Польше!

### 🌟 Что нового:

1. **🎬 Сезон 1 сериала «Жизнь в Польше» (5 ключевых серий):**
   - **Эпизод 1: 🏡 Przyjazd i wynajem mieszkania (Приезд и аренда жилья)** — осмотр квартиры с паном Кшиштофом, счетчики, kaucja zwrotna, договор найма и акт приёмки.
   - **Эпизод 2: 🏛️ Legalizacja i Urząd (Легализация и документы)** — талончик в терминале, подача документов на номер PESEL, прописка (meldunek) и активация Profilu Zaufanego.
   - **Эпизод 3: 💳 Bank i finanse (Банк и финансы)** — открытие счета ROR, платежи кодом BLIK, разбор расчетного листа зарплаты (brutto vs netto, налоги PIT и ZUS).
   - **Эпизод 4: 🩺 Zdrowie i przychodnia POZ (Здоровье и врач NFZ)** — регистрация к семейному врачу, объяснение симптомов, получение 4-значного кода e-recepty и больничного e-ZLA (L4).
   - **Эпизод 5: 🚆 Podróż i transport miejski (Город и транспорт)** — покупка билетов в билетомате, компостирование, проверка билетов контролером без штрафа, поезда PKP Intercity.

2. **📖 Словарь выживания в каждом эпизоде:**
   - 6–8 ключевых терминов в серии с озвучкой Google TTS, примерами предложений и кнопкой пакетного импорта в личный словарь.

3. **🎭 Двойной режим прохождения каждой сцены:**
   - **Диалог с ИИ:** Полноценный ролевой диалог с польским NPC в режиме реального времени (голосом или текстом с подсказками).
   - **Сюжетный квест:** Интерактивная симуляция ситуации с выбором лучших коммуникативных фраз и мгновенным дидактическим фидбеком.

4. **⭐ Система наград и прогресса:**
   - Автоматическое начисление звёзд (до ⭐⭐⭐), открытие следующих серий и зачет диалогов в «Польский паспорт».

5. **🎯 Стильный баннер на Главном экране:**
   - Баннер «🎬 Живые эпизоды» со значком «СЕРИАЛ» и плавным переходом.

---
### 📦 Скачать релиз:
Прямая ссылка на APK:
[Polish_AI_Tutor_v1.4.12.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.12/Polish_AI_Tutor_v1.4.12.apk)
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


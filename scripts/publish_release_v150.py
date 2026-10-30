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
TAG = "v1.5.0"
RELEASE_NAME = "v1.5.0 — 🔤 Polski Elementarz: Польский Букварь для начинающих (Нулевой этап A0)"
BODY = """## 🔤 Релиз v1.5.0: Polski Elementarz (Польский Букварь — Нулевой этап A0)

Полноценный интерактивный Букварь («Polski Elementarz») для абсолютных новичков, созданный как **фундаментальный нулевой этап (A0)** перед началом грамматики и ролевых диалогов.

### 🌟 Что нового в версии 1.5.0:

1. **🔤 Фонетическая звуковая карта (Звуки, Буквы и Диграфы):**
   - **32 буквы** польского алфавита.
   - **9 уникальных польских букв с диакритикой:** ą, ć, ę, ł, ń, ó, ś, ź, ż с подробным разъяснением носового произношения и шипящих.
   - **7 польских диграфов:** ch, cz, dz, dź, dż, rz, sz с сопоставлением с украинской и русской фонетикой.
   - Озвучивание TTS в одно касание, транскрипция и примеры слов.

2. **🔢 Мега-счётная линейка (0 – 1000):**
   - Полная логика польского счёта: от базовых цифр 0–10, подростков 11–19 (`-naście`), десятков (`-dzieścia`, `-dziesiąt`), сотен (`sto`, `-ście`, `-sta`, `-set`) до тысячи (`tysiąc`).
   - **Интерактивный конструктор чисел:** вводите любое число от 0 до 1000 и мгновенно получайте его правильное польское словесное написание, фонетическую транскрипцию и TTS-озвучку.

3. **🧱 Первые 250 кирпичиков языка (Словарь первоклассника):**
   - 8 жизненно необходимых категорий A0:
     - 🙋‍♂️ *Знакомство и вежливость* (Dzień dobry, Proszę, Dziękuję, Przepraszam...)
     - 👨‍👩‍👧 *Семья и люди* (Mama, Tata, Dziecko, Przyjaciel...)
     - 🏠 *Дом и окружение* (Dom, Pokój, Drzwi, Okno...)
     - 🍎 *Еда и напитки* (Woda, Kawa, Chleb, Herbata...)
     - 🏙️ *Город и ориентирование* (Ulica, Sklep, Apteka, Dworzec...)
     - ⏰ *Время и календарь* (Dzisiaj, Jutro, Poniedziałek, Miesiąc...)
     - 🌈 *Цвета и свойства* (Biały, Czarny, Dobry, Zły, Mały...)
     - ⚡ *Топ-15 базовых глаголов* с формами спряжения в скобках (Być, Mieć, Chcieć, Móc, Wiedzieć, Rozumieć, Mówić, Jeść, Pić, Iść, Jechać...).
   - **Пакетный импорт категорий в личный словарь:** в одно нажатие добавляйте все 20–30 слов категории в интервальное повторение SM-2.

4. **🎮 Мини-игры первоклассника:**
   - Интерактивная викторина для проверки понимания звуков, диакритических знаков и базовых слов.
   - Счётчик правильных ответов и моментальная обратная связь.

5. **📖 Интеграция в экосистему приложения и Руководство:**
   - Новый промо-баннер Букваря на главном экране обучения.
   - Добавлен **Раздел 0 («Polski Elementarz A0»)** в интерактивное «Руководство пользователя» на всех 3 языках (🇺🇦, 🇷🇺, 🇵🇱).
   - Полная синхронизация со Вторым мозгом в Obsidian (`Polski_Elementarz_A0_Blueprint.md`, `User_Guide_Manual.md` v1.5.0).

---
### 📦 Скачать:
- **APK:** `Polish_AI_Tutor_v1.5.0.apk`
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


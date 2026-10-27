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
TAG = "v1.4.2"
RELEASE_NAME = "v1.4.2 — Чистый аудиотренажер, идентичные ответы в ложных друзьях и компактный диктант"
BODY = """## 🛠️ Релиз v1.4.2: Чистый UX викторин и оптимизация диктанта

### 🌟 Что исправлено и обновлено:

#### 1. 🎧 Раздел «Аудиотренажер» (Audio drill):
- **Устранены подсказки в вопросе:** в основном вопросе теперь нейтральная инструкция `🎧 Послушайте и выберите перевод` (`🎧 Послухайте та оберіть переклад`). Польское слово больше не спойлерится текстом на экране — восприятие тренируется строго на слух через звук!
- **Чистые варианты ответов:** в кнопках ответов теперь выводятся только переводы (без польских приставок). Полная связка (`слово — перевод`) открывается в блоке объяснения только после выбора ответа.
- **Изоляция чисел:** из базы аудиотренажера удалены числа и денежные номиналы (`jeden`...`osiemdziesiąt groszy`). Числа изучаются в специально выделенном тренажере «Числа, цены и счет».

#### 2. ⚠️ Раздел «Ложные друзья» (False friends):
- **Абсолютно идентичный вид ответов:** все 4 варианта ответа отображаются строго в едином стиле обычных переводов слов.
- **Без маркеров ловушек:** убраны пометки `(➔ хибний зміст)` и польские префиксы. Ложное слово больше никак не выдает себя визуально, обеспечивая честную проверку знаний.

#### 3. 🎯 Режим «Диктант» (Dictation mode):
- **Удалена панель диакритики внизу:** убран дублирующий нижний блок польской диакритики (`ą, ć, ę, ł...`), освобождая полезное пространство экрана.
- **Компактная кассетница в одну строчку:** плитки букв кассетницы больше не растягиваются высоким вертикальным полотном (`Wrap`), а выстроены в аккуратную строчку с плавной горизонтальной прокруткой (`SingleChildScrollView`).

---
### 📦 Скачать релиз:
Прямая ссылка на готовый APK:
[Polish_AI_Tutor_v1.4.2.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.2/Polish_AI_Tutor_v1.4.2.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.2.apk"

def main():
    if not os.path.exists(APK_SOURCE):
        print(f"Error: APK not found at {APK_SOURCE}")
        return

    apk_size_mb = os.path.getsize(APK_SOURCE) / (1024 * 1024)
    print(f"APK size: {apk_size_mb:.2f} MB")

    # Копируем APK в корень проекта для быстрого доступа
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
            data=json.dumps(create_payload).encode('utf-8'),
            headers=headers,
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, context=ctx) as resp:
                release = json.loads(resp.read().decode())
                print(f"Release {TAG} created successfully! ID: {release['id']}")
        except urllib.error.HTTPError as e:
            print(f"Failed to create release: {e.code} - {e.read().decode()}")
            return

    # 3. Upload APK asset
    upload_url_template = release.get("upload_url", "")
    upload_url = upload_url_template.split("{")[0]
    upload_url_with_param = f"{upload_url}?name={urllib.parse.quote(APK_NAME)}"

    print(f"Uploading asset to: {upload_url_with_param}")
    with open(APK_SOURCE, "rb") as f:
        apk_bytes = f.read()

    upload_headers = {
        "Authorization": f"token {TOKEN}",
        "Content-Type": "application/vnd.android.package-archive",
        "Content-Length": str(len(apk_bytes)),
        "User-Agent": "ReleaseScript"
    }

    req = urllib.request.Request(upload_url_with_param, data=apk_bytes, headers=upload_headers, method="POST")
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            asset_info = json.loads(resp.read().decode())
            print(f"Asset uploaded successfully! ID: {asset_info['id']}, Name: {asset_info['name']}")
            print(f"Download URL: {asset_info['browser_download_url']}")
    except urllib.error.HTTPError as e:
        print(f"Asset upload error: {e.code} - {e.read().decode()}")

    print("All done!")

if __name__ == "__main__":
    main()

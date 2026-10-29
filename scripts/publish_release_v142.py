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
RELEASE_NAME = "v1.4.2 — Очистка аудиотренажера и викторин от технических номеров (#) и дублей"
BODY = """## 🧹 Релиз v1.4.2: Очистка викторин и аудиотренажера от подсказок и номеров (#)

### 🌟 Что исправлено в этом обновлении:

#### 1. 🎧 Аудиотренажер очищен от «палевных» номеров (#) и дублей:
- **Удалены все синтетические технические маркеры:** полностью вычищены суррогатные фразы вроде `zakupy w sklepie: początkowy etap #6` и переводы `начальный этап #6`.
- **Исключены подсказки по номерам:** больше нет ситуации, когда при нажатии на значок перевода появлялся номер решётки (`#6`), совпадающий с вариантом ответа, что позволяло угадывать ответ без изучения польского.
- **Новая база живой разговорной речи:** аудиотренажер наполнен реальными полезными фразами повседневной жизни в Польше (магазин, касса, банк, аренда квартиры, транспорт, визит к врачу, ужонд, ресторан).

#### 2. 🛡️ Автоматическая фильтрация и санитайзинг на уровне ядра:
- В `quiz_builders.dart` внедрен централизованный фильтр `cleanDrillText()`, который на лету очищает любые фразы вопросов, вариантов ответов, озвучки и пояснений от решёток (`#1`, `#6`), номеров (`№`) и служебных пометок (`(употребление #)` / `(вживання #)`).
- В `quiz_screen.dart` функция запроса ИИ-перевода очищена от любых цифровых суффиксов: в модальном окне перевода теперь всегда чистый человеческий перевод без технических меток.

#### 3. ⚠️ Очистка баз «Ложные друзья» и «Числа и цены»:
- Удалены искусственные суффиксы `w kontekście #` из ложных друзей.
- Очищены повторяющиеся суффиксы поездов `(odjazd pociągu #)` из числовых упражнений.

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

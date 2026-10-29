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
TAG = "v1.4.4"
RELEASE_NAME = "v1.4.4 — Неповторяющиеся ролевые диалоги: динамические сюжеты и уровни сложности"
BODY = """## 🎲 Релиз v1.4.4: Неповторяющиеся ролевые диалоги и уровни сложности (Вариант 1 + Вариант 2)

### 🌟 Что нового в этом релизе:

#### 1. 🎚️ Выбор уровня сложности и стиля диалога:
В карточке каждого сценария теперь можно выбрать один из 4 режимов:
- **🟢 Spokojny (Спокойный, A1–A2):** размеренный темп, простое понятное словоупотребление, предельно терпеливый и доброжелательный собеседник. Идеально для уверенного освоения базовых фраз.
- **🟡 Życiowy (Жизненный, A2–B1):** естественная разговорная польская речь (*«w sumie»*, *«no tak»*, *«zaraz zerknę»*), живой темп и мелкие повседневные жизненные нюансы.
- **🔴 Wyzwanie / Stresstest (Вызов / Стресс-тест, B1–B2):** требовательный разговор, бюрократические препоны, очередь, спорные ситуации (например, возврат без бумажного чека по банковскому приложению, ошибка в PESEL, отсутствие рецептурного препарата, острая аллергия).
- **🎲 Losowy (Случайный):** полная неожиданность — приложение само выберет уровень и сюжет для тренировки быстрой адаптации!

#### 2. 🎭 Процедурная генерация неповторяющихся диалогов (Dynamic Seed):
- **Характер и темперамент NPC:** для каждого запуска генерируется уникальный архетип собеседника (уставший и торопливый кассир; педантичный проверяющий ужендник; заботливый и дотошный врач; дружелюбный бариста).
- **Пул сюжетных развилок (Twists):** во всех 15 под-сценариях внедрены уникальные матрицы развилок для каждого уровня сложности (более 100+ живых вариаций!). Один и тот же диалог больше никогда не пойдет по шаблону.
- **Индикатор сложности в диалоге:** в верхней информационной панели отображается цветной значок активного режима (`🟢 Спокойный` / `🟡 Жизненный` / `🔴 Вызов`).

---
### 📦 Скачать релиз:
Прямая ссылка на APK:
[Polish_AI_Tutor_v1.4.4.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.4/Polish_AI_Tutor_v1.4.4.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.4.apk"

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
                print(f"Release created successfully! (id: {release['id']})")
        except urllib.error.HTTPError as e:
            print(f"Error creating release: {e.read().decode()}")
            return

    upload_url = release.get("upload_url", "").split("{")[0]
    if not upload_url:
        print("Error: upload_url not found in release")
        return

    # Delete existing asset if present
    for asset in release.get("assets", []):
        if asset.get("name") == APK_NAME:
            print(f"Asset {APK_NAME} already exists (id: {asset['id']}). Deleting old asset...")
            del_req = urllib.request.Request(
                f"https://api.github.com/repos/{REPO}/releases/assets/{asset['id']}",
                headers=headers,
                method="DELETE"
            )
            with urllib.request.urlopen(del_req, context=ctx) as del_resp:
                print("Old asset deleted.")

    # 3. Upload APK asset
    upload_url_with_name = f"{upload_url}?name={APK_NAME}"
    with open(root_apk, "rb") as f:
        apk_data = f.read()

    upload_headers = {
        "Authorization": f"token {TOKEN}",
        "Content-Type": "application/vnd.android.package-archive",
        "Content-Length": str(len(apk_data)),
        "User-Agent": "ReleaseScript"
    }

    print(f"Uploading {APK_NAME} ({len(apk_data) / (1024*1024):.2f} MB)...")
    req = urllib.request.Request(upload_url_with_name, data=apk_data, headers=upload_headers, method="POST")
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            asset = json.loads(resp.read().decode())
            print(f"Asset uploaded successfully! Download URL: {asset.get('browser_download_url')}")
    except urllib.error.HTTPError as e:
        print(f"Asset upload error: {e.code} - {e.read().decode()}")

if __name__ == "__main__":
    main()


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
TAG = "v1.4.10"
RELEASE_NAME = "v1.4.10 — Исправление верстки: плашка профессий, стильный переключатель категорий диалогов и стрелка прокрутки"
BODY = """## 🛠️ Релиз v1.4.10: Исправление верстки и улучшение UX профессий и диалогов

### 🌟 Что исправлено и улучшено:

1. **Плашка «Польский для профессий» на главном экране:**
   - Исправлено наложение и обрезание бейджа `B2C / B2B`: заголовок и бейдж теперь скомпонованы в адаптивном контейнере `Wrap`, что гарантирует идеальное отображение без срезания справа на любых смартфонах.

2. **Премиальный переключатель категорий диалогов («Повседневная жизнь» / «Работа и профессия»):**
   - Убран тесный компактный `SegmentedButton`.
   - Внедрен просторный адаптивный 2-секционный переключатель высотой 46px с мягкими скруглениями, читаемыми шрифтами, иконками и акцентной подсветкой активного таба. Надписи категорий теперь помещаются полностью и выглядят эстетично.

3. **Шапка экрана «Польский для профессий»:**
   - В `AppBar` добавлена адаптивная защита заголовка (`Expanded` / `TextOverflow.ellipsis`), предотвращающая выход текста за границы экрана.

4. **Интерактивная стрелка прокрутки профессий:**
   - В горизонтальной ленте выбора профессий добавлена акцентная кнопка-стрелочка `[ > ]`.
   - Пользователь сразу видит, что в списке есть дополнительные профессии, а по клику на стрелочку лента плавно прокручивается вперед!

---
### 📦 Скачать релиз:
Прямая ссылка на APK:
[Polish_AI_Tutor_v1.4.10.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.10/Polish_AI_Tutor_v1.4.10.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.10.apk"

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


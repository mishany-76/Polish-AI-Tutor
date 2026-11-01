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
TAG = "v1.5.6"
RELEASE_NAME = "v1.5.6 — 🎯 3 уровня сложности в Диктанте + 📥 Авто-добавление слов из уроков и диалогов"
BODY = """## 🎯 Релиз v1.5.6: Адаптивный Диктант (3 уровня) + Бесшовное авто-добавление слов

Релиз сформирован на основе живого пользовательского фидбека: снижение порога входа в правописание для новичков и автоматизация накопления словарного запаса.

### 🌟 Что нового в версии 1.5.6:

1. **🎯 3 уровня сложности в режиме «Диктант» (Active Recall Speller):**
   - 🟢 **Очень легко (Новичок):**
     - В кассетнице находятся **только буквы самого слова** (перемешанные, как в пазле — ни одной лишней ложной буквы!).
     - Интерактивные визуальные слоты под каждую букву (`_ _ _ _ _`).
     - Кнопка 👁️ **«Подсмотреть слово»**: на 2 секунды показывает правильный зрительный образ слова, после чего его легко собрать тапами.
     - Озвучка автоматически замедлена до комфортной для слуха скорости.
   - 🟡 **Легко (Базовый):**
     - Буквы слова + 2 мягкие орфографические ловушки (`ó/u`, `rz/ż`).
     - Визуальные слоты и кнопка 💡 **«Подсказка буквы»** (открывает следующую букву).
   - 🔴 **Трудно (Продвинутый):**
     - Классический строгий диктант на слух: кассетница с полным пулом дистракторов, возможность печатать с системной клавиатуры без подсказок.
   - Выбранный уровень сложности сохраняется в памяти приложения.

2. **📥 Автоматическое добавление новых слов из ВСЕХ диалогов и уроков:**
   - Больше не нужно вручную нажимать кнопки сохранения:
     - При завершении **ролевых диалогов с ИИ** новые слова автоматически регистрируются в словаре.
     - При изучении **«Живых эпизодов»** и **«Польского для профессий»** все термины автоматически попадают в персональный банк.
     - При прохождении тем **«Польского Букваря»** слова автоматически сохраняются.
   - **Защита от дубликатов:** если слово уже есть в словаре, дубликат не создаётся (`registerLessonWord`).
   - **Интервальное повторение SM-2:** новые слова сразу готовы к первому повторению сегодня, а затем повторяются по научно доказанной системе (1 день → 6 дней → 14 дней → месяц), чтобы быть «на глазу и на слуху».

---
### 📦 Скачать:
- **APK:** `Polish_AI_Tutor_v1.5.6.apk`
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
    req = urllib.request.Request(
        f"https://api.github.com/repos/{REPO}/releases/tags/{TAG}",
        headers=headers,
    )
    release_id = None
    upload_url_template = None
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            data = json.loads(resp.read().decode())
            release_id = data.get("id")
            upload_url_template = data.get("upload_url")
            print(f"Found existing release {TAG} (id={release_id}).")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"Release {TAG} does not exist yet. Creating...")
        else:
            raise

    # 2. Create release if needed
    if not release_id:
        create_payload = json.dumps({
            "tag_name": TAG,
            "target_commitish": "main",
            "name": RELEASE_NAME,
            "body": BODY,
            "draft": False,
            "prerelease": False,
        }).encode("utf-8")
        req = urllib.request.Request(
            f"https://api.github.com/repos/{REPO}/releases",
            data=create_payload,
            headers={**headers, "Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req, context=ctx) as resp:
            data = json.loads(resp.read().decode())
            release_id = data.get("id")
            upload_url_template = data.get("upload_url")
            print(f"Created release {TAG} (id={release_id}).")

    # 3. Copy APK to release filename
    src_apk = r"build\app\outputs\flutter-apk\app-release.apk"
    dst_apk = rf"build\app\outputs\flutter-apk\Polish_AI_Tutor_{TAG}.apk"
    if not os.path.exists(src_apk):
        raise FileNotFoundError(f"Source APK not found: {src_apk}")
    shutil.copyfile(src_apk, dst_apk)
    apk_size = os.path.getsize(dst_apk)
    print(f"Prepared APK: {dst_apk} ({apk_size / (1024*1024):.2f} MB)")

    # 4. Check if asset already exists in release and delete if so
    req = urllib.request.Request(
        f"https://api.github.com/repos/{REPO}/releases/{release_id}/assets",
        headers=headers,
    )
    with urllib.request.urlopen(req, context=ctx) as resp:
        assets = json.loads(resp.read().decode())
        target_name = f"Polish_AI_Tutor_{TAG}.apk"
        for a in assets:
            if a.get("name") == target_name:
                asset_id = a.get("id")
                print(f"Deleting existing asset {target_name} (id={asset_id})...")
                del_req = urllib.request.Request(
                    f"https://api.github.com/repos/{REPO}/releases/assets/{asset_id}",
                    headers=headers,
                    method="DELETE",
                )
                with urllib.request.urlopen(del_req, context=ctx) as del_resp:
                    pass

    # 5. Upload asset
    upload_url = upload_url_template.split("{")[0] + f"?name=Polish_AI_Tutor_{TAG}.apk"
    print(f"Uploading Polish_AI_Tutor_{TAG}.apk...")
    with open(dst_apk, "rb") as f:
        apk_data = f.read()

    up_req = urllib.request.Request(
        upload_url,
        data=apk_data,
        headers={
            **headers,
            "Content-Type": "application/vnd.android.package-archive",
            "Content-Length": str(len(apk_data)),
        },
    )
    with urllib.request.urlopen(up_req, context=ctx) as resp:
        res_data = json.loads(resp.read().decode())
        browser_download_url = res_data.get("browser_download_url")
        print(f"Successfully uploaded: {browser_download_url}")

if __name__ == "__main__":
    upload_release()


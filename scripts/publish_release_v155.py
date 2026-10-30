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
TAG = "v1.5.5"
RELEASE_NAME = "v1.5.5 — 🔔 Локальные пуш-напоминания (Daily Streak & Repetition Reminder)"
BODY = """## 🔔 Релиз v1.5.5: Локальные Push-напоминания (Шаг №2 подготовки к монетизации)

Внедрена полнофункциональная локальная система умных напоминаний для удержания пользователей (Retention D7/D30) и регулярных повторений слов по алгоритму SuperMemo SM-2.

### 🌟 Что нового в версии 1.5.5:

1. **🔔 Локальные Push-напоминания (Daily Notifications):**
   - Напоминания работают **полностью автономно и локально**, без внешних серверов и без сбора персональных данных.
   - Используются оптимизированные каналы уведомлений Android с приоритетом `High`.
   - Поддержка разрешений Android 13+ (POST_NOTIFICATIONS) и авто-перезапуска после перезагрузки телефона (`RECEIVE_BOOT_COMPLETED`).

2. **⏰ Гибкая настройка времени и управление:**
   - В разделе **«Настройки»** добавлена карточка **«Ежедневные напоминания / Щоденні нагадування / Codzienne przypomnienia»**:
     - 🔘 Переключатель включения / выключения напоминаний.
     - 🕒 Выбор точного времени напоминания (по умолчанию 19:00) через удобный системный таймпикер.
     - 🚀 Кнопка **«Отправить тестовое уведомление»** для мгновенной проверки отображения в шторке смартфона.

3. **🧠 Контекстные умные тексты на 3 языках:**
   - При наличии слов, готовых к повторению по алгоритму SM-2: показывает точное число ожидающих слов и призыв уделить 3 минуты на закрепление.
   - При активной ударной серии: мотивирует сохранить серию дней (*streak*).
   - Все сообщения полностью локализованы на 🇺🇦 Украинский, 🇷🇺 Русский и 🇵🇱 Польский языки.

---
### 📦 Скачать:
- **APK:** `Polish_AI_Tutor_v1.5.5.apk`
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


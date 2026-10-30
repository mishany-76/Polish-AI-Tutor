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
TAG = "v1.5.4"
RELEASE_NAME = "v1.5.4 — 💾 Бэкап и восстановление данных + 🔗 Сквозная связность модулей"
BODY = """## 💾 Релиз v1.5.4: Резервное копирование и восстановление + Сквозная связность модулей (User Journey)

Первый фундаментальный шаг подготовки к монетизации: защита данных пользователей и устранение изолированности экранов.

### 🌟 Что нового в версии 1.5.4:

1. **💾 Резервное копирование и восстановление всей базы данных (.json):**
   - В разделе «Настройки» добавлена специальная карточка **«Резервное копирование и восстановление»**:
     - 📤 **Создать резервную копию:** выгружает все сохраненные слова со всеми точными метриками алгоритма SM-2 (интервалы, повторения, фактор легкости, даты), все штампы «Польского паспорта», ударные серии (streak) и прогресс серий/экзаменов в компактный `.json` файл и открывает системное меню отправки (Google Drive, Telegram, Почта и т.д.).
     - 📥 **Восстановить из файла:** выбор резервного `.json` файла через системный диалог и мгновенное безопасное восстановление всех слов и настроек без потери прогресса.

2. **🔗 Интерактивные штампы «Польского паспорта»:**
   - Теперь каждая печать в паспорте — это не просто статичная плашка, а **живой навигационный портал**:
     - При тапе на штамп открывается карточка с кнопкой **«Перейти к заданию»**:
       - Штампы пополнения словаря (*«Первое слово»*, *«50 слов»*, *«100 слов»*) ведут прямо в **Словарь**.
       - Штампы сканера ведут в **Сканер документов и вывесок**.
       - Штампы диалогов ведут в **Ролевые диалоги с Kasią**.
       - Штампы викторин ведут в **Тренажеры и викторины**.
       - Штампы выученных слов (*«10/50 освоенных слов»*) ведут в **Экран повторения SM-2**.
       - Штамп «Польский паспорт» ведёт в **Экзаменационный Boss Fight**.

3. **🎯 Мостик «Викторина → Словарь и Диктант»:**
   - По завершении викторины, если допущены ошибки, пользователь видит две быстрые кнопки:
     - 📥 **«Добавить ошибки в словарь»** — автоматическое сохранение слов из неверных ответов в личный словарь SM-2 в один клик.
     - 🎧 **«Потренировать в диктанте»** — мгновенный запуск тренировки правописания этих слов на слух.

4. **📚 Мостик «Словарь → Повторение SM-2 и Диктант»:**
   - В шапке словаря под шкалой CEFR добавлены две удобные кнопки прямого перехода:
     - 🧠 **«Повторить слова (SM-2)»** (с бейджем количества готовых к повторению слов).
     - 🎧 **«Тренировать в диктанте»** — запуск правописания по накопленной колоде.

---
### 📦 Скачать:
- **APK:** `Polish_AI_Tutor_v1.5.4.apk`
"""

def upload_release():
    print(f"Publishing release {TAG} to {REPO}...")
    headers = {
        "Authorization": f"token {TOKEN}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "Antigravity-Release-Publisher",
    }
    
    ctx = ssl.create_default_context()
    
    url = f"https://api.github.com/repos/{REPO}/releases/tags/{TAG}"
    req = urllib.request.Request(url, headers=headers)
    release_id = None
    upload_url = None
    
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            data = json.loads(resp.read().decode())
            release_id = data["id"]
            upload_url = data["upload_url"].split("{")[0]
            print(f"Release {TAG} already exists (id={release_id}).")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"Creating release {TAG}...")
            create_url = f"https://api.github.com/repos/{REPO}/releases"
            payload = json.dumps({
                "tag_name": TAG,
                "name": RELEASE_NAME,
                "body": BODY,
                "draft": False,
                "prerelease": False
            }).encode()
            create_req = urllib.request.Request(create_url, data=payload, headers=headers)
            with urllib.request.urlopen(create_req, context=ctx) as create_resp:
                data = json.loads(create_resp.read().decode())
                release_id = data["id"]
                upload_url = data["upload_url"].split("{")[0]
                print(f"Created release {TAG} (id={release_id}).")
        else:
            raise

    # Copy apk
    src_apk = r"build\app\outputs\flutter-apk\app-release.apk"
    dst_apk = r"build\app\outputs\flutter-apk\Polish_AI_Tutor_v1.5.4.apk"
    if not os.path.exists(src_apk):
        print(f"Error: {src_apk} not found!")
        return
    
    shutil.copyfile(src_apk, dst_apk)
    size_mb = os.path.getsize(dst_apk) / (1024 * 1024)
    print(f"Prepared APK: {dst_apk} ({size_mb:.2f} MB)")
    
    asset_name = "Polish_AI_Tutor_v1.5.4.apk"
    
    assets_url = f"https://api.github.com/repos/{REPO}/releases/{release_id}/assets"
    assets_req = urllib.request.Request(assets_url, headers=headers)
    with urllib.request.urlopen(assets_req, context=ctx) as resp:
        assets = json.loads(resp.read().decode())
        for a in assets:
            if a["name"] == asset_name:
                print(f"Deleting existing asset {a['id']}...")
                del_req = urllib.request.Request(a["url"], headers=headers, method="DELETE")
                with urllib.request.urlopen(del_req, context=ctx) as _:
                    pass
                break
                
    print(f"Uploading {asset_name}...")
    upload_headers = {
        "Authorization": f"token {TOKEN}",
        "Content-Type": "application/vnd.android.package-archive",
        "User-Agent": "Antigravity-Release-Publisher",
    }
    
    with open(dst_apk, "rb") as f:
        apk_data = f.read()
        
    upload_target = f"{upload_url}?name={urllib.parse.quote(asset_name)}"
    up_req = urllib.request.Request(upload_target, data=apk_data, headers=upload_headers)
    with urllib.request.urlopen(up_req, context=ctx) as up_resp:
        result = json.loads(up_resp.read().decode())
        browser_download_url = result.get("browser_download_url", "")
        print(f"Successfully uploaded: {browser_download_url}")

if __name__ == "__main__":
    upload_release()

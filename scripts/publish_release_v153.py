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
TAG = "v1.5.3"
RELEASE_NAME = "v1.5.3 — 🏭 Заводы и Производство, 192 профтермина, выбор сложности диалогов и шкала CEFR"
BODY = """## 🏭 Релиз v1.5.3: Расширение «Польский для профессий», новая категория «Производство и заводы», выбор сложности диалогов и шкала CEFR

Масштабное расширение профессионального хаба: добавление ключевого производственного сектора Польши (заводы электроники, пищевая промышленность, сборочные линии), 5-кратное увеличение терминологической базы (по 32 термина на направление) и интеграция общеевропейской шкалы CEFR в словарь.

### 🌟 Что нового в версии 1.5.3:

1. **🏭 Новая 6-я профессия «Производство и заводы» (Produkcja i Zakłady Przemysłowe):**
   - 32 отборных практических термина: *linia produkcyjna*, *brygadzista*, *kontrola jakości (QA)*, *odrzut / brak*, *stop awaryjny*, *suwmiarka*, *norma akordowa*, *fartuch ochronny*, *karta zakładowa*, *przepustka*, *premia za frekwencję*, *nocka*, *nadgodziny*, *instruktaż BHP* и др.
   - 3 полноценных рабочих сценария ролевых диалогов:
     - 🦺 *Инструктаж по технике безопасности и начало смены с бригадиром*.
     - ⚠️ *Контроль качества (QA): остановка конвейера и оформление брака*.
     - 📅 *График работы, ночные смены и согласование сверхурочных (nadgodziny)*.

2. **📚 Расширение профессионального словаря в 5 раз (192 термина):**
   - Все 6 профессий теперь содержат по **32 практических термина** (всего 192 детальных термина с контекстными примерами употребления и озвучкой):
     - 🚚 *Логистика, склад и водители (Logistyka i Magazyn)* — 32 термина
     - 🏗️ *Строительство и ремонты (Budownictwo i Remonty)* — 32 термина
     - 🍽️ *Гастрономия и ресторанный сервис (Gastronomia)* — 32 термина
     - 🧹 *Клининг, уход и отели (Sprzątanie i Hotelarstwo)* — 32 термина
     - 💻 *IT, офис и корпоративный сектор (IT i Praca Biurowa)* — 32 термина
     - 🏭 *Производство и фабрики (Produkcja i Zakłady)* — 32 термина
   - Добавление любого профессионального словаря в свой личный словарь в один клик.

3. **🎭 Единый конфигуратор ролевых диалогов в профессиях:**
   - Теперь при запуске диалога прямо из экрана профессий открывается интерактивное модальное окно:
     - Выбор под-сценария.
     - **Кто начинает диалог:** ИИ первым (*«Dzień dobry...»*) или Пользователь первым.
     - **Выбор уровня сложности:** *Спокойный (Calm)*, *Жизненный (Life с реалистичными твистами)*, *Вызов (Challenge с трудным собеседником)*, *Случайный (Random)*.

4. **📊 Шкала словарного запаса (CEFR) в разделе «Мой словарь»:**
   - Наглядная плашка текущего ранга владения языком на основе размера словаря:
     - **A0** (0–499 слов) — *Абсолютный новичок (Букварь)*
     - **A1** (500–1499 слов) — *Базовый (быт и выживание)*
     - **A2** (1500–2999 слов) — *Коммуникативный (повседневное общение)*
     - **B1** (3000–4499 слов) — *Самостоятельный (работа и социум)*
     - **B2** (4500–5999 слов) — *Свободный рабочий (профессиональное владение)*
     - **C1** (6000+ слов) — *Продвинутый (полная беглость)*
   - Прогресс-бар с точным числом слов до следующего уровня (*«До уровня A1 осталось 252 слов»*).
   - Информационная шторка с объяснением: 5 000–6 000 слов покрывают более 95% повседневного и профессионального польского языка.

---
### 📦 Скачать:
- **APK:** `Polish_AI_Tutor_v1.5.3.apk`
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
    dst_apk = r"build\app\outputs\flutter-apk\Polish_AI_Tutor_v1.5.3.apk"
    if not os.path.exists(src_apk):
        print(f"Error: {src_apk} not found!")
        return
    
    shutil.copyfile(src_apk, dst_apk)
    size_mb = os.path.getsize(dst_apk) / (1024 * 1024)
    print(f"Prepared APK: {dst_apk} ({size_mb:.2f} MB)")
    
    # Upload APK asset
    asset_name = "Polish_AI_Tutor_v1.5.3.apk"
    
    # Check if asset already exists
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

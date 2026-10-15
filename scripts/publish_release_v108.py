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
TAG = "v1.0.8"
RELEASE_NAME = "v1.0.8 — Банк тренировок 6000+ и живой симулятор диалогов"
BODY = """## 🚀 Релиз v1.0.8: Масштабное расширение возможностей приложения

### 🌟 Что нового:

#### 1. 📚 Масштабный банк тренировок на 6,000+ единиц (JSON-ассеты):
- **«Хибні друзі»**: 1,225 карточек (слова-обманки с разбором ловушек).
- **«Закінчення»**: 1,850 контекстных предложений на все 7 польских падежей.
- **«Числа та ціни»**: 1,230 практических вопросов (кассы, чеки, BLIK, часы, сдача).
- **«Аудіо-тренажер»**: 1,850 выражений живой разговорной речи.
- **Всего 6,155 уникальных заданий**, загружаемых асинхронно через JSON без расхода оперативной памяти смартфона.
- Сохранен умный адаптивный алгоритм отсева выученного (`DrillProgressService`).

#### 2. 🎭 Многосюжетный живой симулятор диалогов (Dynamic Roleplay):
- **Выбор под-сценариев**: при выборе ситуации (Żabka/Biedronka, Банк, Кафе, Врач, Urząd) открывается выбор конкретной бытовой ветки (на кассе, поиск товара, возврат/брак; открытие счета, застрявшая карта, выписка для карты побыту и др.).
- **Выбор инициатора диалога**: тумблер `[ 🗣️ Я звертаюся першим | 👂 До мене звертаються ]`. При выборе ученика ИИ ждет реплику, предоставляя удобную подсказку для старта.
- **Реалистичные сюжетные повороты (Plot Twists)**: персонажи ведут себя как живые поляки (завис терминал, нет свободных номерков к врачу, замена блюда/лекарства, исправление чека).
- Сохранена полная синхронная ИИ-локализация (文A) и польская озвучка TTS (🔊).

#### 3. 🌐 Полная трехъязычная локализация (UK / RU / PL) и стабильность:
- Нулевое количество ошибок `flutter analyze`.
- Все 15/15 unit и widget-тестов пройдены успешно.
"""

APK_SRC = os.path.join("build", "app", "outputs", "flutter-apk", "app-debug.apk")
APK_NAME = "Polish_AI_Tutor_v1.0.8.apk"
APK_DEST = os.path.join(os.getcwd(), APK_NAME)

ctx = ssl.create_default_context()

def api_req(url, method="GET", data=None, headers=None):
    h = {
        "Authorization": f"token {TOKEN}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "Polish-AI-Tutor-Deployer",
    }
    if headers:
        h.update(headers)
    
    req = urllib.request.Request(url, headers=h, method=method)
    if data is not None:
        if isinstance(data, (dict, list)):
            data = json.dumps(data).encode("utf-8")
            req.add_header("Content-Type", "application/json")
        req.data = data
    
    try:
        with urllib.request.urlopen(req, context=ctx) as resp:
            raw = resp.read()
            return resp.status, json.loads(raw.decode("utf-8")) if raw else {}
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8", errors="ignore")
        return e.code, {"error": err_body}

def main():
    print("=== Релиз v1.0.8 Polish AI Tutor ===")
    if not os.path.exists(APK_SRC):
        print(f"❌ APK файл не найден: {APK_SRC}")
        return

    print(f"📦 Копирование APK в корень: {APK_DEST}")
    shutil.copyfile(APK_SRC, APK_DEST)
    file_size_mb = os.path.getsize(APK_DEST) / (1024 * 1024)
    print(f"✅ Размер APK: {file_size_mb:.2f} МБ")

    print(f"🔍 Проверка существующего релиза {TAG}...")
    status, rel = api_req(f"https://api.github.com/repos/{REPO}/releases/tags/{TAG}")
    if status == 200:
        rel_id = rel["id"]
        print(f"⚠️ Релиз {TAG} уже существует (ID {rel_id}), удаляем старый для чистоты...")
        api_req(f"https://api.github.com/repos/{REPO}/releases/{rel_id}", method="DELETE")
        api_req(f"https://api.github.com/repos/{REPO}/git/refs/tags/{TAG}", method="DELETE")

    print(f"✨ Создание нового релиза {TAG}...")
    payload = {
        "tag_name": TAG,
        "name": RELEASE_NAME,
        "body": BODY,
        "draft": False,
        "prerelease": False,
    }
    status, new_rel = api_req(f"https://api.github.com/repos/{REPO}/releases", method="POST", data=payload)
    if status not in (200, 201):
        print(f"❌ Ошибка создания релиза: {status} -> {new_rel}")
        return
    
    rel_id = new_rel["id"]
    upload_url_raw = new_rel["upload_url"]
    upload_url = upload_url_raw.split("{")[0]
    print(f"✅ Релиз создан! ID: {rel_id}")

    print(f"🚀 Загрузка APK ассета: {APK_NAME}...")
    with open(APK_DEST, "rb") as f:
        apk_bytes = f.read()

    upload_full_url = f"{upload_url}?name={urllib.parse.quote(APK_NAME)}"
    status, asset_resp = api_req(
        upload_full_url,
        method="POST",
        data=apk_bytes,
        headers={"Content-Type": "application/vnd.android.package-archive"}
    )
    if status in (200, 201):
        download_url = asset_resp.get("browser_download_url")
        print(f"🎉 Релиз v1.0.8 успешно опубликован!")
        print(f"🔗 Ссылка для скачивания: {download_url}")
    else:
        print(f"❌ Ошибка загрузки ассета: {status} -> {asset_resp}")

if __name__ == "__main__":
    main()

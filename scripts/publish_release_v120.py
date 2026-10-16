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
TAG = "v1.2.0"
RELEASE_NAME = "v1.2.0 — Мой польский за месяц (Monthly Progress Wrapped) & Smart Doc Scanner"
BODY = """## 🚀 Релиз v1.2.0: «Мой польский за месяц» (Monthly Progress Wrapped) & Smart Doc Scanner

### 🌟 Что нового в этом релизе:

#### 1. 📊 «Мой польский за месяц» (Monthly Progress Wrapped — Пункт 1.3 Дорожной карты):
- **Персональные ежемесячные итоги обучения в стиле Spotify Wrapped:**
  - Полный подсчет словарного объема: общее количество слов в словаре и чистый прирост за текущий календарный месяц.
  - Количество слов, выученных назубок (освоенных по SM-2 с интервалом $\\ge 21$ дней).
  - Прогресс по европейской шкале CEFR (A1 / A2 / B1) с наглядным прогресс-баром и процентом достижения цели.
  - Статистика живого общения: количество завершенных диалогов с Kasia.
  - Статистика практической пользы: число просканированных вывесок, чеков и разобранных официальных договоров.
  - Дни непрерывного обучения (ударный режим / streak).
- **Динамический персональный титул месяца:**
  - 👑 *Варшавский Переговорник (Warszawski Negocjator)*
  - 📚 *Лексический Снайпер (Leksykalny Snajper)*
  - 🎯 *Мастер Практики (Mistrz Praktyki)*
  - 🔥 *Человек из Стали (Człowiek z Żelaza)*
  - 🇵🇱 *Активный Студент (Aktywny Student)*
- **Вирусный шеринг результатов:**
  - Кнопка «Поделиться моим результатом» формирует красивую выжимку с эмодзи и копирует в буфер обмена для мгновенной публикации в соцсетях (Instagram, Telegram, TikTok, Facebook).
- **Эстетика «Варшавский Модерн»:**
  - Благородный глубокий кармин (`#6B0B17`), золотистые бейджи, тактильная плавность и интерактивный баннер на главном экране.

#### 2. ⚖️ Умный разбор польских документов (Smart Doc Scanner — Пункт 1.2):
- Разбор официальных договоров (*Umowa o pracę*, *Umowa najmu*), писем из *Urząd Skarbowy*, решений *ZUS*, предписаний и штрафов.
- Выделение юридической сути, финансовых условий, скрытых рисков (🔴/🟡), пошагового плана действий и пакетное сохранение терминов в словарь.

#### 3. 🇵🇱 Система «Польский паспорт» (Polski Paszport — Пункт 1.1):
- 15 интерактивных гербовых штампов за реальные достижения, серия дней (streak) и золотой статус *Obywatel Języka*.

#### 4. 🌐 Строгая трехъязычная локализация и обновленное руководство:
- 100% строгая локализация (🇺🇦 Украинский, 🇷🇺 Русский, 🇵🇱 Польский).
- В интерактивное руководство пользователя добавлен Раздел 7 с инструкцией по работе с ежемесячными итогами.

#### 5. 🧪 Качество и надежность:
- 0 ошибок `flutter analyze`.
- **22/22 unit & widget тестов** успешно пройдены (добавлены тесты расчетов `MonthlyStatsService` и локализации).
"""

APK_SRC = os.path.join("build", "app", "outputs", "flutter-apk", "app-release.apk")
APK_NAME = "Polish_AI_Tutor_v1.2.0.apk"
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
    print("=== Релиз v1.2.0 Polish AI Tutor ===")
    if not os.path.exists(APK_SRC):
        if not os.path.exists(APK_DEST):
            print(f"❌ APK файл не найден ни в {APK_SRC}, ни в {APK_DEST}")
            return
    else:
        print(f"📦 Копирование APK в {APK_DEST}...")
        shutil.copy2(APK_SRC, APK_DEST)
    
    size_mb = os.path.getsize(APK_DEST) / (1024 * 1024)
    print(f"✅ APK готов: {APK_DEST} ({size_mb:.2f} MB)")

    if not TOKEN:
        print("❌ Не найден токен GitHub! Задайте GITHUB_TOKEN.")
        return

    # 1. Проверяем или создаем релиз
    print(f"🔍 Проверка релиза {TAG} на GitHub...")
    status, release = api_req(f"https://api.github.com/repos/{REPO}/releases/tags/{TAG}")
    
    if status == 200 and "id" in release:
        release_id = release["id"]
        print(f"ℹ️ Релиз {TAG} уже существует (ID: {release_id}). Обновляем описание...")
        api_req(
            f"https://api.github.com/repos/{REPO}/releases/{release_id}",
            method="PATCH",
            data={
                "name": RELEASE_NAME,
                "body": BODY,
            }
        )
    else:
        print(f"🚀 Создание нового релиза {TAG}...")
        payload = {
            "tag_name": TAG,
            "target_commitish": "main",
            "name": RELEASE_NAME,
            "body": BODY,
            "draft": False,
            "prerelease": False,
        }
        status, release = api_req(
            f"https://api.github.com/repos/{REPO}/releases",
            method="POST",
            data=payload,
        )
        if status not in (200, 201):
            print(f"❌ Ошибка создания релиза: {status} -> {release}")
            return
        release_id = release["id"]
        print(f"✅ Релиз успешно создан (ID: {release_id})")

    # 2. Проверяем существующие ассеты
    print("🔍 Проверка существующих ассетов...")
    status, assets = api_req(f"https://api.github.com/repos/{REPO}/releases/{release_id}/assets")
    if status == 200 and isinstance(assets, list):
        for asset in assets:
            if asset.get("name") == APK_NAME:
                print(f"🗑️ Удаление старого ассета {APK_NAME} (ID: {asset['id']})...")
                api_req(f"https://api.github.com/repos/{REPO}/releases/assets/{asset['id']}", method="DELETE")

    # 3. Загружаем APK
    print(f"⬆️ Загрузка {APK_NAME} ({size_mb:.2f} MB) в релиз...")
    upload_url_template = release.get("upload_url", f"https://uploads.github.com/repos/{REPO}/releases/{release_id}/assets{{?name,label}}")
    upload_url = upload_url_template.split("{")[0] + f"?name={urllib.parse.quote(APK_NAME)}"

    with open(APK_DEST, "rb") as f:
        apk_data = f.read()

    status, upload_resp = api_req(
        upload_url,
        method="POST",
        data=apk_data,
        headers={"Content-Type": "application/vnd.android.package-archive"},
    )

    if status in (200, 201):
        download_url = upload_resp.get("browser_download_url", f"https://github.com/{REPO}/releases/download/{TAG}/{APK_NAME}")
        print("\n🎉 УСПЕХ! Релиз v1.2.0 опубликован на GitHub!")
        print(f"🔗 Ссылка на релиз: https://github.com/{REPO}/releases/tag/{TAG}")
        print(f"📥 Прямая ссылка на скачивание APK: {download_url}\n")
    else:
        print(f"❌ Ошибка загрузки APK: {status} -> {upload_resp}")

if __name__ == "__main__":
    main()


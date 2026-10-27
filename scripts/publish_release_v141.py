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
TAG = "v1.4.1"
RELEASE_NAME = "v1.4.1 — Исправление викторин, дубляж ответов, кассетница букв в диктанте и реалтайм-паспорт"
BODY = """## 🛠️ Релиз v1.4.1: Комплексное улучшение викторин и тренажеров

### 🌟 Что исправлено и улучшено:

#### 1. 🎧 Подраздел «Аудиотренажер» (Audio drill):
- **Польский текст вопроса:** слово/фраза теперь отображается крупно и четко по центру с кнопкой озвучки.
- **Инструкция к заданию:** аккуратная контрастная плашка «🎧 Послушайте и выберите перевод:».
- **Дубляж вариантов ответа:** каждый вариант содержит польское слово (жирным шрифтом) + перевод (**dziękuję** — спасибо, **proszę** — пожалуйста, **przepraszam** — извините) для ускоренного привыкания глаз к польской речи.

#### 2. ⚠️ Подраздел «Ложные друзья» (False friends):
- **Двуязычный выбор ответов:** каждый вариант выбора содержит связку польского слова и его перевода:
  - Правильный перевод: `zapomnieć — забыть`
  - Раскрытие ловушки: `zapamiętać — запомнить` (сразу видно настоящее польское слово для понятия «запомнить»)
  - Альтернативные дистракторы: `sklep — магазин`, `pokój — комната`

#### 3. 🔢 Подраздел «Числа, цены и счет» (Numbers & Prices):
- **Слуховой текст теперь на первом плане:** произносимый польский текст (**Pokój numer trzysta dwadzieścia cztery**, **Siedemdziesiąt dwa złote pięćdziesiąt groszy**) выводится крупно и жирно в качестве главного заголовка.
- Контекст ситуации (отель, чек, аптека) вынесен в аккуратный бейдж, а варианты ответа содержат польские обозначения (`Pokój 324`, `72,50 zł`).

#### 4. 🎯 Режим «Диктант» — Кассетница букв (Active Recall Letter Bank):
- **Плитки букв для каждого слова:** под полем ввода формируется интерактивный набор букв, содержащий **все необходимые буквы целевого слова + реалистичные ложные буквы** (`rz/ż`, `ó/u`, `ch/h`, `ą/ę`, `sz/ś`, `cz/ć`).
- Слово можно набирать по тапу на буквы без необходимости переключения на польскую раскладку клавиатуры.
- Добавлена удобная кнопка **«Стереть» (`⌫`)** для быстрого удаления символа.
- Сохранена и наглядно подписана панель быстрой польской диакритики.

#### 5. 👁️ Исправление контрастности текста:
- Полностью устранен «еле видный / призрачный» серый текст в викторинах (`colorScheme.outline`). Все пояснения, инструкции и контексты теперь имеют высокий контраст и легко читаются на любых экранах.

#### 6. 🇵🇱 Реальное время в «Польском паспорте»:
- Достижения, серии дней (streak) и счетчики теперь обновляются **мгновенно в режиме реального времени** при завершении диалогов и прохождении викторин.
- Добавлена авто-синхронизация с базой слов и жестом свайпа вниз (Pull-to-refresh).

---
### 📦 Скачать релиз:
Прямая ссылка на готовый APK:
[Polish_AI_Tutor_v1.4.1.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.1/Polish_AI_Tutor_v1.4.1.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.1.apk"

def main():
    if not os.path.exists(APK_SOURCE):
        print(f"Error: APK not found at {APK_SOURCE}")
        return

    apk_size_mb = os.path.getsize(APK_SOURCE) / (1024 * 1024)
    print(f"APK size: {apk_size_mb:.2f} MB")

    # Копируем APK в корень проекта для истории версий
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


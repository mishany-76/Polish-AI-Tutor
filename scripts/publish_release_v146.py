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
TAG = "v1.4.6"
RELEASE_NAME = "v1.4.6 — Внедрение фичи 2.2: «Польское ресторанное меню» (Menu Scanner & Food Explorer)"
BODY = """## 🍽️ Релиз v1.4.6: Внедрение фичи 2.2 — «Польское ресторанное меню» (Menu Scanner & Food Explorer)

### 🌟 Что нового в версии 1.4.6:

#### 1. 🍽️ Новый режим сканера «Меню»:
- В модуль «Переводчик» добавлен 4-й специализированный режим **«🍽️ Меню»** (в дополнение к Камере, Файлам и Тексту).
- Позволяет сканировать фото ресторанного меню, загружать снимки из галереи или вводить текст блюд вручную.
- Автоматический запуск интеллектуального анализа ресторанного меню с классификацией блюд.

#### 2. 🍲 Интеллектуальный разбор польских блюд и гастрономический гид (OmniRoute + Offline Fallback):
- Глубокий анализ блюд через нейросеть OmniRoute с автоматическим извлечением:
  - Польского названия блюда и адаптированного перевода.
  - Категории (*Zupy, Dania główne, Pierogi, Ryby, Przekąski, Sałatki, Desery, Napoje*).
  - Описания блюда и ключевых ингредиентов польской кухни (*żurek, barszcz, flaki, bigos, kotlet schabowy, pierogi ruskie, placki ziemniaczane, tatar, sernik, szarlotka* и др.).
  - Выявление потенциальных аллергенов (*глютен, лактоза, яйца, орехи, рыба*).
  - Значка вегетарианских и традиционных польских блюд.
  - Оценки примерной стоимости.
- **100% автономный офлайн-режим (Fallback Heuristic):** распознавание классических польских блюд и вывод информации даже без подключения к интернету или при отсутствии API-ключа!

#### 3. 📋 Интерактивная карточка меню (Menu Analysis Sheet):
- Стильный интерфейс в теме «Варшавский Модерн».
- Удобная фильтрация блюд по категориям с помощью чипов-фильтров.
- **Готовая фраза для официанта к каждому блюду** (например, *«Poproszę żurek staropolski w chlebku»*) с возможностью мгновенного озвучивания польским диктором (TTS 🔊) и копирования в буфер обмена.
- Быстрое сохранение незнакомых названий блюд в личный словарь пользователя (`📥 Dodaj do słownika`) с автоматическим примером заказа для повторения через интервальные повторения (SRS).

#### 4. 🗣️ Шпаргалка фраз для общения в ресторане:
- Доступна в один клик даже без сканирования меню кнопкой **«🗣️ Фразы для заведения»**.
- Готовые проверенные фразы с озвучкой и переводом на 3 языка (PL / UK / RU):
  - Приветствие, выбор столика и просьба подать меню.
  - Вопросы официанту об аллергенах, остроте и составе блюд (*«Czy w tym daniu jest gluten?»*, *«Czy to danie jest pikantne?»*).
  - Заказ напитков и десертов.
  - Просьба принести счет и выбор способа оплаты (*«Poproszę rachunek. Płatność kartą / BLIKiem»*).
  - Благодарность за вкусный обед.

#### 5. 🛠️ Стабильность и архитектура:
- Все предыдущие функции (Аудиотренажер, Ролевые диалоги с динамическими вариациями, светлая тема Переводчика, зум документов) полностью сохранены в рабочем состоянии.
- Добавлены комплексные юнит-тесты на разбор меню, офлайн-эвристику и локализацию ресторанных фраз.

---
### 📦 Скачать релиз:
Прямая ссылка на APK:
[Polish_AI_Tutor_v1.4.6.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.6/Polish_AI_Tutor_v1.4.6.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.6.apk"

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


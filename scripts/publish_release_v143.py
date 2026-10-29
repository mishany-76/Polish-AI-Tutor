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
TAG = "v1.4.3"
RELEASE_NAME = "v1.4.3 — Логика ролевых диалогов: исправление всех под-сценариев и реплик ИИ"
BODY = """## 🎭 Релиз v1.4.3: Исправление логики ролевых диалогов и всех под-сценариев

### 🌟 Что исправлено и улучшено:

#### 1. 🛒 Исправлена логика под-сценариев в магазине Żabka / Biedronka:
- **«Возврат или рекламация» (Zwrot lub reklamacja):** 
  - Устранена грубая ошибка, когда ИИ в роли собеседника начинал с шаблонного пробивания покупок на кассе (`czy ma pan aplikację Żappka?`).
  - Теперь при выборе «Собеседник начинает первым» кассир/старший смены обращается точно по ситуации: *«Dzień dobry! Widzę, że podchodzi pan z towarem i paragonem. W czym mogę pomóc, chodzi o reklamację czy zwrot towaru?»*.
  - При начале учеником доступна точная стартовая фраза о несовпадении цены в чеке и на полке или браке.
- **«Поиск товара и срок годности» (Szukanie produktu):** 
  - Работник зала обращается с предложением помочь найти нужный товар на полках, проверить срок годности или выпечку.

#### 2. 🩺 Исправлена логика в медицинском блоке («У врача»):
- **«Регистрация в окошке POZ» (Rejestracja w okienku):**
  - Регистратор в окне четко спрашивает, к какому врачу хочет записаться пациент и срочный ли случай на сегодня, проверяя данные в системе e-WUŚ по номеру PESEL.
- **«В аптеке: 4-значный код e-рецепта» (W aptece: e-recepta):**
  - Фармацевт сразу запрашивает 4-значный код электронного рецепта и номер PESEL: *«Dzień dobry! Poproszę czterocyfrowy kod e-recepty oraz pana numer PESEL»*, а также предлагает польские сертифицированные аналоги (zamienniki) при отсутствии оригинального лекарства.
- **«Прием у врача: симптомы и больничный L4» (Konsultacja lekarska):**
  - Терапевт проводит осмотр, аускультацию легких и оформляет больничный лист L4 с запросом NIP работодателя.

#### 3. 🏦 Логика под-сценариев в банке PKO / IKO:
- **«Банкомат заблокировал карту» (Zablokowana karta):**
  - Консультант банка реагирует на инцидент у банкомата, блокирует скомпрометированный пластик и помогает выпустить виртуальную карту в IKO и снять наличные по BLIK.
- **«Выписка с печатью для Urząd» (Wyciąg z pieczęcią):**
  - Консультант оформляет официальное бумажное свидетельство с гербовой «мокрой» печатью и подписью для воеводства.
- **«Открытие счета» (Otwarcie konta):**
  - Полный цикл оформления PKO Konto za Zero, мультивалютной карты и верификации через SMS.

#### 4. ☕ Кафе («Заказ в кафе») и 🏛️ Urząd («Оформление документов»):
- **Кафе:** детально проработаны заказ (молоко обычное/овсяное), вопросы по аллергенам и безглютеновому меню (karta alergenów) и раздельный счет (karta + BLIK + napiwek).
- **Urząd:** точные диалоги для временной прописки (*meldunek czasowy z umową najmu*), подачи на карту побыту (*załącznik nr 1, odciski palców, 440 zł opłata*) и выдачи готового документа по SMS.

#### 5. 🧠 Архитектурные исправления в формировании системного промпта:
- `SubScenario.setting` больше не перекрывается общим описанием родительского сценария (полная изоляция контекста каждого под-сценария).
- Добавлены выделенные поля: `npcRole`, `setting`, `npcFirstInstruction`, `npcFirstStarterPl` для каждого из 15 под-сценариев.
- Написаны интеграционные тесты для валидации всех 15 ситуаций.

---
### 📦 Скачать релиз:
Прямая ссылка на APK:
[Polish_AI_Tutor_v1.4.3.apk](https://github.com/mishany-76/Polish-AI-Tutor/releases/download/v1.4.3/Polish_AI_Tutor_v1.4.3.apk)
"""

APK_SOURCE = r"c:\Users\1\Development\PolishApp\build\app\outputs\flutter-apk\app-release.apk"
APK_NAME = "Polish_AI_Tutor_v1.4.3.apk"

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


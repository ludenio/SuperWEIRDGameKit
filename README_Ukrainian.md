[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# Ігровий набір SuperWEIRD

Привіт! У [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) ми розробляємо [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (дивіться гру в [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). Це кооперативна гра про проєктування та автоматизацію систем із лемінгоподібними роботами, створена на рушії [Defold](https://defold.com).

На ранніх етапах розробки ми провели багато експериментів із візуальними стилями та геймплеєм. Ми вирішили, що це може бути корисним іншим розробникам, і вирішили випустити код, текстури та анімації цих експериментів під відкритою ліцензією [CC0](LICENSE).

У цьому репозиторії ви знайдете шість різних візуальних стилів ([video](https://youtu.be/RJwOEDY3MP4)) та ігрову логіку симулятора магазину/виробництва. Гравець виконує замовлення клієнтів і розширює виробництво. Ви можете зіграти в [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github).

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

Приєднуйтеся до нашого [Discord](https://discord.gg/ludenio), щоб розповісти, що б ви створили за допомогою цих прототипів. Або зазирніть на наш [YouTube channel](https://www.youtube.com/@ludenio) — там багато цікавого, зокрема [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Посилання:
- Discord (ми там щодня): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Розсилка з оновленнями та текстовими щоденниками розробки: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Партнери

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD створюється за підтримки [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun) — благодійного фонду, який прагне дати дітям із різних спільнот доступ до науки й технологій. Вони вважають математику фундаментом майбутніх інновацій і фінансують організації, що надихають та розвивають математичні таланти. Якщо вас цікавлять інші освітні проєкти, зверніть увагу на партнерів Carina Initiatives:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Швидкий старт

1. Встановіть Defold Editor: https://defold.com
2. Клонуйте або завантажте репозиторій.
3. Відкрийте теку проєкту в Defold Editor.
4. Зберіть і запустіть проєкт.

Примітка: для редагування анімацій Spine потрібен Spine Editor.

# Структура проєкту

1. Завантаження
   - `loader` — запускається разом із грою, залишається в пам’яті та керує завантаженням/вивантаженням колекцій через механізм Collection Proxy; під час запуску ініціалізує стартове меню.
   - `menu` — стартове меню, яке показується під час запуску гри.

2. Основна частина
   - `main` — спільний код гри: скрипти та модулі, що використовуються в усіх світах; містить усю ігрову логіку.
   - `assets` — ігрові асети: текстури, моделі Spine, тайлові карти та атласи. Для кожного світу є окрема тека `world_1`, `world_2` тощо з унікальним візуалом.
   - `worlds` — візуальна конфігурація світів: колекції та ігрові об’єкти. Кожен світ — окрема колекція в `world_1`, `world_2` тощо.

3. Додаткові матеріали
   - `SuperWEIRDGameKit_assets` — упорядкований набір графіки та моделей Spine, використаних у проєкті.

# Логіка керування світами

- Перемикання світів здійснюється через `loader`, який завантажує та вивантажує колекції.
- Налаштування світу: оновлюйте візуальні параметри та ігрові об’єкти в `worlds/world_X`, а графіку — в `assets/world_X`.

## Додавання нового світу

1. Створіть теки `assets/world_N` і `worlds/world_N`.
2. Скопіюйте шаблон із наявного світу.
3. Зареєструйте новий світ у коді завантажника/меню (див. логіку в `main`).
4. Переконайтеся, що колекції та асети коректно пов’язані.

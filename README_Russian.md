[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# SuperWEIRD Game Kit

Привет! Мы в компании [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) разрабатываем игру [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (страница игры в [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). Это кооперативная игра про проектирование и автоматизацию систем с помощью лемингоподобных роботов на движке [Defold](https://defold.com).

В самом начале разработки было много экспериментов с визуальным стилем и геймплеем. Мы подумали, что это может пригодиться другим разработчикам и решили выложить код, текстуры и анимации этих экспериментов под открытой лицензией [CC0](LICENSE).

В этом репозитории вы найдёте шесть разных визуальных стилей ([видео](https://youtu.be/RJwOEDY3MP4)) и игровую логику симулятора магазина/производства. Игрок обслуживает заказы клиентов и расширяет производство товаров. Вы можете сыграть в [демо на itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github).

[![Project Video](youtube_intro_cover.png)](https://youtu.be/5moJ_7u64TM)

Заходите к нам в [Discord](https://discord.gg/ludenio), чтобы рассказать, что бы вы сделали с помощью этих прототипов. Или загляните на наш [YouTube-канал](https://www.youtube.com/@ludenio_ru) — там много интересного, в том числе [дневники разработки проекта SuperWEIRD](https://www.youtube.com/@ludenio_ru/videos).

Ссылки:
- Discord (мы там каждый день): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio_ru
- Рассылка с новостями и текстовыми дневниками разработки: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Партнёры

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

Проект SuperWEIRD создаётся при поддержке [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun) — благотворительного фонда, стремящегося дать возможность детям из разных сообществ познакомиться с наукой и технологиями. Они считают математику фундаментом будущих инноваций и финансируют организации, вдохновляющие и раскрывающие математические таланты. Если вас интересуют другие образовательные проекты, обратите внимание на партнёров Carina Initiatives:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Быстрый старт

1. Установите Defold Editor: https://defold.com
2. Склонируйте или скачайте репозиторий.
3. Откройте папку проекта в Defold Editor.
4. Соберите и запустите проект (Build and Run).

Примечание: для редактирования Spine-анимаций требуется Spine Editor.

# Структура проекта

1. Загрузка
   - `loader` — стартует вместе с игрой, остаётся в памяти и управляет загрузкой/выгрузкой коллекций через механизм Collection Proxy; при запуске инициирует стартовое меню.
   - `menu` — стартовое меню, показываемое при старте игры.

2. Основная часть
   - `main` — общий код игры: скрипты и модули, единые для всех миров; здесь хранится вся игровая логика.
   - `assets` — игровые ассеты: текстуры, Spine-модели, тайловые карты и атласы. Для каждого мира — отдельная папка `world_1`, `world_2` и т.д. с уникальными графическими элементами.
   - `worlds` — визуальная настройка миров: коллекции и игровые объекты. Каждый мир — отдельная коллекция в папке `world_1`, `world_2` и т.д.

3. Дополнительные материалы
   - `SuperWEIRDGameKit_assets` — отсортированный набор графики и Spine-моделей, использованных в проекте.

# Логика работы с мирами

- Переключение миров осуществляется через `loader`, который подгружает и выгружает коллекции.
- Кастомизация мира: обновляйте визуальные параметры и игровые объекты в `worlds/world_X`, а графику — в `assets/world_X`.

## Добавление нового мира:

1. Создайте папки `assets/world_N` и `worlds/world_N`.
2. Скопируйте шаблон из существующего мира.
3. Зарегистрируйте новый мир в коде загрузчика/меню (см. логику в `main`).
4. Проверьте, что коллекции и ассеты корректно связаны.

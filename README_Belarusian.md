[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# SuperWEIRD Game Kit

Прывітанне! Мы ў кампаніі [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) распрацоўваем гульню [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (старонка гульні ў [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). Гэта кааператыўная гульня пра праектаванне і аўтаматызацыю сістэм з дапамогай лемінгападобных робатаў на рухавіку [Defold](https://defold.com).

У самым пачатку распрацоўкі мы правялі шмат эксперыментаў з візуальным стылем і геймплеем. Мы падумалі, што гэта можа прыдацца іншым распрацоўшчыкам і вырашылі выкласці код, тэкстуры і анімацыі гэтых эксперыментаў пад адкрытай ліцэнзіяй [CC0](LICENSE).

У гэтым рэпазіторыі вы знойдзеце шэсць розных візуальных стыляў ([video](https://youtu.be/RJwOEDY3MP4)) і гульнявую логіку сімулятара крамы/вытворчасці. Гулец абслугоўвае заказы кліентаў і пашырае вытворчасць тавараў. Вы можаце сыграць у [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github).

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

Заглядайце да нас у [Discord](https://discord.gg/ludenio), каб распавесці, што б вы зрабілі з дапамогай гэтых прататыпаў. Ці завітайце на наш [YouTube channel](https://www.youtube.com/@ludenio) — там шмат цікавага, у тым ліку [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Спасылкі:
- Discord (мы там штодня): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Рассылка з навінамі і тэкставымі дзённікамі распрацоўкі: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Партнёры

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

Праект SuperWEIRD ствараецца пры падтрымцы [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun) — дабрачыннага фонду, які імкнецца даць дзецям з розных супольнасцяў доступ да навукі і тэхналогій. Яны лічаць матэматыку фундаментам будучых інавацый і фінансуюць арганізацыі, якія натхняюць і развіваюць матэматычныя таленты. Калі вас цікавяць іншыя адукацыйныя праекты, звярніце ўвагу на партнёраў Carina Initiatives:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Хуткі старт

1. Усталюйце Defold Editor: https://defold.com
2. Кланіруйце або спампуйце рэпазіторый.
3. Адкрыйце папку праекта ў Defold Editor.
4. Збярыце і запусціце праект (Build and Run).

Заўвага: для рэдагавання Spine-анімацый патрабуецца Spine Editor.

# Структура праекта

1. Загрузка
   - `loader` — стартуе разам з гульнёй, застаецца ў памяці і кіруе загрузкай/выгрузкай калекцый праз механізм Collection Proxy; пры запуску ініцыюе стартовае меню.
   - `menu` — стартовае меню, якое паказваецца пры запуску гульні.

2. Асноўная частка
   - `main` — агульны код гульні: скрыпты і модулі, агульныя для ўсіх светаў; тут захоўваецца ўся гульнявая логіка.
   - `assets` — гульнявыя асеты: тэкстуры, мадэлі Spine, тайлавыя карты і атласы. Для кожнага свету — асобная папка `world_1`, `world_2` і г.д. з унікальнымі графічнымі элементамі.
   - `worlds` — візуальная наладка светаў: калекцыі і гульнявыя аб'екты. Кожны свет — асобная калекцыя ў `world_1`, `world_2` і г.д.

3. Дадатковыя матэрыялы
   - `SuperWEIRDGameKit_assets` — сістэматызаваны набор графікі і мадэляў Spine, выкарыстаных у праекце.

# Логіка працы са светамі

- Пераключэнне светаў ажыццяўляецца праз `loader`, які падгружае і выгружае калекцыі.
- Наладжванне свету: абнаўляйце візуальныя параметры і гульнявыя аб'екты ў `worlds/world_X`, а графіку — у `assets/world_X`.

## Дадаванне новага свету

1. Стварыце папкі `assets/world_N` і `worlds/world_N`.
2. Скапіруйце шаблон з існуючага свету.
3. Зарэгіструйце новы свет у кодзе загрузчыка/меню (гл. логіку ў `main`).
4. Праверце, што калекцыі і асеты карэктна звязаныя.

[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# SuperWEIRD Game Kit

Hoi! Bij [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) ontwikkelen we [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (bekijk de game op [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). Het is een co-op-game over het ontwerpen en automatiseren van systemen met lemming-achtige robots, gebouwd met de [Defold](https://defold.com)-engine.

Vroeg in de ontwikkeling hebben we veel geëxperimenteerd met visuele stijlen en gameplay. We dachten dat dit nuttig kon zijn voor andere ontwikkelaars en besloten de code, textures en animaties uit die experimenten vrij te geven onder de open [CC0](LICENSE)-licentie.

In deze repository vind je zes verschillende visuele stijlen ([video](https://youtu.be/RJwOEDY3MP4)) en de gameplay-logica van een winkel-/productiesimulator. De speler handelt klantbestellingen af en breidt de productie uit. Je kunt de [demo op itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github) spelen.

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

Sluit je aan bij onze [Discord](https://discord.gg/ludenio) om ons te vertellen wat jij met deze prototypes zou bouwen. Of bekijk ons [YouTube channel](https://www.youtube.com/@ludenio) — daar staat veel moois, waaronder de [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Links:
- Discord (we zijn er elke dag): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Nieuwsbrief met updates en tekstuele dev-diaries: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Partners

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD wordt gemaakt met steun van [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun), een filantropisch fonds dat eraan werkt kinderen uit diverse gemeenschappen toegang te geven tot wetenschap en technologie. Zij zien wiskunde als de basis van toekomstige innovatie en financieren organisaties die wiskundig talent inspireren en ontwikkelen. Als je interesse hebt in andere educatieve projecten, bekijk dan de partners van Carina Initiatives:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Snelstart

1. Installeer Defold Editor: https://defold.com
2. Clone of download de repository.
3. Open de projectmap in Defold Editor.
4. Bouw en voer het project uit.

Opmerking: voor het bewerken van Spine-animaties is de Spine Editor vereist.

# Projectstructuur

1. Laden
   - `loader` — wordt met de game gestart, blijft in het geheugen en beheert het laden/ontladen van collecties via de Collection Proxy; initialiseert bij het opstarten het startmenu.
   - `menu` — het startmenu dat wordt getoond wanneer de game start.

2. Kern
   - `main` — gedeelde gamecode: scripts en modules die in alle werelden worden gebruikt; bevat de volledige gamelogica.
   - `assets` — game-assets: textures, Spine-modellen, tilemaps en atlassen. Elke wereld heeft zijn eigen map `world_1`, `world_2`, enz., met unieke visuals.
   - `worlds` — visuele opzet van werelden: collecties en game-objecten. Elke wereld is een aparte collectie in `world_1`, `world_2`, enz.

3. Extra's
   - `SuperWEIRDGameKit_assets` — een geordende set graphics en Spine-modellen die in het project worden gebruikt.

# Wereldbeheerlogica

- Wisselen tussen werelden gebeurt via `loader`, die collecties laadt en ontlaadt.
- Wereld aanpassen: werk visuele parameters en game-objecten bij in `worlds/world_X`, en de graphics in `assets/world_X`.

## Een nieuwe wereld toevoegen

1. Maak de mappen `assets/world_N` en `worlds/world_N` aan.
2. Kopieer een sjabloon uit een bestaande wereld.
3. Registreer de nieuwe wereld in de loader-/menucode (zie de logica in `main`).
4. Zorg dat collecties en assets correct zijn gekoppeld.

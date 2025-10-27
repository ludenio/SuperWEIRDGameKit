[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# SuperWEIRD Game Kit

Hej! På [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) utvecklar vi [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (se spelet på [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). Det är ett co-op-spel om att designa och automatisera system med lemmingliknande robotar, byggt med spelmotorn [Defold](https://defold.com).

Tidigt i utvecklingen gjorde vi många experiment med visuella stilar och gameplay. Vi insåg att de kunde vara användbara för andra utvecklare och bestämde oss för att släppa koden, texturerna och animationerna från dessa experiment under den öppna licensen [CC0](LICENSE).

I det här repot hittar du sex olika visuella stilar ([video](https://youtu.be/RJwOEDY3MP4)) och spelmekaniken för en butik-/produktionssimulator. Spelaren uppfyller kundbeställningar och bygger ut produktionen. Du kan spela [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github).

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

Gå med i vår [Discord](https://discord.gg/ludenio) och berätta vad du skulle bygga med de här prototyperna. Eller kolla in vår [YouTube channel](https://www.youtube.com/@ludenio) — där finns mycket bra material, inklusive [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Länkar:
- Discord (vi är där varje dag): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Nyhetsbrev med uppdateringar och textbaserade utvecklingsdagböcker: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Partners

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD skapas med stöd från [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun), en filantropisk fond som arbetar för att ge barn från olika samhällen tillgång till vetenskap och teknik. De ser matematiken som grunden för framtida innovation och finansierar organisationer som inspirerar och utvecklar matematisk talang. Om du är intresserad av andra utbildningsprojekt, kolla in Carina Initiatives partners:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Snabbstart

1. Installera Defold Editor: https://defold.com
2. Klona eller ladda ner repot.
3. Öppna projektmappen i Defold Editor.
4. Bygg och kör projektet.

Obs: För att redigera Spine-animationer krävs Spine Editor.

# Projektstruktur

1. Laddning
   - `loader` — startar tillsammans med spelet, ligger kvar i minnet och hanterar in-/utladdning av kollektioner via Collection Proxy; vid uppstart initierar den startmenyn.
   - `menu` — startmenyn som visas när spelet startar.

2. Kärna
   - `main` — delad spelkod: skript och moduler som används i alla världar; innehåller hela spel­logiken.
   - `assets` — spelresurser: texturer, Spine-modeller, tilemaps och atlaser. Varje värld har sin egen mapp `world_1`, `world_2` osv. med unika visuella element.
   - `worlds` — världarnas visuella uppsättning: kollektioner och spelobjekt. Varje värld är en separat kollektion i `world_1`, `world_2` osv.

3. Extra
   - `SuperWEIRDGameKit_assets` — ett organiserat paket med grafik och Spine-modeller som används i projektet.

# Logik för världshantering

- Världsbyte hanteras via `loader`, som laddar in och ur kollektioner.
- Anpassning av värld: uppdatera visuella parametrar och spelobjekt i `worlds/world_X`, och grafiken i `assets/world_X`.

## Lägga till en ny värld

1. Skapa mapparna `assets/world_N` och `worlds/world_N`.
2. Kopiera en mall från en befintlig värld.
3. Registrera den nya världen i loader-/menykoden (se logiken i `main`).
4. Säkerställ att kollektioner och resurser är korrekt länkade.

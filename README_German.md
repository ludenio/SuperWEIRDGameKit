[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)

# SuperWEIRD Game Kit

Hallo! Bei [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) entwickeln wir [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (siehe das Spiel auf [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). Es ist ein Koop-Spiel über das Entwerfen und Automatisieren von Systemen mit lemmingartigen Robotern, entwickelt mit der Engine [Defold](https://defold.com).

Früh in der Entwicklung haben wir viele Experimente mit visuellen Stilen und Gameplay gemacht. Wir dachten, dass diese für andere Entwickler nützlich sein könnten, und haben beschlossen, den Code, die Texturen und Animationen aus diesen Experimenten unter der offenen [CC0](LICENSE)-Lizenz zu veröffentlichen.

In diesem Repository findest du sechs verschiedene visuelle Stile ([video](https://youtu.be/RJwOEDY3MP4)) sowie die Spiellogik eines Shop-/Produktionssimulators. Der Spieler erfüllt Kundenbestellungen und erweitert die Produktion. Du kannst das [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github) spielen.

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

Tritt unserem [Discord](https://discord.gg/ludenio) bei, um uns zu erzählen, was du mit diesen Prototypen bauen würdest. Oder schau auf unserem [YouTube channel](https://www.youtube.com/@ludenio) vorbei — dort gibt es viele interessante Inhalte, darunter die [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Links:
- Discord (wir sind dort jeden Tag): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Newsletter mit Updates und textbasierten Dev-Diaries: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Partner

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD entsteht mit Unterstützung von [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun), einem philanthropischen Fonds, der Kindern aus vielfältigen Gemeinschaften Zugang zu Wissenschaft und Technologie ermöglichen möchte. Sie sehen in der Mathematik die Grundlage zukünftiger Innovationen und fördern Organisationen, die mathematische Talente inspirieren und entwickeln. Wenn dich weitere Bildungsprojekte interessieren, schau dir die Partner von Carina Initiatives an:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Schnellstart

1. Installiere den Defold Editor: https://defold.com
2. Klone oder lade das Repository herunter.
3. Öffne den Projektordner im Defold Editor.
4. Baue und starte das Projekt.

Hinweis: Zum Bearbeiten von Spine-Animationen wird der Spine Editor benötigt.

# Projektstruktur

1. Laden
   - `loader` — startet zusammen mit dem Spiel, bleibt im Speicher und verwaltet das Laden/Entladen von Collections über den Collection Proxy; beim Start initialisiert er das Startmenü.
   - `menu` — das Startmenü, das beim Spielstart angezeigt wird.

2. Kern
   - `main` — gemeinsamer Spielcode: Skripte und Module, die in allen Welten verwendet werden; enthält die gesamte Spiellogik.
   - `assets` — Spiel-Assets: Texturen, Spine-Modelle, Tilemaps und Atlanten. Jede Welt hat ihren eigenen Ordner `world_1`, `world_2` usw. mit einzigartiger Grafik.
   - `worlds` — visuelles Setup der Welten: Collections und Spielobjekte. Jede Welt ist eine eigene Collection in `world_1`, `world_2` usw.

3. Extras
   - `SuperWEIRDGameKit_assets` — ein geordnetes Set aus Grafiken und Spine-Modellen, die im Projekt verwendet werden.

# Logik der Weltverwaltung

- Das Wechseln der Welten erfolgt über den `loader`, der Collections lädt und entlädt.
- Anpassung einer Welt: Aktualisiere visuelle Parameter und Spielobjekte in `worlds/world_X` und die Grafiken in `assets/world_X`.

## Eine neue Welt hinzufügen

1. Erstelle die Ordner `assets/world_N` und `worlds/world_N`.
2. Kopiere eine Vorlage aus einer bestehenden Welt.
3. Registriere die neue Welt im Loader-/Menü-Code (siehe Logik in `main`).
4. Stelle sicher, dass Collections und Assets korrekt verknüpft sind.

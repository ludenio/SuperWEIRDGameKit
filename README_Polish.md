[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# SuperWEIRD Game Kit

Cześć! W [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) tworzymy [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (zobacz grę na [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). To kooperacyjna gra o projektowaniu i automatyzacji systemów z udziałem robotów przypominających lemingi, zbudowana na silniku [Defold](https://defold.com).

Na wczesnym etapie rozwoju przeprowadziliśmy wiele eksperymentów ze stylami wizualnymi i rozgrywką. Uzna­liśmy, że mogą być przydatne dla innych twórców, dlatego udostępniamy kod, tekstury i animacje z tych eksperymentów na otwartej licencji [CC0](LICENSE).

W tym repozytorium znajdziesz sześć różnych stylów wizualnych ([video](https://youtu.be/RJwOEDY3MP4)) oraz logikę rozgrywki symulatora sklepu/produkcji. Gracz realizuje zamówienia klientów i rozwija produkcję. Możesz zagrać w [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github).

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

Dołącz do naszego [Discord](https://discord.gg/ludenio), aby powiedzieć nam, co zbudował(a)byś dzięki tym prototypom. Albo zajrzyj na nasz [YouTube channel](https://www.youtube.com/@ludenio) — jest tam mnóstwo świetnych materiałów, w tym [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Linki:
- Discord (jesteśmy tam codziennie): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Newsletter z aktualizacjami i tekstowymi dziennikami deweloperskimi: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Partnerzy

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD powstaje przy wsparciu [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun), filantropijnego funduszu, który dąży do zapewnienia dzieciom z różnych społeczności dostępu do nauki i technologii. Uważają, że matematyka jest fundamentem przyszłych innowacji, i finansują organizacje, które inspirują oraz rozwijają talenty matematyczne. Jeśli interesują cię inne projekty edukacyjne, sprawdź partnerów Carina Initiatives:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Szybki start

1. Zainstaluj Defold Editor: https://defold.com
2. Sklonuj lub pobierz repozytorium.
3. Otwórz folder projektu w Defold Editor.
4. Zbuduj i uruchom projekt.

Uwaga: edytowanie animacji Spine wymaga programu Spine Editor.

# Struktura projektu

1. Ładowanie
   - `loader` — uruchamia się wraz z grą, pozostaje w pamięci i zarządza ładowaniem/zwalnianiem kolekcji przez mechanizm Collection Proxy; przy starcie inicjuje menu główne.
   - `menu` — menu startowe wyświetlane po uruchomieniu gry.

2. Rdzeń
   - `main` — wspólny kod gry: skrypty i moduły używane we wszystkich światach; zawiera całą logikę gry.
   - `assets` — zasoby gry: tekstury, modele Spine, tilemapy i atlasy. Każdy świat ma własny folder `world_1`, `world_2` itd. z unikalną oprawą graficzną.
   - `worlds` — konfiguracja wizualna światów: kolekcje i obiekty gry. Każdy świat to osobna kolekcja w `world_1`, `world_2` itd.

3. Dodatkowe materiały
   - `SuperWEIRDGameKit_assets` — uporządkowany zestaw grafik i modeli Spine użytych w projekcie.

# Logika zarządzania światami

- Przełączanie światów odbywa się przez `loader`, który ładuje i zwalnia kolekcje.
- Personalizacja świata: aktualizuj parametry wizualne i obiekty gry w `worlds/world_X`, a grafiki w `assets/world_X`.

## Dodawanie nowego świata

1. Utwórz foldery `assets/world_N` i `worlds/world_N`.
2. Skopiuj szablon z istniejącego świata.
3. Zarejestruj nowy świat w kodzie loadera/menu (zob. logikę w `main`).
4. Upewnij się, że kolekcje i zasoby są poprawnie powiązane.

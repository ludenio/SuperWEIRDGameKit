[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)

# Kit de Jogo SuperWEIRD

Oi! Na [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) estamos desenvolvendo [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (veja o jogo na [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). É um jogo cooperativo sobre projetar e automatizar sistemas com robôs parecidos com lemingues, feito com o motor [Defold](https://defold.com).

No início do desenvolvimento, fizemos muitos experimentos com estilos visuais e gameplay. Achamos que isso poderia ser útil para outros desenvolvedores e decidimos liberar o código, as texturas e as animações desses experimentos sob a licença aberta [CC0](LICENSE).

Neste repositório você encontrará seis estilos visuais diferentes ([video](https://youtu.be/RJwOEDY3MP4)) e a lógica de gameplay de um simulador de loja/produção. O jogador atende pedidos de clientes e expande a produção. Você pode jogar a [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github).

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

Entre no nosso [Discord](https://discord.gg/ludenio) para contar o que você construiria com esses protótipos. Ou confira nosso [YouTube channel](https://www.youtube.com/@ludenio) — tem muita coisa legal, incluindo os [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Links:
- Discord (estamos lá todos os dias): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Newsletter com atualizações e diários de desenvolvimento em texto: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Parceiros

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD está sendo criado com o apoio da [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun), um fundo filantrópico que trabalha para dar a crianças de comunidades diversas acesso à ciência e à tecnologia. Eles veem a matemática como a base das inovações futuras e financiam organizações que inspiram e desenvolvem talentos matemáticos. Se você se interessa por outros projetos educacionais, confira os parceiros da Carina Initiatives:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Início Rápido

1. Instale o Defold Editor: https://defold.com
2. Clone ou baixe o repositório.
3. Abra a pasta do projeto no Defold Editor.
4. Compile e execute o projeto.

Observação: editar animações do Spine requer o Spine Editor.

# Estrutura do Projeto

1. Carregamento
   - `loader` — inicia junto com o jogo, permanece na memória e gerencia o carregamento/descarregamento de coleções via o Collection Proxy; ao iniciar, inicializa o menu inicial.
   - `menu` — o menu inicial exibido quando o jogo começa.

2. Núcleo
   - `main` — código compartilhado do jogo: scripts e módulos usados em todos os mundos; contém toda a lógica do jogo.
   - `assets` — assets do jogo: texturas, modelos Spine, tilemaps e atlas. Cada mundo tem sua própria pasta `world_1`, `world_2` etc., com visuais únicos.
   - `worlds` — configuração visual dos mundos: coleções e objetos de jogo. Cada mundo é uma coleção separada em `world_1`, `world_2` etc.

3. Extras
   - `SuperWEIRDGameKit_assets` — um conjunto organizado de gráficos e modelos Spine usados no projeto.

# Lógica de Gerenciamento de Mundos

- A troca de mundos é feita via `loader`, que carrega e descarrega coleções.
- Personalização de mundo: atualize os parâmetros visuais e os objetos de jogo em `worlds/world_X`, e os gráficos em `assets/world_X`.

## Adicionando um Novo Mundo

1. Crie as pastas `assets/world_N` e `worlds/world_N`.
2. Copie um modelo de um mundo existente.
3. Registre o novo mundo no código do loader/menu (veja a lógica em `main`).
4. Garanta que as coleções e os assets estejam corretamente vinculados.

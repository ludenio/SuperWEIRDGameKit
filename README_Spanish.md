[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# Kit de juego SuperWEIRD

¡Hola! En [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) estamos desarrollando [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (consulta el juego en [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). Es un juego cooperativo sobre diseñar y automatizar sistemas con robots similares a lemmings, creado con el motor [Defold](https://defold.com).

Al principio del desarrollo hicimos muchos experimentos con estilos visuales y jugabilidad. Pensamos que podían ser útiles para otros desarrolladores y decidimos publicar el código, las texturas y las animaciones de esos experimentos bajo la licencia abierta [CC0](LICENSE).

En este repositorio encontrarás seis estilos visuales diferentes ([video](https://youtu.be/RJwOEDY3MP4)) y la lógica jugable de un simulador de tienda/producción. El jugador atiende pedidos de clientes y amplía la producción. Puedes jugar a la [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github).

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

Únete a nuestro [Discord](https://discord.gg/ludenio) para contarnos qué construirías con estos prototipos. O visita nuestro [YouTube channel](https://www.youtube.com/@ludenio), donde hay mucho contenido interesante, incluidos los [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Enlaces:
- Discord (estamos allí todos los días): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Boletín con actualizaciones y diarios de desarrollo en texto: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Socios

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD se está creando con el apoyo de [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun), un fondo filantrópico que trabaja para dar a niños de comunidades diversas acceso a la ciencia y la tecnología. Consideran las matemáticas como la base de la innovación futura y financian organizaciones que inspiran y desarrollan el talento matemático. Si te interesan otros proyectos educativos, echa un vistazo a los socios de Carina Initiatives:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Inicio rápido

1. Instala Defold Editor: https://defold.com
2. Clona o descarga el repositorio.
3. Abre la carpeta del proyecto en Defold Editor.
4. Compila y ejecuta el proyecto.

Nota: editar animaciones de Spine requiere Spine Editor.

# Estructura del proyecto

1. Carga
   - `loader` — se inicia con el juego, permanece en memoria y gestiona la carga/descarga de colecciones mediante Collection Proxy; al arrancar inicializa el menú de inicio.
   - `menu` — el menú de inicio que se muestra al comenzar el juego.

2. Núcleo
   - `main` — código compartido del juego: scripts y módulos usados en todos los mundos; contiene toda la lógica del juego.
   - `assets` — assets del juego: texturas, modelos de Spine, tilemaps y atlas. Cada mundo tiene su propia carpeta `world_1`, `world_2`, etc., con elementos visuales únicos.
   - `worlds` — configuración visual de los mundos: colecciones y objetos de juego. Cada mundo es una colección independiente en `world_1`, `world_2`, etc.

3. Extras
   - `SuperWEIRDGameKit_assets` — conjunto organizado de gráficos y modelos de Spine usados en el proyecto.

# Lógica de gestión de mundos

- El cambio de mundo se gestiona a través de `loader`, que carga y descarga colecciones.
- Personalización de mundos: actualiza los parámetros visuales y los objetos de juego en `worlds/world_X`, y la gráfica en `assets/world_X`.

## Añadir un mundo nuevo

1. Crea las carpetas `assets/world_N` y `worlds/world_N`.
2. Copia una plantilla de un mundo existente.
3. Registra el nuevo mundo en el código del loader/menú (consulta la lógica en `main`).
4. Asegúrate de que las colecciones y los assets estén correctamente vinculados.

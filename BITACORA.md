# Bitácora — MexTradeBot Mapa Técnico

Registro de trabajo día por día en este proyecto. Cada entrada resume qué se hizo, qué se decidió y por qué — no solo el qué, para que quede el contexto de las decisiones.

---

## 2026-08-26

**Diseño de la conectividad**

Se agregó al mapa un capítulo nuevo de Conectividad (Sección 09), documentando cómo pasa un robot ya construido a operar en una cuenta real, con las tres herramientas pedidas:

1. **Cuenta de XM** — el usuario conecta el robot ya construido a su cuenta de XM (demo o real, a su elección) ingresando sus credenciales, sin salir de MexTradeBot.
2. **Test de comportamiento con TickStory** — antes de operar en real, el robot se puede probar contra datos históricos descargados con TickStory, con la misma disciplina de out-of-sample ya documentada en el mapa.
3. **MT4 y MT5, a elección del usuario** — el robot se configura con las credenciales de la plataforma que el usuario prefiera; ninguna de las dos es "principal".

**Por qué:** cierra el hueco que quedaba entre "el robot ya está construido y validado" y "el robot ya está operando con dinero real" — la pieza de conectividad es la que convierte el mapa técnico en un flujo completo de producto, de principio a fin.

---

## 2026-08-25

**Cambios en el programa de desarrollo del mapa**

- Compatibilidad **MT4 y MT5** explícita en la propuesta de arquitectura (antes solo mencionaba MT4) — MexTradeBot construye robots indistintamente para ambas plataformas.
- **Prioridad de producto** redefinida: sistema de competición comunitaria primero; cuentas de fondeo incluidas en la propuesta pero en segundo plano del roadmap (no en la primera versión). Se marcó explícitamente la sección de fondeo del mapa como "Prioridad secundaria".
- Modelo de negocio propio reemplazó al de la plataforma de referencia que se había usado como placeholder: **Free** ($0, construir sin conectar cuentas) → **Premium** ($27 USD/mes, construir + conectar demo + conectar real) → **Golden** ($35 USD/mes, todo lo anterior + elegir un robot ya hecho en producción, clases de agentes de IA que construyen robots, cursos de indicadores). Comunidad MexTradeBot incluida en los tres planes.
- Contenido de la presentación para XM preparado y redactado en 10 tarjetas (límite del plan gratuito de Gamma), documentando el proceso completo: infraestructura n8n, metodología de trading, categorías de indicadores/estrategias aprendidas, hallazgos de la investigación, y la propuesta.

**Apertura de GitHub**

- Ricardo creó el repositorio `mextradebot-maker/mextradebot-mapa-tecnico`.
- Se preparó el proyecto localmente (`index.html` con el mapa técnico + `README.md`), con commit y remoto ya configurados desde esta sesión.
- El `git push` lo corrió Ricardo directamente desde su terminal — en esta sesión el push por git se cuelga pidiendo login interactivo, así que ese paso queda siempre de su lado.

**Apertura de Vercel y despliegue**

- Ricardo registró el team `mextradebot-9549` en Vercel.
- Se importó el repositorio de GitHub como proyecto estático (framework "Other", sin build ni variables de entorno).
- **Deploy completado y confirmado en vivo** — el mapa técnico ya está publicado.

**Por qué:** el mapa técnico se prepara para presentárselo a XM como propuesta de alianza (broker oficial exclusivo) — de ahí el rebranding de marca, el broker único, y que el modelo de negocio y las prioridades de producto queden reflejados con precisión antes de esa reunión.

---

## 2026-08-24

**Consolidación del mapa técnico**

- Investigación de la plataforma de referencia (tradEasy) completada: exploración en vivo de la app + 5 videos del curso interno "Trading Robot Academy" (Sesiones 1-4 + comunidad), más de 14 horas de contenido documentadas con precisión al segundo.
- Hallazgos organizados en 6 memorias de proyecto: gap de indicadores vs. nuestra metodología (SMC/price action), mecánica de negocio de la plataforma, constructor y optimización (mecanismo Filtro/Disparo, reglas de oro de optimización), carteras y QuantAnalyzer (correlación), IA aplicada y cuentas de fondeo, y los fundamentos de la Sesión 1.
- Consolidado todo en un único documento de referencia — publicado primero como Artifact ("tradEasy Deconstruido"), con diseño propio (paleta navy/oro/teal, tipografía IBM Plex, sidebar con índice, tablas comparativas, callouts por tipo de hallazgo).
- Rebranding a pedido de Ricardo: "tradEasy" → "MexTradeBot" en todo el documento, brokers mencionados → "XM" (único broker permitido), logos de MexTradeBot y XM incorporados (sidebar + insignia "Broker oficial"). Resuelta la contradicción lógica que generó el rebranding en la sección de hallazgo clave (la plataforma estudiada pasó a llamarse "la plataforma base" en esa sección específica, para no comparar MexTradeBot consigo mismo).

**Por qué:** antes de diseñar el sistema propio de MexTradeBot había que entender a fondo una plataforma de referencia real de la industria — qué resuelve, qué no, y qué haría falta construir custom (Order Blocks, FVG, liquidez — conceptos SMC que ningún constructor del mercado ofrece nativo).

---

<!-- Nueva entrada: copiar el formato de arriba — fecha en ## AAAA-MM-DD, subtítulo corto, bullets de qué se hizo, cierre con "Por qué" cuando la decisión no sea obvia. -->

# Bitácora — MexTradeBot Mapa Técnico

Registro de trabajo día por día en este proyecto. Cada entrada resume qué se hizo, qué se decidió y por qué — no solo el qué, para que quede el contexto de las decisiones.

---

## 2026-08-27

**Plan de construcción definido: primer paso de estructura**

Cerramos la fase de definición del sistema propio. Quedó documentada como una sección nueva y visible en el sitio (Sección 10, "Plan de construcción"), con el paso a paso completo y una tabla de qué herramienta de la plataforma base reemplaza cada pieza propia.

Lo investigado, debatido y definido:

1. **Tres formas de generar y entregar robots** evaluadas a fondo — el sistema planeado desde cero, los flujos ya existentes de n8n (Serie T), o agentes especialistas por Telegram conectados a XM. Se concluyó que el motor propio va primero, no el pipeline ni la cara cliente: sin motor propio (Order Blocks, FVG, liquidez), lo que recibe el cliente se puede leer como "señales" en vez de algo construido y verificable.
2. **Motor propio investigado y validado, no desde cero**: paquete oficial `MetaTrader5` (Python↔MT5), librería abierta `smartmoneyconcepts` como acelerador de Order Blocks/FVG/liquidez, Backtrader/VectorBT para backtesting con disciplina out-of-sample, `dukascopy-python` para datos históricos directos.
3. **TickStory y QuantAnalyzer reemplazados** por sus equivalentes nativos en Python — la disciplina que enseñan (out-of-sample, correlación de carteras) se queda, la herramienta específica no.
4. **Calendario económico resuelto a costo cero**: ForexFactory no tiene API oficial, pero sí un feed gratuito documentado (`nfs.faireconomy.media`, JSON) usado desde hace años por la comunidad de EAs de MT4/5 — se adopta con control de frecuencia (máx. 2 descargas/5min según el proveedor, se refresca 1 vez al día) y chequeo de última actualización para que no falle en silencio.
5. **Se descartó mezclar noticias editoriales con el motor de reglas** — un resumen de noticias generado por IA no es reproducible en backtest; si se construye, queda como producto de contenido aparte (mismo patrón que `generador_de_contenido`), nunca como señal de entrada del robot.
6. **Secuencia de construcción final**: Motor propio → Conectividad en paralelo (datos históricos, Conector XM, MT4/MT5, Filtro de calendario económico) → reparar pipeline T-01→T-05 → exponer versión cliente-facing por Telegram → constructor visual completo, condicional a que las etapas anteriores estén maduras y en uso real.

**Por qué documentamos esto como "primer paso de estructura":** hasta hoy todo era investigación y debate — con la Sección 10 escrita, el proyecto pasa de "sabemos qué plataforma estudiamos" a "sabemos, en orden, qué construimos primero y por qué". Es la bisagra entre la fase de definición y la fase de construcción real.

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

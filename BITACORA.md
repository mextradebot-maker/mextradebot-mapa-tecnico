# Bitácora — MexTradeBot Mapa Técnico

Registro de trabajo día por día en este proyecto. Cada entrada resume qué se hizo, qué se decidió y por qué — no solo el qué, para que quede el contexto de las decisiones.

---

## 2026-08-28

**Paso 1b + Backtesting formal completos: 5 piezas construidas y probadas con datos reales**

Antes de tocar n8n, se cerró toda la Conectividad (Paso 1b) y el Backtesting formal — cinco piezas nuevas, cada una validada contra el sistema real (dukascopy, MT5, ForexFactory), no con datos de prueba inventados.

- **Datos históricos** (`conectividad.historico`) — vía `dukascopy-python`. Probado con años reales: 14 años de velas diarias de XAUUSD (2010-2024) bajados en 1.7s, 2 años de H1 (~11,800 velas) en 1.9s. El paquete trae 1,380 instrumentos (forex, commodities, índices, cripto, acciones) — hoy solo XAUUSD y EURUSD están mapeados con nombre corto, cualquier otro se pasa como string crudo.
- **Conector XM/MT5** (`conectividad.xm`) — conexión, info de cuenta y velas en vivo vía el paquete oficial `MetaTrader5`. Solo lectura a propósito: **envío de órdenes no está incluido**, es un paso aparte que necesita sus propias salvaguardas. Es un puente IPC local (Windows-only) — no puede correr en Vercel, por eso quedó con marcador de plataforma en las dependencias para no romper el build. MT4 sigue sin resolver: el paquete no tiene API oficial para MT4, sería un conector distinto.
- **Filtro de calendario económico** (`conectividad.calendario`) — feed gratuito de ForexFactory (`nfs.faireconomy.media`), probado en vivo (72 eventos reales de la semana, 9 de impacto Alto). Cachea 1 vez al día, tolera hasta 48h de feed caído antes de desactivarse explícitamente — nunca opera con datos viejos sin avisar.
- **Backtesting formal** (`backtesting.backtest`) — simulación propia en pandas en vez de Backtrader/VectorBT (los setups son eventos discretos, no una estrategia continua — un framework completo era más de lo necesario). Aplica las 3 reglas de oro de la Sección 05. **Reporte financiero real** sobre XAUUSD H1 2020-2024 (corte 2023): in-sample +0.36R de expectativa (11 setups), out-of-sample plano en 0.0R (3 setups) — exactamente la caída que la disciplina out-of-sample existe para exponer, no un bug.
- **Endpoint `/api/setups`** (Vercel) — junta las piezas de arriba en un solo request: trae datos históricos y corre el motor completo, para que n8n (o cualquier consumidor externo) pregunte "¿hay setups reales ahora?" sin hablar con dukascopy directo. Se descubrió en el camino que Vercel en modo single-entrypoint no auto-descubre archivos nuevos bajo `api/` como funciones propias — hubo que convertir `api/analizar.py` en router explícito.

**Por qué:** cada pieza se probó con datos/servicios reales antes de darla por terminada (no solo datos sintéticos) — así se encontraron a tiempo el bug del router de Vercel y la columna `volume` que `smc.ob()` exige sin documentarlo. Con esto, todo lo que necesita el pipeline de n8n (Paso 2) ya existe y está verificado.

---

## 2026-08-28 (continuación 2)

**T-02 reparado: entrega el robot ya construido, no lo inventa**

Segunda workflow de la Serie T reparada, y la más importante de las 5 — hasta hoy le pedía a Claude genérico que inventara un Expert Advisor en MQL5 desde cero (indicadores clásicos) y lo mandaba a un VPS de compilación que nunca se construyó.

- **Decisión de arquitectura confirmada con Ricardo**: el EA no reimplementa Order Blocks/FVG/liquidez en MQL5 — consulta `/api/setups` (el motor Python ya validado) en cada vela nueva vía `WebRequest`, y opera exactamente lo que responda. Cualquier mejora al motor se refleja en todos los robots ya entregados sin tocar el archivo. La alternativa (un EA 100% independiente del servidor) quedó evaluada y descartada por ahora — es una segunda implementación completa del motor, con riesgo de que las dos versiones diverjan.
- **Orden pendiente, no orden de mercado**: coloca una orden límite en el punto medio del FVG, SL en la vela de barrido, TP fijo a 2R — el mismo múltiplo ya validado en el backtest. Sin break-even ni trailing a propósito, para que el resultado en vivo sea comparable al backtest.
- **T-02 rediseñada**: Webhook → descarga el `.mq5` ya construido directo de GitHub (repo público, sin credenciales) → lo entrega por Telegram como documento con instrucciones. Sin IA de por medio.
- **Bug real encontrado y corregido durante la prueba**: una referencia cruzada entre nodos de n8n (`$('NombreNodo')`) devolvía los datos del nodo equivocado en el modo de prueba simulado, sin error visible. Se corrigió referenciando el nodo disparador directo, y se eliminó un nodo intermedio que ya no hacía falta.

**Por qué:** la decisión de no reimplementar SMC en MQL5 sigue el mismo principio que ya gobierna todo el proyecto — nunca duplicar lógica que ya existe y está validada. La documentación completa de esta decisión (y las alternativas evaluadas) vive en un manual técnico interno aparte, no en este mapa público.

---

## 2026-08-28 (continuación)

**Paso 2 arranca: T-01 (Detector Activos Rentables) reparado y verificado en vivo**

Primera de las 5 workflows de la Serie T reparada por completo — conectada al motor propio en vez de duplicar lógica, y probada de punta a punta con un envío real de Telegram confirmado por Ricardo, no solo una simulación.

- **Diagnóstico inicial**: las 5 workflows (T-01 a T-05) compartían el mismo bug — un nodo "Extraer [X]" completamente vacío que no extraía nada, dejando roto todo lo que venía después. Además, ninguna tenía credencial de Telegram vinculada, y todas usaban `$env.*` para credenciales (que este n8n no soporta).
- **T-01 rediseñada**: reemplaza el llamado muerto a Yahoo Finance + opinión genérica de Claude por el motor real — llama a `/api/setups` (el endpoint nuevo de `tradebotbuilder`) para XAUUSD y EURUSD, y Claude solo redacta el reporte con los datos reales que ya vienen del motor SMC, sin decidir nada por su cuenta.
- **Cadena de bugs reales encontrados al probarlo en vivo** (no en teoría — cada uno tronó una ejecución real antes de arreglarse): restricción de dominio en la credencial de Anthropic bloqueando su uso en nodos HTTP genéricos; una API key "identity-linked" que exigía un `workspace-id` en vez de una key de un workspace específico; el campo "Name" de la credencial de header mal llenado (mandaba el header equivocado); el JSON armado a mano con comillas incrustadas rompiéndose con datos reales (se corrigió construyendo el body como objeto en un nodo Code, no concatenando strings); y el modelo `claude-sonnet-4-20250514` retirado, reemplazado por `claude-sonnet-5`.
- **Bot dedicado**: se creó `mxtrading_robot` en BotFather y su credencial en n8n, en vez de reusar un bot genérico de otro proyecto — el chat_id real (`943121056`) se obtuvo con un workflow temporal desechable (`telegramTrigger` publicado, capturó el mensaje real, luego se archivó).
- **Verificación**: `execute_workflow` en modo manual, ejecución real (no pin data) de punta a punta — el reporte llegó de verdad al Telegram de Ricardo, confirmado por él.

**Por qué:** cada arreglo se probó contra el sistema real (Anthropic, Telegram, el motor propio) en vez de darlo por bueno con la lógica simulada — varios de estos bugs (la restricción de dominio, el workspace de la API key, el nombre del header) solo aparecen al ejecutar de verdad, nunca se habrían visto revisando el JSON del workflow. T-01 queda como la plantilla del proceso para reparar T-02 a T-05.

---

## 2026-08-27 (continuación)

**Arranca el Paso 1: motor propio SMC (código)**

Primer código real del sistema, en `codigo/motor_smc/` (venv local, `smartmoneyconcepts` + pandas):

- `motor.py` — envoltorio de detección nativa (`analizar()`): swings, FVG, order blocks, estructura (BOS/CHoCH) y liquidez, directo sobre `smartmoneyconcepts`. Sin reimplementar la detección, tal como se decidió en el Plan de construcción.
- `setup_ob_fvg.py` — primera regla concreta encima de esa detección: opera­cionaliza el setup insignia de la metodología (`docs/metodologia-trading.md` §7.4, "cacería de liquidez + MSB + FVG"). Un CHoCH confirmado por `bos_choch` ya exige por construcción que el swing previo haya sido barrido, así que la fila del CHoCH es la vela de barrido; se busca el primer FVG del mismo signo en una ventana corta después de esa vela (no atada al índice de confirmación, que puede quedar muy lejos) y la entrada queda en el punto medio del FVG, el stop en el extremo de la vela de barrido.
- Al escribir el self-check se encontró y corrigió un bug real: el candidato de FVG se buscaba en una ventana demasiado amplia (hasta el índice de confirmación de estructura, que puede estar 30+ velas después del barrido) y podía devolver un FVG de un movimiento posterior no relacionado, con el stop del lado equivocado de la entrada. Se acotó la ventana al barrido + N velas y se agregó un filtro de geometría que descarta cualquier candidato inválido en vez de reportarlo.

**Por qué:** valida que la librería (`smartmoneyconcepts`) resuelve lo que el plan asumía que resolvía, y deja el primer setup de la metodología operacionalizado de punta a punta (detección → regla → señal con entrada/stop) antes de sumar conectividad real o backtesting formal — ambos quedan pendientes, documentados en `codigo/README.md`.

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

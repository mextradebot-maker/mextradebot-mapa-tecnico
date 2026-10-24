# Bitácora — MexTradeBot Mapa Técnico

Registro de trabajo día por día en este proyecto. Cada entrada resume qué se hizo, qué se decidió y por qué — no solo el qué, para que quede el contexto de las decisiones.

---

## 2026-10-23

**Conferencia en The Trading Festival México (12 y 13 nov): todo el material listo — guion, láminas, video, tres QR y un canal público de Telegram**

- **Contexto:** XM invitó a Ricardo a una charla de 30 min para divulgar MexTradeBot (15 min de video + 15 min de preguntas). El material se entregó a XM Partners para que lo editen y le pongan su marca. Ricardo no sale en cámara: habla en vivo y el video corre detrás, sin audio.
- **Guion** de ~1,500 palabras (intro, método en 4 pasos, planes y costos, dónde suscribirse, cuenta en XM con el bono del 100 %, VPS, Jarvis, cierre) y una **guía de sincronización** con la hora exacta de cada cambio de lámina y la frase en que ocurre.
- **PowerPoint de 11 láminas** con marca de MexTradeBot y XM Partners: portada con imagen IA (un robot con corte ejecutivo toma una clase de trading), intro nueva, los 4 videos de diagramas (ecosistema, vida de un robot, datos y operación, flujo de membresía), planes, cuenta en XM, Jarvis y lámina final con Jarvis orquestando agentes de IA.
- **Video de 16:07** en 1080p, sin audio: los bloques de cada lámina aparecen cuando se habla de ellos, con dos bloques libres (2 min en la portada y 1 min al final) para que Ricardo hable con sus palabras. Se generó exportando desde PowerPoint con tiempos por lámina.
- **Tres códigos QR** con logo al centro, probados con lector: plan Trader mensual (Hotmart), registro en XM y comunidad de Telegram.
- **Canal público de Telegram** `t.me/mextradebot_comunidad` para captar gente (el canal que ya existía es solo para quienes contrataron; la Comunidad de Hotmart es exclusiva para suscriptores). Con guía de textos, reglas y primeras publicaciones.
- **Lenguaje cuidado de punta a punta:** sin promesas de ingresos ni "rentable", backtests presentados con sus límites (varias combinaciones resultaron compatibles con el azar), el bono descrito como algo que "multiplica el resultado, no lo asegura", Jarvis solo como "en desarrollo e informativo".

**Pendiente:** entregar el material a XM por enlace (el video pesa ~138 MB), publicar y fijar el mensaje de bienvenida del canal, ensayar el ritmo con la guía, decidir si se corrige el texto "activos rentables" del video 4, y atender lo que pida XM (guía de marca, leyendas legales). Detalle completo en `docs/checkpoint-2026-10-23.md` del proyecto MexTradeBot.

**Por qué:** la charla es la primera vez que MexTradeBot se presenta ante el público de un evento de trading junto a XM, así que el material se construyó con las mismas reglas de transparencia que ya gobiernan el sistema: mostrar los límites del backtest y no prometer resultados.

---

## 2026-09-21 → 2026-10-22

**Resumen retroactivo: esta bitácora no se actualizó entre el 20 de septiembre y hoy. Lo siguiente se reconstruye de los checkpoints del proyecto (`docs/checkpoint-*.md`), donde está el detalle.**

- **Master Trader y cuentas demo (21 sep):** el servicio local del VPS Windows ya devuelve el estado de las 5 cuentas demo conectadas en MT5 (4 de 5 correctas; una con credenciales por corregir) y existe el agente coordinador.
- **Decisión de arquitectura "el cerebro" (25 sep):** las reglas deterministas guardadas en Postgres son las que deciden; la IA solo propone reglas, no decide. Backend de **licencias** construido en una rama aparte, con una regla única para el tamaño de lote que une conectividad y riesgo. Faltaba desplegar variables de entorno.
- **Licencias automatizadas (26 sep):** el acceso DEMO se activa al conectar la cuenta de XM, el acceso REAL al pagar, y cada alumno recibe un robot (`.ex5`) personalizado.
- **Infraestructura (28 sep):** la API quedó en el VPS gestionado con EasyPanel, detrás de `mextradebot.com.mx` y `www` (Cloudflare); se resolvió el consumo de CPU del servidor, causado por procesos de otro proyecto.
- **Reglas de riesgo y Motor SMC v2 (29 sep):** pérdida máxima de 3 % con cierre forzado, no abrir si el stop supera 2 %, breakeven y trailing (EA v1.15); Motor SMC v2 con 7 temporalidades, almacén de velas y backtest largo en producción.
- **3 oct:** EA v1.17 en las 5 cuentas, catálogo real de 34 activos, ficha de descarga en producción y bot de Telegram arreglado. Se diagnosticó que los errores 502 venían de un bucle de reinicios del servicio.
- **13–14 oct:** correo con dominio propio y páginas legales con soporte@ desplegados; arreglo del 502 con un proceso hijo; estándar de seguridad de 20 puntos aplicado; curso importado a Hotmart; router de eventos de Hotmart (H-00) activo, enviando por Brevo con el dominio autenticado.
- **19–20 oct:** programa de afiliados de Hotmart (40 % recurrente) con kit y página; cumplimiento legal (términos, reglas de afiliado, avisos de riesgo, lenguaje neutro en panel, bot y correos).
- **21 oct:** casilla de consentimiento en el registro, `/alumnos` corregido, avisos a Slack (ventas, afiliados, errores, salud, motor de trading), y **carga histórica completa: 102 series y 204 backtests largos**. Resultado honesto: las combinaciones marcadas como buenas son compatibles con el azar (expectativa agregada cercana a cero) y las ventas en 1H y 4H pierden. Decisión: no cambiar el stop por ahora.
- **22 oct:** se instalaron alternativas a Adobe (PhotoCraft, VectorCraft, SoundCraft) con acceso confinado a una carpeta de trabajo.

**Por qué:** el hallazgo más importante del periodo es el del 21 oct: el sistema es transparente al reportar que el backtest largo no demuestra ventaja estadística, y eso marca cómo se habla del producto (sin "rentable", sin promesas) y qué sigue (revisar juntos el backtest y las estrategias antes de cualquier afirmación comercial).

---

## 2026-09-20

**Fase 2 BD SMC persistente terminada: el backtesting del wizard ahora puede arrancar desde la fecha en que cada símbolo entró al catálogo, no solo desde "últimos N días"**

- **Tabla `catalogo_activos` en Postgres**: estructura nueva (`simbolo`, `temporalidad`, `fecha_inicio DATE`, `activo BOOL`, clave primaria compuesta), con 180 pares precargados (36 símbolos × 5 temporalidades: Scalping, Intraday, Swing H/S/M), todos con `fecha_inicio = 2026-09-20` — la fecha real de arranque del catálogo completo. La migración vive en `persistencia/migraciones.py` y se aplica sola al levantar el sistema; no requiere intervención manual.
- **Parámetro `desde_catalogo` en `/api/backtest` y `/api/setups`**: cuando el panel (o cualquier llamador) lo manda como `true`, el sistema busca `fecha_inicio` en `catalogo_activos` para ese par símbolo+temporalidad y arranca el backtest desde ahí, ignorando el parámetro `dias`. Si Postgres no está disponible o el par no existe en el catálogo, cae silenciosamente al comportamiento de siempre (`dias`). Diseño deliberado: no rompe nada que ya funcionaba.
- **Endpoint nuevo `/api/catalogo`** (GET y POST): devuelve la lista completa de entradas del catálogo con sus fechas de inicio. Registrado en el router central `api/analizar.py`. Útil para que el panel muestre al alumno desde cuándo existe cada símbolo en el catálogo.
- **Toggle "Desde catálogo" / "Histórico completo" en la pestaña "Mis Validaciones" del wizard**: botón nuevo en la UI del panel de alumnos (Tab 6). Cuando está activo (azul), el backtest usa `desde_catalogo=true`; cuando no, usa el rango histórico por defecto. El estado se guarda en memoria dentro de la función JS de esa sección, sin localStorage — intencional: el alumno siempre arranca viendo el modo conservador por defecto.
- **Commit y push**: 7 archivos Python en un solo commit (`f1662a1`) al repo `mextradebot-maker/tradebotbuilder` → Vercel redesplegó automáticamente. El HTML del wizard se aplicó directamente al workflow `ltIbLXX62h0hXl7K` de n8n (nodo "Responder HTML"), sin pasar por git — ese nodo sigue siendo la fuente de verdad del panel.

**Pendiente técnico inmediato**: las migraciones de Postgres todavía no se han corrido contra el servidor real del VPS — la tabla `catalogo_activos` y su seed de 180 pares aún no existen en producción. Hay que ejecutar las migraciones una vez para que el parámetro `desde_catalogo` funcione de extremo a extremo; hasta entonces el sistema cae al comportamiento de "N días" (sin error visible para el alumno).

**Siguiente fase — Master Trader (no iniciada):** una cuenta demo XM por cada activo del catálogo + un agente autónomo que abra y cierre posiciones en esas cuentas siguiendo las señales que el mismo catálogo ya calcula. Los alumnos no dependen de esto para nada — conectan su propia cuenta MT5 de forma independiente. Esta fase requiere diseño antes de código (N cuentas MT5 en paralelo, envío de órdenes desde Python, extensión del endpoint de la pestaña "Cuenta demo").

**Por qué**: la Fase 1 (snapshots persistentes de setups) ya estaba; la Fase 2 añade el eje temporal — saber desde cuándo cada símbolo está "vigente" en el catálogo permite que el alumno vea el desempeño histórico desde el inicio real del catálogo, no un horizonte arbitrario de días. Detalle técnico (nombres exactos de archivos, commit hash, lógica de graceful degradation) en la memoria del proyecto y en los archivos de código correspondientes.

---

## 2026-09-19

**VPS gratuito de XM conectado de verdad a MT5, la pestaña "Cuenta demo" del panel ya muestra datos reales por primera vez, y se agregó una sexta pestaña de backtesting bajo demanda**

- **Dominio público correcto para el Panel de Alumnos**: se detectó que `mextradebot-app.vercel.app` (el dominio real que se le va a dar a los alumnos, y donde después va a apuntar `mextradebot.com.mx`) no mostraba el panel — mostraba otro proyecto (el motor/API). Se corrigió con un proxy transparente: el alumno visita ese mismo dominio y nunca ve la dirección real donde vive el panel por detrás.
- **El VPS gratuito de XM (conseguido por ser afiliado) ya está en uso real**: se instaló ahí MetaTrader 5 conectado a la cuenta demo de referencia, y el pequeño servicio que lee su balance/operaciones quedó corriendo como tarea programada de Windows — sobrevive sin que nadie tenga la sesión remota abierta. Resultado: la pestaña "Cuenta demo" del panel, que desde que se construyó solo mostraba un mensaje de "no se pudo conectar", **ya muestra el balance y las operaciones reales de la cuenta**.
- **Aclaración de alcance importante, revisando el mapa completo de pantallas**: se confirmó que un alumno NO necesita conectar nada a esta infraestructura para usar su propio robot — descarga el robot y lo conecta a su propia cuenta XM, totalmente aparte. Este VPS solo sirve para mostrar la cuenta de referencia de Ricardo como prueba de que los robots funcionan de verdad. Quedó anotado como pendiente futuro (no construido todavía): una cuenta demo por cada activo del catálogo, con un proceso automático que las opere solas.
- **Sexta pestaña del panel: "Mis Validaciones" (backtesting bajo demanda)**. Sorpresa favorable: los cálculos de backtest ya existían en el sistema (los usa el canal de Telegram desde hace tiempo), así que no hizo falta construir nada nuevo por detrás — solo conectar el panel a eso. Tiene dos modos: uno donde el alumno solo elige el símbolo y el sistema detecta la dirección solo, y otro donde el alumno elige todo a mano — este segundo se dejó listo a propósito para cuando exista el Constructor visual, sin tener que reconstruirlo entonces.

**Por qué:** el detalle técnico completo (arquitectura del proxy, pasos exactos del VPS, diseño de las dos pestañas) vive en `docs/superpowers/` y en la memoria de la sesión, no aquí — esta entrada es el resumen para quien solo quiere saber qué avanzó y por qué importa, sin tener que leer el detalle técnico.

---

## 2026-09-14

**Catálogo de activos ampliado de 9 a 36 símbolos, con 5 horizontes de tiempo en vez de 3, indicadores de confluencia, y un filtro real de "solo mostrar lo que ya funciona" — todo definido con cuidado antes de tocar código, y verificado en producción, no solo probado**

Sesión larga con un método distinto a las anteriores: primero se definió cada decisión de producto a detalle (qué símbolos, qué reglas, qué mostrar), después se construyó — no al revés.

- **Catálogo ampliado y verificado símbolo por símbolo**: de 9 a 36 activos (más cruces de forex, índices bursátiles, metales/energía, cripto y un puñado de acciones, incluidas dos mexicanas). Cada candidato se cruzó contra la fuente de datos históricos **y** contra el catálogo real del broker antes de aceptarlo — algunos candidatos quedaron fuera precisamente por no existir en ambos lados a la vez (cobre solo como futuro con vencimiento, una criptomoneda sin datos históricos disponibles, la mayoría de las acciones mexicanas propuestas sin cobertura del broker). El catálogo pasó de vivir duplicado en tres lugares distintos a una sola fuente compartida por Telegram, el panel web y el análisis diario de mercado.
- **De 3 horizontes de tiempo a 5**: se agregaron dos niveles de Swing más largos (semanal y mensual), cada uno con su propia tendencia — ya se sabía que la dirección del mercado puede ser distinta según la temporalidad, así que cada símbolo ahora se evalúa en los 5 horizontes, no en uno solo.
- **Indicadores de confluencia añadidos, con una regla explícita de uso**: se suman RSI, medias móviles, MACD y retroceso de Fibonacci como confirmaciones opcionales — pero de **una a la vez**, nunca combinadas. Combinar varias reduce la muestra de operaciones y puede dar una falsa sensación de estrategia óptima cuando en realidad está sobreajustada al pasado; el sistema explica esto directamente al alumno en vez de solo restringirlo en silencio.
- **Filtro real de viabilidad, no una etiqueta inventada**: antes de esta sesión no existía ningún cálculo real de "qué activos vale la pena mostrar". Ahora el catálogo se cruza contra los resultados reales del análisis diario y solo muestra por default los símbolos con evidencia real de operaciones históricas — el resto queda disponible en una lista completa desplegable, para quien quiera revisar el criterio.
- **Dos bugs reales encontrados y corregidos al ampliar el análisis diario a los 5 horizontes**: uno ya existente (el resumen del catálogo no recibía los datos de resultado del backtest, llegaban vacíos sin que nadie lo notara) y uno nuevo (el horizonte mensual, al tener muy pocas velas, a veces no logra determinar una tendencia clara, y eso podía tumbar toda la corrida en vez de simplemente saltarse ese caso). Ambos corregidos y verificados con una corrida real contra los 36 símbolos.
- **Bloqueo real encontrado, no de código**: la corrida de análisis diario llega hasta el paso de generar el resumen con IA y se detiene por falta de saldo en la cuenta usada ahí — el mismo pendiente de facturación que ya bloqueaba el monitoreo de la cuenta demo (ver entrada del 13). En cuanto se recargue, el catálogo termina de llenarse solo.

**Por qué:** definir cada decisión con precisión antes de construir evitó tener que rehacer trabajo — varias de las suposiciones iniciales (qué activos "deberían" estar disponibles, qué tan simple sería activar más indicadores) no coincidían con lo que el sistema realmente soporta, y se descubrió a tiempo revisando el código real en vez de asumiendo. El detalle técnico completo (nombres exactos de hojas de cálculo, workflows y archivos) vive en `docs/panel-alumnos-catalogo-indicadores-spec.md` y en la memoria de la sesión, no aquí.

---

## 2026-09-13

**T-05 queda expuesto a internet de verdad (dominio + túnel + servicio), EA pegado a un chart real con AutoTrading activo, y T-04 gana autenticación mínima**

- **Dominio propio para el proyecto**: se compró `mextradebot.com.mx` y se dio de alta en Cloudflare (gratis) — su DNS se movió ahí sin tocar el hosting de Neubox donde se compró, que sigue disponible para cuando se configure el sitio.
- **El "VPS provisional" (la propia PC) ya es alcanzable desde internet, sin abrir ningún puerto del router**: se instaló Cloudflare Tunnel como servicio de Windows (arranca solo, sobrevive reinicios igual que la Tarea Programada de MT5) y se publicó `https://demo-status.mextradebot.com.mx` apuntando al servidor local de T-05. El servidor mismo (`servidor_local.py`) también quedó con su propia Tarea Programada para arrancar solo al iniciar sesión. Probado de punta a punta con una consulta real desde fuera de la red — respondió con datos reales de la cuenta demo.
- **T-05 conectado en n8n a esa URL real** (ya no al placeholder "no existe VPS Windows"). Al correrlo real por primera vez, el nodo que trae los datos de MT5 funcionó perfecto — el eslabón que le seguía (Claude evaluando esos datos) se detuvo por falta de saldo en la cuenta de Anthropic usada ahí, algo de facturación externo, no del flujo en sí. Queda pendiente repetir la prueba completa una vez recargado ese saldo.
- **El EA (`MexTradeBot_SeguidorSMC.mq5`) se pegó por primera vez a un chart real** (GOLD, H1) con AutoTrading activado, documentando el proceso en vivo. Se confirmó el mismo aviso que ya predecía el manual del EA (falta autorizar la URL de la API en las opciones de MT5) y, además, se encontró y corrigió un bug real: el tiempo de espera de la consulta a la API (5 segundos) se quedaba corto cuando esa función pasa un rato sin usarse y tarda en "despertar" — se subió a 15 segundos y ya quedó publicado en el mismo archivo que reciben los alumnos.
- **T-04 (el webhook web para el futuro Panel de Alumnos) ya exige un código para usarse**, en vez de estar abierto a cualquiera que encontrara la URL — un candado sencillo mientras no existe todavía un sistema de acceso por alumno.

**Por qué:** T-05 llevaba semanas con el código listo pero bloqueado por no tener dónde correr el monitoreo de MT5 — con dominio propio y un túnel gratuito, la propia PC de Ricardo ya cumple ese papel de forma real y verificable, no solo en teoría, mientras se resuelve el VPS gratuito de XM. El bug del EA (timeout corto) es el tipo de falla que solo aparece usando el sistema en vivo, no revisando el código en papel — por eso vale la pena seguir probando cada pieza contra el sistema real antes de darla por buena. Detalle técnico completo (nameservers, nombre del túnel, comandos exactos) vive en `docs/manual-tecnico-interno.md`, no aquí.

---

## 2026-09-12 (continuación)

**T-04 con canal web publicado; arranca la preparación de T-05 — tu propia PC funcionando como "VPS" provisional, probado con reinicios reales**

- **T-04 ahora sirve por dos canales**: el mismo catálogo/creación de robots que ya existía en Telegram, ahora también disponible por un webhook nuevo para el Panel de Alumnos. Se extendió el nodo clasificador existente en vez de duplicarlo (duplicarlo rompía las referencias cruzadas de n8n entre Telegram y web) — mismo catálogo, mismas reglas de negocio, sin repetir lógica. Se encontró y corrigió un bug real antes de publicar: la regla de "no permitir robot Swing si la tendencia es bajista" se podía saltar mandando `"swing"` en minúsculas desde el canal web. Ya publicado en producción.
- **QuantAnalyzer investigado para T-05, descartado para uso automático**: es una herramienta de foto estática de un backtest ya hecho, sin conexión en vivo — sirve para análisis manual más adelante, no para la evaluación automática cada 6 horas que necesita T-05. La fuente correcta es el historial de operaciones que MT5 ya trae (`mt5.history_deals_get()`), consultado en vivo.
- **Se confirmó que el robot (`MexTradeBot_SeguidorSMC.mq5`) ya sobrevive reinicios sin cambiarle nada** — no guarda ningún estado propio, siempre revisa si ya hay algo abierto antes de operar, y el stop/take-profit viven en el servidor del broker, no en la terminal. Reinicio → retoma solo, preguntando de nuevo cuál es la mejor tendencia actual — exactamente el comportamiento que se buscaba.
- **Se armó y probó de verdad (con 3 reinicios reales) la cadena para que tu PC aguante reinicios sin que nadie esté presente**: inicio de sesión automático de Windows (Sysinternals Autologon, lo corrió Ricardo mismo — es un cambio de seguridad que no le corresponde a la IA), una tarea programada que abre MT5 solo al iniciar sesión, y un ajuste de permisos de administrador en esa tarea para que no se quede esperando el aviso de "¿permitir cambios?" que nadie puede aprobar en un reinicio desatendido. El primer intento (acceso directo en la carpeta de Inicio) no funcionó — se reemplazó por una tarea programada de verdad, más confiable y con historial de diagnóstico.
- **Pendiente, a propósito**: falta poner el EA en la gráfica y activar el trading automático (Ricardo lo quiere documentar con capturas antes de hacerlo, como los manuales anteriores) y construir la pieza real de T-05 (el mini-servidor local que exponga el historial de MT5 para que n8n lo consulte) — todo lo de hoy fue la base de infraestructura, no T-05 en sí.

**Por qué:** sin un VPS de verdad todavía, la propia PC de Ricardo tiene que aguantar el mismo trabajo — pero solo sirve si sobrevive sus reinicios frecuentes sin intervención humana. Probarlo con reinicios reales (no solo en teoría) fue lo que expuso los dos bloqueos reales (el acceso directo no confiable, y el aviso de permisos de administrador) — ninguno se habría visto solo revisando la configuración.

---

## 2026-09-09 (continuación)

**Cuenta demo nueva creada de punta a punta, conexión real a MT5/XM verificada por fin, y arranca el manual visual para alumnos**

- **Cuenta demo XM nueva**: la anterior (`99967235`) seguía muerta (ver entrada de abajo). Se creó una cuenta demo nueva (`318680674`, servidor `XMGlobal-MT5 7`, tipo Standard, balance inicial $10,000 USD) siguiendo el flujo real de registro con el link de afiliado de Ricardo (`affs.click/Ahf2k` + código `HDY28`) — todo el proceso quedó documentado paso a paso con capturas reales (ver punto del manual, abajo).
- **Conexión real MT5↔Python verificada, por fin funcionando**: `conectividad.xm.demo()` conecta con la cuenta nueva y trae el balance real. En el camino se encontró y corrigió un bug: el símbolo de oro estaba hardcodeado como `"XAUUSD"`, pero en este servidor de XM se llama `"GOLD"` — no existe `XAUUSD` en su catálogo. Se agregó también un `symbol_select()` defensivo antes de pedir velas, para que un símbolo mal escrito dé un error claro en vez de uno genérico. Se encontró y borró de paso un `.env` duplicado suelto dentro de `tradebotbuilder/.venv/` que traía los valores viejos y generaba confusión al revisar el archivo.
- **Arranca el manual visual para alumnos** ("Cómo abrir tu cuenta XM para MetaTrader 5"): un slider de una sola pieza (`mextradebot-mapa-tecnico/manual-cuenta-xm.html`), con el mismo sistema visual del mapa técnico (IBM Plex, paleta pergamino/oscuro), capturas reales incrustadas en base64, navegación por teclado/botones/puntos, y el link+código de afiliado copiables en la portada. Cubre 13 pasos hasta ahora: entrar con el link oficial, registro, panel de cuenta, elegir Demo, elegir MT5, elegir tipo de cuenta (Standard, con la razón de por qué no Ultra Low), configurar parámetros del robot, revisar el correo con ID/servidor, descargar la plataforma, elegir sistema operativo, y abrir el instalador. Queda pausado a propósito para retomar la conectividad — sigue pendiente el paso final de login dentro de MT5 (falta una captura) antes de darlo por completo.

**Por qué:** la cuenta muerta llevaba bloqueando la verificación real de la conectividad desde ayer — con una cuenta viva, T-05 ya tiene lo único que le faltaba (un MT5 con sesión real para monitorear). El manual, aparte de ser material para alumnos, terminó sirviendo como el registro paso a paso de cómo se creó esta cuenta nueva. Detalle técnico completo (nombres exactos de archivos, credenciales) vive en `docs/manual-tecnico-interno.md` y en la memoria de la sesión, no aquí.

---

## 2026-09-09

**Panel de Alumnos construido y migrado a base de datos real; primer intento de conexión real a MT5/XM**

- **Panel de Alumnos (registro + login)**: nueva experiencia visual para que un alumno se registre, reciba el link al canal de Telegram, y desde ahí descargue los robots que quiera para conectarlos a su propia instalación de MT5 — decidido explícitamente que MexTradeBot no aloja un sistema de escritorio remoto compartido, cada alumno usa su propio MT5. Primero se probó sobre Google Sheets; a petición de Ricardo se migró la base de usuarios al Postgres real que ya existe en EasyPanel, con contraseñas guardadas con sal + hash, nunca en texto plano. Registro y login verificados en vivo, de punta a punta.
- **Primer intento de conexión real a una cuenta de XM vía MT5**: se probó el conector ya construido (`conectividad.xm`) contra una cuenta demo real. Tras una sesión larga de diagnóstico, se encontró la causa real: la cuenta demo usada llevaba tiempo inactiva y XM la había congelado automáticamente — no era un problema del código ni de las credenciales. Queda pendiente repetir la prueba con una cuenta demo nueva.

**Por qué:** el Panel de Alumnos es la pieza que faltaba entre "un alumno se inscribe" y "un alumno tiene un robot corriendo en su propia cuenta" — sin volver a pedirle credenciales de trading directo, que era el diseño que ya se había descartado por parecerse a copy trading. El detalle técnico completo (arquitectura del panel, esquema de base de datos, y el diagnóstico completo de la cuenta XM) vive en el manual técnico interno, no en este mapa público.

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

## 2026-08-28 (continuación 5)

**Búsqueda de VPS Windows para T-05 — resuelta por la vía correcta, en espera**

Cierre corto del día: se evaluaron varias opciones para el VPS Windows que necesita T-05 (Azure free tier, un proveedor especializado en VPS para trading, el propio VPS de XM). Cada una tuvo su propia fricción — cuentas nuevas de Azure con cuotas restringidas, un proveedor que pedía tarjeta pese a anunciarse como gratis sin tarjeta, la interfaz nueva de XM sin el botón de VPS visible a simple vista.

La resuelve la vía correcta: Ricardo es afiliado de XM, y por ese patrocinio le corresponde VPS gratis — el trámite ya quedó enviado con el equipo correspondiente de XM, en espera de respuesta. Se decidió no seguir forzando alternativas peores solo por prisa — T-05 no bloquea nada más del sistema, así que esperar la vía gratuita confirmada es lo correcto.

**Por qué:** vale más documentar honestamente una búsqueda que no cerró hoy que forzar una solución de peor calidad solo para marcar la tarea como completa. El detalle completo de cada opción evaluada vive en el manual técnico interno.

---

## 2026-08-28 (continuación 4)

**Cierra la Serie T: T-01 corregido de verdad, T-04 rediseñada y en producción, T-05 reparado (bloqueado por infraestructura)**

Última tanda del día — cierra la primera pasada completa de reparación de las 5 workflows de la Serie T.

- **T-01 corregido de verdad**: el bug del nodo de edición de campos encontrado ayer en T-03 también rompía T-01, que se había marcado como resuelto sin haberlo verificado a fondo. Ya corregido y confirmado con una ejecución real — el reporte completo llega a Telegram.
- **T-04 rediseñada por completo, dos veces, a petición de Ricardo**: el diseño original (transmitir señales de trading a un grupo) se descartó por completo. Ahora es un flujo conversacional dentro de Telegram (`/Robot`) que entrega robots ya construidos y con backtest real, no señales. El usuario elige símbolo, temporalidad y riesgo con botones; si elige temporalidad "swing" y el activo no está en tendencia alcista en ese momento, se le avisa y se le ofrecen alternativas — nunca se le vende una operación swing en contra de la tendencia. Antes de entregar el robot, el sistema avisa el momento actual del mercado y corre un backtest real de esa dirección específica. Ya está en producción, probado en vivo con datos reales.
- **T-05 reparado en la parte que depende de nosotros**: la lógica de evaluación (Claude + extracción + notificación) quedó corregida y verificada. Pero el monitoreo de la cuenta demo real de MT5 sigue bloqueado — se necesita un servidor Windows con la terminal MT5 corriendo, y el único servidor disponible hoy es Linux. Queda documentado como pendiente de infraestructura, no de código.

**Por qué:** con esto las 5 workflows de la Serie T pasaron por una revisión real, con ejecuciones reales, no solo una revisión de que la configuración se viera correcta — que es exactamente el patrón que expuso el bug de T-01. El detalle técnico completo (arquitectura de T-04, la regla de negocio del swing trading, el bloqueo de infraestructura de T-05) vive en el manual técnico interno, no en este mapa público.

---

## 2026-08-28 (continuación 3)

**T-03 reparado: Claude ahora audita resultados de backtest reales, no solo reenvía datos vacíos**

Tercera workflow de la Serie T reparada — el más profundo de los tres arreglos hasta ahora, con varios bugs reales encontrados en producción, no solo en teoría.

- **Qué hace ahora T-03**: recibe resultados de un backtest por webhook, Claude los audita contra 3 criterios (profit factor, drawdown, win rate), y en el mismo análisis calcula el capital mínimo recomendado para operar el robot y clasifica su nivel de riesgo. Si aprueba, registra el robot en una hoja de cálculo y notifica por Telegram; si rechaza, notifica igual con las razones.
- **Bug de arquitectura encontrado y corregido, aplicable a cualquier workflow futura**: un tipo de nodo de n8n (el que edita/renombra campos) dejó de aplicar su configuración silenciosamente — el dato pasaba de largo sin transformarse, sin ningún error visible. Se comprobó que el mismo problema ya afectaba a T-01 desde su reparación anterior (el reporte llegaba vacío a Telegram) — queda pendiente corregirlo ahí también. La solución fue reemplazar ese tipo de nodo por uno de código explícito, que sí ejecuta de forma confiable.
- **Tres comportamientos reales de Claude que había que manejar** (encontrados probando con datos reales, no anticipados de antemano): a veces antepone su razonamiento interno antes de la respuesta y hay que saber distinguirlo del resultado final; si el límite de longitud de respuesta es muy corto, puede agotarlo pensando y nunca llegar a responder; y pese a pedir explícitamente una respuesta sin formato extra, a veces la envuelve en un bloque de código de todos modos. Los tres quedaron resueltos con manejo defensivo.
- **Verificado en vivo, no solo en simulación**: seis pruebas reales, ambos caminos (aprobado y rechazado), incluyendo el registro real en la hoja de cálculo y la llegada del mensaje completo a Telegram — confirmado por Ricardo.

**Por qué:** el bug del nodo de edición de campos es el hallazgo más importante del día — no es exclusivo de T-03, ya estaba presente (sin detectar) en un workflow que se había dado por resuelto. La disciplina de probar con ejecuciones reales, no solo revisar que la configuración se vea correcta, fue lo que lo sacó a la luz. El detalle técnico completo (nombres de nodos, código exacto, la anatomía de cada bug) vive en el manual técnico interno, no en este mapa público.

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

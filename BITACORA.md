# Bitácora — MexTradeBot Mapa Técnico

Registro de trabajo día por día en este proyecto. Cada entrada resume qué se hizo, qué se decidió y por qué — no solo el qué, para que quede el contexto de las decisiones.

---

## 2026-08-25

**Publicación y modelo de negocio**

- Se resolvieron las notas de producto pendientes sobre el mapa técnico:
  - Compatibilidad **MT4 y MT5** explícita en la propuesta de arquitectura (antes solo mencionaba MT4).
  - **Prioridad de producto**: sistema de competición comunitaria primero; cuentas de fondeo incluidas pero en segundo plano del roadmap (no en la primera versión).
  - Modelo de negocio propio reemplazó al de la plataforma de referencia: **Free** ($0, construir sin conectar cuentas) → **Premium** ($27 USD/mes, construir + demo + real) → **Golden** ($35 USD/mes, todo lo anterior + robot en producción, clases de agentes de IA, cursos de indicadores). Comunidad MexTradeBot incluida en los tres planes.
- Contenido de la presentación para XM preparado en 10 tarjetas (límite del plan gratuito de Gamma) — Gamma vía MCP falló por créditos de API insuficientes (pool separado del de la cuenta web, que sí tenía 400 créditos) — se optó por generar manualmente pegando texto en gamma.app.
- Repo creado por Ricardo: `mextradebot-maker/mextradebot-mapa-tecnico`. Se preparó localmente (`index.html` + `README.md`), commit hecho, remoto configurado — el `git push` lo corrió Ricardo directamente (en esta sesión el push por git se cuelga pidiendo login interactivo).
- **Desplegado en Vercel** bajo el team `mextradebot-9549`.

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

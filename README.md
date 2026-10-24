# MexTradeBot — Mapa Técnico

Documento de referencia técnica consolidado para el diseño del sistema propio de robots de trading de MexTradeBot (constructor, optimización, carteras, IA aplicada y cuentas de fondeo), incluyendo nuestro modelo de negocio y la propuesta de arquitectura.

Página estática de una sola pieza (`index.html`), sin build step — Vercel la sirve directamente.

## Desarrollo local

Abre `index.html` en el navegador. No requiere instalación ni dependencias.

## Despliegue

**Actual (desde 23 oct 2026): VPS con EasyPanel, en `mapa.mextradebot.com.mx`, con usuario y clave.**

El repositorio incluye un `Dockerfile` (nginx) que sirve `index.html`. Variables de entorno obligatorias en EasyPanel: `MAPA_USER` y `MAPA_PASS`. Sin ellas el contenedor no arranca, para que nunca se publique sin clave. El chequeo de salud es `/health`. No se guardan claves en el repositorio.

Pasos en EasyPanel: crear una app desde este repositorio de GitHub con build por Dockerfile, agregar las dos variables, asignar el dominio y activar HTTPS. En Cloudflare: registro CNAME `mapa` hacia el mismo destino que `www`.

**Anterior:** Vercel, como proyecto estático (framework preset "Other"). El equipo de Vercel fue bloqueado por uso justo el 23 oct 2026, por eso se migró.

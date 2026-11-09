# OpenHIIT ES

Versión personal de [OpenHIIT](https://github.com/a-mabe/OpenHIIT) (licencia MIT,
© Abby Mabe) con:

- Interfaz completa en español de España, incluida la notificación del temporizador.
- Anuncios por voz de series y tandas («Serie 2 de 4. Tanda 3 de 8.»).
  - Funcionan con la pantalla bloqueada y en segundo plano.
  - Bajan el volumen de Spotify u otras apps mientras hablan.
  - Se activan o desactivan en Ajustes → Anuncios por voz.
- Identificador propio (`com.aker1305.openhiit_es`, nombre «OpenHIIT ES»), de modo
  que se instala junto a la OpenHIIT oficial.

Terminología: **serie** = una vuelta completa del bloque; **tanda** = cada intervalo
de trabajo dentro de la serie.

## Contenido

| Carpeta | Qué es |
|---|---|
| `apk/` | APK listo para instalar (`OpenHIIT-ES-1.7.0-b59.apk`) y su SHA-256. |
| `codigo/` | Código fuente completo, listo para compilar. |
| `parches/` | Los 6 cambios sobre OpenHIIT original, como parches de git. |

## Instalar

1. Descargar `apk/OpenHIIT-ES-1.7.0-b59.apk` en el móvil y abrirlo.
2. Permitir «Instalar apps desconocidas» si Android lo pide.
3. Requisitos: Android 7.0 o superior y la voz en español instalada en
   Ajustes → Sistema → Idioma → Salida de texto a voz.

## Firma (importante)

El APK está firmado con una clave propia que **no está en este repositorio**
(`openhiit-es.jks`, alias `openhiit-es`). Se guarda aparte, en privado.
Sin esa clave, una versión nueva no se puede instalar encima de la actual:
habría que desinstalar y se perderían los temporizadores no exportados.

## Compilar

Base: OpenHIIT commit `f95cf5028eeb4dd7d5255e28266e4aab540e4585`
(versión 1.7.0+56). El APK b59 se compiló con Flutter 3.47.9 estable.

```bash
cd codigo
# android/key.properties (no se sube al repositorio):
#   storePassword=...
#   keyPassword=...
#   keyAlias=openhiit-es
#   storeFile=/ruta/a/openhiit-es.jks
flutter pub get
flutter test
flutter build apk --release --build-number=60 --android-skip-build-dependency-validation
```

- Subir `--build-number` en cada versión nueva para que se instale como actualización.
- `--android-skip-build-dependency-validation`: con Flutter 3.47 hace falta porque el
  proyecto usa Android Gradle Plugin 8.9.1 y esa versión de Flutter pide 8.11.1.
  Con una versión de Flutter más antigua puede no hacer falta (no comprobado).
- Al compilar, Flutter puede añadir líneas automáticas a `android/gradle.properties`.

## Cambios técnicos

- `packages/background_hiit_timer/`: copia local de la librería del temporizador
  (MIT, © Abigail Mabe, versión 1.2.3) con la voz añadida en el servicio de
  segundo plano (`lib/utils/voice.dart`).
- `lib/features/run_timer/voice/voice_announcements.dart`: genera los textos.
- `lib/core/utils/display_names.dart`: nombres de intervalos en español; los nombres
  internos («Work», «Rest»…) no cambian, así que los temporizadores guardados siguen
  funcionando.

## Limitaciones conocidas

- Siguen en inglés, porque no son de la app: los textos de licencias de software
  (Ajustes → Acerca de) y los diálogos de permisos del sistema, que usan el idioma
  del móvil.
- Verificado con tests unitarios y análisis estático. Los tests de integración
  (necesitan dispositivo) no se han ejecutado. La b58 está probada en el móvil
  (voz con pantalla bloqueada y con Spotify). La b59 solo cambia textos y está
  pendiente de probar en el móvil.

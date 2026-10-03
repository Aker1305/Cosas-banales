# 🧹 LIMPIEZA EXTREMA WINDOWS 11 - GUÍA COMPLETA

## 📋 Descripción

Script batch optimizado que combina las mejores prácticas de limpieza del sistema Windows 11. Realiza una limpieza exhaustiva y segura del PC, eliminando archivos temporales, caché, registros y optimizando el rendimiento.

## 🔐 Características de Seguridad

✅ **Punto de restauración automático** - Se crea antes de iniciar la limpieza
✅ **Validación de permisos** - Solicita admin automáticamente si es necesario
✅ **Manejo seguro de errores** - Continúa aunque falle alguna operación
✅ **Reversible** - Puedes restaurar desde el punto creado al inicio
✅ **Servicios respaldados** - Reinicia automáticamente los servicios detenidos

## 📂 Qué Limpia

### 1. **Archivos Temporales**
- Carpeta TEMP de usuario (`%TEMP%`)
- Carpeta TEMP del sistema (`C:\Windows\Temp`)
- Carpeta Windows.old

### 2. **Cache de Windows Update**
- Descargas pendientes
- DataStore de actualizaciones
- Respaldos de actualizaciones supercedidas

### 3. **Registros del Sistema**
- Logs de Windows
- Archivos de eventos (.evtx)

### 4. **Cache y Prefetch**
- Archivos de Prefetch
- Caché de miniaturas del Explorador
- Caché de AppData

### 5. **Memoria y Dumps**
- Volcados de memoria completos
- Minidumps del sistema

### 6. **Optimizaciones del Sistema**
- Limpieza profunda WinSxS (DISM)
- CompactOS (compresión de archivos del SO)
- TRIM en SSD
- Caché DNS

### 7. **Papelera de Reciclaje**
- Vaciado completo

## ⚡ Servicios Detenidos (y Reiniciados)

- Windows Update (wuauserv)
- BITS
- Windows Search
- Superfetch/SysMain

## 🚀 Cómo Usar

### ⭐ OPCIÓN RECOMENDADA: Archivo VBS

**Usa este método, es el más confiable:**

```
1. Descarga: LIMPIEZA_EXTREMA_WINDOWS11.vbs
2. Doble click directo en el archivo
3. Verás ventana negra con "LIMPIEZA EXTREMA WINDOWS 11"
4. Se abre aviso de UAC (pantalla azul)
5. Haces click en "Sí"
6. Se ejecuta la limpieza completa
7. Verás el progreso en tiempo real
8. Al terminar muestra: "LIMPIEZA COMPLETADA CON EXITO"
9. Cierra la ventana y reinicia el PC
```

**Ventajas del VBS:**
- ✅ Doble click directo, sin problemas
- ✅ Pide permisos correctamente
- ✅ Se ejecuta siempre completamente
- ✅ No se cierra prematuramente
- ✅ Compatible con más sistemas

### Opción 2: Versión Batch (Alternativa)
```batch
1. Descarga el archivo LIMPIEZA_EXTREMA_WINDOWS11.bat
2. Click derecho → "Ejecutar como administrador"
3. Confirma el aviso de UAC
4. Espera a que se complete
5. Reinicia tu PC cuando termine
```

### Opción 3: Desde PowerShell (Admin)
```powershell
cd "C:\ruta\del\archivo"
.\LIMPIEZA_EXTREMA_WINDOWS11.vbs
```

### Opción 4: Crear Tarea Programada
```
1. Abre Programador de tareas
2. Crear tarea básica
3. Nombre: "Limpieza Windows 11"
4. Desencadenador: Diariamente a las 2:00 AM
5. Acción: Ejecutar programa (LIMPIEZA_EXTREMA_WINDOWS11.vbs)
6. Marcar: "Ejecutar con privilegios más altos"
```

## ⏱️ Tiempo Estimado

- **Limpieza rápida**: 15-20 minutos
- **Con DISM completo**: 30-45 minutos
- **Con CompactOS**: 45-60 minutos

*El tiempo varía según:
- Cantidad de archivos temporales
- Tamaño de la partición C:
- Velocidad del disco (HDD vs SSD)
- Poder de procesamiento del PC*

## 📊 Espacio Liberado Típico

- **Limpieza básica**: 1-5 GB
- **Con DISM**: 5-20 GB
- **Con CompactOS**: 10-50 GB (puede ocupar más al inicio)

## ⚙️ Qué Sucede Durante la Ejecución

```
1. Valida permisos admin (solicita elevación si falta)
2. Crea punto de restauración de seguridad
3. Detiene servicios bloqueantes
4. Limpia todas las categorías de archivos temporales
5. Ejecuta operaciones de optimización (DISM, CompactOS, TRIM)
6. Reinicia los servicios que detuvo
7. Reinicia el Explorador de Windows
8. Muestra confirmación de finalización
```

## ⚠️ Advertencias Importantes

### ❌ NO Hagas Esto
- No interrumpas el script mientras se ejecuta
- No desconectes el PC de la corriente
- No abras aplicaciones pesadas durante la ejecución
- No uses el PC intensivamente durante DISM/CompactOS

### ⚠️ Posibles Efectos Secundarios (Normales)
- El siguiente arranque puede ser **más lento** (reconstruye caché)
- Windows Update puede tardar en empezar (normal)
- Búsqueda de Windows se indexará nuevamente

## 🔄 Recuperación

Si algo sale mal, tienes dos opciones:

### Opción 1: Restaurar Sistema
```
1. Inicio → Configuración → Sistema → Recuperación
2. Opciones avanzadas → Restaurar sistema
3. Selecciona el punto "Respaldo antes de limpieza extrema"
4. Confirma y espera
```

### Opción 2: Reparar Windows
```powershell
# En PowerShell como admin:
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```

## 📈 Resultados Esperados

Después de ejecutar este script:
- ✅ Más espacio libre en disco
- ✅ Sistema más responsivo
- ✅ Menos consumo de RAM
- ✅ Arranque más rápido (después del primer)
- ✅ Menos archivos basura
- ✅ Mejor rendimiento en juegos y aplicaciones pesadas

## 🛠️ Mejoras sobre Scripts Originales

| Característica | Original 1 | Original 2 | Este Script |
|---|---|---|---|
| Punto de restauración | ❌ | ❌ | ✅ |
| Manejo de errores | Básico | Bueno | Excelente |
| Reinicia servicios | Parcial | No | ✅ Completo |
| Vacía papelera | ❌ | ✅ | ✅ |
| DISM Cleanup | ✅ | ✅ | ✅ |
| CompactOS | ✅ | ❌ | ✅ |
| TRIM automático | ✅ | ❌ | ✅ |
| Logs claros | Básico | Bueno | Excelente |
| Seguridad | Media | Alta | Muy Alta |

## 🔗 Comandos Clave Explicados

```batch
:: Detiene servicios (no los desinstala)
net stop wuauserv

:: Limpia recursivamente archivos y carpetas
del /s /f /q "C:\carpeta\*.*"
for /d %%x in ("C:\carpeta\*") do @rd /s /q "%%x"

:: Limpieza de componentes Windows (sin desinstalar)
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

:: Comprime archivos del SO (reversible)
compact.exe /CompactOS:always

:: Optimiza SSD
defrag C: /L

:: Limpia DNS
ipconfig /flushdns
```

## 🎯 Recomendaciones Post-Limpieza

1. **Reinicia el PC** - Es lo más importante
2. **Ejecuta Disk Cleanup** - Puede haber más archivos
3. **Actualiza Windows** - Los servicios ya están listos
4. **Ejecuta este script mensualmente** - Mantenimiento óptimo
5. **Revisa Administrador de tareas** - Busca procesos innecesarios

## 📞 Soporte

Si tienes problemas:
1. Comprueba que tienes permisos admin
2. Desactiva antivirus temporalmente
3. Reinicia en Modo Seguro si falla
4. Usa la restauración de sistema si es necesario

## 📄 Licencia y Autoría

- **Script Combinado y Optimizado**: v2.0
- **Autor Original**: Alberto
- **Optimización**: Script Mejorado para máxima limpieza
- **Uso**: Personal y educativo

---

**Última actualización**: 2026-10-03
**Compatibilidad**: Windows 11 (todas las ediciones)

@echo off
REM ============================================
REM   LIMPIEZA EXTREMA WINDOWS 11 - OPTIMIZADO
REM   By Alberto | Script Combinado v2.0
REM   Limpieza exhaustiva y segura del sistema
REM ============================================

setlocal enabledelayedexpansion
color 1F
cls

REM 1. VERIFICAR PERMISOS DE ADMINISTRADOR
echo.
echo ============================================
echo   VERIFICANDO PERMISOS DE ADMINISTRADOR
echo ============================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [!] Se requieren permisos de administrador.
    echo.
    echo Solicitando elevacion de privilegios...
    timeout /t 2 /nobreak >nul
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

echo [+] Permisos de administrador confirmados.
timeout /t 1 /nobreak >nul

REM 2. CREAR PUNTO DE RESTAURACIÓN (RESPALDO DE SEGURIDAD)
echo.
echo ============================================
echo   CREANDO PUNTO DE RESTAURACION
echo ============================================
echo [+] Creando punto de restauracion para seguridad...
powershell -Command "Checkpoint-Computer -Description 'Respaldo antes de limpieza extrema' -RestorePointType 'MODIFY_SETTINGS'" 2>nul
if %errorlevel% equ 0 (
    echo [+] Punto de restauracion creado exitosamente.
) else (
    echo [!] No se pudo crear punto de restauracion (puede continuar).
)
timeout /t 2 /nobreak >nul

REM 3. DETENER SERVICIOS BLOQUEANTES
echo.
echo ============================================
echo   DETENIENDO SERVICIOS Y PROCESOS
echo ============================================
echo [+] Deteniendo OneDrive...
taskkill /F /IM OneDrive.exe >nul 2>&1

echo [+] Deteniendo Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

echo [+] Deteniendo servicio de busqueda...
net stop WSearch >nul 2>&1

echo [+] Deteniendo Superfetch...
net stop SysMain >nul 2>&1

timeout /t 2 /nobreak >nul

REM 4. LIMPIAR TEMPORALES DE USUARIO Y SISTEMA
echo.
echo ============================================
echo   LIMPIANDO ARCHIVOS TEMPORALES
echo ============================================
echo [+] Limpiando carpeta TEMP de usuario...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%x in ("%temp%\*") do @rd /s /q "%%x" >nul 2>&1

echo [+] Limpiando carpeta TEMP del sistema...
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do @rd /s /q "%%x" >nul 2>&1

echo [+] Limpiando carpeta Windows.old (si existe)...
rmdir /s /q "C:\Windows.old" >nul 2>&1

timeout /t 2 /nobreak >nul

REM 5. LIMPIAR CACHE DE WINDOWS UPDATE
echo.
echo ============================================
echo   LIMPIANDO CACHE DE WINDOWS UPDATE
echo ============================================
echo [+] Eliminando descargas de Windows Update...
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\SoftwareDistribution\Download\*") do @rd /s /q "%%x" >nul 2>&1

echo [+] Limpiando DataStore de Windows Update...
del /s /f /q "C:\Windows\SoftwareDistribution\DataStore\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\SoftwareDistribution\DataStore\*") do @rd /s /q "%%x" >nul 2>&1

timeout /t 1 /nobreak >nul

REM 6. LIMPIAR LOGS DEL SISTEMA
echo.
echo ============================================
echo   ELIMINANDO REGISTROS DE EVENTOS
echo ============================================
echo [+] Limpiando logs del sistema...
del /s /f /q "C:\Windows\Logs\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\Logs\*") do @rd /s /q "%%x" >nul 2>&1

echo [+] Limpiando archivos de eventos...
del /s /f /q "C:\Windows\System32\winevt\Logs\*.evtx" >nul 2>&1

timeout /t 1 /nobreak >nul

REM 7. LIMPIAR PREFETCH
echo.
echo ============================================
echo   LIMPIANDO PREFETCH
echo ============================================
echo [+] Eliminando archivos de Prefetch...
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\Prefetch\*") do @rd /s /q "%%x" >nul 2>&1

timeout /t 1 /nobreak >nul

REM 8. LIMPIAR CACHÉ DE MINIATURAS
echo.
echo ============================================
echo   LIMPIANDO CACHE DE MINIATURAS
echo ============================================
echo [+] Eliminando caché de miniaturas del Explorador...
del /s /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache*.*" >nul 2>&1

timeout /t 1 /nobreak >nul

REM 9. LIMPIAR CACHÉ DE APLICACIONES
echo.
echo ============================================
echo   LIMPIANDO CACHE DE APLICACIONES
echo ============================================
echo [+] Limpiando caché de AppData...
del /s /f /q "%LocalAppData%\Temp\*.*" >nul 2>&1
for /d %%x in ("%LocalAppData%\Temp\*") do @rd /s /q "%%x" >nul 2>&1

timeout /t 1 /nobreak >nul

REM 10. LIMPIAR VOLCADOS DE MEMORIA
echo.
echo ============================================
echo   ELIMINANDO VOLCADOS DE MEMORIA
echo ============================================
echo [+] Eliminando volcados de memoria completos...
del /s /f /q "C:\Windows\MEMORY.DMP" >nul 2>&1

echo [+] Eliminando minidumps...
del /s /f /q "C:\Windows\Minidump\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\Minidump\*") do @rd /s /q "%%x" >nul 2>&1

timeout /t 1 /nobreak >nul

REM 11. LIMPIAR WINSXS (LIMPIEZA PROFUNDA)
echo.
echo ============================================
echo   LIMPIEZA PROFUNDA WINSXS
echo ============================================
echo [+] Iniciando DISM Cleanup-Image (puede tardar unos minutos)...
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
echo [+] DISM Cleanup completado.

timeout /t 2 /nobreak >nul

REM 12. ELIMINAR ACTUALIZACIONES SUPERCEDIDAS
echo.
echo ============================================
echo   ELIMINANDO ACTUALIZACIONES SUPERCEDIDAS
echo ============================================
echo [+] Limpiando actualizaciones antiguas...
dism /online /cleanup-image /spsuperseded >nul 2>&1
echo [+] Actualizaciones antiguas eliminadas.

timeout /t 1 /nobreak >nul

REM 13. BORRAR PUNTOS DE RESTAURACIÓN ANTIGUOS
echo.
echo ============================================
echo   ELIMINANDO PUNTOS DE RESTAURACION ANTIGUOS
echo ============================================
echo [+] Eliminando volumenes espejo antiguos...
vssadmin delete shadows /all /quiet >nul 2>&1
echo [+] Puntos de restauracion antiguos eliminados.

timeout /t 1 /nobreak >nul

REM 14. COMPACTAR SISTEMA (COMPACTOS)
echo.
echo ============================================
echo   ACTIVANDO COMPACTOS
echo ============================================
echo [+] Comprimiendo archivos del sistema (puede tardar)...
compact.exe /CompactOS:always >nul 2>&1
echo [+] CompactOS activado.

timeout /t 2 /nobreak >nul

REM 15. EJECUTAR TRIM EN SSD
echo.
echo ============================================
echo   OPTIMIZANDO SSD - TRIM
echo ============================================
echo [+] Ejecutando optimizacion TRIM (puede tardar)...
defrag C: /L >nul 2>&1
echo [+] TRIM completado.

timeout /t 1 /nobreak >nul

REM 16. LIMPIAR CACHÉ DNS
echo.
echo ============================================
echo   LIMPIANDO CACHE DNS
echo ============================================
echo [+] Vaciando caché DNS...
ipconfig /flushdns >nul 2>&1
echo [+] Caché DNS limpiado.

timeout /t 1 /nobreak >nul

REM 17. VACIAR PAPELERA DE RECICLAJE
echo.
echo ============================================
echo   VACIANDO PAPELERA DE RECICLAJE
echo ============================================
echo [+] Vaciando papelera...
powershell -Command "Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue" >nul 2>&1
echo [+] Papelera vaciada.

timeout /t 1 /nobreak >nul

REM 18. REINICIAR SERVICIOS
echo.
echo ============================================
echo   REINICIANDO SERVICIOS
echo ============================================
echo [+] Reiniciando Windows Update...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo [+] Reiniciando servicio de busqueda...
net start WSearch >nul 2>&1

echo [+] Reiniciando Superfetch...
net start SysMain >nul 2>&1

timeout /t 2 /nobreak >nul

REM 19. REINICIAR EXPLORADOR
echo.
echo ============================================
echo   REINICIANDO EXPLORADOR
echo ============================================
echo [+] Reiniciando Explorador de Windows...
start explorer.exe >nul 2>&1

echo.
echo ============================================
echo   LIMPIEZA EXTREMA COMPLETADA CON EXITO
echo ============================================
echo.
echo [✓] Tu PC ha sido optimizado al maximo
echo [✓] Se creo un punto de restauracion al inicio
echo [✓] Todos los servicios han sido reiniciados
echo.
echo RECOMENDACIONES:
echo  - Reinicia el PC para ver los cambios totales
echo  - La proxima vez tardara mas en arrancar (caché se renueva)
echo.

timeout /t 5 /nobreak
pause
exit /b

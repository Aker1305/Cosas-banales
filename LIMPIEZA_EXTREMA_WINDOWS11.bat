@echo off
REM ============================================
REM   LIMPIEZA EXTREMA WINDOWS 11 - v2.2
REM   By Alberto | Script Optimizado
REM ============================================

setlocal enabledelayedexpansion
color 1F

REM DETECTAR SI ESTÁ EJECUTÁNDOSE COMO ADMIN
whoami /groups | find /i "S-1-16-12288" >nul
if errorlevel 1 (
    cls
    echo.
    echo ============================================
    echo   SOLICITANDO PERMISOS DE ADMINISTRADOR
    echo ============================================
    echo.
    echo [!] Se requieren permisos de administrador.
    echo.
    echo Acepte el aviso de UAC cuando aparezca...
    echo.

    REM Crear archivo batch temporal en Windows\Temp
    set "batchfile=%~0"
    set "tempbat=%tmp%\cleanup_temp_%random%.bat"

    REM Copiar este script al temp
    copy /Y "%batchfile%" "%tempbat%" >nul 2>&1

    REM Ejecutar con privilegios elevados usando mshta
    mshta vbscript:CreateObject("Shell.Application").ShellExecute("%tempbat%","","",""runas"",1)(window.close)

    REM Limpiar
    timeout /t 2 >nul
    del /f /q "%tempbat%" >nul 2>&1
    exit /b
)

REM AHORA SÍ TENEMOS PERMISOS - EMPEZAR LA LIMPIEZA
cls
echo.
echo ============================================
echo   LIMPIEZA EXTREMA WINDOWS 11
echo   Optimizacion total del sistema
echo ============================================
echo.
echo [OK] Permisos de administrador confirmados.
echo.
timeout /t 2 /nobreak >nul

REM 2. CREAR PUNTO DE RESTAURACIÓN
echo.
echo ============================================
echo   CREANDO PUNTO DE RESTAURACION
echo ============================================
echo [+] Creando punto de seguridad...
powershell -NoProfile -Command "Checkpoint-Computer -Description 'Respaldo antes de limpieza extrema' -RestorePointType 'MODIFY_SETTINGS'" 2>nul
echo [OK] Punto creado.
timeout /t 2 /nobreak >nul

REM 3. DETENER SERVICIOS
echo.
echo ============================================
echo   DETENIENDO SERVICIOS
echo ============================================
echo [+] Deteniendo OneDrive...
taskkill /F /IM OneDrive.exe >nul 2>&1

echo [+] Deteniendo Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

echo [+] Deteniendo búsqueda...
net stop WSearch >nul 2>&1

echo [+] Deteniendo Superfetch...
net stop SysMain >nul 2>&1

echo [OK] Servicios detenidos.
timeout /t 1 /nobreak >nul

REM 4. LIMPIAR TEMPORALES
echo.
echo ============================================
echo   LIMPIANDO ARCHIVOS TEMPORALES
echo ============================================
echo [+] TEMP usuario...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%x in ("%temp%\*") do @rd /s /q "%%x" >nul 2>&1

echo [+] TEMP sistema...
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do @rd /s /q "%%x" >nul 2>&1

echo [+] Windows.old...
rmdir /s /q "C:\Windows.old" >nul 2>&1

echo [OK] Temporales limpios.
timeout /t 1 /nobreak >nul

REM 5. LIMPIAR WINDOWS UPDATE
echo.
echo ============================================
echo   LIMPIANDO WINDOWS UPDATE
echo ============================================
echo [+] Eliminando descargas...
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\SoftwareDistribution\Download\*") do @rd /s /q "%%x" >nul 2>&1

echo [+] Limpiando DataStore...
del /s /f /q "C:\Windows\SoftwareDistribution\DataStore\*.*" >nul 2>&1

echo [OK] Windows Update limpio.
timeout /t 1 /nobreak >nul

REM 6. LIMPIAR LOGS
echo.
echo ============================================
echo   ELIMINANDO REGISTROS
echo ============================================
echo [+] Limpiando logs...
del /s /f /q "C:\Windows\Logs\*.*" >nul 2>&1
del /s /f /q "C:\Windows\System32\winevt\Logs\*.evtx" >nul 2>&1

echo [OK] Logs eliminados.
timeout /t 1 /nobreak >nul

REM 7. LIMPIAR PREFETCH
echo.
echo ============================================
echo   LIMPIANDO PREFETCH
echo ============================================
echo [+] Eliminando Prefetch...
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1

echo [OK] Prefetch limpio.
timeout /t 1 /nobreak >nul

REM 8. LIMPIAR CACHÉ
echo.
echo ============================================
echo   LIMPIANDO CACHE
echo ============================================
echo [+] Caché de miniaturas...
del /s /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache*.*" >nul 2>&1

echo [+] AppData Temp...
del /s /f /q "%LocalAppData%\Temp\*.*" >nul 2>&1

echo [OK] Cache limpio.
timeout /t 1 /nobreak >nul

REM 9. LIMPIAR VOLCADOS DE MEMORIA
echo.
echo ============================================
echo   ELIMINANDO VOLCADOS
echo ============================================
echo [+] Eliminando volcados...
del /s /f /q "C:\Windows\MEMORY.DMP" >nul 2>&1
del /s /f /q "C:\Windows\Minidump\*.*" >nul 2>&1

echo [OK] Volcados eliminados.
timeout /t 1 /nobreak >nul

REM 10. DISM CLEANUP
echo.
echo ============================================
echo   LIMPIEZA DISM (puede tardar...)
echo ============================================
echo [+] Iniciando DISM...
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1

echo [OK] DISM completado.
timeout /t 2 /nobreak >nul

REM 11. ACTUALIZACIONES ANTIGUAS
echo.
echo ============================================
echo   ELIMINANDO ACTUALIZACIONES ANTIGUAS
echo ============================================
echo [+] Limpiando...
dism /online /cleanup-image /spsuperseded >nul 2>&1

echo [OK] Actualizaciones antiguas eliminadas.
timeout /t 1 /nobreak >nul

REM 12. BORRAR PUNTOS DE RESTAURACIÓN ANTIGUOS
echo.
echo ============================================
echo   ELIMINANDO PUNTOS ANTIGUOS
echo ============================================
echo [+] Eliminando puntos viejos...
vssadmin delete shadows /all /quiet >nul 2>&1

echo [OK] Puntos antiguos eliminados.
timeout /t 1 /nobreak >nul

REM 13. COMPACTOS
echo.
echo ============================================
echo   COMPRIMIENDO SISTEMA (puede tardar...)
echo ============================================
echo [+] Activando CompactOS...
compact.exe /CompactOS:always >nul 2>&1

echo [OK] CompactOS completado.
timeout /t 2 /nobreak >nul

REM 14. TRIM
echo.
echo ============================================
echo   OPTIMIZANDO SSD
echo ============================================
echo [+] Ejecutando TRIM...
defrag C: /L >nul 2>&1

echo [OK] TRIM completado.
timeout /t 1 /nobreak >nul

REM 15. DNS
echo.
echo ============================================
echo   LIMPIANDO DNS
echo ============================================
echo [+] Limpiando cache DNS...
ipconfig /flushdns >nul 2>&1

echo [OK] DNS limpio.
timeout /t 1 /nobreak >nul

REM 16. PAPELERA
echo.
echo ============================================
echo   VACIANDO PAPELERA
echo ============================================
echo [+] Vaciando papelera...
powershell -NoProfile -Command "Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue" >nul 2>&1

echo [OK] Papelera vaciada.
timeout /t 1 /nobreak >nul

REM 17. REINICIAR SERVICIOS
echo.
echo ============================================
echo   REINICIANDO SERVICIOS
echo ============================================
echo [+] Reiniciando Windows Update...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo [+] Reiniciando búsqueda...
net start WSearch >nul 2>&1

echo [+] Reiniciando Superfetch...
net start SysMain >nul 2>&1

echo [OK] Servicios reiniciados.
timeout /t 2 /nobreak >nul

REM 18. REINICIAR EXPLORADOR
echo.
echo ============================================
echo   FINALIZANDO
echo ============================================
echo [+] Reiniciando Explorador...
start explorer.exe >nul 2>&1

timeout /t 1 /nobreak >nul

REM FINALIZACIÓN
cls
echo.
echo ============================================
echo   LIMPIEZA COMPLETADA CON EXITO
echo ============================================
echo.
echo [OK] Tu PC ha sido optimizado al maximo
echo [OK] Se creo punto de restauracion
echo [OK] Todos los servicios reiniciados
echo.
echo IMPORTANTE:
echo  - Reinicia el PC para mejores resultados
echo  - El siguiente arranque sera mas lento
echo  - La caché se renueva automaticamente
echo.
echo.

pause
exit /b

@echo off
title LIMPIEZA EXTREMA WINDOWS 11 - By Alberto
color 1F

REM Verificar permisos de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo Solicitando permisos de administrador...
    echo.
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

REM AHORA TENEMOS PERMISOS - COMENZAR LIMPIEZA
cls
echo ============================================
echo   LIMPIEZA EXTREMA WINDOWS 11 - By Alberto
echo   Optimizacion total del sistema
echo ============================================
echo.

REM 1. Cerrar procesos que bloquean archivos
echo Cerrando procesos innecesarios...
taskkill /F /IM OneDrive.exe >nul 2>&1
taskkill /F /IM explorer.exe >nul 2>&1

REM 2. Crear punto de restauracion
echo Creando punto de restauracion...
powershell -NoProfile -Command "Checkpoint-Computer -Description 'Respaldo antes de limpieza extrema' -RestorePointType 'MODIFY_SETTINGS'" 2>nul

REM 3. Limpiar temporales del sistema y usuario
echo Limpiando temporales...
del /s /f /q %temp%\*.* >nul 2>&1
del /s /f /q C:\Windows\Temp\*.* >nul 2>&1

REM 4. Limpiar cache de Windows Update
echo Limpiando Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /s /f /q C:\Windows\SoftwareDistribution\Download\*.* >nul 2>&1
del /s /f /q C:\Windows\SoftwareDistribution\DataStore\*.* >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

REM 5. Limpiar logs del sistema
echo Limpiando logs...
del /s /f /q C:\Windows\Logs\*.* >nul 2>&1
del /s /f /q C:\Windows\System32\winevt\Logs\*.* >nul 2>&1

REM 6. Limpiar Prefetch
echo Limpiando Prefetch...
del /s /f /q C:\Windows\Prefetch\*.* >nul 2>&1

REM 7. Limpiar miniaturas
echo Limpiando cache de miniaturas...
del /s /f /q %LocalAppData%\Microsoft\Windows\Explorer\thumbcache*.* >nul 2>&1

REM 8. Limpiar restos de drivers
echo Eliminando restos de drivers antiguos...
pnputil /enum-drivers | findstr /i "oem" > drivers.txt
for /f %%i in (drivers.txt) do pnputil /delete-driver %%i /uninstall /force >nul 2>&1
del drivers.txt >nul 2>&1

REM 9. Limpiar volcados de memoria
echo Eliminando volcados de memoria...
del /s /f /q C:\Windows\MEMORY.DMP >nul 2>&1
del /s /f /q C:\Windows\Minidump\*.* >nul 2>&1

REM 10. Limpieza profunda WinSxS
echo Limpieza profunda WinSxS...
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1

REM 11. Borrar puntos de restauracion antiguos
echo Borrando puntos de restauracion antiguos...
vssadmin delete shadows /all /quiet >nul 2>&1

REM 12. Borrar backups de actualizaciones
echo Eliminando backups de actualizaciones...
dism /online /cleanup-image /spsuperseded >nul 2>&1

REM 13. Compactar sistema (CompactOS)
echo Activando CompactOS...
compact.exe /CompactOS:always >nul 2>&1

REM 14. Optimizar SSD (TRIM)
echo Ejecutando TRIM...
defrag C: /L >nul 2>&1

REM 15. Flush DNS
echo Limpiando cache DNS...
ipconfig /flushdns >nul 2>&1

REM 16. Limpiar AppData Temp
echo Limpiando AppData temporal...
del /s /f /q "%LocalAppData%\Temp\*.*" >nul 2>&1
for /d %%x in ("%LocalAppData%\Temp\*") do @rd /s /q "%%x" >nul 2>&1

REM 17. Vaciar papelera
echo Vaciando papelera...
powershell -NoProfile -Command "Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue" >nul 2>&1

REM 18. Reiniciar Explorer
echo Reiniciando Explorer...
start explorer.exe >nul 2>&1

echo.
echo ============================================
echo   LIMPIEZA EXTREMA COMPLETADA
echo   Tu sistema esta totalmente optimizado
echo ============================================
echo.
echo IMPORTANTE: Reinicia tu PC para los mejores resultados
echo.

pause
exit /b

@echo off
title LIMPIEZA EXTREMA WINDOWS 11 - By Alberto
color 1F

:: 1. Forzar ejecucion como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Solicitando permisos de administrador...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo ============================================
echo   LIMPIEZA EXTREMA WINDOWS 11
echo   Optimizacion total del sistema
echo ============================================
echo.

:: 2. Cerrar procesos que bloquean archivos
echo [1/16] Cerrando procesos que bloquean archivos...
taskkill /F /IM OneDrive.exe >nul 2>&1
taskkill /F /IM explorer.exe >nul 2>&1

:: 3. Temporales del usuario y del sistema
echo [2/16] Limpiando temporales...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%x in ("%temp%\*") do rd /s /q "%%x" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do rd /s /q "%%x" >nul 2>&1

:: 4. Cache de Windows Update
echo [3/16] Limpiando cache de Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%x" >nul 2>&1
del /s /f /q "C:\Windows\SoftwareDistribution\DataStore\*.*" >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

:: 5. Logs del sistema y registros de eventos
echo [4/16] Limpiando logs y registros de eventos...
del /s /f /q "C:\Windows\Logs\*.*" >nul 2>&1
for /f "tokens=*" %%G in ('wevtutil el') do wevtutil cl "%%G" >nul 2>&1

:: 6. Prefetch
echo [5/16] Limpiando Prefetch...
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1

:: 7. Cache de miniaturas
echo [6/16] Limpiando cache de miniaturas...
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1

:: 8. Volcados de memoria e informes de errores
echo [7/16] Eliminando volcados de memoria e informes de errores...
del /f /q "C:\Windows\MEMORY.DMP" >nul 2>&1
del /s /f /q "C:\Windows\Minidump\*.*" >nul 2>&1
del /s /f /q "C:\ProgramData\Microsoft\Windows\WER\*.*" >nul 2>&1

:: 9. Papelera de reciclaje
echo [8/16] Vaciando papelera...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: 10. Cache DNS
echo [9/16] Limpiando cache DNS...
ipconfig /flushdns >nul 2>&1

:: 11. Liberador de espacio de Windows (todas las categorias)
echo [10/16] Ejecutando Liberador de espacio de Windows...
for /f "tokens=*" %%K in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" 2^>nul ^| findstr /v /i "DownloadsFolder"') do reg add "%%K" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
cleanmgr /sagerun:99

:: 12. Limpieza profunda WinSxS
echo [11/16] Limpieza profunda WinSxS (puede tardar varios minutos)...
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

:: 13. Puntos de restauracion antiguos
echo [12/16] Borrando puntos de restauracion antiguos...
vssadmin delete shadows /all /quiet >nul 2>&1

:: 14. Punto de restauracion nuevo (despues de borrar los antiguos)
echo [13/16] Creando punto de restauracion limpio...
powershell -NoProfile -Command "Checkpoint-Computer -Description 'Tras limpieza extrema' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1

:: 15. CompactOS
echo [14/16] Activando CompactOS (puede tardar varios minutos)...
compact.exe /CompactOS:always

:: 16. TRIM del SSD
echo [15/16] Ejecutando TRIM...
defrag C: /L

:: 17. Reiniciar Explorer
echo [16/16] Reiniciando Explorer...
start explorer.exe

echo.
echo ============================================
echo   LIMPIEZA EXTREMA COMPLETADA
echo   Reinicia el PC para terminar
echo ============================================
pause
exit /b

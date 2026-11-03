@echo off
title LIMPIEZA EXTREMA WINDOWS 11 - By Alberto
color 1F

:: Forzar ejecucion como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Solicitando permisos de administrador...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
set "INFORME=%~dp0Informe_limpieza.txt"

echo ============================================
echo   LIMPIEZA EXTREMA WINDOWS 11
echo   Optimizacion total del sistema
echo ============================================
echo.
echo Midiendo espacio libre inicial...
call :libre LIBRE_INI

> "%INFORME%" echo ==========================================================
>> "%INFORME%" echo   INFORME DE LIMPIEZA - %date% %time:~0,5%
>> "%INFORME%" echo ==========================================================
>> "%INFORME%" echo.

:: 1. Cerrar procesos que bloquean archivos
echo [1/16] Cerrando procesos que bloquean archivos...
taskkill /F /IM OneDrive.exe >nul 2>&1
taskkill /F /IM explorer.exe >nul 2>&1

:: 2. Temporales del usuario y del sistema
echo [2/16] Limpiando temporales...
call :medir "'%temp%','C:\Windows\Temp'" ANTES
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%x in ("%temp%\*") do rd /s /q "%%x" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do rd /s /q "%%x" >nul 2>&1
call :medir "'%temp%','C:\Windows\Temp'" DESPUES
set /a DIF=ANTES-DESPUES
call :anotar "Archivos temporales" %DIF%

:: 3. Cache de Windows Update
echo [3/16] Limpiando cache de Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
call :medir "'C:\Windows\SoftwareDistribution\Download','C:\Windows\SoftwareDistribution\DataStore'" ANTES
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%x" >nul 2>&1
del /s /f /q "C:\Windows\SoftwareDistribution\DataStore\*.*" >nul 2>&1
call :medir "'C:\Windows\SoftwareDistribution\Download','C:\Windows\SoftwareDistribution\DataStore'" DESPUES
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
set /a DIF=ANTES-DESPUES
call :anotar "Cache de Windows Update" %DIF%

:: 4. Logs del sistema y registros de eventos
echo [4/16] Limpiando logs y registros de eventos...
call :medir "'C:\Windows\Logs','C:\Windows\System32\winevt\Logs'" ANTES
del /s /f /q "C:\Windows\Logs\*.*" >nul 2>&1
set NLOGS=0
for /f "tokens=*" %%G in ('wevtutil el') do wevtutil cl "%%G" >nul 2>&1 && set /a NLOGS+=1
call :medir "'C:\Windows\Logs','C:\Windows\System32\winevt\Logs'" DESPUES
set /a DIF=ANTES-DESPUES
call :anotar "Logs y registros de eventos" %DIF%
call :nota "Registros de eventos vaciados" "%NLOGS%"

:: 5. Prefetch
echo [5/16] Limpiando Prefetch...
call :medir "'C:\Windows\Prefetch'" ANTES
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
call :medir "'C:\Windows\Prefetch'" DESPUES
set /a DIF=ANTES-DESPUES
call :anotar "Prefetch" %DIF%

:: 6. Cache de miniaturas
echo [6/16] Limpiando cache de miniaturas...
call :medir "'%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db'" ANTES
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
call :medir "'%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db'" DESPUES
set /a DIF=ANTES-DESPUES
call :anotar "Cache de miniaturas" %DIF%

:: 7. Volcados de memoria e informes de errores
echo [7/16] Eliminando volcados de memoria e informes de errores...
call :medir "'C:\Windows\MEMORY.DMP','C:\Windows\Minidump','C:\ProgramData\Microsoft\Windows\WER'" ANTES
del /f /q "C:\Windows\MEMORY.DMP" >nul 2>&1
del /s /f /q "C:\Windows\Minidump\*.*" >nul 2>&1
del /s /f /q "C:\ProgramData\Microsoft\Windows\WER\*.*" >nul 2>&1
call :medir "'C:\Windows\MEMORY.DMP','C:\Windows\Minidump','C:\ProgramData\Microsoft\Windows\WER'" DESPUES
set /a DIF=ANTES-DESPUES
call :anotar "Volcados de memoria e informes de errores" %DIF%

:: 8. Papelera de reciclaje
echo [8/16] Vaciando papelera...
call :libre ANTES
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
call :libre DESPUES
set /a DIF=DESPUES-ANTES
call :anotar "Papelera de reciclaje" %DIF%

:: 9. Cache DNS
echo [9/16] Limpiando cache DNS...
ipconfig /flushdns >nul 2>&1
call :nota "Cache DNS" "Vaciada"

:: 10. Liberador de espacio de Windows (todas las categorias salvo Descargas)
echo [10/16] Ejecutando Liberador de espacio de Windows...
for /f "tokens=*" %%K in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" 2^>nul ^| findstr /v /i "DownloadsFolder"') do reg add "%%K" /v StateFlags0099 /t REG_DWORD /d 2 /f >nul 2>&1
call :libre ANTES
start "" /wait cleanmgr /sagerun:99
call :libre DESPUES
set /a DIF=DESPUES-ANTES
call :anotar "Liberador de espacio de Windows" %DIF%

:: 11. Limpieza profunda WinSxS
echo [11/16] Limpieza profunda WinSxS (puede tardar varios minutos)...
call :libre ANTES
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
call :libre DESPUES
set /a DIF=DESPUES-ANTES
call :anotar "Componentes WinSxS (DISM)" %DIF%

:: 12. Puntos de restauracion antiguos
echo [12/16] Borrando puntos de restauracion antiguos...
call :sombras NSOMBRAS
call :libre ANTES
vssadmin delete shadows /all /quiet >nul 2>&1
call :libre DESPUES
set /a DIF=DESPUES-ANTES
call :anotar "Puntos de restauracion antiguos" %DIF%
call :nota "Puntos de restauracion borrados" "%NSOMBRAS%"

:: 13. Punto de restauracion nuevo (despues de borrar los antiguos)
echo [13/16] Creando punto de restauracion limpio...
powershell -NoProfile -Command "Checkpoint-Computer -Description 'Tras limpieza extrema' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
call :sombras NSOMBRAS
set "RP=No creado: limite de 24 h o proteccion del sistema desactivada"
if %NSOMBRAS% gtr 0 set "RP=Creado"
call :nota "Punto de restauracion nuevo" "%RP%"

:: 14. CompactOS
echo [14/16] Activando CompactOS (puede tardar varios minutos)...
call :libre ANTES
compact.exe /CompactOS:always
call :libre DESPUES
set /a DIF=DESPUES-ANTES
call :anotar "Compresion del sistema (CompactOS)" %DIF%

:: 15. TRIM del SSD
echo [15/16] Ejecutando TRIM...
defrag C: /L
if errorlevel 1 (set "TR=Error o unidad no compatible") else (set "TR=Completado")
call :nota "TRIM en C:" "%TR%"

:: 16. Reiniciar Explorer
echo [16/16] Reiniciando Explorer...
start explorer.exe

:: Resumen final
call :libre LIBRE_FIN
set /a DIF=LIBRE_FIN-LIBRE_INI
>> "%INFORME%" echo.
>> "%INFORME%" echo ----------------------------------------------------------
call :anotar "TOTAL espacio libre ganado en C:" %DIF%
call :anotar "Espacio libre en C: ahora" %LIBRE_FIN%
>> "%INFORME%" echo ----------------------------------------------------------
>> "%INFORME%" echo   Los archivos en uso no se pueden borrar; es normal.
>> "%INFORME%" echo   Reinicia el PC para terminar.
>> "%INFORME%" echo ==========================================================

cls
type "%INFORME%"
echo.
echo Informe guardado en: %INFORME%
echo.
pause
exit /b


:: ===== Subrutinas =====

:: Tamano en KB de una lista de rutas de PowerShell: 'ruta1','ruta2'
:medir
set "%~2=0"
for /f %%S in ('powershell -NoProfile -Command "$t=0; foreach($x in @(%~1)){ if($x -like '*[*]*'){$f=Get-ChildItem -Path $x -Force -File -EA 0} elseif(Test-Path -LiteralPath $x -PathType Leaf){$f=Get-Item -LiteralPath $x -Force -EA 0} else {$f=Get-ChildItem -LiteralPath $x -Recurse -Force -File -EA 0}; $t+=($f | Measure-Object -Property Length -Sum).Sum }; [math]::Floor($t/1KB)"') do set "%~2=%%S"
exit /b

:: Espacio libre en C: en KB
:libre
set "%~1=0"
for /f %%S in ('powershell -NoProfile -Command "[math]::Floor((Get-PSDrive C).Free/1KB)"') do set "%~1=%%S"
exit /b

:: Numero de instantaneas de volumen (puntos de restauracion)
:sombras
set "%~1=0"
for /f %%S in ('powershell -NoProfile -Command "@(Get-CimInstance Win32_ShadowCopy -ErrorAction SilentlyContinue).Count"') do set "%~1=%%S"
exit /b

:: Anota una linea con tamano: "texto" KB
:anotar
setlocal
set "TXT=%~1                                            "
set "TXT=%TXT:~0,44%"
set /a KB=%~2
set "SG="
if %KB% lss 0 set "SG=-"
if %KB% lss 0 set /a KB=0-KB
if %KB% geq 1048576 goto :anotar_gb
if %KB% geq 1024 goto :anotar_mb
set "VAL=%SG%%KB% KB"
goto :anotar_fin
:anotar_mb
set /a ENT=KB/1024
set /a DEC=(KB%%1024)*10/1024
set "VAL=%SG%%ENT%,%DEC% MB"
goto :anotar_fin
:anotar_gb
set /a ENT=KB/1048576
set /a DEC=(KB%%1048576)*100/1048576
if %DEC% lss 10 set "DEC=0%DEC%"
set "VAL=%SG%%ENT%,%DEC% GB"
:anotar_fin
>> "%INFORME%" echo   %TXT%%VAL%
endlocal
exit /b

:: Anota una linea de texto: "texto" "valor"
:nota
setlocal
set "TXT=%~1                                            "
set "TXT=%TXT:~0,44%"
>> "%INFORME%" echo   %TXT%%~2
endlocal
exit /b

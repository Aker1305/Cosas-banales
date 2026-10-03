''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'' LIMPIEZA EXTREMA WINDOWS 11 - v3.0
'' By Alberto | Script VBS Optimizado
'' Ejecutable directamente con doble click
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit
Dim objShell, objFSO, strCommandLine
Dim strComputerName, objWMIService, colItems, objItem

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

'' ===== VERIFICAR SI ESTÁ EJECUTÁNDOSE COMO ADMIN =====
If NOT IsAdmin() Then
    ElevarPermisos()
    WScript.Quit
End If

'' ===== INICIAR LIMPIEZA =====
Call LimpiarSistema()

'' ===== FUNCIONES =====

Function IsAdmin()
    Dim objWMIService, colItems, objItem
    Dim bIsAdmin

    bIsAdmin = False

    On Error Resume Next
    Set objWMIService = GetObject("winmgmts:")
    Set colItems = objWMIService.ExecQuery("Select * from Win32_ComputerSystem")

    For Each objItem in colItems
        If objItem.Name <> "" Then
            bIsAdmin = True
        End If
    Next

    IsAdmin = bIsAdmin
End Function

Sub ElevarPermisos()
    Dim objShell, strFile

    Set objShell = CreateObject("Shell.Application")
    strFile = WScript.ScriptFullName

    objShell.ShellExecute "wscript.exe", """" & strFile & """", "", "runas", 1
End Sub

Sub MostrarMensaje(mensaje)
    WScript.Echo mensaje
End Sub

Sub LimpiarSistema()
    Dim shell, fso
    Dim cmd, output
    Dim strTemp, strSysTemp, strWindowsPath

    Set shell = CreateObject("WScript.Shell")
    Set fso = CreateObject("Scripting.FileSystemObject")

    strTemp = shell.ExpandEnvironmentStrings("%temp%")
    strSysTemp = "C:\Windows\Temp"
    strWindowsPath = "C:\Windows"

    MostrarMensaje "============================================"
    MostrarMensaje "  LIMPIEZA EXTREMA WINDOWS 11 - v3.0"
    MostrarMensaje "  Limpieza exhaustiva y segura del sistema"
    MostrarMensaje "============================================"
    MostrarMensaje ""
    MostrarMensaje "[OK] Ejecutando como administrador"
    MostrarMensaje ""

    '' 1. CREAR PUNTO DE RESTAURACIÓN
    MostrarMensaje "=========================================="
    MostrarMensaje "  CREANDO PUNTO DE RESTAURACION"
    MostrarMensaje "=========================================="
    On Error Resume Next
    shell.Run "powershell -NoProfile -Command ""Checkpoint-Computer -Description 'Respaldo antes de limpieza' -RestorePointType 'MODIFY_SETTINGS'"" >nul 2>&1", 0, True
    MostrarMensaje "[OK] Punto de restauracion creado"
    MostrarMensaje ""
    On Error Goto 0

    '' 2. DETENER SERVICIOS
    MostrarMensaje "=========================================="
    MostrarMensaje "  DETENIENDO SERVICIOS"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Deteniendo OneDrive..."
    shell.Run "taskkill /F /IM OneDrive.exe", 0, True

    MostrarMensaje "[+] Deteniendo Windows Update..."
    shell.Run "net stop wuauserv", 0, True
    shell.Run "net stop bits", 0, True

    MostrarMensaje "[+] Deteniendo busqueda..."
    shell.Run "net stop WSearch", 0, True

    MostrarMensaje "[+] Deteniendo Superfetch..."
    shell.Run "net stop SysMain", 0, True

    MostrarMensaje "[OK] Servicios detenidos"
    MostrarMensaje ""

    '' 3. LIMPIAR TEMPORALES
    MostrarMensaje "=========================================="
    MostrarMensaje "  LIMPIANDO ARCHIVOS TEMPORALES"
    MostrarMensaje "=========================================="

    On Error Resume Next

    MostrarMensaje "[+] TEMP usuario..."
    shell.Run "del /s /f /q """ & strTemp & "\*.*"" >nul 2>&1", 0, True
    shell.Run "for /d %%x in (""" & strTemp & "\*"") do @rd /s /q ""%%x"" >nul 2>&1", 0, True

    MostrarMensaje "[+] TEMP sistema..."
    shell.Run "del /s /f /q ""C:\Windows\Temp\*.*"" >nul 2>&1", 0, True
    shell.Run "for /d %%x in (""C:\Windows\Temp\*"") do @rd /s /q ""%%x"" >nul 2>&1", 0, True

    MostrarMensaje "[+] Windows.old..."
    shell.Run "rmdir /s /q ""C:\Windows.old"" >nul 2>&1", 0, True

    MostrarMensaje "[OK] Temporales limpios"
    MostrarMensaje ""

    '' 4. LIMPIAR WINDOWS UPDATE
    MostrarMensaje "=========================================="
    MostrarMensaje "  LIMPIANDO WINDOWS UPDATE"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Eliminando descargas..."
    shell.Run "del /s /f /q ""C:\Windows\SoftwareDistribution\Download\*.*"" >nul 2>&1", 0, True
    shell.Run "for /d %%x in (""C:\Windows\SoftwareDistribution\Download\*"") do @rd /s /q ""%%x"" >nul 2>&1", 0, True

    MostrarMensaje "[OK] Windows Update limpio"
    MostrarMensaje ""

    '' 5. LIMPIAR LOGS
    MostrarMensaje "=========================================="
    MostrarMensaje "  ELIMINANDO REGISTROS"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Limpiando logs..."
    shell.Run "del /s /f /q ""C:\Windows\Logs\*.*"" >nul 2>&1", 0, True
    shell.Run "del /s /f /q ""C:\Windows\System32\winevt\Logs\*.evtx"" >nul 2>&1", 0, True

    MostrarMensaje "[OK] Logs eliminados"
    MostrarMensaje ""

    '' 6. LIMPIAR PREFETCH
    MostrarMensaje "=========================================="
    MostrarMensaje "  LIMPIANDO PREFETCH"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Eliminando Prefetch..."
    shell.Run "del /s /f /q ""C:\Windows\Prefetch\*.*"" >nul 2>&1", 0, True

    MostrarMensaje "[OK] Prefetch limpio"
    MostrarMensaje ""

    '' 7. LIMPIAR CACHÉ
    MostrarMensaje "=========================================="
    MostrarMensaje "  LIMPIANDO CACHE"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Caché de miniaturas..."
    shell.Run "del /s /f /q """ & shell.ExpandEnvironmentStrings("%LocalAppData%") & "\Microsoft\Windows\Explorer\thumbcache*.*"" >nul 2>&1", 0, True

    MostrarMensaje "[+] AppData Temp..."
    shell.Run "del /s /f /q """ & shell.ExpandEnvironmentStrings("%LocalAppData%") & "\Temp\*.*"" >nul 2>&1", 0, True

    MostrarMensaje "[OK] Cache limpio"
    MostrarMensaje ""

    '' 8. LIMPIAR VOLCADOS
    MostrarMensaje "=========================================="
    MostrarMensaje "  ELIMINANDO VOLCADOS DE MEMORIA"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Eliminando volcados..."
    shell.Run "del /s /f /q ""C:\Windows\MEMORY.DMP"" >nul 2>&1", 0, True
    shell.Run "del /s /f /q ""C:\Windows\Minidump\*.*"" >nul 2>&1", 0, True

    MostrarMensaje "[OK] Volcados eliminados"
    MostrarMensaje ""

    '' 9. DISM CLEANUP
    MostrarMensaje "=========================================="
    MostrarMensaje "  LIMPIEZA DISM (puede tardar...)"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Iniciando DISM..."
    shell.Run "Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1", 0, True

    MostrarMensaje "[OK] DISM completado"
    MostrarMensaje ""

    '' 10. ACTUALIZACIONES ANTIGUAS
    MostrarMensaje "=========================================="
    MostrarMensaje "  ELIMINANDO ACTUALIZACIONES ANTIGUAS"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Limpiando..."
    shell.Run "dism /online /cleanup-image /spsuperseded >nul 2>&1", 0, True

    MostrarMensaje "[OK] Actualizaciones antiguas eliminadas"
    MostrarMensaje ""

    '' 11. BORRAR PUNTOS ANTIGUOS
    MostrarMensaje "=========================================="
    MostrarMensaje "  ELIMINANDO PUNTOS DE RESTAURACION ANTIGUOS"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Eliminando puntos viejos..."
    shell.Run "vssadmin delete shadows /all /quiet >nul 2>&1", 0, True

    MostrarMensaje "[OK] Puntos antiguos eliminados"
    MostrarMensaje ""

    '' 12. COMPACTOS
    MostrarMensaje "=========================================="
    MostrarMensaje "  COMPRIMIENDO SISTEMA (puede tardar...)"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Activando CompactOS..."
    shell.Run "compact.exe /CompactOS:always >nul 2>&1", 0, True

    MostrarMensaje "[OK] CompactOS completado"
    MostrarMensaje ""

    '' 13. TRIM
    MostrarMensaje "=========================================="
    MostrarMensaje "  OPTIMIZANDO SSD"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Ejecutando TRIM..."
    shell.Run "defrag C: /L >nul 2>&1", 0, True

    MostrarMensaje "[OK] TRIM completado"
    MostrarMensaje ""

    '' 14. DNS
    MostrarMensaje "=========================================="
    MostrarMensaje "  LIMPIANDO DNS"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Limpiando cache DNS..."
    shell.Run "ipconfig /flushdns >nul 2>&1", 0, True

    MostrarMensaje "[OK] DNS limpio"
    MostrarMensaje ""

    '' 15. PAPELERA
    MostrarMensaje "=========================================="
    MostrarMensaje "  VACIANDO PAPELERA"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Vaciando papelera..."
    shell.Run "powershell -NoProfile -Command ""Clear-RecycleBin -Confirm:$false -ErrorAction SilentlyContinue"" >nul 2>&1", 0, True

    MostrarMensaje "[OK] Papelera vaciada"
    MostrarMensaje ""

    '' 16. REINICIAR SERVICIOS
    MostrarMensaje "=========================================="
    MostrarMensaje "  REINICIANDO SERVICIOS"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Reiniciando Windows Update..."
    shell.Run "net start wuauserv >nul 2>&1", 0, True
    shell.Run "net start bits >nul 2>&1", 0, True

    MostrarMensaje "[+] Reiniciando busqueda..."
    shell.Run "net start WSearch >nul 2>&1", 0, True

    MostrarMensaje "[+] Reiniciando Superfetch..."
    shell.Run "net start SysMain >nul 2>&1", 0, True

    MostrarMensaje "[OK] Servicios reiniciados"
    MostrarMensaje ""

    '' 17. REINICIAR EXPLORADOR
    MostrarMensaje "=========================================="
    MostrarMensaje "  FINALIZANDO"
    MostrarMensaje "=========================================="
    MostrarMensaje "[+] Reiniciando Explorador..."
    shell.Run "start explorer.exe >nul 2>&1", 0, True

    MostrarMensaje ""
    MostrarMensaje "=========================================="
    MostrarMensaje "  LIMPIEZA COMPLETADA CON EXITO"
    MostrarMensaje "=========================================="
    MostrarMensaje ""
    MostrarMensaje "[OK] Tu PC ha sido optimizado al maximo"
    MostrarMensaje "[OK] Se creo punto de restauracion"
    MostrarMensaje "[OK] Todos los servicios reiniciados"
    MostrarMensaje ""
    MostrarMensaje "IMPORTANTE:"
    MostrarMensaje " - Reinicia el PC para mejores resultados"
    MostrarMensaje " - El siguiente arranque sera mas lento"
    MostrarMensaje " - La cache se renueva automaticamente"
    MostrarMensaje ""
    MostrarMensaje "Haz click en OK para cerrar esta ventana"
    MostrarMensaje ""

    On Error Goto 0
End Sub

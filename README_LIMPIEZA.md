# Limpieza extrema Windows 11

Uso: doble clic en `LIMPIEZA_EXTREMA_WINDOWS11.bat` y aceptar el aviso de UAC. Al terminar, reiniciar el PC.

El archivo debe conservar finales de línea CRLF. Descárgalo con el botón "Download raw file" de GitHub; no copies y pegues el texto en otro editor.

## Qué hace

1. Pide permisos de administrador si no los tiene.
2. Cierra OneDrive y Explorer.
3. Borra temporales de usuario y del sistema.
4. Borra la caché de Windows Update.
5. Borra logs de `C:\Windows\Logs` y vacía todos los registros de eventos (`wevtutil`).
6. Borra Prefetch.
7. Borra la caché de miniaturas.
8. Borra volcados de memoria e informes de errores (WER).
9. Vacía la papelera.
10. Limpia la caché DNS.
11. Ejecuta el Liberador de espacio de Windows con todas las categorías, salvo la carpeta Descargas.
12. DISM `StartComponentCleanup /ResetBase`. Después de esto ya no se pueden desinstalar las actualizaciones instaladas.
13. Borra todos los puntos de restauración.
14. Crea un punto de restauración nuevo.
15. Activa CompactOS.
16. Ejecuta TRIM en C:.
17. Reinicia Explorer.

## Notas

- Windows solo permite crear un punto de restauración cada 24 horas por defecto, así que el del paso 14 puede no crearse.
- Los archivos que estén en uso no se borran. Es normal.

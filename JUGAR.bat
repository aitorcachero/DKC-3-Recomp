@echo off
setlocal
cd /d "%~dp0"
if exist "build\Release\ZeldaALTTPRecomp.exe" (
    start "" "build\Release\ZeldaALTTPRecomp.exe" --launcher
) else if exist "ZeldaALTTPRecomp.exe" (
    start "" "ZeldaALTTPRecomp.exe" --launcher
) else (
    echo No se encontro ZeldaALTTPRecomp.exe. Ejecuta primero COMPILAR.bat.
    pause
)
exit /b 0

@echo off
setlocal
cd /d "%~dp0"
if exist "Dkc3SNESRecomp.exe" (
    start "" "Dkc3SNESRecomp.exe" --launcher
) else if exist "build\Release\Dkc3SNESRecomp.exe" (
    start "" "build\Release\Dkc3SNESRecomp.exe" --launcher
) else (
    echo No se encontro Dkc3SNESRecomp.exe.
    pause
)
exit /b 0

@echo off
setlocal
cd /d "%~dp0"
echo Configurando CMake para The Legend of Zelda - A Link to the Past...
cmake -B build -A x64
if errorlevel 1 goto error
echo Compilando The Legend of Zelda - A Link to the Past (Release)...
cmake --build build --config Release --target ZeldaALTTPRecomp
if errorlevel 1 goto error
echo.
echo Compilacion exitosa. Ejecutable generado en build\Release\ZeldaALTTPRecomp.exe
copy /y "build\Release\ZeldaALTTPRecomp.exe" "ZeldaALTTPRecomp.exe"
pause
exit /b 0
:error
echo Error durante la compilacion.
pause
exit /b 1

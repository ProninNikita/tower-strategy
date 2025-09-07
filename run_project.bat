@echo off
echo Starting Tower Strategy Game...
echo.

REM Try to find Godot in common installation paths
set GODOT_PATHS=^
"C:\Program Files\Godot\Godot_v4.4-stable_win64.exe" ^
"C:\Program Files (x86)\Godot\Godot_v4.4-stable_win64.exe" ^
"C:\Godot\Godot_v4.4-stable_win64.exe" ^
"C:\Users\%USERNAME%\Downloads\Godot_v4.4-stable_win64.exe" ^
"C:\Users\%USERNAME%\Desktop\Godot_v4.4-stable_win64.exe"

REM Try different Godot versions
set GODOT_VERSIONS=4.4 4.3 4.2 4.1 4.0

echo Searching for Godot executable...

REM Check if Godot is in PATH
godot --version >nul 2>&1
if %errorlevel% == 0 (
    echo Found Godot in PATH
    godot --path "%~dp0" --main-pack scenes/Main.tscn
    goto :end
)

REM Search in common paths
for %%p in (%GODOT_PATHS%) do (
    if exist "%%p" (
        echo Found Godot at: %%p
        "%%p" --path "%~dp0" --main-pack scenes/Main.tscn
        goto :end
    )
)

REM Search for any Godot executable in current directory and subdirectories
for /r "%~dp0" %%f in (Godot*.exe) do (
    echo Found Godot at: %%f
    "%%f" --path "%~dp0" --main-pack scenes/Main.tscn
    goto :end
)

echo.
echo ERROR: Godot executable not found!
echo.
echo Please install Godot 4.x from: https://godotengine.org/download/
echo Or place Godot executable in one of these locations:
echo - Current project directory
echo - C:\Program Files\Godot\
echo - C:\Program Files (x86)\Godot\
echo - C:\Godot\
echo.
echo You can also add Godot to your system PATH.
echo.
pause

:end
@echo off
REM ==============================================================================
REM build.bat - Hilfs-Script zum Erstellen von Präsentationen (Windows)
REM ==============================================================================
REM Verwendung: build.bat <format> <input-datei>
REM Beispiel:   build.bat revealjs examples\example-presentation.md

setlocal enabledelayedexpansion

REM ==============================================================================
REM Funktionen
REM ==============================================================================

:show_usage
echo Verwendung: %~nx0 ^<format^> ^<input-datei^> [optionen]
echo.
echo Formate:
echo   revealjs    - Erstellt eine Reveal.js HTML-Präsentation
echo   beamer      - Erstellt eine Beamer PDF-Präsentation
echo   pptx        - Erstellt eine PowerPoint-Präsentation
echo.
echo Beispiele:
echo   %~nx0 revealjs examples\example-presentation.md
echo   %~nx0 beamer examples\example-presentation.md
echo   %~nx0 pptx examples\example-presentation.md
echo.
echo Optionen:
echo   -o, --output    Ausgabedatei ^(Standard: output\presentation.^<format^>^)
echo   -h, --help      Diese Hilfe anzeigen
exit /b 0

REM ==============================================================================
REM Hauptprogramm
REM ==============================================================================

REM Parameter prüfen
if "%~1"=="" (
    call :show_usage
    exit /b 1
)

if "%~2"=="" (
    call :show_usage
    exit /b 1
)

set "FORMAT=%~1"
set "INPUT=%~2"
set "OUTPUT="

REM Optionen parsen
:parse_args
shift
shift
if "%~1"=="" goto :args_done
if /i "%~1"=="-o" (
    set "OUTPUT=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--output" (
    set "OUTPUT=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-h" (
    call :show_usage
    exit /b 0
)
if /i "%~1"=="--help" (
    call :show_usage
    exit /b 0
)
echo [ERROR] Unbekannte Option: %~1
call :show_usage
exit /b 1
:args_done

REM Format validieren
if not "!FORMAT!"=="revealjs" (
    if not "!FORMAT!"=="beamer" (
        if not "!FORMAT!"=="pptx" (
            echo [ERROR] Unbekanntes Format: !FORMAT!
            call :show_usage
            exit /b 1
        )
    )
)

REM Input-Datei prüfen
if not exist "!INPUT!" (
    echo [ERROR] Datei nicht gefunden: !INPUT!
    exit /b 1
)

REM Abhängigkeiten prüfen
echo [INFO] Überprüfe Abhängigkeiten...
pandoc --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Pandoc ist nicht installiert!
    echo Installation: https://pandoc.org/installing.html
    exit /b 1
)

for /f "tokens=*" %%i in ('pandoc --version ^| findstr /C:"pandoc"') do (
    echo [OK] Gefunden: %%i
)

REM Zusätzliche Checks für Beamer
if "!FORMAT!"=="beamer" (
    xelatex --version >nul 2>&1
    if errorlevel 1 (
        pdflatex --version >nul 2>&1
        if errorlevel 1 (
            echo [WARNING] Kein LaTeX-Engine gefunden ^(xelatex oder pdflatex^)
            echo [WARNING] Für Beamer-Präsentationen wird LaTeX benötigt!
        )
    )
)

REM Output-Verzeichnis erstellen
if not exist "output" mkdir output

REM Defaults-Datei prüfen
set "DEFAULTS_FILE=defaults\!FORMAT!.yaml"
if not exist "!DEFAULTS_FILE!" (
    echo [ERROR] Defaults-Datei nicht gefunden: !DEFAULTS_FILE!
    exit /b 1
)

REM Pandoc ausführen
echo [INFO] Erstelle Präsentation im Format: !FORMAT!
echo [INFO] Input: !INPUT!

if not "!OUTPUT!"=="" (
    echo [INFO] Output: !OUTPUT!
    pandoc -d "!DEFAULTS_FILE!" "!INPUT!" -o "!OUTPUT!"
    set "OUTPUT_FILE=!OUTPUT!"
) else (
    pandoc -d "!DEFAULTS_FILE!" "!INPUT!"
    if "!FORMAT!"=="revealjs" set "OUTPUT_FILE=output\presentation.html"
    if "!FORMAT!"=="beamer" set "OUTPUT_FILE=output\presentation.pdf"
    if "!FORMAT!"=="pptx" set "OUTPUT_FILE=output\presentation.pptx"
)

if exist "!OUTPUT_FILE!" (
    echo [OK] Präsentation erfolgreich erstellt: !OUTPUT_FILE!
    
    REM Dateigröße anzeigen
    for %%A in ("!OUTPUT_FILE!") do (
        set "FILE_SIZE=%%~zA"
        set /a "FILE_SIZE_KB=!FILE_SIZE! / 1024"
        echo [INFO] Dateigröße: !FILE_SIZE_KB! KB
    )
) else (
    echo [ERROR] Fehler beim Erstellen der Präsentation
    exit /b 1
)

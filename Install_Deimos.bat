@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo             Deimos Automated Setup Script
echo ====================================================
echo.

REM Step 1: Check Python
echo Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH!
    echo Please install Python first. Make sure to check "Add Python to PATH" during installation.
    pause
    exit /b
)
echo Python found.
echo.

REM Step 1.5: Check Git
echo Checking Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed or not in PATH!
    echo Please install Git first. Download from: https://git-scm.com/download/win
    pause
    exit /b
)
echo Git found.
echo.

REM Step 2: Install UV
echo Installing UV dependency manager...
python -m pip install uv
if errorlevel 1 (
    echo [ERROR] Failed to install uv via pip.
    pause
    exit /b
)
echo UV installed successfully.
echo.

REM Step 3: Check/Install VS Build Tools
echo Checking for compiler tools [link.exe]...
where /r "C:\Program Files (x86)\Microsoft Visual Studio" link.exe >nul 2>&1
if errorlevel 1 (
    echo Compiler tools not found. Starting automatic installation...
    echo.
    echo [ACTION REQUIRED] A Windows popup [User Account Control] will appear.
    echo Please click YES to allow the installer to run.
    echo.
    winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive --norestart" --accept-source-agreements --accept-package-agreements
    if errorlevel 1 (
        echo [ERROR] winget installation failed or was denied.
        pause
        exit /b
    )
    echo.
    echo Build Tools installation complete.
) else (
    echo Compiler tools found.
)
echo.

REM Step 4: Clone Deimos Repo
if not exist "Deimos" (
    echo Cloning Deimos repository...
    git clone -b main https://github.com/Ratul-23/Deimos.git
    if errorlevel 1 (
        echo [ERROR] Git clone failed. Is Git installed?
        pause
        exit /b
    )
) else (
    echo Deimos folder already exists, skipping clone.
)
echo.

REM Step 5: Compile/Sync dependencies
echo Navigating into Deimos folder and compiling...
cd Deimos
uv sync --reinstall-package wizlaunch
if errorlevel 1 (
    echo [ERROR] Dependency sync and compilation failed.
    pause
    exit /b
)
echo.

echo Installing patched wizwalker for Wizard101 compatibility...
uv pip install git+https://github.com/LaurenzLikeThat/wizwalker --force-reinstall
if errorlevel 1 (
    echo [ERROR] Failed to install patched wizwalker.
    pause
    exit /b
)
echo.

REM Step 6: Create Launcher
echo Creating silent launcher shortcut [Deimos.vbs]...
if exist Deimos.bat del Deimos.bat
if exist Deimos.exe del Deimos.exe
(
echo Set WshShell = CreateObject("WScript.Shell"^)
echo Set FSO = CreateObject("Scripting.FileSystemObject"^)
echo ScriptDir = FSO.GetParentFolderName(WScript.ScriptFullName^)
echo WshShell.Run """" ^& ScriptDir ^& "\.venv\Scripts\pythonw.exe"" """ ^& ScriptDir ^& "\Deimos.py""", 0, False
) > Deimos.vbs

echo Creating custom icon shortcut [Launch Deimos.lnk]...
(
echo Set Shell = CreateObject("WScript.Shell"^)
echo Set FSO = CreateObject("Scripting.FileSystemObject"^)
echo CurrentDir = FSO.GetAbsolutePathName("."^)
echo ShortcutPath = CurrentDir ^& "\Launch Deimos.lnk"
echo Set Shortcut = Shell.CreateShortcut(ShortcutPath^)
echo Shortcut.TargetPath = "wscript.exe"
echo Shortcut.Arguments = """" ^& CurrentDir ^& "\Deimos.vbs"""
echo Shortcut.WorkingDirectory = CurrentDir
echo Shortcut.IconLocation = CurrentDir ^& "\Deimos-logo.ico"
echo Shortcut.Save
) > make_shortcut.vbs
wscript.exe make_shortcut.vbs
del make_shortcut.vbs

echo.
echo ====================================================
echo SETUP COMPLETE!
echo You can now run the app by opening the Deimos folder
echo and double-clicking 'Launch Deimos'.
echo ====================================================
echo.
pause

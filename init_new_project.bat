@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========================================
::   AI Workflow - New Project Init
:: ========================================

:: Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Check for -y flag (auto confirm)
set "AUTO_CONFIRM=0"
set "ARG1=%~1"
set "ARG2=%~2"
set "ARG3=%~3"

if /i "%~1"=="-y" (
    set "AUTO_CONFIRM=1"
    set "PROJECT_NAME=%~2"
    set "TARGET_PATH=%~3"
) else if /i "%~2"=="-y" (
    set "AUTO_CONFIRM=1"
    set "PROJECT_NAME=%~1"
    set "TARGET_PATH=%~3"
) else if /i "%~3"=="-y" (
    set "AUTO_CONFIRM=1"
    set "PROJECT_NAME=%~1"
    set "TARGET_PATH=%~2"
) else (
    set "PROJECT_NAME=%~1"
    set "TARGET_PATH=%~2"
)

:: Check parameters - prompt if empty
if "!PROJECT_NAME!"=="" (
    echo.
    echo ========================================
    echo   AI Workflow - New Project Init
    echo ========================================
    echo.
    set /p PROJECT_NAME="Enter project name: "
    if "!PROJECT_NAME!"=="" (
        echo.
        echo [ERROR] Project name cannot be empty
        pause
        exit /b 1
    )
    echo.
    set /p TARGET_PATH="Enter target path (press Enter to use current dir): "
    if "!TARGET_PATH!"=="" set TARGET_PATH=.\!PROJECT_NAME!
) else (
    if "!TARGET_PATH!"=="" set TARGET_PATH=.\!PROJECT_NAME!
)

:: Convert to absolute path
pushd "!SCRIPT_DIR!" 2>nul
for %%I in ("!TARGET_PATH!") do set "TARGET_PATH=%%~fI"
popd

:: Safety check: prevent overwriting current directory
set "CURRENT_DIR=%SCRIPT_DIR%"
for %%I in ("!TARGET_PATH!") do set "TARGET_DIR=%%~fI"

:: Check if target is current directory
if /i "!TARGET_DIR!"=="!CURRENT_DIR!" (
    echo.
    echo ========================================
    echo   [ERROR] Target cannot be current dir!
    echo ========================================
    echo.
    echo Current: !CURRENT_DIR!
    echo Target: !TARGET_DIR!
    echo.
    echo Please use a different project name or path.
    echo.
    pause
    exit /b 1
)

:: Check if target is parent directory
for %%I in ("!CURRENT_DIR!") do set "PARENT_DIR=%%~dpI"
set "PARENT_DIR=!PARENT_DIR:~0,-1!"
if /i "!TARGET_DIR!"=="!PARENT_DIR!" (
    echo.
    echo ========================================
    echo   [ERROR] Target cannot be parent dir!
    echo ========================================
    echo.
    pause
    exit /b 1
)

:: Display project info
echo.
echo ========================================
echo   Initializing: !PROJECT_NAME!
echo ========================================
echo.
echo Source: !SCRIPT_DIR!
echo Target: !TARGET_DIR!
echo.

:: Confirm creation
if "!AUTO_CONFIRM!"=="1" (
    set "CONFIRM=Y"
) else (
    set /p CONFIRM="Confirm creation? (Y/N): "
)
if "!AUTO_CONFIRM!"=="1" echo [Auto-confirmed] Proceeding...
if /i not "!CONFIRM!"=="Y" (
    echo.
    echo [CANCELLED] User cancelled
    pause
    exit /b 0
)

:: Check if target exists
if exist "!TARGET_DIR!" (
    echo.
    echo [WARNING] Target exists: !TARGET_DIR!
    if "!AUTO_CONFIRM!"=="1" (
        set "OVERWRITE=Y"
    ) else (
        set /p OVERWRITE="Overwrite? (Y/N): "
    )
    if "!AUTO_CONFIRM!"=="1" echo [Auto-confirmed] Will overwrite...
    if /i not "!OVERWRITE!"=="Y" (
        echo.
        echo [CANCELLED] User cancelled
        pause
        exit /b 0
    )
    echo [2/8] Removing existing directory...
    rmdir /s /q "!TARGET_DIR!" 2>nul
)

:: Step 1: Create project directory
echo [1/8] Creating project directory...
mkdir "!TARGET_DIR!" 2>nul
if errorlevel 1 (
    echo [ERROR] Cannot create directory: !TARGET_DIR!
    pause
    exit /b 1
)

:: Step 2: Copy workflow template
echo [2/8] Copying workflow template...
xcopy "!SCRIPT_DIR!\workflow" "!TARGET_DIR!\workflow" /E /I /Q /Y >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy workflow folder
    pause
    exit /b 1
)

:: Step 3: Reset task status file
echo [3/8] Resetting tasks.json...
(
echo {
echo   "project_name": "!PROJECT_NAME!",
echo   "version": "1.0.0",
echo   "created_at": "%DATE%T%TIME%",
echo   "tasks": [],
echo   "dependency_graph": {},
echo   "statistics": {
echo     "total": 0,
echo     "blocked": 0,
echo     "ready": 0,
echo     "running": 0,
echo     "done": 0,
echo     "failed": 0
echo   }
echo }
) > "!TARGET_DIR!\workflow\tasks.json"

:: Step 4: Reset contract file
echo [4/8] Resetting contract.json...
(
echo {
echo   "contract_id": "CONTRACT-%DATE:~0,4%-001",
echo   "version": "1.0.0",
echo   "status": "DRAFT",
echo   "created_at": "%DATE%T%TIME%",
echo   "modules": {},
echo   "global_config": {},
echo   "change_history": []
echo }
) > "!TARGET_DIR!\workflow\contract.json"

:: Step 5: Reset dependency matrix
echo [5/8] Resetting dependency_matrix.json...
(
echo {
echo   "version": "1.0.0",
echo   "env_variables": {},
echo   "shared_modules": {},
echo   "data_dependencies": {},
echo   "hidden_dependencies": {
echo     "pending_verification": [],
echo     "verified": []
echo   }
echo }
) > "!TARGET_DIR!\workflow\dependency_matrix.json"

:: Step 6: Clear runtime directories
echo [6/8] Clearing runtime directories...
del /q "!TARGET_DIR!\workflow\tasks\*.md" 2>nul
del /q "!TARGET_DIR!\workflow\logs\*.md" 2>nul
del /q "!TARGET_DIR!\workflow\stubs\*.py" 2>nul
del /q "!TARGET_DIR!\workflow\sandbox\*.*" 2>nul

:: Step 7: Update project config
echo [7/8] Updating global_config.json...
(
echo {
echo   "project": {
echo     "name": "!PROJECT_NAME!",
echo     "version": "1.0.0",
echo     "created_at": "%DATE%T%TIME%"
echo   },
echo   "agent_config": {
echo     "main_agent": {
echo       "heartbeat_interval_seconds": 30,
echo       "max_concurrent_tasks": 3,
echo       "task_timeout_minutes": 60
echo     },
echo     "sub_agents": {
echo       "max_retries": 3,
echo       "retry_delay_seconds": 10
echo     }
echo   },
echo   "sandbox_config": {
echo     "enabled": true,
echo     "isolation_level": "column",
echo     "sandbox_column": "sandbox_id"
echo   },
echo   "thresholds": {
echo     "human_approval_score": 15,
echo     "max_task_failures": 3,
echo     "confidence_warning": 0.7
echo   }
echo }
) > "!TARGET_DIR!\workflow\global_config.json"

:: Create input directory and requirements template
if not exist "!TARGET_DIR!\workflow\input" mkdir "!TARGET_DIR!\workflow\input"
(
echo # Project Requirements
echo.
echo ## Project Name
echo !PROJECT_NAME!
echo.
echo ## Project Goals
echo [Describe the problem this project solves]
echo.
echo ## Core Features
echo 1. [Feature 1]
echo 2. [Feature 2]
echo 3. [Feature 3]
echo.
echo ## Constraints
echo - [Technical constraints]
echo - [Time constraints]
echo.
echo ## Expected Deliverables
echo - [Deliverable 1]
echo - [Deliverable 2]
) > "!TARGET_DIR!\workflow\input\requirements.md"

:: Step 8: Initialize Git repository
echo [8/8] Initializing Git repository...
cd /d "!TARGET_DIR!"
git init >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Git init failed - Git not installed?
) else (
    git checkout -b main >nul 2>&1
    echo    Git repository initialized
)

:: Done
echo.
echo ========================================
echo   Project initialized successfully!
echo ========================================
echo.
echo Project path: !TARGET_DIR!
echo.
echo Next steps:
echo    1. Edit requirements:
echo       !TARGET_DIR!\workflow\input\requirements.md
echo.
echo    2. Start workflow (requires core code implementation):
echo       cd /d "!TARGET_DIR!"
echo       python -m workflow.main_agent --project !PROJECT_NAME!
echo.

:: Return to original directory
cd /d "!SCRIPT_DIR!"

endlocal

:: Prevent window from closing
echo.
pause

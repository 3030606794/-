@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title GitHub 万能发布工具 (C# .NET 8 修复版)
color 0A

:: ========================================================
:: 0. 自动排除脚本自身
:: ========================================================
cd /d "%~dp0"
if not exist .gitignore type nul > .gitignore
findstr /C:"万能发布工具.bat" .gitignore >nul
if errorlevel 1 echo 万能发布工具.bat>> .gitignore

:: ========================================================
:: 1. 仓库选择菜单
:: ========================================================
:repo_menu
cls
echo ========================================================
echo               第一步：选择目标仓库
echo ========================================================
echo.
echo  [1] PasteBar (电脑版)
echo      地址: https://github.com/3030606794/-.git
echo.
echo  [2] KGPT (安卓版)
echo      地址: https://github.com/3030606794/KGPT.git
echo.
echo  [3] 毒蛇
echo      地址: https://github.com/3030606794/毒蛇.git
echo.
echo  [4] DDCToolbox-Build
echo      地址: https://github.com/3030606794/DDCToolbox-Build.git
echo.
echo  [5] 手动粘贴新仓库地址...
echo.
echo ========================================================
set /p repo_choice="请输入数字 (1-5): "

if "%repo_choice%"=="1" set "repo_url=https://github.com/3030606794/-.git" && goto mode_menu
if "%repo_choice%"=="2" set "repo_url=https://github.com/3030606794/KGPT.git" && goto mode_menu
if "%repo_choice%"=="3" set "repo_url=https://github.com/3030606794/毒蛇.git" && goto mode_menu
if "%repo_choice%"=="4" set "repo_url=https://github.com/3030606794/DDCToolbox-Build.git" && goto mode_menu
if "%repo_choice%"=="5" goto manual_repo

echo 输入错误，请重试。
goto repo_menu

:manual_repo
echo.
set /p repo_url="请粘贴仓库地址 (右键粘贴): "
if "%repo_url%"=="" goto manual_repo
goto mode_menu

:: ========================================================
:: 2. 项目类型 (已升级为 .NET 8 模式)
:: ========================================================
:mode_menu
cls
echo ========================================================
echo               第二步：选择项目类型
echo ========================================================
echo.
echo  [1] 电脑软件 (C# .NET 8 / WinUI 3)
echo      - 目标: .exe (修复依赖丢失报错)
echo.
echo  [2] 安卓软件 (Android)
echo      - 目标: .apk
echo.
echo ========================================================
set /p mode="请输入数字 (1 或 2): "

if "%mode%"=="1" goto pc_config
if "%mode%"=="2" goto android_config
goto mode_menu

:: --- 电脑版配置 (PC) - .NET 8 专用 ---
:pc_config
echo.
echo [1/3] 正在生成 Windows 配置 (.NET 8 模式)...
if not exist ".github\workflows" mkdir ".github\workflows"
del ".github\workflows\*.yml" 2>nul

(
echo name: Windows Build
echo on:
echo   push:
echo     branches: [ "main" ]
echo jobs:
echo   build:
echo     runs-on: windows-latest
echo     steps:
echo     - uses: actions/checkout@v4
echo     - name: Setup .NET 8
echo       uses: actions/setup-dotnet@v4
echo       with:
echo         dotnet-version: 8.0.x
echo     - name: Restore dependencies
echo       run: dotnet restore LittleBigMouse.sln
echo     - name: Build
echo       run: dotnet build LittleBigMouse.sln -c Release
echo     - name: Upload Artifact
echo       uses: actions/upload-artifact@v4
echo       with:
echo         name: LittleBigMouse-Build
echo         path: "**/bin/Release/**/*.exe"
) > ".github\workflows\windows_build.yml"

goto upload_start

:: --- 安卓版配置 (Android) ---
:android_config
echo.
echo [1/3] 正在生成 Android 配置...
if not exist ".github\workflows" mkdir ".github\workflows"
del ".github\workflows\*.yml" 2>nul

(
echo name: Android Build
echo on:
echo   push:
echo     branches: [ "main" ]
echo jobs:
echo   build-android:
echo     runs-on: ubuntu-latest
echo     steps:
echo     - uses: actions/checkout@v4
echo     - name: Set up JDK 17
echo       uses: actions/setup-java@v4
echo       with:
echo         java-version: '17'
echo         distribution: 'temurin'
echo     - name: Grant execute permission for gradlew
echo       run: chmod +x gradlew
echo     - name: Build with Gradle
echo       run: ./gradlew assembleDebug
echo     - name: Upload APK
echo       uses: actions/upload-artifact@v4
echo       with:
echo         name: Android-APK-Installer
echo         path: "**/*.apk"
) > ".github\workflows\android_build.yml"

goto upload_start

:: ========================================================
:: 3. 核心上传逻辑
:: ========================================================
:upload_start
echo.
echo [2/3] 正在打包所有文件 (包括子文件夹)...
if not exist .git git init
git remote remove origin 2>nul
git remote add origin %repo_url%

git config --global --unset http.proxy 2>nul
git config --global --unset https.proxy 2>nul

:: 暴力添加所有内容
git add --all
git commit -m "Auto Upload Source Code" 2>nul
git branch -M main

echo.
echo [3/3] 正在推送到 GitHub...
echo 目标: %repo_url%

:: 端口轮询
echo [尝试] 端口 7897...
git config http.proxy http://127.0.0.1:7897
git config https.proxy http://127.0.0.1:7897
git push -u origin main --force
if not errorlevel 1 goto success

echo [尝试] 端口 7890...
git config http.proxy http://127.0.0.1:7890
git config https.proxy http://127.0.0.1:7890
git push -u origin main --force
if not errorlevel 1 goto success

echo [尝试] 直连...
git config --unset http.proxy
git config --unset https.proxy
git push -u origin main --force
if not errorlevel 1 goto success

color 0C
echo.
echo [失败] 无法上传。请检查网络。
pause
exit

:: ========================================================
:: 4. 成功倒计时
:: ========================================================
:success
color 0A
cls
echo ========================================================
echo               🎉 任务圆满完成！
echo ========================================================
echo.
echo  1. 已上传至: %repo_url%
echo  2. 编译已开始，稍后请去 GitHub 下载。
echo.
echo  窗口将在 10 秒后自动关闭...
echo ========================================================
timeout /t 10
exit
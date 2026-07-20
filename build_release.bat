@echo off
setlocal enabledelayedexpansion
title Flock - Release Build (AAB + APK)

REM ==========================================================================
REM  Flock surumlu (release) derleme betigi.
REM  Cift tikla ya da terminalden calistir. AAB (Play) + APK (elden kurulum)
REM  uretir, ikisi de android\key.properties'teki upload anahtariyla imzali.
REM
REM  Not: Bu makinede Dart derleyicisi ara sira kendiliginden cokebiliyor;
REM  bu yuzden her build 3 kez denenir. Ilk denemede takilirsa panige gerek yok.
REM ==========================================================================

REM --- Ortam (bu makineye gore sabit) ---
set "JAVA_HOME=%USERPROFILE%\.jdks\jdk17.0.19_10"
set "ANDROID_HOME=C:\Asdk"
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
set "FLUTTER=C:\src\flutter\bin\flutter.bat"
if not exist "%FLUTTER%" set "FLUTTER=flutter"

REM --- Proje koku = bu betigin bulundugu klasor ---
cd /d "%~dp0"

echo(
echo ===========================================================
echo   Flock release build
echo   JDK : %JAVA_HOME%
echo   SDK : %ANDROID_HOME%
echo   Dizin: %CD%
echo ===========================================================
echo(

REM --- Bagimliliklar ---
echo [1/3] flutter pub get...
call "%FLUTTER%" pub get
if errorlevel 1 (
  echo.
  echo HATA: pub get basarisiz. Cikiliyor.
  goto :fail
)

REM --- AAB (Play Store) ---
echo(
echo [2/3] AAB derleniyor (Play Store)...
set AAB_OK=0
for /L %%i in (1,1,3) do (
  if !AAB_OK!==0 (
    echo   -- deneme %%i/3 --
    call "%FLUTTER%" build appbundle --release
    if !errorlevel!==0 ( set AAB_OK=1 ) else ( echo   deneme %%i basarisiz, tekrar deneniyor... )
  )
)
if !AAB_OK!==0 (
  echo.
  echo HATA: AAB 3 denemede de derlenemedi.
  goto :fail
)

REM --- APK (elden kurulum / test) ---
echo(
echo [3/3] APK derleniyor (elden kurulum)...
set APK_OK=0
for /L %%i in (1,1,3) do (
  if !APK_OK!==0 (
    echo   -- deneme %%i/3 --
    call "%FLUTTER%" build apk --release
    if !errorlevel!==0 ( set APK_OK=1 ) else ( echo   deneme %%i basarisiz, tekrar deneniyor... )
  )
)
if !APK_OK!==0 (
  echo.
  echo HATA: APK 3 denemede de derlenemedi.
  goto :fail
)

REM --- Ciktilari Indirilenler'e tarih-saatli klasore kopyala ---
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set "STAMP=%%t"
set "OUTDIR=%USERPROFILE%\Downloads\Flock-build-%STAMP%"
mkdir "%OUTDIR%" 2>nul
copy /y "%CD%\build\app\outputs\bundle\release\app-release.aab" "%OUTDIR%\Flock-%STAMP%.aab" >nul
copy /y "%CD%\build\app\outputs\flutter-apk\app-release.apk" "%OUTDIR%\Flock-%STAMP%.apk" >nul

echo(
echo ===========================================================
echo   BASARILI
echo ===========================================================
echo   Kopyalandi (Indirilenler):
echo     %OUTDIR%
echo       - Flock-%STAMP%.aab   (Play'e yukle)
echo       - Flock-%STAMP%.apk   (telefona kur)
echo(
echo   Orijinal derleme ciktilari:
echo     %CD%\build\app\outputs\bundle\release\app-release.aab
echo     %CD%\build\app\outputs\flutter-apk\app-release.apk
echo ===========================================================
echo(
start "" "%OUTDIR%"
goto :end

:fail
echo(
echo Build basarisiz oldu. Yukaridaki cikti loglarina bak.
echo(

:end
endlocal
pause

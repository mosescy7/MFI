@echo off
title MFSD Financial Health Dashboard

REM ── Find Rscript.exe ──────────────────────────────────────────
SET RSCRIPT=
FOR /D %%V IN ("C:\Program Files\R\R-*") DO SET RSCRIPT=%%V\bin\Rscript.exe
FOR /D %%V IN ("C:\Users\%USERNAME%\AppData\Local\Programs\R\R-*") DO SET RSCRIPT=%%V\bin\Rscript.exe

IF NOT EXIST "%RSCRIPT%" (
  echo ERROR: Rscript.exe not found. Please install R from https://cran.r-project.org
  pause
  exit /b 1
)

echo ============================================================
echo  MFSD Financial Health Dashboard
echo  URL : http://192.168.50.112:3838
echo  Stop: close this window or press Ctrl+C
echo ============================================================
echo.

REM ── Launch the dashboard ──────────────────────────────────────
"%RSCRIPT%" "%~dp0launch_dashboard.R"

pause

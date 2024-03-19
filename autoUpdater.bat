@echo off


:loop
timeout -t 1 >nul

for /r ".\src" %%f in (*) do (
  echo %%~af|find "a">nul
  if errorlevel 1 (echo > nul) else (CALL :src_file_changed %%f)
)

goto :loop

EXIT /B 0


:src_file_changed
echo File %~1 was changed - Updating Reaper scripts
attrib -a %~1
echo %~1
COPY %~1 %AppData%\REAPER\Scripts\Aelkaro\%~nx1
EXIT /B 0
@echo off
cd /d "%~dp0human_sim"
echo Town Square Sim — setup...
call mix setup
echo.
echo Web UI: http://localhost:4000
echo.
call iex -S mix
pause

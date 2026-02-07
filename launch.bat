@echo off
echo Starting Human Simulator...
cd /d "%~dp0human_sim"
call mix deps.get
call mix compile
call iex -S mix
pause

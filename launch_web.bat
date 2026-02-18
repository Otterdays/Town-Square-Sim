@echo off
cd /d "%~dp0human_sim"
call mix setup
call mix phx.server
pause

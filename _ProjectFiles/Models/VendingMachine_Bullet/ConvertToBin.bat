REM @echo off
setlocal EnableDelayedExpansion

:LOOP
if "%~1"=="" goto :END

"C:\The Divinity Engine 2\DefEd\LSPakUtilityBulletToPhysX.exe" -i "%~1"
shift

goto :LOOP
:END
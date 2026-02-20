@echo off
REM Run this ONCE on the server as Administrator to open port 3838
netsh advfirewall firewall add rule ^
  name="MFSD Shiny Dashboard (port 3838)" ^
  dir=in ^
  action=allow ^
  protocol=TCP ^
  localport=3838
echo Port 3838 opened successfully.
pause

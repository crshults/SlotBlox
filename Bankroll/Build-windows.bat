tclkit-8.6.9-windows.exe sdx.kit wrap Bankroll.exe -runtime tclkit-8.6.9-windows-runtime.exe
move /y Bankroll.exe Bankroll-windows.exe

tclkit-8.6.9-windows.exe sdx.kit wrap Bankroll -runtime tclkit-8.6.9-linux-runtime
move /y Bankroll Bankroll-linux

tclkit-8.6.9-windows.exe sdx.kit wrap Bankroll -runtime tclkit-8.6.9-raspberrypi-runtime
move /y Bankroll Bankroll-raspberrypi

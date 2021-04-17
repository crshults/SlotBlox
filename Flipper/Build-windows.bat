tclkit-8.6.9-windows.exe sdx.kit wrap Flipper.exe -runtime tclkit-8.6.9-windows-runtime.exe
move /y Flipper.exe Flipper-windows.exe

tclkit-8.6.9-windows.exe sdx.kit wrap Flipper -runtime tclkit-8.6.9-linux-runtime
move /y Flipper Flipper-linux

tclkit-8.6.9-windows.exe sdx.kit wrap Flipper -runtime tclkit-8.6.9-raspberrypi-runtime
move /y Flipper Flipper-raspberrypi

tclkit-8.6.9-windows.exe sdx.kit wrap BankrollInspector.exe -runtime tclkit-8.6.9-windows-runtime.exe
move /y BankrollInspector.exe BankrollInspector-windows.exe

tclkit-8.6.9-windows.exe sdx.kit wrap BankrollInspector -runtime tclkit-8.6.9-linux-runtime
move /y BankrollInspector BankrollInspector-linux

tclkit-8.6.9-windows.exe sdx.kit wrap BankrollInspector -runtime tclkit-8.6.9-raspberrypi-runtime
move /y BankrollInspector BankrollInspector-raspberrypi

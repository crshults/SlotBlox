tclkit-8.6.9-windows.exe sdx.kit wrap TickTackDoughGameCartridge-1_0.exe -runtime tclkit-8.6.9-windows-runtime.exe
move /y TickTackDoughGameCartridge-1_0.exe TickTackDoughGameCartridge-1_0-windows.exe

tclkit-8.6.9-windows.exe sdx.kit wrap TickTackDoughGameCartridge-1_0 -runtime tclkit-8.6.9-linux-runtime
move /y TickTackDoughGameCartridge-1_0 TickTackDoughGameCartridge-1_0-linux

tclkit-8.6.9-windows.exe sdx.kit wrap TickTackDoughGameCartridge-1_0 -runtime tclkit-8.6.9-raspberrypi-runtime
move /y TickTackDoughGameCartridge-1_0 TickTackDoughGameCartridge-1_0-raspberrypi

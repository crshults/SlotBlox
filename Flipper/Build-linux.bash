#!/usr/bin/env bash
./tclkit-8.6.9-linux sdx.kit wrap Flipper.exe -runtime tclkit-8.6.9-windows-runtime.exe
mv -f Flipper.exe Flipper-windows.exe

./tclkit-8.6.9-linux sdx.kit wrap Flipper -runtime tclkit-8.6.9-linux-runtime
mv -f Flipper Flipper-linux

./tclkit-8.6.9-linux sdx.kit wrap Flipper -runtime tclkit-8.6.9-raspberrypi-runtime
mv -f Flipper Flipper-raspberrypi

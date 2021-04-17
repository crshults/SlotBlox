#!/usr/bin/env bash
./tclkit-8.6.9-raspberrypi sdx.kit wrap BankrollInspector.exe -runtime tclkit-8.6.9-windows-runtime.exe
mv -f BankrollInspector.exe BankrollInspector-windows.exe

./tclkit-8.6.9-raspberrypi sdx.kit wrap BankrollInspector -runtime tclkit-8.6.9-linux-runtime
mv -f BankrollInspector BankrollInspector-linux

./tclkit-8.6.9-raspberrypi sdx.kit wrap BankrollInspector -runtime tclkit-8.6.9-raspberrypi-runtime
mv -f BankrollInspector BankrollInspector-raspberrypi

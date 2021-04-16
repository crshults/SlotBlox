#!/usr/bin/env bash
./tclkit-8.6.9-raspberrypi sdx.kit wrap TickTackDoughGameCartridge-1_0.exe -runtime tclkit-8.6.9-windows-runtime.exe
mv -f TickTackDoughGameCartridge-1_0.exe TickTackDoughGameCartridge-1_0-windows.exe

./tclkit-8.6.9-raspberrypi sdx.kit wrap TickTackDoughGameCartridge-1_0 -runtime tclkit-8.6.9-linux-runtime
mv -f TickTackDoughGameCartridge-1_0 TickTackDoughGameCartridge-1_0-linux

./tclkit-8.6.9-raspberrypi sdx.kit wrap TickTackDoughGameCartridge-1_0 -runtime tclkit-8.6.9-raspberrypi-runtime
mv -f TickTackDoughGameCartridge-1_0 TickTackDoughGameCartridge-1_0-raspberrypi

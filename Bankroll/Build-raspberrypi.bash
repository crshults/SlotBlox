#!/usr/bin/env bash
./tclkit-8.6.9-raspberrypi sdx.kit wrap Bankroll.exe -runtime tclkit-8.6.9-windows-runtime.exe
mv -f Bankroll.exe Bankroll-windows.exe

./tclkit-8.6.9-raspberrypi sdx.kit wrap Bankroll -runtime tclkit-8.6.9-linux-runtime
mv -f Bankroll Bankroll-linux

./tclkit-8.6.9-raspberrypi sdx.kit wrap Bankroll -runtime tclkit-8.6.9-raspberrypi-runtime
mv -f Bankroll Bankroll-raspberrypi

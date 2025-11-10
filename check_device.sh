#!/bin/bash
# Quick script to check Android device connection

echo "Checking for Android devices..."
adb devices -l

echo ""
echo "Checking Flutter device detection..."
flutter devices

echo ""
echo "If your device appears above, you're ready to start!"
echo "If not, make sure USB debugging is enabled and try: adb kill-server && adb start-server"

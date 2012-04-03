#!/bin/bash
#This script sets up user-configured external monitors. It offers two functions,
#one an action to be taken if a monitor is detected, and another if no external monitor is found.
#This script is based heavily on: ost *
export DISPLAY=:0.0 #This is necessary because root won't be able to call xrandr without knowing the DISPLAY
#sleep 5
function connect() {
#If using KDE, grab next line from ~/.kde/share/config/krandrrc after using System Settings 
#Display panel to configure monitors, then choose Save as Default
    xrandr --output LVDS1 --pos 0x860 --mode 1366x768 --refresh 60.0186\nxrandr --output VGA1 --pos 1366x0 --mode 2048x1152 --refresh 59.9087\nxrandr --output LVDS1 --primary
}

function disconnect() {
    xrandr --output VGA1 --off
}

xrandr | grep "VGA1 connected" &> /dev/null && connect || disconnect

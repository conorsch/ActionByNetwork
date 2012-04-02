#!/bin/bash
#===============================================================================
#
#          FILE:  hotplug_monitor.sh
# 
#         USAGE:  ./hotplug_monitor.sh 
# 
#   DESCRIPTION:  Configure screen layout according to external monitor state
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:   (), 
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  03/20/2012 03:29:55 PM EDT
#      REVISION:  ---
#===============================================================================

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

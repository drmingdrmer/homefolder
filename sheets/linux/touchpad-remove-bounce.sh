#!/bin/bash


# list all touchpad properties
#     xinput list-props "AlpsPS/2 ALPS GlidePoint"

# find 'Coasting': 
#     xinput list-props "AlpsPS/2 ALPS GlidePoint" | grep Coas
#             Synaptics Coasting Speed (285): 3.000000, 8.000000

# change it to zero to disable touchpad from moving after finger left:
#     xfconf-query -c pointers -p /AlpsPS2_ALPS_GlidePoint/Properties/Synaptics_Coasting_Speed -n -t double -t double -s 0 -s 0

#     # NOTE: -t specifies type and it must match or nothing gonna change

#     xinput list-props "AlpsPS/2 ALPS GlidePoint" | grep Coas
#             Synaptics Coasting Speed (285): 0.000000, 0.000000

xinput

echo choose id of touch-pad:

read id


devname=$(xinput | grep "id=$id\b" | grep -o "↳.*id=" | awk '{gsub(".*", "", $1); gsub(".*", "", $NF); print $0}')
devname=$(echo $devname)

echo
echo "device is '$devname'"

echo
echo device prop Coas currently:
xinput list-props "$devname" | grep Coas

devpath=$(echo "$devname" | sed 's/[ ]/_/g; s/[\/]//g')
echo
echo device path name is $devpath
xfconf-query -c pointers -p /$devpath/Properties/Synaptics_Coasting_Speed -n -t double -t double -s 0 -s 0

echo
echo device prop Coas changed to:
xinput list-props "$devname" | grep Coas

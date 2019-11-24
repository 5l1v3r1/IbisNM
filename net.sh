#!/bin/bash

blue='\e[0;34'
cyan='\e[0;36m'
green='\e[0;34m'
okegreen='\033[92m'
lightgreen='\e[1;32m'
white='\e[1;37m'
red='\e[1;31m'
yellow='\e[1;33m'

if [ ! -d ~/.config/wpa ]; then
	mkdir ~/.config/wpa
fi

echo -e "$white         ______    _      $red _   ____  ___"
echo -e "$white        /  _/ /_  (_)____$red / | / /  |/  /"
echo -e "$white        / // __ \/ / ___/$red   |/ / /|_/ / "
echo -e "$white      _/ // /_/ / (__  )$red  /|  / /  / /  "
echo -e "$white     /___/_.___/_/____/$red _/ |_/_/  /_/   "
echo -e ""
echo -e "$white       Ibis-Linux_ Network Manager"
echo -e ""
read -p "Interface : " interface;
ifconfig $interface up
iwlist $interface scan | grep 'Frequency:\|Quality=\|Encryption\|ESSID:' | sed "s/=/:/" | sed "s/                    //" | sed "s/Signal level=/\nSignal:/" | sed "s/ (Channel /\nChannel:/" | sed "s/)//" | sed "s/Frequency:/\nFrequency:/"
echo -e ""
read -p "ESSID : " essid;
read -p "Pass  : " pass;
echo -e ""
echo -e "$red //$white Connecting ..."
if [ $pass == '' ]
then
    iwconfig $interface essid "$essid"
    dhcpcd $interface
else
    wpa_passphrase $essid $pass > ~/.config/wpa/$essid.conf
    wpa_supplicant -B -i $interface -c ~/.config/wpa/$essid.conf -D wext
    dhcpcd $interface
fi
wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
        echo -e "$okegreen **$white Connected"
else
        echo -e "$red !!$white Not Connected"
fi

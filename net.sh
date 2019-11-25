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
read -p " NM : " act;
if [ $act == 'connect' ]
then
    read -p " Interface : " interface;
    ifconfig $interface up
    iwlist $interface scan | grep 'Frequency:\|Quality=\|Encryption\|ESSID:' | sed "s/=/:/" | sed "s/                    //" | sed "s/Signal level=/\nSignal:/" | sed "s/ (Channel /\nChannel:/" | sed "s/)//" | sed "s/Frequency:/\nFrequency:/"
    echo -e ""
    read -p " ESSID : " essid;
    read -p " Pass  : " pass;
    echo -e ""
    if [ $pass == '' ]
    then
        echo -e "$red //$white Connecting to $essid ..."
        iwconfig $interface essid "$essid"
        echo -e "$red //$white Authenticating ..."
        dhcpcd $interface
    else
        echo -e "$red //$white Creating wpa_passhrase config ..."
        wpa_passphrase "$essid" $pass > ~/.config/wpa/ssid.conf
        echo -e "$red //$white Connecting to $essid ..."
        wpa_supplicant -B -i $interface -c ~/.config/wpa/ssid.conf -D wext
        echo -e "$red //$white Authenticating ..."
        dhcpcd $interface
    fi
    ip=`ifconfig $interface | grep 'inet ' | awk '{print $2}'`
    if [ $ip == '' ]
    then
        echo -e "$yellow !!$white Cannot obtain IP Address"
    else
        echo -e "$okegreen **$white Success obtain IP Address ..."
        echo -e "$okegreen **$white Your local IP : $ip"
    fi
    echo -e "$red //$white Checking connection ..."
    wget -q --tries=10 --timeout=20 --spider http://google.com
    if [[ $? -eq 0 ]]
    then
        echo -e "$okegreen **$white Connected to Internet"
    else
        echo -e "$yellow !!$white Not Connected to Internet"
    fi
    rm -rf ~/.config/wpa/ssid.conf
elif [ $act == 'disconnect' ]
then
    echo ''
elif [ $act == 'status' ]
then
    ssid=`iwconfig wlan0 | grep ESSID | awk '{print $4}' | sed "s/ESSID://"`
    if [ $ssid == 'off/any' ]
    then
        echo -e "$yellow !!$white Not Connected to any routers"
    else
        ip=`ifconfig $interface | grep 'inet ' | awk '{print $2}'`
        echo -e "$okegreen **$white Connected to $ssid"
        echo -e "$okegreen **$white Your IP : $ip"
    fi
elif [ $act == 'exit' ]
then
    echo -e "$yellow !!$white Exitting"
    exit
else
    echo -e ""
    echo -e "$yellow !!$white Command $act not found"
    echo -e "$red //$white Available commands :"
    echo -e ""
    echo -e "$yellow    ->$white connect"
    echo -e "$yellow    ->$white disconnect"
    echo -e "$yellow    ->$white status"
    echo -e "$yellow    ->$white exit"
    echo -e ""
fi

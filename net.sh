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

readinput(){
    read -p " Command : " act;
    if [[ $type == 'wifi' ]]; then
        if [[ $act == 'connect' ]]; then
            connect_wifi
        elif [[ $act == 'disconnect' ]]; then
            disconnect_wifi
        elif [[ $act == 'status' ]]; then
            wifi_status
        else
            readinput
        fi
    elif [[ $type == 'eth' ]]; then
        if [[ $act == 'connect' ]]; then
            connect_ethernet
        elif [[ $act == 'disconnect' ]]; then
            disconnect_ethernet
        elif [[ $act == 'status' ]]; then
            ethernet_status
        else
            readinput
        fi
    fi
}

banner(){
    clear
    echo -e ""
    echo -e "$white         ______    _      $red _   ____  ___"
    echo -e "$white        /  _/ /_  (_)____$red / | / /  |/  /"
    echo -e "$white        / // __ \/ / ___/$red   |/ / /|_/ / "
    echo -e "$white      _/ // /_/ / (__  )$red  /|  / /  / /  "
    echo -e "$white     /___/_.___/_/____/$red _/ |_/_/  /_/   "
    echo -e ""
    echo -e "$white       Ibis-Linux_ Network Manager"
}

main_input(){
    echo -e ""
    read -p " Ethernet / Wifi (eth/wifi) ? " type;
    banner
    echo -e ""
    echo -e "$okegreen **$white Available interface :"
    echo -e ""
    ifconfig -a | grep Link | awk '{print $1}'
    echo -e ""
    read -p " Interface : " interface;
    main_menu
}

main_menu(){
    banner
    echo -e ""
    echo -e "$cyan connect$yellow      |$white   Connect to network"
    echo -e "$cyan disconnect$yellow   |$white   Disconnect from network"
    echo -e "$cyan status$yellow       |$white   Connection status"
    echo -e ""
    readinput
}

connect_wifi(){
    ifconfig $interface up
    banner
    echo -e ""
    echo -e "$okegreen **$white Available wifi : "
    echo -e ""
    iwlist $interface scan | grep 'Frequency:\|Quality=\|Encryption\|ESSID:' | sed "s/=/:/" | sed "s/                    //" | sed "s/Signal level=/\nSignal:/" | sed "s/ (Channel /\nChannel:/" | sed "s/)//" | sed "s/Frequency:/\nFrequency:/"
    echo -e ""
    read -p " ESSID : " essid;
    read -p " Pass  : " pass;
    echo -e ""
    if [[ $pass == '' ]]; then
        connect_open_wifi
    else
        connect_secure_wifi
    fi
}

connect_open_wifi(){
    banner
    echo -e ""
    echo -e "$red //$white Connecting to $essid ..."
    iwconfig $interface essid "$essid"
    echo -e "$red //$white Authenticating ..."
    dhcpcd $interface
    check_connection
}

connect_secure_wifi(){
    banner
    echo -e ""
    echo -e "$red //$white Creating wpa_passhrase config ..."
    wpa_passphrase "$essid" "$pass" > ~/.config/wpa/ssid.conf
    echo -e "$red //$white Connecting to $essid ..."
    wpa_supplicant -B -i $interface -c ~/.config/wpa/ssid.conf -D wext
    echo -e "$red //$white Authenticating ..."
    dhcpcd $interface
    check_connection
}

check_connection(){
    ip=`ifconfig $interface | grep 'inet addr' | sed "s/addr:/addr /" | awk '{print $3}'`
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
}

disconnect_wifi(){
    banner
    echo -e ""
    ssid=`iwconfig $interface | grep ESSID | awk '{print $4$5$6}' | sed "s/ESSID://"`
    if [ $ssid == 'off/any' ]
    then
        echo -e "$red //$white Disconnecting ..."
        killall wpa_supplicant
        echo -e "$red //$white Done"
    else
        echo -e "$okegreen **$white You are connected to $ssid"
        read -p " Do you really want to disconnect (y/N) ? " yn;
        if [ $yn == 'y' ] || [ $yn == 'Y' ]
        then
            echo -e "$red //$white Disconnecting ..."
            killall wpa_supplicant
            echo -e "$red //$white Done"
        elif [ $yn == 'n' ] || [ $yn == 'N' ]
        then
            echo -e "$red //$white Cancelling ..."
        else
            echo -e "$yellow !!$white Aborting ..."
        fi
    fi
}

wifi_status(){
    banner
    echo -e ""
    ssid=`iwconfig $interface | grep ESSID | awk '{print $4$5$6}' | sed "s/ESSID://"`
    if [ $ssid == 'off/any' ]
    then
        echo -e "$yellow !!$white Not Connected to any routers"
    else
        ip=`ifconfig $interface | grep 'inet addr' | sed "s/addr:/addr /" | awk '{print $3}'`
        echo -e "$okegreen **$white Connected to $ssid"
        echo -e "$okegreen **$white Your IP : $ip"
    fi
    echo -e ""
}

connect_ethernet(){
    banner
    echo -e ""
    echo -e "$red //$white Connecting ..."
    dhcpcd $interface
    check_connection
}

disconnect_ethernet(){
    banner
    echo -e ""
    echo -e "$red //$white Just plug out your ethernet cable"
    echo -e ""
}

ethernet_status(){
    banner
    echo -e ""
    ip=`ifconfig $interface | grep 'inet addr' | sed "s/addr:/addr /" | awk '{print $3}'`
    if [[ $ip == '' ]]; then
        echo -e "$yellow !!$white Not Connected to any Ethernet"
    else
        echo -e "$okegreen **$white Connected to Ethernet"
        echo -e "$okegreen **$white Your IP : $ip"
    fi
}

banner
main_input

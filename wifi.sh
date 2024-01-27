#!/bin/sh

help_text="WIFI-MANAGER V1.2 - A tool to connect to wifi networks using nmcli
================================================
[e]ESSID           print the currently connected network (blank string when unconnected)
[l]LIST            list avialable wifi networks where the 2nd argument is the table headers
[t]TOGGLE          toggle wifi on/off
[u]CONNECT-UNKNOWN connect to an unknown network where 2nd argument is name, 3rd argument is password (use 'queryPass' to use wofi to find the password) and 4th argument is security
[k]CONNECT-KNOWN   connect to a known network where 2nd argument is the network name
[C]CONNECT          an aliases to connect-unknown that automatically uses connect-known where possible
[d]DISCONNECT       disconnect from connected network
[E]ENABLED          returns true if wifi is enabled false otherwise
[i]INFO             show basic info on device hardware
================================================
if argument mathces none of the above this help text will be shown
"

case $1 in
e | "ESSID")
	echo "$(nmcli c | grep wlan0 | awk '{print ($1)}')"
;;

l | "LIST")
	echo "$(nmcli --fields "$2" dev wifi list | awk '!a[$0]++')"
;;

t | "TOGGLE")
    if [[ "$($0 ENABLED)" == "true" ]]; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
    fi
;;

E | "ENABLED")
    enabled=$(nmcli radio wifi)
    if [[ "$enabled" == "enabled" ]]; then
        echo "true"
    else
        echo "false"
    fi
;;

u | "CONNECT-UNKNOWN")
    ~/eww/scripts/wifi.sh DISCONNECT
    if [[ "$3" == "queryPass" ]] && [[ "$4" != "--" ]]; then # if the password is queryPass and the network has a password
        password=$(wofi -H 60 --style ~/.config/wofi/styles.css --show dmenu -p "Password for $2: ")
    else
        password=$3
    fi
    nmcli dev wifi connect "$2" password "$password"
    notify-send -t 5000 "Connection complete"
;;

k | "CONNECT-KNOWN")
    ~/eww/scripts/wifi.sh DISCONNECT
    nmcli con up $2
;;

C | "CONNECT")
    knownLine=$(nmcli con show | grep "$2 ")
    if [[ "$knownLine" == "" ]]; then # if we have not connected to the wifi before
        ~/.config/eww/scripts/wifi.sh CONNECT-UNKNOWN $2 $3 $4
    else # if we have connected to the wifi before
        ~/.config/eww/scripts/wifi.sh CONNECT-KNOWN $2
    fi
;;

D | "DISCONNECT")
    nmcli con down "$(~/eww/scripts/wifi.sh ESSID)"
;;

i | "INFO")
    echo "$(nmcli -o)"
;;

*)
    echo -e "$help_text"
;;
esac

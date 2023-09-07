#!/bin/bash

# 
# Script created to help track down active IPs in given scope
#

# TEST IF USER GAVE 1 PARAMETER (required args)
if [ "$#" -ne 1 ]; then
    echo "You entered incorrect parameters"
    echo "Try again and provide only the Class C subnet"
    echo "EXAMPLE: ping_sweep.sh 192.168.1"
    exit
fi

classC=$1

# CREDIT TO BELOW LINK FOR VALIDATION RULES
# https://www.linuxjournal.com/content/validating-ip-address-bash-script
if [[ $classC =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "FELL INTO GOOD IP TEST BLOCK"
    OIFS=$IFS
    IFS='.'
    ip=($classC)
    IFS=$OIFS
    if [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 ]]; then
        validClassC="TRUE"
        echo "CONGRATULATIONS YOU PROVIDED A VALID CLASS C SUBNET!!"
    else
        validClassC="FALSE"
        echo "WHOOPS! YOU PROVIDED AN INVALID ARGUMENT" $classC
    fi
else echo "WHOOPS! YOU PROVIDED AN INVALID ARGUMENT" $classC
fi

# FOUND THIS FUNCTION DEFINITION TO ACCOUNT FOR THE FACT THAT THE WINDOWS
# VERSION OF PING UTILITY SEEMS TO ALWAYS RETURN A VALUE OF 0 EVEN FOR
# UNREACHABLE HOSTS. SO HAVE TO GREP FOR THE OUTPUT TO FIGURE OUT IF
# HOST IS REALLY THERE OR NOT. THE CODE FOR LINUX PING IS TO JUST
# CHECK FOR $? VALUE, WHICH CAPTURES LAST EXIT CODE
# https://unix.stackexchange.com/questions/454634/ping-command-always-returns-zero-exit-code-in-cygwin
is_host_online_windows()
{
    ping_output_raw=$(ping -n 1 "$1")
    ! echo "$ping_output_raw" | grep 'Destination host unreachable' > /dev/null 2>&1
}

# FOLLOWING IS THE PING SWEEP CODE AND OUTPUT
echo ""
echo "Scanning $classC.0/24..."
echo "--------"

# IF THE HOST FILES ALERADY EXIST MAKE A BACKUP OF THE CURRENT
# FILES BY RENAMING THEM AND OUTPUT A MESSAGE TO USER SO
# THEY ARE AWARE
if [ -f live_hosts.txt ]; then
    mv -f live_hosts.txt live_hosts1.txt && echo "EXISTING live_hosts.txt BACKED UP TO live_hosts1.txt"
fi
if [ -f down_hosts.txt ]; then
    mv -f down_hosts.txt down_hosts1.txt && echo "EXISTING down_hosts.txt BACKED UP TO live_hosts1.txt"
fi


for i in {1..5}
do
    ip="$classC.$i"
#    ping -c 1 $ip &> /dev/null
    is_host_online_windows $ip
    if [ $? -eq 0 ]; then
        echo "$ip is UP!" >> live_hosts.txt
    else
        echo "$ip is DOWN!" >> down_hosts.txt
    fi
done

echo ""
echo "The following hosts are UP:"
echo "These hosts have been saved to 'live_hosts.txt'"
echo "-----"
cat live_hosts.txt
echo ""
echo "-----"
echo "IP Addresses that are DOWN are stored in 'down_hosts.txt'"
cat down_hosts.txt
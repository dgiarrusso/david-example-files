#!/bin/bash
set +x #echo on|off

# 
# Script created to help automation frequent system audit activities
#


###################################
# Usage:
# gerVersions.sh          = query all endpoints EXCEPT lengthy queries (default)
# getVersions.sh <all>    = query all endpoints including queries deemed to take a longer time
#
###################################

# THIS SCRIPT IS INTENDED TO:
# Retrieve version numbers for various APPLICATION test-beds including
# APPLICATION Portal
# SDApi
# EventPropagator (VM and in GCP) - GCP requires gcloud tools and to be authenticated
# PBX D2 API (???)
# MY API
# Phone API (a.k.a. monitoring-service API)
# SD Gateway (a.k.a. provisioning-server API)
# MCSS Url (from DATABASE)


###################################
# REQUIRED SOFTWARE FOR RUNNING SCRIPT ON WINDOWS HOST
###################################
# Gcloud SDK Install - https://cloud.google.com/sdk/docs/install
# Command to update already installed - gcloud components update <enter>
# sqlcmd Utility:
#    Windows Install - https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15
#    Linux Install   - https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15
# Git tools (git bash) - https://help.github.com/en/github/getting-started-with-github/set-up-git
# Source editor / IDE:
#     PyCharm - https://www.jetbrains.com/pycharm/download/
#     Visual Studio Code -https://code.visualstudio.com/download
# Putty / plink - requires enablment of EPEL repo on CentOS systems
#     yum -y install epel-release
#     yum repolist
#     yum -y install putty
# 


# Begin a basic html file that can be used later to upload to web server for viewing
logFile="./systemVersions.html"
cat > $logFile << EOF
<!DOCTYPE html>
<html>
    <head>
        <title>System Version Info</title>
    </head>
    <body>
EOF


if [ "$1" == "" ] || [ $# -gt 1 ]; then
    echo -e "Parameters are empty, performing default version queries ..." | tee -a ${logFile}; echo "<br>" >> $logFile
fi
echo | tee -a ${logFile}; echo "<br>" >> $logFile

# start time stamp
start=`date +%s`
echo -e `date -R` | tee -a ${logFile}; echo "<br>" >> $logFile


##############################
# CHECK MCSS URL
##############################
echo -e "Requesting Console url for all MCSS-enabled systems ..." | tee -a ${logFile}; echo "<br>" >> $logFile
mcssUrl_USQA=$(sqlcmd -S DATABASE.qa.my.fqdn.app  -U USERNAME -P PASSWORD -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)
#mcssUrl_EUD=$(sqlcmd -S DATABASE.dev.my.fqdn.app  -U USERNAME -P 1bwvFfwo -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)
mcssUrl_CAN01=$(sqlcmd -S 192.168.65.32  -U USERNAME -P PASSWORD -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)
mcssUrl_MIFT=$(sqlcmd -S 192.168.107.149  -U USERNAME -P PASSWORD -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)
mcssUrl_SIT=$(sqlcmd -S 192.168.129.69  -U USERNAME -P PASSWORD -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)
mcssUrl_UTIT=$(sqlcmd -S 192.168.173.9  -U USERNAME -P PASSWORD -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)
mcssUrl_SCOQA=$(sqlcmd -S 192.168.105.127  -U USERNAME -P PASSWORD -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)
mcssUrl_MAC=$(sqlcmd -S 192.168.131.12  -U USERNAME -P PASSWORD -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)
mcssUrl_WIN=$(sqlcmd -S 192.168.132.19  -U USERNAME -P PASSWORD -Q "use DATABASE; select value from REDACTEDTABLE where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "fqdn.io" | xargs)


##############################
# FIND PORTAL VERSIONS
##############################
# Easier curl command to ger portal version info from 'Create' page ... just need to update below to use this instead if desired
# curl --max-time 20 -sk https://my.fqdn.com/connect/create | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+'
echo -e "Requesting APPLICATION Portal version for all systems ..." | tee -a ${logFile}; echo "<br>" >> $logFile
ver_usqaPortal=$(curl --max-time 20 -s https://my.fqdn.com/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_macPortal=$(curl --max-time 20 -s https://my.fqdn.com/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
#ver_eudPortal=$(curl --max-time 20 -s https://portal.my.fqdn.eu/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_sitPortal=$(curl --max-time 20 -s https://portal.my.fqdn.com/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_miftPortal=$(curl --max-time 20 -s https://portal-my.fqdn.com/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_utitPortal=$(curl --max-time 20 -s https://utit-portal.my.fqdn.com/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_can01Portal=$(curl --max-time 20 -s https://portal-my.fqdn.com/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_winPortal=$(curl --max-time 20 -s https://portal.my.fqdn.com/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_scoqaPortal=$(curl --max-time 30 -s http://192.168.105.68/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_scosusPortal=$(curl --max-time 30 -s http://192.168.7.200/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_scoausPortal=$(curl --max-time 30 -s http://192.168.107.94/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')
ver_onxPortal=$(curl --max-time 30 -s https://portal.my.fqdn.com/Connect/Create | grep -i m5-version | awk -v FS="(<span class=\"m5-version\">|&nbsp;</span>)" '{print $2}')


##############################
# FIND SDAPI VERSIONS
##############################
echo -e "Requesting SDApi version for all systems ..." | tee -a ${logFile}; echo "<br>" >> $logFile
ver_usqaSdapi=$(curl --max-time 20 -s https://sdapi-my.fqdn.com/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
ver_macSdapi=$(curl --max-time 20 -s http://192.168.131.32:PORTNUM/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
# duplicate MAC sdapi version call because it seems to be "sleeping" or something causing timeout
ver_macSdapi=$(curl --max-time 20 -s http://192.168.131.32:PORTNUM/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
#ver_eudSdapi=$(curl --max-time 20 -s https://sdapi.my.fqdn.eu/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
ver_sitSdapi=$(curl --max-time 20 -s https://sdapi.my.fqdn.com/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
ver_miftSdapi=$(curl --max-time 20 -s https://portal-my.fqdn.com:PORTNUM/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
ver_utitSdapi=$(curl --max-time 20 -s https://utit-sdapi.my.fqdn.com/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
ver_can01Sdapi=$(curl --max-time 20 -s https://portal-my.fqdn.com:PORTNUM/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
ver_winSdapi=$(curl --max-time 20 -s https://sdapi.my.fqdn.com/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
ver_scoqaSdapi=$(curl --max-time 20 -s https://sdapi-my.fqdn.com/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
#NO SDAPI FOR SCO SUSTAINING - ver_scosusSdapi=$(curl --max-time 20 -s https://sdapi.my.fqdn.com/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
#NO SDAPI FOR SCO AUS (?) - ver_scoausSdapi=$(curl --max-time 30 -s http://192.168.104.62:PORTNUM/api/System/Version | awk -v FS="(\"|\")" '{print $2}')
#NO SDAPI FOR ONX (AUS)


##############################
# FIND D2 (PBX) VERSIONS
##############################
echo -e "Requesting PBX D2 version for all systems ..." | tee -a ${logFile}; echo "<br>" >> $logFile
ver_usqaD2Kramer=$(curl --max-time 20 -s http://192.168.128.10:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_macD2OSX=$(curl --max-time 20 -s http://192.168.131.50:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
#ver_eudD2NDE=$(curl --max-time 20 -s http://hostname.my.fqdn:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_miftD2DSY=$(curl --max-time 20 -s http://192.168.105.50:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_miftD2NQ5=$(curl --max-time 20 -s http://192.168.107.187:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_utitD2INT=$(curl --max-time 20 -s http://192.168.173.102:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_can01D2OT1=$(curl --max-time 20 -s http://192.168.65.34:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_winD2DOS=$(curl --max-time 20 -s http://192.168.132.50:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_scoqaD2HQSV01=$(curl --max-time 20 -s http://192.168.104.236:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
# ?? in use? - ver_scoqaD2HQSV02=$(curl --max-time 20 -s http://192.168.104.236:8000/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_scosusD2SUS=$(curl --max-time 20 -s http://192.168.7.195:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_scoausD2AUS=$(curl --max-time 20 -s http://192.168.107.93:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
#?? private network - ver_scoausD2A2C=$(curl --max-time 20 -s http://192.168.237.27:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_onxD2AQ1=$(curl --max-time 20 -s http://192.168.134.200:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_sitD2ND7=$(curl --max-time 20 -s http://hostname.my.fqdn:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
ver_sitD2NDL=$(curl --max-time 20 -s http://hostname.my.fqdn:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')

# THESE QUERIES MAY TAKE A WHILE SO ONLY INVOKE IF USER ASKED TO
if [ "$1" == "all" ]; then
    ver_sitD2PIT=$(curl --max-time 20 -s http://192.168.77.10:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2FIG=$(curl --max-time 20 -s http://192.168.129.50:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2RUM=$(curl --max-time 20 -s http://192.168.129.70:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2TWI=$(curl --max-time 20 -s http://192.168.129.90:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2FBT=$(curl --max-time 20 -s http://192.168.129.100:PORTNUM/dm/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2DOC=$(curl --max-time 20 -s http://192.168.129.140:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2BON=$(curl --max-time 20 -s http://192.168.129.170:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2GST=$(curl --max-time 20 -s http://192.168.129.190:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2ND1=$(curl --max-time 20 -s http://192.168.129.210:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2NQ1=$(curl --max-time 20 -s http://192.168.129.230:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2NQ4=$(curl --max-time 20 -s http://192.168.129.132:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2ND8=$(curl --max-time 20 -s http://hostname.my.fqdn:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2FAT=$(curl --max-time 20 -s http://192.168.129.120:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
    ver_sitD2BAV=$(curl --max-time 20 -s http://192.168.129.180:PORTNUM/director/login | grep -i build | awk -v FS="(Build |)" '{print $2}')
fi


#################################
# SETTING UP CRON JOB ON HOSTS ON PRIVATE NETWORKS TO SEND VERSION DATA
# Create the following shell script that will find the COMPANY packag eversion installed and put data in file to scp later
# - On RP / SBC / ABC / etc host create /USERNAME/get-COMPANY-version.sh script file and add below contents and save
#   #! /bin/bash
#   set +x #echo on|off
#   rm -f /USERNAME/mift-abc-version (name file appropriately of course)
#   rpm -qa | grep -i COMPANY > /USERNAME/mift-abc-version
#   date -R >> /USERNAME/mift-abc-version
#   scp /USERNAME/mift-abc-version USERNAME@REDACTEDIP:/USERNAME/uploads/.
# - Then run following command to allow script to be executed
#   chmod 755 /USERNAME/get-COMPANY-version.sh
# 
# How to set up scp without password prompt: https://www.thegeekdiary.com/how-to-run-scp-without-password-prompt-interruption-in-linux/
# - As user you want to scp files FROM do the following
#   cd /USERNAME (or users home dir)
#   ssh-keygen -t rsa -b 4096 -C "USERNAME@localhost"
#   ls -lah .ssh/ (make sure .pub file exists)
#   cat .ssh/id_rsa.pub | ssh USERNAME@REDACTEDIP 'cat >> .ssh/authorized_keys'
# - Then try to ssh to target host to confirm key is in place
#   ssh USERNAME@REDACTEDIP (should not prompt for password)
# - Then try to scp file 
#   scp /USERNAME/mift-abc-version USERNAME@REDACTEDIP:/USERNAME/uploads/.
# 
# How to create basic cron job: https://www.taniarascia.com/setting-up-a-basic-cron-job-in-linux/
# On RP / ABC / SBC / etc. ...
#    cd /USERNAME
#    crontab -l > /USERNAME/myCronjobs
#    gedit ./myCronjobs
#    - Add following line to file and save (runs script every hour):
#      0 * * * * /USERNAME/get-COMPANY-version.sh > /dev/null 2>&1
#    crontab /USERNAME/myCronjobs
#    crontab -l
#    
# YUM UPDATE FAILING ON CENTOS ... -> https://access.redhat.com/solutions/45815
#################################
# FIND REVERSE PROXY VERSIONS
#################################
echo -e "Requesting Reverse Proxy version for all systems ..." | tee -a ${logFile}; echo "<br>" >> $logFile
rpCan01="TBD" #Runs cron job to upload version to REDACTEDIP:/USERNAME/uploads/can01-rp-version
rpMift="REDACTEDIP"
rpUsqa="TBD" #Runs cron job to upload version to REDACTEDIP:/USERNAME/uploads/usqa-rp-version
rpMac1="REDACTEDIP" #Off-Net CentOS 7.5 - REDACTEDIP
rpMac2="REDACTEDIP" #Off-Net - REDACTEDIP
rpMac3="REDACTEDIP" #On-Net
#rpScoqa="192.168.107.117"
#summitScosus="127.0.0.1"

ver_can01RP=$(pscp -q -pw PASSWORD USERNAME@REDACTEDIP:/USERNAME/uploads/can01-rp-version ./tmpFile && cat tmpFile | grep -i COMPANY | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4 && rm -f ./tmpFile)
ver_miftRP=$(plink -ssh -l USERNAME -pw "PASSWORD" $rpMift 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)
ver_usqaRP=$(pscp -q -pw PASSWORD USERNAME@REDACTEDIP:/USERNAME/uploads/usqa-rp-version ./tmpFile && cat tmpFile | grep -i COMPANY | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4 && rm -f ./tmpFile)
ver_macRP1=$(plink -ssh -l USERNAME -pw "PASSWORD" $rpMac1 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)
ver_macRP2=$(plink -ssh -l USERNAME -pw "PASSWORD" $rpMac2 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)
ver_macRP3=$(plink -ssh -l USERNAME -pw "PASSWORD" $rpMac3 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)


#################################
# FIND SBC VERSIONS
#################################
echo -e "Requesting SBC version for all systems ..." | tee -a ${logFile}; echo "<br>" >> $logFile
sbcCan01="TBD" #Runs cron job to upload version to REDACTEDIP:/USERNAME/uploads/can01-sbc-version
sbcMift="192.168.107.146"
sbcUsqa="TBD" #Runs cron job to upload version to REDACTEDIP:/USERNAME/uploads/usqa-rp-version
sbcMac1="192.168.131.21" #Phone SBC1 Off-Net
sbcMac2="192.168.131.23" #Tie Trunk SBC 1 (Not set up yet??)
sbcMac3="192.168.131.25" #3rd Party SBC 1

#sbcScoqa="192.168.107.117"
#summitScosus="127.0.0.1"

ver_can01SBC=$(pscp -q -pw PASSWORD USERNAME@REDACTEDIP:/USERNAME/uploads/can01-sbc-version ./tmpFile && cat tmpFile | grep -i COMPANY | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4 && rm -f ./tmpFile)
ver_miftSBC=$(plink -ssh -l USERNAME -pw "PASSWORD" $sbcMift 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)
ver_usqaSBC=$(pscp -q -pw PASSWORD USERNAME@REDACTEDIP:/USERNAME/uploads/usqa-sbc-version ./tmpFile && cat tmpFile | grep -i COMPANY | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4 && rm -f ./tmpFile)
ver_macSBC1=$(plink -ssh -l USERNAME -pw "PASSWORD" $sbcMac1 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)
ver_macSBC2=$(plink -ssh -l USERNAME -pw "PASSWORD" $sbcMac2 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)
ver_macSBC3=$(plink -ssh -l USERNAME -pw "PASSWORD" $sbcMac3 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)


#################################
# FIND ABC VERSIONS
#################################
echo -e "Requesting ABC version for all systems ..." | tee -a ${logFile}; echo "<br>" >> $logFile
abcCan01="TBD" #Runs cron job to upload version to REDACTEDIP:/USERNAME/uploads/can01-abc-version
abcMift="TBD" #Runs cron job to upload version to REDACTEDIP:/USERNAME/uploads/mift-abc-version
abcUsqa="192.168.128.12"
abcMac="192.168.131.16"
#abcScoqa="192.168.107.117"
#summitScosus="127.0.0.1"

ver_can01ABC=$(pscp -q -pw PASSWORD USERNAME@REDACTEDIP:/USERNAME/uploads/can01-abc-version ./tmpFile && cat tmpFile | grep -i COMPANY | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4 && rm -f ./tmpFile)
ver_miftABC=$(pscp -q -pw PASSWORD USERNAME@REDACTEDIP:/USERNAME/uploads/mift-abc-version ./tmpFile && cat tmpFile | grep -i COMPANY | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4 && rm -f ./tmpFile)
ver_usqaABC=$(plink -ssh -l USERNAME -pw "PASSWORD" $abcUsqa 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)
ver_macABC=$(plink -ssh -l USERNAME -pw "PASSWORD" $abcMac 'rpm -qa | grep -i COMPANY' | awk -v FS="(-)" '{print $3}' | cut -d"." -f1-4)


#################################
# FIND EVENTPROPAGATOR VERSIONS
# FROM SUMMIT VIRTUAL MACHINES
#################################
# Initial variables to ensure they are actually updated with real data
ver_usqaCApi="SUMMIT DATA NOT UPDATED"
ver_miftCApi="SUMMIT DATA NOT UPDATED"
ver_can01CApi="SUMMIT DATA NOT UPDATED"
ver_scoqaEP="SUMMIT DATA NOT UPDATED"
ver_scosusEP="SUMMIT DATA NOT UPDATED"

echo -e "Requesting EventPropagator version for all systems ..." | tee -a ${logFile}; echo "<br>" >> $logFile
summitCan01="192.168.65.30"
summitMift="192.168.107.233"
summitUsqa="192.168.128.43"
summitScoqa="192.168.107.117"
#summitScosus="127.0.0.1"

ver_can01EP=$(plink -ssh -l USERNAME -pw "PASSWORD" $summitCan01 'docker ps -a | grep -i "/eventpropagatorapi:"')
ver_can01EP=$(echo $ver_can01EP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)

ver_miftEP=$(plink -ssh -l USERNAME -pw "PASSWORD" $summitMift 'docker ps -a | grep -i "/eventpropagatorapi:"')
ver_miftEP=$(echo $ver_miftEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)

ver_usqaEP=$(plink -ssh -l USERNAME -pw "PASSWORD" $summitUsqa 'docker ps -a | grep -i "/eventpropagatorapi:"')
ver_usqaEP=$(echo $ver_usqaEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)

ver_scoqaEP=$(plink -ssh -l USERNAME -pw "PASSWORD" $summitScoqa 'docker ps -a | grep -i "/eventpropagatorapi:"')
ver_scoqaEP=$(echo $ver_scoqaEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)

#ver_scosusEP=$(plink -ssh -l USERNAME -pw "PASSWORD" $summitScosus 'docker ps -a | grep -i "/eventpropagatorapi:"')
#ver_scosusEP=$(echo $ver_scosusEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)


##################################################
# Gathering versions from GCP:
# EventPropagator
# MY API (where applicable)
##################################################
# Initial variables to ensure they are actually updated with real data
ver_sitEP="GCP DATA NOT UPDATED"
ver_sitCApi="GCP DATA NOT UPDATED"

ver_utitEP="GCP DATA NOT UPDATED"
ver_utitCApi="GCP DATA NOT UPDATED"

#ver_eudEP="GCP DATA NOT UPDATED"
ver_macEP="GCP DATA NOT UPDATED"
ver_winEP="GCP DATA NOT UPDATED"
ver_scoqaCApi="GCP DATA NOT UPDATED"
ver_scoausEP="GCP DATA NOT UPDATED"
ver_onxEP="GCP DATA NOT UPDATED"


# Test to see if Google Cloud SDK is installed
# Gcloud SDK Install - https://cloud.google.com/sdk/docs/install
# Command to update already installed - gcloud components update <enter>
# Event Propagator wiki info:
# https://my.fqdn.net/wiki/spaces/APPLICATION/pages/613308115262/EP+-+System+Details+and+Deployment+Procedure
#
gcloudVersion=$(gcloud -v | grep "Google Cloud SDK")

# DO NOT Continue if Google Cloud SDK is NOT installed
if [ "$gcloudVersion" == "" ]; then
    echo GOOGLE CLOUD SDK IS NOT INSTALLED ... GOODBYE | tee -a ${logFile}; echo "<br>" >> $logFile

# Continue if Google Cloud SDK is installed
else
    # Make sure someone is logged in and authenticated to GCP before running kubectl commands
    # NOTE: user must also be whitelisted on the NA and UK project regions to access the data (GCO must set this up)
    loggedIn=$(gcloud info | grep "Account: \[")
    if [ "$loggedIn" == "Account: \[None\]" ]; then
        echo NOBODY IS LOGGED IN ... GOODBYE | tee -a ${logFile}; echo "<br>" >> $logFile

    else
        # -----------------------------------------------
        # Systems that use NA dev project
        # -----------------------------------------------
        echo | tee -a ${logFile}; echo "<br>" >> $logFile
        echo -e "Setting gcloud and kubectl context to NA ..." | tee -a ${logFile}; echo "<br>" >> $logFile
        gcloud config set project GCP-PROJECT
        sleep 2
        # gcloud container clusters get-credentials <CLUSTER NAME> --region <REGION THE CLUSTER IS IN> --project <PROJECT THE CLUSTER IS IN>
        gcloud container clusters get-credentials CLUSTER --region us-central1 --project GCP-PROJECT
        sleep 2
        context=$(kubectl config view | grep -i "current-context:")
        echo $context | tee -a ${logFile}; echo "<br>" >> $logFile
        echo | tee -a ${logFile}; echo "<br>" >> $logFile

        # Verify by running:
        # kubectl get nodes

        ver_usqaCApi=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -m1 -i -P "MY-api-.*MY-api-docker")
        ver_usqaCApi=$(echo $ver_usqaCApi | awk '{print $2}' | awk -v FS="(/gonzo:|)" '{print $2}' | cut -d"." -f1-3)

        ver_miftCApi=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -m1 -i -P "MY-api-.*MY-api-docker")
        ver_miftCApi=$(echo $ver_miftCApi | awk '{print $2}' | awk -v FS="(/gonzo:|)" '{print $2}' | cut -d"." -f1-3)

        ver_can01CApi=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -m1 -i -P "MY-api-.*MY-api-docker")
        ver_can01CApi=$(echo $ver_can01CApi | awk '{print $2}' | awk -v FS="(/gonzo:|)" '{print $2}' | cut -d"." -f1-3)

        #UTIT EP = GCP = https://bitbucket.org/ucaas_company/event-propagator/src/master/kubernetes/na/templates/eventpropagator/servicedelivery-dev-manifest.yaml
        ver_utitEP=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -i event-propagator)
        ver_utitEP=$(echo $ver_utitEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)
        ver_utitCApi=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -m1 -i -P "MY-api-.*MY-api-docker")
        ver_utitCApi=$(echo $ver_utitCApi | awk '{print $2}' | awk -v FS="(/gonzo:|)" '{print $2}' | cut -d"." -f1-3)

        #SIT EP = GCP = https://bitbucket.org/ucaas_company/event-propagator/src/master/kubernetes/na/templates/eventpropagator/servicedelivery-test-manifest.yaml
        ver_sitEP=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -i event-propagator)
        ver_sitEP=$(echo $ver_sitEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)
        ver_sitCApi=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -m1 -i -P "MY-api-.*MY-api-docker")
        ver_sitCApi=$(echo $ver_sitCApi | awk '{print $2}' | awk -v FS="(/gonzo:|)" '{print $2}' | cut -d"." -f1-3)

        #EUD EP = GCP = https://bitbucket.org/ucaas_company/event-propagator/src/master/kubernetes/na/templates/eventpropagator/servicedelivery-eu-dev-manifest.yaml
        #ver_eudEP=$(kubectl get pods --namespace servicedelivery-eu-dev --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -i event-propagator)
        #ver_eudEP=$(echo $ver_eudEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)

        ver_scoqaCApi=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -m1 -i -P "MY-api-.*MY-api-docker")
        ver_scoqaCApi=$(echo $ver_scoqaCApi | awk '{print $2}' | awk -v FS="(/gonzo:|)" '{print $2}' | cut -d"." -f1-3)

        #ver_scosusCApi=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -m1 -i -P "MY-api-.*MY-api-docker")
        #ver_scosusCApi=$(echo $ver_scoqaCApi | awk '{print $2}' | awk -v FS="(/gonzo:|)" '{print $2}' | cut -d"." -f1-3)
        
        # -----------------------------------------------
        # Systems that use UK dev project
        # -----------------------------------------------
        echo -e "Setting gcloud and kubectl context to UK ..." | tee -a ${logFile}; echo "<br>" >> $logFile
        gcloud config set project GCP-PROJECT
        sleep 2
        # gcloud container clusters get-credentials <CLUSTER NAME> --region <REGION THE CLUSTER IS IN> --project <PROJECT THE CLUSTER IS IN>
        gcloud container clusters get-credentials CLUSTER --region europe-west2 --project GCP-PROJECT
        sleep 2
        context=$(kubectl config view | grep -i "current-context:")
        echo $context | tee -a ${logFile}; echo "<br>" >> $logFile
        echo | tee -a ${logFile}; echo "<br>" >> $logFile

        #MAC EP = GCP = https://bitbucket-url/src/master/kubernetes/uk/templates/eventpropagator/dev-manifest.yaml
        ver_macEP=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -i event-propagator)
        ver_macEP=$(echo $ver_macEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)

        #WIN EP = GCP = https://bitbucket-url/master/kubernetes/uk/templates/eventpropagator/test-manifest.yaml
        ver_winEP=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -i event-propagator)
        ver_winEP=$(echo $ver_winEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)


        # -----------------------------------------------
        # Systems that use AU dev project
        # -----------------------------------------------
        echo -e "Setting gcloud and kubectl context to AU ..." | tee -a ${logFile}; echo "<br>" >> $logFile
        gcloud config set project GCP-PROJECT
        sleep 2
        # gcloud container clusters get-credentials <CLUSTER NAME> --region <REGION THE CLUSTER IS IN> --project <PROJECT THE CLUSTER IS IN>
        gcloud container clusters get-credentials CLUSTER --region australia-southeast1 --project GCP-PROJECT
        sleep 2
        context=$(kubectl config view | grep -i "current-context:")
        echo $context | tee -a ${logFile}; echo "<br>" >> $logFile
        echo | tee -a ${logFile}; echo "<br>" >> $logFile

        #SCO AUS EP = GCP = https://bitbucket.org/ucaas_company/event-propagator/src/master/kubernetes/au/templates/eventpropagator/test-manifest.yaml
        ver_scoausEP=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -i event-propagator)
        ver_scoausEP=$(echo $ver_scoausEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)

        #ONX AUS EP = GCP = https://bitbucket-url/master/kubernetes/au/templates/eventpropagator/test-manifest.yaml
        #Shares same EP config yaml as SCO AUS system (above)
        #Polling version info again just for completeness and independence of code
        ver_onxEP=$(kubectl get pods --namespace NAMESPACE --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image" | grep -i event-propagator)
        ver_onxEP=$(echo $ver_onxEP | awk '{print $2}' | awk -v FS="(/eventpropagatorapi:|)" '{print $2}' | cut -d"." -f1-3)

    fi
fi


#################################
# FIND MCSS CONSOLE VERSION
# From AWS ...
#################################
echo -e "Requesting Console code- base version info ..." | tee -a ${logFile}; echo "<br>" >> $logFile

# latest branch (CONSOLE DEV) - Typically integrates with dev environments such as CAN01, MIFT, WIN etc.
# https://raw.githubusercontent.com/my.fqdn/latest/package.json?token=APPTOKEN
ver_latestConsole=$(curl --max-time 20 -s https://raw.githubusercontent.com/my.fqdn/latest/package.json?token=APPTOKEN | grep -i "version\":" | awk -v FS="(version\": \"|\",)" '{print $2}' | cut -d"." -f1-3)

# dev branch (CONSOLE QA) - Typically integrates with USQA, MAC, SIT, UTIT, EUD etc.
# https://raw.githubusercontent.com/my.fqdn/dev/package.json?token=APPTOKEN
ver_devConsole=$(curl --max-time 20 -s https://raw.githubusercontent.com/my.fqdn/dev/package.json?token=APPTOKEN | grep -i "version\":" | awk -v FS="(version\": \"|\",)" '{print $2}' | cut -d"." -f1-3)

# master branch (CONSOLE PROD) - Typically integrates with Alpha, US PROD, UK PROD, DE PROD
# https://raw.githubusercontent.com/my.fqdn/master/package.json?token=APPTOKEN
#ver_alphaConsole=$(curl --max-time 20 -s https://raw.githubusercontent.com/my.fqdn/master/package.json?token=APPTOKEN | grep -i "version\":" | awk -v FS="(version\": \"|\",)" '{print $2}' | cut -d"." -f1-3)

# master branch (CONSOLE PROD) - Typically integrates with Alpha, US PROD, UK PROD, DE PROD
# https://raw.githubusercontent.com/my.fqdn/master/package.json?token=APPTOKEN
ver_prodConsole=$(curl --max-time 20 -s https://raw.githubusercontent.com/my.fqdn/master/package.json?token=APPTOKEN | grep -i "version\":" | awk -v FS="(version\": \"|\",)" '{print $2}' | cut -d"." -f1-3)



# end time stamp
end=`date +%s`
# calc and output TOTAL runtime for above
runtime=$((end-start))
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "Total Data Collection Time = $runtime seconds" | tee -a ${logFile}; echo "<br>" >> $logFile

##############################
# OUTPUT VERSION INFO
##############################
echo | tee -a ${logFile}; echo "<br>" >> $logFile
#echo -e "Console code base - connect-accounts-latest-stage.dev.fqdn.io = $ver_latestConsole" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "Console code base - connect-accounts-latest/-stage.dev.fqdn.io = $ver_latestConsole" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "Console code base - accounts.fqdn.io               = $ver_devConsole" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "Console code base - accounts.connect.fqdn.io (PROD)            = $ver_prodConsole" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>US QA - Portal       = $ver_usqaPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "US QA - SDApi        = $ver_usqaSdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "US QA - EP           = $ver_usqaEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "US QA - MY API  = $ver_usqaCApi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "US QA - D2 Kramer    = $ver_usqaD2Kramer" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "US QA - MCSS url     = <a href='$mcssUrl_USQA'>$mcssUrl_USQA</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "US QA - Rev Proxy    = $ver_usqaRP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "US QA - ABC          = $ver_usqaABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "US QA - SBC          = $ver_usqaSBC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>MAC   - Portal       = $ver_macPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - SDApi        = $ver_macSdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - EP           = $ver_macEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - D2 OSX       = $ver_macD2OSX" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - MCSS url     = <a href='$mcssUrl_MAC'>$mcssUrl_MAC</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - Rev Proxy (CentOS 7.5) = $ver_macRP1" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - Rev Proxy (Off-Net) = $ver_macRP2" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - Rev Proxy (On-Net) = $ver_macRP3" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - ABC          = $ver_macABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - SBC1 (off-net)  = $ver_macSBC1" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - SBC2 (tie trunk)  = $ver_macSBC2" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MAC   - SBC3 (3rd party)  = $ver_macSBC3" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
# echo -e "<b>EUD   - Portal       = $ver_eudPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
# echo -e "EUD   - SDApi        = $ver_eudSdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
# echo -e "EUD   - EP           = $ver_eudEP" | tee -a ${logFile}; echo "<br>" >> $logFile
# echo -e "EUD   - D2 NDE       = $ver_eudD2NDE" | tee -a ${logFile}; echo "<br>" >> $logFile
# echo -e "EUD   - MCSS url     = <a href='$mcssUrl_EUD'>$mcssUrl_EUD</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
# echo -e "EUD   - Rev Proxy    = $ver_eudRP" | tee -a ${logFile}; echo "<br>" >> $logFile
# echo -e "EUD   - ABC          = $ver_eudABC" | tee -a ${logFile}; echo "<br>" >> $logFile
# echo -e "EUD   - SBC          = $ver_eudSBC" | tee -a ${logFile}; echo "<br>" >> $logFile
# echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>MIFT  - Portal       = $ver_miftPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - SDApi        = $ver_miftSdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - EP           = $ver_miftEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - MY API  = $ver_miftCApi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - D2 DSY       = $ver_miftD2DSY" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - D2 NQ5       = $ver_miftD2NQ5" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - MCSS url     = <a href='$mcssUrl_MIFT'>$mcssUrl_MIFT</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - Rev Proxy    = $ver_miftRP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - ABC          = $ver_miftABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "MIFT  - SBC          = $ver_miftSBC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>CAN01 - Portal       = $ver_can01Portal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "CAN01 - SDApi        = $ver_can01Sdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "CAN01 - EP           = $ver_can01EP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "CAN01 - MY API  = $ver_can01CApi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "CAN01 - D2 OT1       = $ver_can01D2OT1" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "CAN01 - MCSS url     = <a href='$mcssUrl_CAN01'>$mcssUrl_CAN01</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "CAN01 - Rev Proxy    = $ver_can01RP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "CAN01 - ABC          = $ver_can01ABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "CAN01 - SBC          = $ver_can01SBC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>UTIT  - Portal       = $ver_utitPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "UTIT  - SDApi        = $ver_utitSdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "UTIT  - EP           = $ver_utitEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "UTIT  - MY API  = $ver_utitCApi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "UTIT  - D2 INT       = $ver_utitD2INT" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "UTIT  - MCSS url     = <a href='$mcssUrl_UTIT'>$mcssUrl_UTIT</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "UTIT  - Rev Proxy    = $ver_utitRP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "UTIT  - ABC          = $ver_utitABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "UTIT  - SBC          = $ver_utitSBC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>WIN   - Portal       = $ver_winPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "WIN   - SDApi        = $ver_winSdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "WIN   - EP           = $ver_winEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "WIN   - D2 DOS       = $ver_winD2DOS" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "WIN   - MCSS url     = <a href='$mcssUrl_WIN'>$mcssUrl_WIN</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "WIN   - Rev Proxy    = $ver_winRP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "WIN   - ABC          = $ver_winABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "WIN   - SBC          = $ver_winSBC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>SIT   - Portal       = $ver_sitPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - SDApi        = $ver_sitSdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - EP           = $ver_sitEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - MY API  = $ver_sitCApi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - MCSS url     = <a href='$mcssUrl_SIT'>$mcssUrl_SIT</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - D2 ND7       = $ver_sitD2ND7" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - D2 NDL       = $ver_sitD2NDL" | tee -a ${logFile}; echo "<br>" >> $logFile

if [ "$1" == "all" ]; then
    echo -e "SIT   - D2 PIT       = $ver_sitD2PIT" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 FIG       = $ver_sitD2FIG" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 RUM       = $ver_sitD2RUM" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 TWI       = $ver_sitD2TWI" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 FBT       = $ver_sitD2FBT" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 DOC       = $ver_sitD2DOC" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 BON       = $ver_sitD2BON" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 GST       = $ver_sitD2GST" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 ND1       = $ver_sitD2ND1" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 NQ1       = $ver_sitD2NQ1" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 NQ4       = $ver_sitD2NQ4" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 ND8       = $ver_sitD2ND8" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 FAT       = $ver_sitD2FAT" | tee -a ${logFile}; echo "<br>" >> $logFile
    echo -e "SIT   - D2 BAV       = $ver_sitD2BAV" | tee -a ${logFile}; echo "<br>" >> $logFile
fi
echo -e "SIT   - Rev Proxy (off-net)   = $ver_sitRP1" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - Rev Proxy (internal)   = $ver_sitRP2" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - ABC1         = $ver_sitABC1" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - ABC2         = $ver_sitABC2" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SIT   - ABC3         = $ver_sitABC3" | tee -a ${logFile}; echo "<br>" >> $logFile

echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>SCOQA - Portal       = $ver_scoqaPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOQA - SDApi        = $ver_scoqaSdapi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOQA - EP           = $ver_scoqaEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOQA - MY API  = $ver_scoqaCApi" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOQA - D2 HQ SV01   = $ver_scoqaD2HQSV01" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOQA - MCSS url     = <a href='$mcssUrl_SCOQA'>$mcssUrl_SCOQA</a>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOQA - Rev Proxy    = $ver_scoqaRP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOQA - ABC          = $ver_scoqaABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOQA - SBC          = $ver_scoqaSBC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>SCOSUS - Portal      = $ver_scosusPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOSUS - EP          = $ver_scosusEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOSUS - D2 SUS      = $ver_scosusD2SUS" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOSUS - Rev Proxy   = $ver_scosusRP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOSUS - ABC         = $ver_scosusABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOSUS - SBC         = $ver_scosusSBC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>SCOAUS - Portal      = $ver_scoausPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOAUS - EP          = $ver_scoausEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOAUS - D2 AUS      = $ver_scoausD2AUS" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOAUS - Rev Proxy   = $ver_scoausRP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOAUS - ABC         = $ver_scoausABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOAUS - SBC         = $ver_scoausSBC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "<b>ONX - Portal        = $ver_onxPortal</b>" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "ONX - EP             = $ver_onxEP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "ONX - D2 AQ1         = $ver_onxD2AQ1" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "ONX - Rev Proxy      = $ver_onxRP" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "ONX - ABC            = $ver_onxABC" | tee -a ${logFile}; echo "<br>" >> $logFile
echo -e "SCOSUS - SBC         = $ver_onxSBC" | tee -a ${logFile}; echo "<br>" >> $logFile


echo | tee -a ${logFile}; echo "<br>" >> $logFile
echo | tee -a ${logFile}; echo "<br>" >> $logFile

cat >> $logFile << EOF
        <p>Thank You - Have a great day!</p>
        <p>.</p>
        <p>.</p>
    </body>
</html>
EOF

# SCP the file to David's web server REDACTEDIP
pscp -scp -l USERNAME -pw "PASSWORD" $logFile USERNAME@REDACTEDIP:/var/www/html

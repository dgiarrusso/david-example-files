#!/bin/bash
set +x #echo on|off

# THIS SCRIPT IS INTENDED TO:
# Update Console url values for databases where we have MCSS enabled
# Typically these should not change but due to a number of factors we are
# having to re-map these urls periodically to ensure the correct Console version is
# being tested against the appropriate APP Portal / SDApi version
#


if [ "$1" == "" ] || [ $# -gt 1 ]; then
    echo -e "Parameters are empty..."
fi

# start time stamp
start=`date +%s`


##############################
# BEFORE - CHECK MCSS URL
##############################
echo -e "BEFORE ... GETTING Console url for all systems ..."
# US QA
echo -e "US QA  = " $(sqlcmd -S my.fqdn.app  -U PASSWORD -P 4fXw7Thu4dEg8L18 -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# EUD
#echo -e "EUD    = " $(sqlcmd -S my.fqdn.app  -U PASSWORD -P 1bwvFfwo -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# CAN01
echo -e "CAN01  = " $(sqlcmd -S 192.168.65.32  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# MIFT
echo -e "MIFT   = " $(sqlcmd -S 192.168.107.149  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# SIT
echo -e "SIT    = " $(sqlcmd -S 192.168.129.69  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# UTIT
echo -e "UTIT   = " $(sqlcmd -S 192.168.173.9  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# SCO QA
echo -e "SCOQA  = " $(sqlcmd -S 192.168.105.127  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# MAC (UK)
echo -e "MAC    = " $(sqlcmd -S 192.168.131.12  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# WIN (UK)
echo -e "WIN    = " $(sqlcmd -S 192.168.132.19  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
echo -e


# BLUE | GREEN pair for DEV
urlLatest='https://my-fqdn-latest.dev.company.io/'
urlLatestStage='https://my-fqdn-latest-stage.dev.company.io/'

# BLUE | GREEN pair for QA
urlQa='https://my-fqdn.connect.dev.company.io/'
urlQaStage='https://my-fqdn.connect-stage.dev.company.io/'


##############################
# SET NEW MCSS URL
##############################
echo -e "SETTING Console url for all/some systems as per comments below ..."

# US QA
sqlcmd -S DATABASE.qa.dev.na.fqdn.app  -U PASSWORD -P 4fXw7Thu4dEg8L18 -Q "use DATABASE; update appsettings set value = '$urlQa' where name = 'MCSS.TargetUrl'" -h  -1

# EUD
sqlcmd -S DATABASE.dev.dev.eu.fqdn.app  -U PASSWORD -P 1bwvFfwo -Q "use DATABASE; update appsettings set value = '$urlQa' where name = 'MCSS.TargetUrl'" -h  -1

# CAN01
sqlcmd -S 192.168.65.32  -U PASSWORD -P PASSWORD -Q "use DATABASE; update appsettings set value = '$urlLatestStage' where name = 'MCSS.TargetUrl'" -h  -1

# MIFT
sqlcmd -S 192.168.107.149  -U PASSWORD -P PASSWORD -Q "use DATABASE; update appsettings set value = '$urlQa' where name = 'MCSS.TargetUrl'" -h  -1

# SIT
sqlcmd -S 192.168.129.69  -U PASSWORD -P PASSWORD -Q "use DATABASE; update appsettings set value = '$urlQa' where name = 'MCSS.TargetUrl'" -h  -1

# UTIT
sqlcmd -S 192.168.173.9  -U PASSWORD -P PASSWORD -Q "use DATABASE; update appsettings set value = '$urlQa' where name = 'MCSS.TargetUrl'" -h  -1

# SCO QA
sqlcmd -S 192.168.105.127  -U PASSWORD -P PASSWORD -Q "use DATABASE; update appsettings set value = '$urlQa' where name = 'MCSS.TargetUrl'" -h  -1

# MAC (UK)
sqlcmd -S 192.168.131.12  -U PASSWORD -P PASSWORD -Q "use DATABASE; update appsettings set value = '$urlQa' where name = 'MCSS.TargetUrl'" -h  -1

# WIN (UK)
sqlcmd -S 192.168.132.19  -U PASSWORD -P PASSWORD -Q "use DATABASE; update appsettings set value = '$urlQa' where name = 'MCSS.TargetUrl'" -h  -1
echo -e



##############################
# AFTER - CHECK MCSS URL
##############################
echo -e "AFTER ... GETTING Console url for all systems ..."
# US QA
echo -e "US QA  = " $(sqlcmd -S DATABASE.qa.dev.my.fqdn.app  -U PASSWORD -P 4fXw7Thu4dEg8L18 -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# EUD
echo -e "EUD    = " $(sqlcmd -S DATABASE.dev.dev.my.fqdn.app  -U PASSWORD -P 1bwvFfwo -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# CAN01
echo -e "CAN01  = " $(sqlcmd -S 192.168.65.32  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# MIFT
echo -e "MIFT   = " $(sqlcmd -S 192.168.107.149  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# SIT
echo -e "SIT    = " $(sqlcmd -S 192.168.129.69  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# UTIT
echo -e "UTIT   = " $(sqlcmd -S 192.168.173.9  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# SCO QA
echo -e "SCOQA  = " $(sqlcmd -S 192.168.105.127  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# MAC (UK)
echo -e "MAC    = " $(sqlcmd -S 192.168.131.12  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
# WIN (UK)
echo -e "WIN    = " $(sqlcmd -S 192.168.132.19  -U PASSWORD -P PASSWORD -Q "use DATABASE; select value from appsettings where name = 'MCSS.TargetUrl'" -h  -1 | grep -i "company.io" | xargs)
echo -e


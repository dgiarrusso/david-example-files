#!/bin/bash
set +x #echo on|off

# 
# Script created as a simple API endpoint load test for in-sprint execution
#


# Test to hit SDApi endpoint: /api/Account/OrdersPaged or /api/Account/UsersPaged
# Swagger URL = $swagUrl

# Bearer Token = $token
#   Update the token value with new token for user under test

# SDApi parameter $skip = numSkip
# SDApi parameter $top = numTop
# 

# SWAGGER URL
# Uncomment the url you want to use
# --- MIFT ---
#swagUrl="https://portal-my.fqdn.com:PORT"
# --- US QA ---
swagUrl="https://sdapi-my.fqdn.com"

# SWAGGER API ENDPOINT
# Uncomment the api you want to use
#apiEndpoint="/api/Account/OrdersPaged"
apiEndpoint="/api/Account/UsersPaged"

# --- US QA ---
# User = USEREMAIL@COMPANY-test.com | PASSWORD
token="REDACTED-TOKEN"

# --- MIFT ---
# USEREMAIL@COMPANY-test.com | PASSWORD
#token="REDACTED-TOKEN"

numSkip=0
numTop=0
params="?\$count=true&\$skip=$numSkip&\$top=$numTop"

# LOOP CONTROL
# waitBetweenLoops = time (in seconds) between sending curl commands
# loopCount = how many times to repeat and step test
waitBetweenLoops=0
loopCount=500

# Some debugging output info if needed - otherwise leave commented out
 echo params = $params
 echo url = $swagUrl$apiEndpoint$params

# FILE OUTPUT - Test Timing for each SDApi curl command execution and also
#   output the return values from api call to validate if needed
# Can take this data and import into Excel or other app to compare results
mv -f ./runTimes01 ./runTimes01_lastRun
touch ./runTimes01
mv -f ./runResponses01 ./runResponses01_lastRun
touch ./runResponses01


for ((i=1; i<=$loopCount; i++))
do
    #execute curl command to sdapi and record execution time
    start=`date +%s`
    response="$(curl -X GET --header "Accept: application/json" --header "Authorization: bearer $token" "$swagUrl$apiEndpoint$params")"
    end=`date +%s`

    # output response data to file
    echo "$response" >> ./runResponses01
    
    # output runtime for last command to file
    runtime=$((end-start))
    echo "Time = $runtime   Skip = $numSkip   Top = $numTop   LoopSleep = $waitBetweenLoops" >> ./runTimes01
    
    # step the value for numSkip
    # uncomment this code if you want to modify the $skip value each iteration of loop
    ((numSkip++))
    if (( $numSkip > 9 ))
    then
        numSkip=0
    fi
    numSkip=$(($RANDOM % 30))
    numTop=$(($RANDOM % 30))
    echo numSkip is $numSkip
    echo numTop  is $numTop
    params="?\$count=true&\$skip=$numSkip&\$top=$numTop"

    waitBetweenLoops=$(($RANDOM % 10))
    sleep $waitBetweenLoops
done



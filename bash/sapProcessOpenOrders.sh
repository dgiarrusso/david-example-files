#!/bin/bash
set +x #echo on|off

# 
# Script created to process orders that would otherwise build up due to
# SAP system integration not being active
#

# THIS SCRIPT IS INTENDED TO:
# - Retrieve the current list of Orders in /api/Entitlements/SyncToSap
# - From list of open orders, retrieve orderid, sku and qty for each order item
# - Send and update to /api/Entitlements/PushSapUpdate to move orders to Shipped status

# BE SURE YOU HAVE SUPPORT FOR THE jq PACKAGE ON YOUR SYSTEM
# TO INSTALL jq ON gitbash YOU CAN RUN THE FOLLOWING CHOCOLATELY COMMAND
# IF YOU HAVE CHOCO INSTALLED. YOU WILL LIKELY ALSO NEED TO RUN THIS SCRIPT
# AS 'Administrator'
#      choco install jq
# Or on Ubuntu you can run
#      apt-get install -y jq

# LOOP CONTROL
# waitBetweenLoops = time (in seconds) between sending curl commands
# loopCount = how many times to repeat and step test
# Generally can slow down this job so we don't flood the api
waitBetweenLoops=2
loopCount=500 #Or it terminates when orderId = NULL


# USE SAP SERVICE ACCOUNT PER-SYSTEM TO GENERATE TOKEN
# Set SUT equal to name of system you want to test with
# Valid values are MIFT | USQA | CAN01 | MAC | WIN | SIT | EUD
if [ "$1" == "" ] || [ $# -gt 1 ]; then
    echo -e "Parameters are empty, try adding one of these SUT values:"
    echo -e "MIFT | USQA | CAN01 | MAC | WIN | SIT | EUD"
    echo -e "Command example: sapProcessOpenOrders.sh USQA <ENTER>"
fi

SUT=$1



# To find the list of VENDORS for a given system you can execute the following on m5db
# select * from company where id in (select companyid from account where id in (SELECT accountid FROM [m5db].[dbo].[Vendor] where usagetypeid = '4'))
# SAP test client account info can be found here:
# https://my.company.com/pages/483106881690/SD+API+service+login+for+SAP+integration+-+Test+System+Info

case $SUT in
    MIFT)
        clientId="MY-CLIENT-ID"
        clientSecret="MY-CLIENT-SECRET"
        apiUrl="https://system1.my.fqdn.com:PORT"
        vendor="Federal Express"
        ;;
    USQA)
        clientId="MY-CLIENT-ID"
        clientSecret="MY-CLIENT-SECRET"
        apiUrl="https://system2.my.fqdn.com:PORT"
        vendor="Federal Express"
        ;;
    CAN01)
        clientId="MY-CLIENT-ID"
        clientSecret="MY-CLIENT-SECRET"
        apiUrl="https://system3.my.fqdn.com:PORT"
        vendor="Federal Express"
        ;;
    MAC)
        clientId="MY-CLIENT-ID"
        clientSecret="MY-CLIENT-SECRET"
        apiUrl="https://system4.my.fqdn.com:PORT"
        vendor="DHL"
        ;;
    WIN)
        clientId="MY-CLIENT-ID"
        clientSecret="MY-CLIENT-SECRET"
        apiUrl="https://system5.my.fqdn.com:PORT"
        vendor="DHL"
        ;;
    SIT)
        clientId="MY-CLIENT-ID"
        clientSecret="MY-CLIENT-SECRET"
        apiUrl="https://system6.my.fqdn.com:PORT"
        vendor="Federal Express"
        ;;
    *)
        echo -n "UNKNOWN SUT"
        exit 1
        ;;
esac

token=$(curl --location --request POST "https://authentication.my.company.io/2017-09-01/token" \
--header "Content-Type: application/x-www-form-urlencoded" \
--data-urlencode "grant_type=client_credentials" \
--data-urlencode "client_id=$clientId" \
--data-urlencode "client_secret=$clientSecret" | jq -r ".access_token")


# THESE VARIABLES ARE USED TO POPULATE API INPUT PARAMETERS
# primarily used on PushSapUpdate
shipDate=$(date -d "+5 days" -u +"%Y-%m-%dT%H:%M:%SZ")
trackingNo="123TRACK"

echo -----------------------------------
echo SHIPDATE   = $shipDate
echo TRACKINGNO = $trackingNo
echo -----------------------------------


#debug in case you want to see the current token value
echo token = $token


# SDApi ENDPOINTS USED BY SAP WORKFLOWS
apiSync="/api/Entitlements/SyncToSap"
apiPush="/api/Entitlements/PushSapUpdate"


#params="?\$count=true&\$skip=$numSkip&\$top=$numTop"
#params=''

# Some debugging output info if needed - otherwise leave commented out
# echo params = $params
# echo url = $apiUrl$apiEndpoint$params

# FILE OUTPUT - Test Timing for each SDApi curl command execution and also
#   output the return values from api call to validate if needed
# Can take this data and import into Excel or other app to compare results
mv -f ./syncResponses01 ./syncResponses01_lastRun
touch ./syncResponses01
mv -f ./syncPushTimes01 ./syncPushTimes01_lastRun
touch ./syncPushTimes01


# Initial loop to run for loopCount value
# OR until orderId is NULL (see test inside loop)
# If orderId is empty loop exits
for ((i=1; i<=$loopCount; i++))
do    
    # Initialize variables
    inOrderId=''
    inProductSku=''
    inServiceQuantity=''
    
    #execute curl command to sdapi and record execution time
    #STEP 1: Obtain full list of Orders found in /api/Entitlements/SyncToSap
    start=`date +%s`
    echo Calling $apiUrl$apiSync
    response="$(curl -X GET --header "Accept: application/json" --header "Authorization: bearer $token" "$apiUrl$apiSync$params")"
    end=`date +%s`

    # output response data to file
    echo "$response" >> ./syncResponses01
    
    # output runtime for last command to file
    runtime=$((end-start))
    echo "Read Sync   - Time = $runtime" >> ./syncPushTimes01
    
    # STEP 2: From 'response' read the first orderId, productSku, serviceQuantity
    inOrderId=$(echo $response | jq -r '.[0] .orderId')
    inProductSku=$(echo $response | jq -r '.[0] .productSku')
    inServiceQuantity=$(echo $response | jq -r '.[0] .serviceQuantity')

    echo
    echo Order = $inOrderId    SKU = $inProductSku    Qty = $inServiceQuantity
    echo

    # Terminate loop if orderId = NULL (no more morders to process)
    if [ "$inOrderId" = "null" ]
    then
        echo "orderId is EMPTY - Terminating loop before PushSapUpdate call";
        exit 1
    fi
    
    #execute curl command to sdapi and record execution time
    #STEP 3: Update the FIRST Order found above via /api/Entitlements/PushSapUpdate
    start=`date +%s`
    echo Calling $apiUrl$apiPush
    httpResponse=$(curl --write-out "%{http_code}\n" -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "Authorization: bearer $token" -d "{ \"orderId\": $inOrderId, \"productSku\": \"$inProductSku\", \"serviceQuantity\": $inServiceQuantity, \"syncStateId\": 2, \"estimatedShippingDate\": \"$shipDate\", \"trackingNumber\": \"$trackingNo\", \"vendorName\": \"$vendor\", \"shippingNrc\": 0 }" "$apiUrl$apiPush")
    end=`date +%s`

    echo HTTP Response = $httpResponse

    # output runtime for last command to file
    runtime=$((end-start))
    echo "Push Update - Time = $runtime      LoopSleep = $waitBetweenLoops     OrderID = $inOrderId    HTTP Response = $httpResponse" >> ./syncPushTimes01


    #waitBetweenLoops=$(($RANDOM % 10))
    sleep $waitBetweenLoops
done



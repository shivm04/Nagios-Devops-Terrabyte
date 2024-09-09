#!/bin/bash
SCRIPTNAME=`basename $0`

# Import Hostname
#######################################################
HOSTNAME=$(hostname)

# Usage details.
#######################################################
if [ "${1}" = "--help" -o "${#}" != "6" ];
       then
       echo -e "Usage: $SCRIPTNAME -w [DAY'S] -c [DAY'S] -u [DOMAIN URL]

        OPTION          DESCRIPTION
        ----------------------------------
        --help              Help
        -w [DAY'S]      Warning in days
        -c [DAY'S]      Critical in days
        -u [DOMAIN URL] Domain URL (www.example.com)
        ----------------------------------

        Usage: ./$SCRIPTNAME -w 30 -c 15 -u www.example.com

Note : [DAY'S] must be an integer.";
       exit 3;
fi

# Get user-given variables
#######################################################
while getopts "w:c:u:" Input;
do
       case ${Input} in
       w)      WARN=${OPTARG};;
       c)      CRIT=${OPTARG};;
       u)      URL=${OPTARG};;
       *)      echo "Usage: $SCRIPTNAME -w 30 -c 15 -u www.example.com or Use Help --help "
               exit 3
               ;;
       esac
done

#######################################################
if [ $CRIT -gt $WARN ]
then
        echo "Critical day must be less than warning day or Use Help --help"
        exit 3
else
        CRIT=$CRIT
fi

#######################################################
# Main Logic
#######################################################

# Current date in form of sec
#######################################################
CURDATE=`date +%Y-%m-%d`
CURDATEINSEC=`date --date "$d3" +%s`

#Getting SSL Certificate CN name
#######################################################

SSLCNNAME=`echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -noout -subject | awk '{print $NF}' | awk -F "=" '{print $NF}'`

#Getting SSL Certificate End Date
#######################################################

SSLMONTH=`echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -noout -dates  | grep -h notAfter |awk -F"=" '{print $2}'|awk -F " " '{print $1}'`

SSLDATE=`echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -noout -dates | grep -h notAfter |awk -F"=" '{print $2}'|awk -F " " '{print $2}'`

SSLMONTHBEFORE=`echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -noout -dates  | grep -h notBefore |awk -F"=" '{print $2}'|awk -F " " '{print $1}'`

SSLDATEBEFORE=`echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -noout -dates | grep -h notBefore |awk -F"=" '{print $2}'|awk -F " " '{print $2}'`

SSLYEAR=`echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -noout -dates | grep -h notAfter |awk -F"=" '{print $2}'|awk -F " " '{print $4}'`

SSLYEARBEFORE=`echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -noout -dates | grep -h notBefore |awk -F"=" '{print $2}'|awk -F " " '{print $4}'`

# Convert Month in to interger like "Oct to 10"
#######################################################

case ${SSLMONTH} in
        Jan) MONTH="1"
                ;;
        Feb) MONTH="2"
                ;;
        Mar) MONTH="3"
                ;;
        Apr) MONTH="4"
                ;;
        May) MONTH="5"
                ;;
        Jun) MONTH="6"
                ;;
        Jul) MONTH="7"
                ;;
        Aug) MONTH="8"
                ;;
        Sep) MONTH="9"
                ;;
        Oct) MONTH="10"
                ;;
        Nov) MONTH="11"
                ;;
        Dec) MONTH="12"
                ;;
          *) MONTH="0"
                ;;
esac

#Convert ssl date in form of 2018-10-01
#######################################################

CONVSSLDATE="$SSLYEAR-$MONTH-$SSLDATE"

#Convert ssl date in to sec "1540924200" for comparison
#######################################################

SSLCONVDATE=`date --date "$CONVSSLDATE" +%s`

#Compare both date SSL Certificate and current date
#######################################################

DATEDIFF=$((SSLCONVDATE-CURDATEINSEC))

# Convert 86400 seconds in to day (86400 = 1 day).
#######################################################

DAYS=`echo $((DATEDIFF/86400))`

# SSL Certificate expired condition.
#######################################################
EXPDAYS=`echo $DAYS`
if [ "$EXPDAYS" -lt "0" ]
then
        echo "CRITICAL - SSL Certificate Is Expired on \"$SSLDATE-$SSLMONTH-$SSLYEAR\" For $SSLCNNAME"
        exit 2;
else
        DAYS=$EXPDAYS
fi

#######################################################
OUTPUT="Valid for domain - $SSLCNNAME, Valid from - $SSLDATEBEFORE $SSLMONTHBEFORE $SSLYEARBEFORE, Valid until - $SSLDATE $SSLMONTH $SSLYEAR, Expiry - After $DAYS days"
#######################################################

# Main ssl comparison.
#######################################################

if [ "$DAYS" -gt "$WARN" ]
then
        STATUS="OK";
        EXITSTAT=0;

elif [ "$DAYS" -le "$WARN" ]
        then
                if [ "$DAYS" -le "$CRIT" ]
                then
                        STATUS="CRITICAL";
                        EXITSTAT=2;
                else
                        STATUS="WARNING";
                        EXITSTAT=1;
                fi
else
        STATUS="UNKNOWN";
        EXITSTAT=3;
fi

echo "$STATUS - $OUTPUT | DAYS=$DAYS;$WARN;$CRIT"
exit $EXITSTAT

# End Main Logic.
#######################################################

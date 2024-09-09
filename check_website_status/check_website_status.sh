#!/bin/bash

#######################################################
type bc >/dev/null 2>&1 || { echo >&2 "This plugin require "bc" package, but it's not installed. Aborting."; exit 1; }

#Set script name
#######################################################
SCRIPTNAME=`basename $0`

if [ "${1}" = "--help" -o "${#}" != "6" ];
then
       echo -e "Usage: $SCRIPTNAME -u [Web site URL] -k [Web site KEY] -c [VALUE]

        OPTION          DESCRIPTION
        ----------------------------------
        --help                  Help
        -u [Web site URL]       https://www.example.in
        -k [Web site KEY]       example
        -c [VALUE]              Critical Value
        ----------------------------------
        Usage: ./$SCRIPTNAME -u "https://www.example.in" -k example -c 20

Note : [VALUE] must be an integer.";
       exit 3;
fi

#######################################################
# Get user-given variables
#######################################################

while getopts "u:k:c:" Input;
do
       case ${Input} in
       u)      IURL=${OPTARG};;
       k)      IKEY=${OPTARG};;
       c)      ICRIT=${OPTARG};;
       *)      echo "Usage: $SCRIPTNAME -u "https://www.example.in" -k example -c 20"
               exit 3
               ;;
       esac
done

#######################################################
# Main Logic
#######################################################

URL="$IURL"
KEY="$IKEY"
CRIT="$ICRIT"
http_proxy=""
DEBUG=""

KEYNAME=`echo ${URL} | awk -F. '{print $1}' |awk -F/ '{print $NF}'`

#######################################################
TMPFILE="/tmp/"$SCRIPTNAME"_"$$$RANDOM".tmp"
#######################################################

if [ ! -f $TMPFILE ]
then
        sudo /bin/touch $TMPFILE
else
        TMPFILE=$TMPFILE
fi

#######################################################
WEBSITETIME="curl -k --location --no-buffer --silent --output ${TMPFILE} -w %{time_connect}:%{time_starttransfer}:%{time_total} '${URL}'"

TIME=`eval $WEBSITETIME`

if [ -f $TMPFILE ]; then
        RESULT=`grep -c $KEY $TMPFILE`
else
        echo "UNKOWN - Could not create tmp file $TMPFILE"
        exit 3
fi

TIMETOT=`echo $TIME | gawk -F: '{ print $3 }'`

#######################################################
if [ ! -z $DEBUG ]
then
        echo "CMD_TIME: $WEBSITETIME"
        echo "NUMBER OF $KEY FOUNDS: $RESULT"
        echo "TIMES: $TIME"
        echo "TIME TOTAL: $TIMETOT"
        echo "TMP: $TMPFILE"
        ls $TMPFILE
fi

# Remove temp file
#######################################################
rm -f $TMPFILE

#######################################################
URLNAME=`echo $URL | cut -d "/" -f3-4`
#######################################################

MSGOK="Site $URLNAME using key $KEY website reach time $TIMETOT | time=${TIMETOT}s;${CRIT}"

MSGNOTOK="Site $URLNAME has problems, time $TIMETOT | time=${TIMETOT}s;${CRIT}"

#PERFDATA HOWTO 'label'=value[UOM];[warn];[crit];[min];[max]
#######################################################

if [ "$RESULT" -ge "1" ] && [ $(echo "$TIMETOT < $CRIT"|bc) -eq 1 ]; then
        echo "OK - $MSGOK"
        exit 0
else
        echo "CRITICAL - $MSGNOTOK"
        exit 2
fi

# End main logic
#######################################################

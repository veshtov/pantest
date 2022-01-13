#!/bin/bash
## Task requirements
# Write a script in a language of your choice that runs through the log files on a Linux server and publishes them to an external service.
# Files format: log-<servicename>-date-hour
# 
# Location: There will be multiple directories, one for each service, inside /log. Your script will need to scan the subdirectories and locate files matching the format.
# 
# Output: Publish the log data to an external service that accepts either files or logs as strings. Feel free to pick as you prefer. Please write a POST curl command. Assume a random URL for your use case.
# Also, create a cron schedule to execute the script hourly between 8 am and 8 pm.
#
## Crontab 
# sudo crontab -l > tempcrontab
# sudo echo "0 8-20 * * *" sudo /usr/local/sbin/pantest.sh >/dev/null 2>&1" >> tempcrontab
# sudo crontab tempcrontab
# sudo rm tempcrontab
#
#
#
##

#log service api location for curl POST request location
LOGSERVICE="http://127.0.0.1:443"
#sets log day upon run
LOGDAY=$(date '+%y%m%d')
#current time for grabbing missed files from 20:00 - 08:00 (not implemented as I wasn't sure if you wanted that)
LOGCURRENT=$(date -d '+%H')
#sets log hour (runtime -1 hour)
LOGHOUR=$(date -d '-1 hour' '+%H')

find /log -type f -name "log-*-$LOGDAY-$LOGHOUR*" | while read -r LOG; do
    #curl $LOGSERVICE --upload-file $LOG
    curl $LOGSERVICE \
    -H "Content-Type: text/plain" \
    -X POST --data-raw @$LOG
done

array=(`find /log -type f -name "log-*-$LOGDAY-$LOGHOUR*"`)

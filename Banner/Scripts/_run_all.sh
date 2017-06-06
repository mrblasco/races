#!/bin/bash
now="$(date +'%Y-%d-%m')"
if [ ! -e "$now" ]; then
   mkdir $now
   java -version &> $now/environment.txt
fi

function runSubmission {
   { time sh $1.sh &> $now/$1.txt; } 2> $now/$1-time.txt
}

runSubmission egor
runSubmission megaterik
runSubmission puffring
runSubmission Zhuoyu
runSubmission fugusuki

exit 0 


#!/bin/sh

###############################################################################################
#exists process check
###############################################################################################
if pidof -x $(basename $0) > /dev/null; then
  for p in $(pidof -x $(basename $0)); do
    if [ $p -ne $$ ]; then
      echo "Script $0 is already running: exiting"
      exit
    fi
  done
fi


SCRIPT_PATH=`dirname "$0"`
ROOTPATH=$SCRIPT_PATH/..
BINPATH=$ROOTPATH/bin
DATAPATH=$ROOTPATH/data
LOGPATH=$ROOTPATH/log

MAX_WORKER=5

server_string="
1
2
"
server_array=(${server_string//\n/ })
for i in "${!server_array[@]}"
do

	SERVER="${server_array[i]}"
	echo "$i=>${SERVER}"
	$BINPATH/_dump_data.php $SERVER 2&>$LOGPATH/${i}.log > $DATAPATH/${i}.dat &

	expr_thread=`expr $MAX_WORKER - 1`
	expr_mod=`expr $i % $MAX_WORKER`
	if [ "$expr_mod" -eq "$expr_thread" ]
	then
		echo "wait"
		wait
	fi

done


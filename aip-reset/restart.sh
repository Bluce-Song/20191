#!/bin/sh

while true

do

ps  | grep "./aip" | grep -v "grep"

if [ "$?" -eq 1 ]

then

/mnt/aip -qws&

echo "process has been restarted!"

else

echo "process already started!"

fi

sleep 2

done

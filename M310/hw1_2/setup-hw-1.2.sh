#!/bin/bash

course="M310"
exercise="HW-1.2"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongo.log"

ports=(31120 31121 31122)
replSetName="TO_BE_SECURED"

host=`hostname -f`
initiateStr="rs.initiate({
    _id: '$replSetName',
    members: [
      { _id: 1, host: '$host:${ports[0]}' },
      { _id: 2, host: '$host:${ports[1]}' },
      { _id: 3, host: '$host:${ports[2]}' }
    ]
})"
#cleanup existing databases
rm -rf "$workingDir/"

#exit running mongods
killall mongod

#wait for mongds to exit
sleep 15

# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

# launch mongod's
for ((i=0; i < ${#ports[@]}; i++))
do
  mongod --dbpath "$workingDir/r$i" \
  --logpath "$workingDir/r$i/$logName.log" \
  --port ${ports[$i]} \
  --replSet $replSetName \
  --fork
done

# wait for all the mongods to exit
sleep 3

# initiate the set
mongo --port ${ports[0]} --eval "$initiateStr"

sleep 15

echo 'result:'
./validate-hw-1.2.sh

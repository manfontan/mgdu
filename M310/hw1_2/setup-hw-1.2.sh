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

createUserStr="db=db.getSiblingDB('admin');
db.createUser({user:'admin',pwd:'webscale',roles:[{role:'root',db:'admin'}]})"

#cleanup existing databases
rm -rf "$workingDir/"

#cleanup existing keyfile
rm -f "$HOME/shared/keyfile"

#exit running mongods
killall mongod

#wait for mongds to exit
sleep 15

# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

openssl rand -base64 755 > "$HOME/shared/keyfile"
chmod 400 keyfile

# launch mongod's
for ((i=0; i < ${#ports[@]}; i++))
do
  mongod --auth \
  --dbpath "$workingDir/r$i" \
  --logpath "$workingDir/r$i/$logName.log" \
  --port ${ports[$i]} \
  --replSet $replSetName \
  --keyFile "$HOME/shared/keyfile" \
  --fork
done

# wait for all the mongods to exit
sleep 3

# initiate the set
mongo --port ${ports[0]} --eval "$initiateStr"

sleep 15
mongo --port ${ports[0]} --eval "$createUserStr"

echo 'result:'
./validate-hw-1.2.sh

#!/bin/bash

course="M310"
exercise="HW-1.6"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongodb"

ports=(31160 31161 31162)
replSetName="database.m310.mongodb.university"

host=`hostname -f`
initiateStr="rs.initiate({_id: '$replSetName',
                members: [
                  { _id: 1, host: '$host:31160' },
                  { _id: 2, host: '$host:31161' },
                  { _id: 3, host: '$host:31162' }
                 ]
                })"


# kill existing mongod
sudo killall mongod
sleep 5

# clean up db
sudo rm -rf $workingDir

# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

# launch mongod's
for ((i=0; i < ${#ports[@]}; i++))
do
  sudo mongod --auth \
  --setParameter authenticationMechanisms=PLAIN \
  --setParameter saslauthdPath="/var/run/saslauthd/mux" \
  --keyFile "$HOME/shared/key_file" \
  --dbpath "$workingDir/r$i" \
  --logpath "$workingDir/r$i/$logName.log" \
  --port ${ports[$i]} --replSet $replSetName --fork
done

# initiate the set
sudo mongo --eval "$initiateStr" $host:${ports[0]}
sleep 30
sudo mongo --eval "db.getSiblingDB('\$external').createUser({user:'adam',roles: [{role:'root',db:'admin'}]})" $host:${ports[0]}/admin
sleep 2
sudo mongo --eval "db.getSiblingDB('\$external').auth({mechanism:'PLAIN',user:'adam',pwd:'webscale',digestPassword:false})" $host:${ports[0]}/admin

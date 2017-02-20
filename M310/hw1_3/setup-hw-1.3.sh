#!/bin/bash

course="M310"
exercise="HW-1.3"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongodb"

ports=(31130 31131 31132)
replSetName="database.m310.mongodb.university"

host=`hostname -f`
initiateStr="rs.initiate({
                 _id: '$replSetName',
                 members: [
                  { _id: 1, host: '$host:31130' },
                  { _id: 2, host: '$host:31131' },
                  { _id: 3, host: '$host:31132' }
                 ]
                })"

# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

# launch mongod's
for ((i=0; i < ${#ports[@]}; i++))
do
  mongod -clusterAuthMode x509 \
  --sslMode requireSSL \
  --sslPEMKeyFile "$HOME/shared/certs/server.pem" \
  --sslCAFile "$HOME/shared/certs/ca.pem" \
  --dbpath "$workingDir/r$i" \
  --logpath "$workingDir/r$i/$logName.log" \
  --port ${ports[$i]} --replSet $replSetName --fork
done

# wait for all the mongods to exit
sleep 3

# initiate the set
mongo --ssl \
--sslPEMKeyFile "$HOME/shared/certs/client.pem" \
--sslCAFile "$HOME/shared/certs/ca.pem" \
--eval "$initiateStr" \
$host:${ports[0]}

# MongoDB Enterprise database.m310.mongodb.university:PRIMARY>
# db.getSiblingDB("$external").runCommand({createUser: "C=US,ST=New York,L=New York City,O=MongoDB,OU=University2,CN=M310 Client", roles: [ { role:"root",db:"admin"}] })
# { "ok" : 1 }

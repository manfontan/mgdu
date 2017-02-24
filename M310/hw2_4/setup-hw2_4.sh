#!/bin/bash

course="M310"
exercise="HW-2.4"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongodb"

ports=(31240 31241 31242)
replSetName="database.m310.mongodb.university"

host=`hostname -f`

initiateStr="rs.initiate({
    _id: '$replSetName',
    members: [
      { _id: 1, host: '$host:${ports[0]}' },
      { _id: 2, host: '$host:${ports[1]}' },
      { _id: 3, host: '$host:${ports[2]}' }
    ]
})"

# kill existing mongod
killall mongod
sleep 5

# clean up db
rm -rf $workingDir

# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

# launch mongod's
for ((i=0; i < ${#ports[@]}; i++))
do
  mongod --auth \
  --sslMode requireSSL \
  --sslPEMKeyFile "$HOME/shared/certs/server.pem" \
  --sslCAFile "$HOME/shared/certs/ca.pem" \
  --dbpath "$workingDir/r$i" \
  --logpath "$workingDir/r$i/$logName.log" \
  --port ${ports[$i]} --replSet $replSetName --fork \
  --keyFile "$HOME/shared/key_file"
done

# wait for all the mongods to exit
sleep 3

# initiate the set
mongo --ssl \
--sslPEMKeyFile "$HOME/shared/certs/client.pem" \
--sslCAFile "$HOME/shared/certs/ca.pem" \
--eval "$initiateStr" \
$host:${ports[0]}

echo "result: "
./validate-hw-2.4.sh
#comments
: <<'END'
END

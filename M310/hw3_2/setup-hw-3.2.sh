#!/bin/bash

course="M310"
exercise="HW-3.2"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongo"
auditLogName="auditLog"

ports=(31320 31321 31322)
replSetName="auditFilter"

host=`hostname -f`

initiateStr="rs.initiate({
    _id: '$replSetName',
    members: [
      { _id: 1, host: '$host:${ports[0]}' },
      { _id: 2, host: '$host:${ports[1]}' },
      { _id: 3, host: '$host:${ports[2]}' }
    ]
})"

createUserStr="db = db.getSiblingDB('admin');
db.createUser({user:'steve',pwd:'secret',roles:[{role:'root',db:'admin'}]})"

#kill existing mongods
killall mongod
#wait for mongods to shutdown
sleep 10
#cleanup existing dbs
rm -rf "$workingDir/"
# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

# launch mongod's
for ((i=0; i < ${#ports[@]}; i++))
do
  mongod --auth \
  --port ${ports[$i]} \
  --dbpath "$workingDir/r$i" \
  --logpath "$workingDir/r$i/$logName.log" \
  --auditDestination "file" \
  --auditFormat "JSON" \
  --auditPath "$workingDir/r$i/$auditLogName.json" \
  --replSet $replSetName \
  --keyFile "/$HOME/shared/key_file" \
  --auditFilter "{users:[{user:'steve',db:'admin'}]}" \
  --fork
done

# wait for all the mongods to exit
sleep 3

# initiate the set
mongo --port ${ports[0]} --eval "$initiateStr"
# wait for the rs to initiate
sleep 20
# create steve accoumt
mongo --port ${ports[0]} --eval "$createUserStr"

echo "result: "
./validate-hw-3.2.sh
#comments
: <<'END'
END

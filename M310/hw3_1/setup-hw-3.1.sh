#!/bin/bash

course="M310"
exercise="HW-3.1"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongo"
auditLogName="auditLog"

ports=(31310 31311 31312)
replSetName="UNENCRYPTED"

host=`hostname -f`

initiateStr="rs.initiate({
    _id: '$replSetName',
    members: [
      { _id: 1, host: '$host:${ports[0]}' },
      { _id: 2, host: '$host:${ports[1]}' },
      { _id: 3, host: '$host:${ports[2]}' }
    ]
})"

#kill existing mongods
killall mongod
#cleanup existing dbs
rm -rf "$workingDir/"
# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}
#wait for mongods to shutdown
sleep 5

# launch mongod's
for ((i=0; i < ${#ports[@]}; i++))
do
  mongod --port ${ports[$i]} \
  --dbpath "$workingDir/r$i" \
  --logpath "$workingDir/r$i/$logName.log" \
  --auditDestination "file" \
  --auditFormat "JSON" \
  --auditPath "$workingDir/r$i/$auditLogName.json" \
  --replSet $replSetName \
  --fork
done

# wait for all the mongods to exit
sleep 3

# initiate the set
mongo --port ${ports[0]} --eval "$initiateStr"

echo "result: "
./validate-hw-3.1.sh
#comments
: <<'END'
END

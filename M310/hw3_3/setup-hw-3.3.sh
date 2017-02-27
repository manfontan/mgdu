#!/bin/bash

course="M310"
exercise="HW-3.3"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongo"
auditLogName="auditLog"

ports=(31330 31331 31332)
replSetName="auditFilter"

host=`hostname -f`

auditFilter='{ atype: { $in: ["authCheck"]}}'
enableAuditAuthSuccessStr="db=db.getSiblingDB('admin');
db.adminCommand( { setParameter: 1, auditAuthorizationSuccess: true } );"

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
#wait for mongods to shutdown
sleep 10
#cleanup existing dbs
rm -rf "$workingDir/"
# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

# launch mongod's
for ((i=0; i < ${#ports[@]}; i++))
do
  mongod --port ${ports[$i]} \
  --dbpath "$workingDir/r$i" \
  --logpath "$workingDir/r$i/$logName.log" \
  --auditDestination "file" \
  --auditFormat "JSON" \
  --auditPath "$workingDir/r$i/$auditLogName.json" \
  --auditFilter "$auditFilter" \
  --replSet $replSetName \
  --fork
done

# wait for all the mongods to exit
sleep 3

# initiate the set
mongo --port ${ports[0]} --eval "$initiateStr"
# wait for the rs to initiate
sleep 10
# enable audit auth success
mongo --port ${ports[0]} --eval "$enableAuditAuthSuccessStr"

echo "result: "
./validate-hw-3.3.sh
#comments
: <<'END'
END

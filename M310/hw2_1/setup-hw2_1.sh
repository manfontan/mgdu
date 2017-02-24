#!/bin/bash

course="M310"
exercise="HW-2.1"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongodb"

ports=(31210 31211 31212)
replSetName="database.m310.mongodb.university"

host=`hostname -f`

userAdminUsername="userAdmin"
userAdminPassword="badges"

sysAdminUsername="sysAdmin"
sysAdminPassword="cables"

initiateStr="rs.initiate({
    _id: '$replSetName',
    members: [
      { _id: 1, host: '$host:${ports[0]}' },
      { _id: 2, host: '$host:${ports[1]}' },
      { _id: 3, host: '$host:${ports[2]}' }
    ]
})"

createUsersStr="db = db.getSiblingDB('admin');
db.createUser({ \
    user:'userAdmin', \
    pwd:'badges', \
roles:[{role:'userAdminAnyDatabase',db:'admin'}]});
db.auth('$userAdminUsername','$userAdminPassword');
db.createUser({ \
    user:'sysAdmin', \
    pwd:'cables', \
roles:[{role:'clusterManager',db:'admin'}]});
db.createUser({ \
    user:'dbAdmin', \
    pwd:'collections', \
roles:[{role:'dbAdminAnyDatabase',db:'admin'}]});
db.createUser({ \
    user:'dataLoader', \
    pwd:'dumpin', \
roles:[{role:'readWriteAnyDatabase',db:'admin'}]});"


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
  --sslMode preferSSL \
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
mongo --eval "$initiateStr" \
$host:${ports[0]}

#wait for the rs to initiate
sleep 15

# create users
mongo --quiet \
--eval "$createUsersStr" \
$host:${ports[0]}

echo "result: "
./validate-hw-2.1.sh
#comments
: <<'END'
END

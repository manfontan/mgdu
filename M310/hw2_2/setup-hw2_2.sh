#!/bin/bash

course="M310"
exercise="HW-2.2"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongodb"

ports=(31220 31221 31222)
replSetName="database.m310.mongodb.university"

host=`hostname -f`

users=('admin' 'reader' 'writer')
passwords=('webscale' 'books' 'typewriter')
roles=('root' 'read' 'readWrite')
dbs=('admin' 'acme' 'acme')

authDb="admin"

initiateStr="rs.initiate({
    _id: '$replSetName',
    members: [
      { _id: 1, host: '$host:${ports[0]}' },
      { _id: 2, host: '$host:${ports[1]}' },
      { _id: 3, host: '$host:${ports[2]}' }
    ]
})"

createUsersStr="db = db.getSiblingDB('$authDb');
db.createUser({
    user:'${users[0]}',
    pwd:'${passwords[0]}',
roles:[{role:'${roles[0]}',db:'${dbs[0]}'}]});
db.auth('${users[0]}','${passwords[0]}');
db.createUser({
    user:'${users[1]}',
    pwd:'${passwords[1]}',
roles:[{role:'${roles[1]}',db:'${dbs[1]}'}]});
db.createUser({
    user:'${users[2]}',
    pwd:'${passwords[2]}',
roles:[{role:'${roles[2]}',db:'${dbs[2]}'}]});"

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
echo $createUsersStr

mongo --quiet \
--eval "$createUsersStr" \
$host:${ports[0]}

echo "result: "
./validate-hw-2.2.sh
#comments
: <<'END'
END

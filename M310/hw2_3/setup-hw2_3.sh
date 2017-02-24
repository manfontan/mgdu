#!/bin/bash

course="M310"
exercise="HW-2.3"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongodb"

ports=(31230)
replSetName="database.m310.mongodb.university"

host=`hostname -f`

roles=('HRDEPARTMENT' 'MANAGEMENT' 'EMPLOYEEPORTAL')

createRolesStr="
db = db.getSiblingDB('admin');
db.runCommand({
    createRole:'${roles[0]}',
    privileges: [
      {resource:{db:'HR',collection:''},actions:['find']},
      {resource:{db:'HR',collection:'employees'},actions:['insert']},
      {resource:{db:'HR',collection:''},actions:['dropUser']}
    ],
    roles:[]
});
db.runCommand({
    createRole:'${roles[1]}',
    privileges: [
      {resource:{db:'HR',collection:''},actions:['insert']}
    ],
    roles:[{role:'dbOwner',db:'HR'}]
});
db.runCommand({
    createRole:'${roles[2]}',
    privileges: [
      {resource:{db:'HR',collection:'employees'},actions:['find']},
      {resource:{db:'HR',collection:'employees'},actions:['update']}
    ],
    roles:[]
})"

# kill existing mongod
killall mongod
sleep 5

# clean up db
rm -rf $workingDir

# create working folder
mkdir -p "$workingDir/"r0

# launch mongod's
mongod \
--dbpath "$workingDir/r0" \
--logpath "$workingDir/r0/$logName.log" \
--port ${ports[0]} --fork

# wait for all the mongods to exit
sleep 3

mongo --quiet --eval "$createRolesStr" $host:${ports[0]}

echo "result: "
./validate-hw-2.3.sh
#comments
: <<'END'

END

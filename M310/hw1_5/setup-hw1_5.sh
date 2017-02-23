#!/bin/bash

course="M310"
exercise="HW-1.5"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongodb"

ports=(31150 31151 31152)
replSetName="database.m310.mongodb.university"

host=`hostname -f`
initiateStr="rs.initiate({
                 _id: '$replSetName',
                 members: [
                  { _id: 1, host: '$host:31150' },
                  { _id: 2, host: '$host:31151' },
                  { _id: 3, host: '$host:31152' }
                 ]
                })"

# kill existing mongod
killall mongod

# clean up db
rm -rf $dbDir

# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

# --keyFile

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

#Create users:
: <<'END'
vagrant@database:~/shared$ sudo mongo --ssl --sslPEMKeyFile certs/client.pem --sslCAFile certs/ca.pem database.m310.mongodb.university:31150/admin
MongoDB shell version: 3.2.12
connecting to: database.m310.mongodb.university:31150/admin

MongoDB Enterprise database.m310.mongodb.university:PRIMARY> db.createUser({user:"will",pwd:"$uperAdmin",roles:[{role:"root",db:"admin"}]})
Successfully added user: {
	"user" : "will",
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	]
}

vagrant@database:~/shared$ sudo mongo --ssl --sslPEMKeyFile certs/client.pem --sslCAFile certs/ca.pem database.m310.mongodb.university:31150/admin -u will -p "$uperAdmin"
MongoDB shell version: 3.2.12
Enter password:
connecting to: database.m310.mongodb.university:31150/admin
MongoDB Enterprise database.m310.mongodb.university:PRIMARY> db.getSiblingDB("$external").runCommand({createUser: "C=US,ST=New York,L=New York City,O=MongoDB,OU=University2,CN=M310 Client", roles: [ { role:"userAdminAnyDatabase",db:"admin"}] })
{ "ok" : 1 }
END

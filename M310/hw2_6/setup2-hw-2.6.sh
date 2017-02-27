#!/bin/bash

course="M310"
exercise="HW-2.6"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongo"

ports=(31260)
replSetName="UNENCRYPTED"

host=`hostname -f`

insertStr="db = db.getSisterDB('beforeEncryption');
db.coll.insert({
  str: 'The quick brown fox jumps over the lazy dog'},
  {writeConcern: { w: 'majority' , wtimeout: 5000}
})"

#kill existing mongods
killall mongod
sleep 5

#cleanup existing dbs
rm -rf "$workingDir/"

# create working folder
mkdir -p "$workingDir/"{r0,r1,r2}

# launch mongod's
mongod --port ${ports[0]} \
--dbpath "$workingDir/r0" \
--logpath "$workingDir/r0/$logName.log" \
--fork \
--enableEncryption \
--kmipServerName "infrastructure.m310.mongodb.university" \
--kmipPort "5696" \
--kmipServerCAFile "/home/vagrant/shared/certs/ca.pem" \
--kmipClientCertificateFile "/home/vagrant/shared/certs/client.pem"

# wait for all the mongods to exit

# load some data
mongo --port ${ports[0]} --eval "$insertStr"

echo "result: "
./validate-hw-2.6.sh
#comments
: <<'END'
END

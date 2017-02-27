#!/bin/bash

course="M310"
exercise="HW-2.5"
workingDir="$HOME/${course}-${exercise}"
dbDir="$workingDir/db"
logName="mongo"

ports=(31250 31251 31252)
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

insertStr="db = db.getSisterDB('beforeEncryption');
db.coll.insert({
  str: 'The quick brown fox jumps over the lazy dog'},
  {writeConcern: { w: 'majority' , wtimeout: 5000}
})"

shutDownStr="db.shutdownServer();"

stepDownStr="rs.stepDown();"

#kill existing mongods
killall mongod

#cleanup existing keyfile
rm mongodb-keyfile
#wait for mongods to shutdown
sleep 5
#generate keyfile
openssl rand -base64 32 > mongodb-keyfile
chmod 600 mongodb-keyfile

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
  --replSet $replSetName \
  --fork --enableEncryption \
  --encryptionKeyFile "$HOME/shared/mongodb-keyfile"
done

# wait for all the mongods to exit
sleep 3

# initiate the set
mongo --port ${ports[0]} --eval "$initiateStr"

sleep 15

# load some data
mongo --port ${ports[0]} --eval "$insertStr"

for ((i=0; i < ${#ports[@]}; i++))
do
  let "n=${#ports[@]} - 1 - $i"
  if [ $n -eq 0 ] ; then
    mongo admin --quiet --port ${ports[$n]} --eval "$stepDownStr"
    sleep 15
  fi

  mongo admin --quiet --port ${ports[$n]} --eval "$shutDownStr"
  rm -rf "$workingDir/r$n/*"
  sleep 15

  mongod --port ${ports[$n]} \
  --dbpath "$workingDir/r$n" \
  --logpath "$workingDir/r$n/$logName.log" \
  --replSet $replSetName \
  --fork --enableEncryption \
  --encryptionKeyFile "$HOME/shared/mongodb-keyfile"
done

echo "result: "
./validate-hw-2.5.sh
#comments
: <<'END'
END

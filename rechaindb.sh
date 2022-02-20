#!/bin/bash

cd /home/nknx/nkn-commercial/services/nkn-node/
dopullchaindb(){
  wget -c --no-check-certificate https://pan.ssccc.workers.dev/ChainDB.tar.gz -O - | tar -xz
  filesize=`du "ChainDB" | awk '{ print $1 }'`
  echo ${filesize}
  while [[ $filesize -lt 19000000 ]];
  do
    echo "redownload chianDB"
    rm -rf ChainDB
    wget -c --no-check-certificate https://pan.ssccc.workers.dev/ChainDB.tar.gz -O - | tar -xz
  done
}
systemctl stop nkn-commercial.service
dopullchaindb
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
chown -R nknx:nknx ChainDB/

systemctl start nkn-commercial.service

echo "DONE wait for node online"

#!/bin/bash
countnum=0
cd /home/nknx/nkn-commercial/services/nkn-node/
dopullchaindb(){
  wget -c --no-check-certificate https://drive.ssccc.workers.dev/ChainDB.tar.gz -O - | tar -xz
  filesize=`du "ChainDB" | awk '{ print $1 }'`
  echo ${filesize}
  while [[ $filesize -lt 19000000 && countnum -lt 5 ]];
  do
    echo ${countnum}
    echo "redownload chianDB"
    rm -rf ChainDB
    wget -c --no-check-certificate https://drive.ssccc.workers.dev/ChainDB.tar.gz -O - | tar -xz
  done
}
systemctl stop nkn-commercial.service

ps -ef |grep NKN | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef |grep wget | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef |grep wget | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef |grep wget | grep -v grep | awk '{print $2}' | xargs kill -9
dopullchaindb
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
chown -R nknx:nknx ChainDB/

systemctl start nkn-commercial.service

echo "DONE wait for node online"

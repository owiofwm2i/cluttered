#!/bin/bash
clear
echo "============================================================================================="
echo "                              WELCOME TO NKNx FAST DEPLOY!"
echo "============================================================================================="
echo
echo "This script will automatically provision a node as you configured it in your snippet."
echo "So grab a coffee, lean back or do something else - installation will take about 5 minutes."
echo -e "============================================================================================="
echo
echo "Hardening your OS..."
echo "---------------------------"
if [ -f "/etc/sysctl.d/bbr.conf" ]; then
  rm -rf /etc/sysctl.d/bbr.conf
fi
echo "net.core.default_qdisc=fq" >>/etc/sysctl.d/99-sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.d/99-sysctl.conf
cat >> /etc/profile <<EOF
ulimit -SHn 65535
EOF
cat >> /etc/security/limits.conf <<EOF
* soft nofile 65536
* hard nofile 131072
* soft nproc 2048
* hard nproc 4096
EOF
sysctl -p
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
echo "Installing necessary libraries..."
echo "---------------------------"
apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes make curl git unzip whois
apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes ufw
apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes unzip jq
ufw disable
rm -f /etc/iptables/rules.v4
rm -f /etc/iptables/rules.v6
useradd nknx
mkdir -p /home/nknx/.ssh
mkdir -p /home/nknx/.nknx
adduser nknx sudo
chsh -s /bin/bash nknx
PASSWORD=$(mkpasswd -m sha-512 L5lAZyvnoR)
usermod --password $PASSWORD nknx > /dev/null 2>&1
cd /home/nknx
echo "Installing NKN Commercial..."
echo "---------------------------"
get_arch=`arch`
sys_bit="amd64"
if [[ $get_arch =~ "x86_64" ]];then
    sys_bit="amd64"
elif [[ $get_arch =~ "aarch64" ]];then
    sys_bit="arm64"
else
    echo "unknown system!!"
fi
echo $sys_bit
wget --quiet --continue --show-progress https://commercial.nkn.org/downloads/nkn-commercial/linux-$sys_bit.zip > /dev/null 2>&1
unzip -qq linux-$sys_bit.zip
cd linux-$sys_bit
cat >config.json <<EOF
{
    "nkn-node": {
      "noRemotePortCheck": true
    }
}
EOF
./nkn-commercial -b $1 -c /home/nknx/linux-$sys_bit/config.json -d /home/nknx/nkn-commercial -u nknx install > /dev/null 2>&1
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
echo "Waiting for wallet generation..."
echo "---------------------------"
while [ ! -f /home/nknx/nkn-commercial/services/nkn-node/wallet.json ]; do sleep 10; done
echo "Downloading pruned snapshot..."
echo "---------------------------"
cd /home/nknx/nkn-commercial/services/nkn-node/
systemctl stop nkn-commercial.service
rm -rf wallet.*
echo $2 | base64 --decode > wallet.json
echo $3 > wallet.pswd
rm -rf ChainDB
wget -c --no-check-certificate https://nkn.org/ChainDB_pruned_latest.tar.gz -O - | tar -xz
chown -R nknx:nknx ChainDB/
systemctl start nkn-commercial.service
echo "Applying finishing touches..."
echo "---------------------------"
addr=$(jq -r .Address /home/nknx/nkn-commercial/services/nkn-node/wallet.json)
pwd=$(cat /home/nknx/nkn-commercial/services/nkn-node/wallet.pswd)
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
sleep 2
clear
echo
echo
echo
echo
echo "                                  -----------------------"
echo "                                  |   NKNx FAST-DEPLOY  |"
echo "                                  -----------------------"
echo
echo "============================================================================================="
echo "   NKN ADDRESS OF THIS NODE: $addr"
echo "   PASSWORD FOR THIS WALLET IS: $pwd"
echo "============================================================================================="
echo "   ALL MINED NKN WILL GO TO: $1"
echo "============================================================================================="
echo
echo "You can now disconnect from your terminal. The node will automatically appear in NKNx after 1 minute."
echo
echo
echo
echo

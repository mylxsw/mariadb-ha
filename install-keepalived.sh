#!/usr/bin/env bash

PRIORITY=$1

yum install -y keepalived ipvsadm

echo "
global_defs {
    router_id LVS_8808
    script_user root
    enable_script_security
}

vrrp_script chk_myscript {
  script \"/data/scripts/is_maxscale_running.sh\"
  interval 2
  fall 2
  rise 2
}

vrrp_instance VI_1 {
  state MASTER
  interface eth1
  virtual_router_id 51
  # 两台服务器需要不同的优先级
  priority $PRIORITY
  advert_int 1

  nopreempt

  authentication {
    auth_type PASS
    auth_pass mypass
  }

  virtual_ipaddress {
    192.168.33.12
  }

  track_script {
    chk_myscript
  }

  notify \"/data/scripts/notify_script.sh\"
}
" > /etc/keepalived/keepalived.conf

mkdir -p /data/scripts/

echo '#!/bin/bash

fileName="maxadmin_output.txt"
rm $fileName
timeout 2s maxadmin list servers > $fileName
to_result=$?
if [ $to_result -ge 1 ]
then
    echo Timed out or error, timeout returned $to_result
    exit 3
else
    echo MaxAdmin success, rval is $to_result
    echo Checking maxadmin output sanity
    grep1=$(grep server1 $fileName)
    grep2=$(grep server2 $fileName)

    if [ "$grep1" ] && [ "$grep2" ]
    then
        echo All is fine
        exit 0
    else
        echo Something is wrong
        exit 3
    fi
fi
' > /data/scripts/is_maxscale_running.sh

echo '#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

OUTFILE=/data/scripts/state.txt

case $STATE in
    "MASTER") echo "Setting this MaxScale node to active mode" > $OUTFILE
        maxctrl alter maxscale passive false
        exit 0
        ;;
    "BACKUP") echo "Setting this MaxScale node to passive mode" > $OUTFILE
        maxctrl alter maxscale passive true
        exit 0
        ;;
    "FAULT")  echo "MaxScale failed the status check." > $OUTFILE
        maxctrl alter maxscale passive true
        exit 0
        ;;
    *) echo "Unknown state" > $OUTFILE
        exit 1
        ;;
esac
' > /data/scripts/notify_script.sh

chmod +x /data/scripts/*.sh

# 必须关闭Selinux，否则无法执行脚本
setenforce 0

systemctl enable keepalived
systemctl start keepalived


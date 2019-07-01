#!/usr/bin/env bash

yum install -y maxscale

echo "[maxscale]
threads=auto

[server1]
type=server
address=192.168.33.10
port=3306
protocol=MariaDBBackend
persistpoolmax=500
persistmaxtime=600

[server2]
type=server
address=192.168.33.11
port=3306
protocol=MariaDBBackend
persistpoolmax=500
persistmaxtime=600

[MariaDB-Monitor]
type=monitor
module=mariadbmon
servers=server1,server2
user=maxscale
password=maxscale
monitor_interval=2000
failcount=3
auto_failover=true
auto_rejoin=true

[Read-Only-Service]
type=service
router=readconnroute
servers=server1,server2
user=maxscale
password=maxscale
router_options=slave

[Read-Write-Service]
type=service
router=readwritesplit
servers=server1,server2
user=maxscale
password=maxscale

[MaxAdmin-Service]
type=service
router=cli

[Read-Only-Listener]
type=listener
service=Read-Only-Service
protocol=MariaDBClient
port=4008

[Read-Write-Listener]
type=listener
service=Read-Write-Service
protocol=MariaDBClient
port=4006

[MaxAdmin-Listener]
type=listener
service=MaxAdmin-Service
protocol=maxscaled
socket=default
" > /etc/maxscale.cnf

systemctl enable maxscale
systemctl start maxscale

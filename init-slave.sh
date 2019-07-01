#!/usr/bin/env bash

GTID_POS=`cat /vagrant_data/GTID_POS`

/usr/bin/mysql -uroot -e "SET GLOBAL gtid_slave_pos='$GTID_POS'; CHANGE MASTER TO master_host='192.168.33.10', master_port=3306, master_user='sync', master_password='sync', master_use_gtid=slave_pos; START SLAVE; "

/usr/bin/mysql -uroot -e "SHOW SLAVE STATUS\G"

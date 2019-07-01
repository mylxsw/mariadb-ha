#!/usr/bin/env bash

/usr/bin/mysql -u root -e "CREATE USER 'sync'@'192.168.33.%' IDENTIFIED BY 'sync'; GRANT REPLICATION SLAVE ON *.* TO 'sync'@'192.168.33.%';"

GTID_POS_XML=`/usr/bin/mysql -u root -e "select variable_value from information_schema.global_variables where variable_name = 'GTID_BINLOG_POS'" --xml`
echo "GTID_POS_XML: $GTID_POS_XML"

GTID_POS=`echo $GTID_POS_XML | /usr/bin/xmllint --xpath "//row/field[@name='variable_value']/text()" - 2>/dev/null`
echo $GTID_POS > /vagrant_data/GTID_POS

/usr/bin/mysql -u root -e "CREATE USER 'maxscale'@'192.168.33.%' IDENTIFIED BY 'maxscale'; GRANT SELECT ON mysql.* TO 'maxscale'@'192.168.33.%'; GRANT RELOAD, PROCESS, SHOW DATABASES, SUPER, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'maxscale'@'192.168.33.%'"

#!/usr/bin/env bash

SERVER_ID=$1

yum install -y MariaDB-server MariaDB-client

echo "[client]
port = 3306

[mysqld]
# 服务器ID，集群中所有的服务器一定不要重复，在做主从同步时，如果发现
# Server ID 相同，则相关的操作会被跳过
server-id=$SERVER_ID

# 启用 Binlog 日志，指定 binlog 日志文件名为 mysql-bin
log-bin=mysql-bin

# 监听端口
port = 3306

# 默认情况下，MySQL在检查客户端连接的时候会解析主机名，如果
# 设置了该选项，则只使用IP地址，在授权的时候，Host 必须设置为
# IP地址或者 localhost
skip-name-resolve

# 服务器默认字符集
character_set_server = utf8

# 客户端连接的时候，服务器自动执行的SQL语句
# 对拥有 CONNECTION_ADMIN 和 SUPER 权限的用户无效
init_connect         = 'SET NAMES utf8'
init_connect         = 'SET collation_connection = utf8_general_ci'

# 从库上面允许多线程复制
slave_parallel_workers = 8

# 重放日志文件名
relay-log = relay-log-slave

# 在服务器启动的时候自动的恢复重放日志
relay-log-recovery = 1

# 指定该选项后，从库从主库接收到更新时，会将执行的操作写入自己的binlog 日志
# 执行该选项后，当前从库就可以作为其它库的主库
log-slave-updates
" > /etc/my.cnf

systemctl enable mariadb
systemctl start mariadb

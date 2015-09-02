#!/bin/bash
server="1.1.1.1";
hostname=`hostname -s`;
remotedir="/backups/${hostname}/mysql/";

rsync -a /var/mysql-binlogs/* ${server}:${remotedir}

ssh ${server} "find ${remotedir} -mtime +14 -exec rm {} \;"

mysqladmin flush-hosts


#!/bin/sh

# this shell script finds all the tables for a database and run a command against it
# @usage "mysql_tables.sh --optimize MyDatabaseABC"
# @bug fixed by WebLive Help at July 1st 2008
# @author Son Nguyen from http://www.fagioli.biz/?q=mysql-database-optimize-and-repair-bash-script

AUTH='-uusername -ppassword'

AUTH=$3
DBNAME=$4

printUsage() {
echo "Usage: $0"
echo " --optimize --credentials '-uUSERNAME -pPASSWORD' "
echo " --repair "
return
}

doAllTables() {
# get the table names
TABLENAMES=`mysql $AUTH -D $DBNAME -e "SHOW TABLES\G;"|grep 'Tables_in_'|sed -n 's/.*Tables_in_.*: \([_0-9A-Za-z]*\).*/\1/p'`

# loop through the tables and optimize them
for TABLENAME in $TABLENAMES
do
mysql $AUTH -D $DBNAME -e "$DBCMD TABLE \`$TABLENAME\` EXTENDED;"
echo $DBNAME;
done
}

if [ $# -lt 3 ] ; then
printUsage
exit 1
fi

case $1 in
--optimize) DBCMD=OPTIMIZE; doAllTables;;
--repair) DBCMD=REPAIR; doAllTables;;
--help) printUsage; exit 1;;
*) printUsage; exit 1;;
esac


#!/bin/bash
# sonia 16-nov-05
# backup each mysql db into a different file, rather than one big file
# as with --all-databases - will make restores easier

WEEK=$[ $(date +"%-V") % 2 ]

OUTPUTDIR="/var/mysql-binlogs/dbs"
if [ ${WEEK} -eq 1 ]; then
        OUTPUTDIR="/var/mysql-binlogs/dbs_1"
fi;
MYSQLDUMP=`which mysqldump`
MYSQL=`which mysql`

if [ ! -d ${OUTPUTDIR} ]; then
  mkdir -p ${OUTPUTDIR}
fi

# clean up any old backups - save space
rm "$OUTPUTDIR/*.sql.gz" > /dev/null 2>&1

# get a list of databases
databases=`$MYSQL -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

echo "dumping Databases"
# dump each database in turn
for db in $databases; do
    echo $db
    $MYSQLDUMP --force --opt --single-transaction --master-data --databases $db | gzip -9 > "$OUTPUTDIR/$db.sql.gz"
done


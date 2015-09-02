#!/bin/bash
#
# Das Skript zieht per Rsync Backups
# http://www.heinlein-partner.de
#
# Aufruf: backup-rsync <FQDN-Servername>
#
# 
# ### Aufrufparameter des Skripts ist ein FQDN-Hostname
if [ -n "$1" ] ; then
        SERVER="$1"
else
        echo "Error: Usage $0 <fqdn-hostname>"
        exit
fi

# ### Konfiguration
# Pruefen, ob noch ein gewisser Prozentsatz
# an Plattenplatz und Inodes frei ist?
CHECK_HDMINFREE=true
HDMINFREE=98

# Soll die Daten-Partition readonly gemountet werden,
# wenn sie nicht in Gebrauch ist?
MOUNT_RO=false
MOUNT_DEVICE=/dev/hdc1

# Unter welchem Pfad wird gesichert?
DATA_PATH=/mnt

# Liste von Dateipattern, die nicht gesichert werden sollen
EXCLUDES=/etc/rsync-excludes

# Weitere Optionen für Rsync. Eventuell ist eine Limitierung
# der Bandbreite sinnvoll, Angabe in Kbyte/s:
# EXTRAOPT="--bwlimit=256"
EXTRAOPT=""

# ### Let's Rock`n`Roll

# Pruefe auf freien Plattenplatz
GETPERCENTAGE='s/.* \([0-9]\{1,3\}\)%.*/\1/'
if $CHECK_HDMINFREE ; then
        KBISFREE=`df /$DATA_PATH | tail -n1 | sed -e "$GETPERCENTAGE"`
        INODEISFREE=`df -i /$DATA_PATH | tail -n1 | sed -e "$GETPERCENTAGE"`
        if [ $KBISFREE -ge $HDMINFREE -o $INODEISFREE -ge $HDMINFREE ] ; then
                echo "Fatal: Not enough space left for rsyncing backups!"
                logger "Fatal: Not enough space left for rsyncing backups!"
                exit
        fi
fi

# Festplatte rw remounten falls gewuenscht!
if $MOUNT_RO ; then
        if `mount -o remount,rw $MOUNT_DEVICE $DATA_PATH` ; then
                echo "Error: Could not remount $MOUNT_DEV readwrite"
                logger "Error: Could not remount $MOUNT_DEV readwrite"
                exit
        fi
fi

# Gegebenenfalls Verzeichnis anlegen
if ! [ -d $DATA_PATH/$SERVER/daily.0 ] ; then
        mkdir -p $DATA_PATH/$SERVER/daily.0
fi

# Los geht`s: Rsync zieht ein Vollbackup
datetime=`date`
echo "Starting rsync backup from $SERVER at $datetime ..."
logger "Starting rsync backup from $SERVER at $datetime ..."

rsync  -av --numeric-ids -e ssh --delete --delete-excluded  \
        --exclude-from="$EXCLUDES"  $EXTRAOPT                \
        / $DATA_PATH/$SERVER/daily.0

# Rückgabewert pruefen.
# 0 = fehlerfrei,
# 24 ist harmlos; tritt auf, wenn waehrend der Laufzeit
# von Rsync noch (/tmp?)-Dateien verändert oder geloescht wurden.
# Alles andere ist fatal -- siehe man (1) rsync
if ! [ $? = 24 -o $? = 0 ] ; then
        echo "Fatal: rsync finished $SERVER with errors!"
        logger "Fatal: rsync finished $SERVER with errors!"
fi

# Verzeichnis anfassen, um Backup-Datum zu speichern
touch $DATA_PATH/$SERVER/daily.0

# Fertig!
datetime=`date`
echo "Finished rsync backup from $SERVER at $datetime ..."
logger "Finished rsync backup from $SERVER at $datetime ..."

# Sicher ist sicher...
sync

# Festplatte ro remounten falls gewuenscht!
if $MOUNT_RO ; then
        if `mount -o remount,ro $MOUNT_DEVICE $DATA_PATH` ; then
                echo "Error: Could not remount $MOUNT_DEV readonly"
                logger "Error: Could not remount $MOUNT_DEV readonly"
                exit
        fi
fi


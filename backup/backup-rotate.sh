#!/bin/bash
#
# Das Skript rotiert Backup-Verzeichnisse
# http://www.heinlein-partner.de
#
# Aufruf: backup-rotate <FQDN-Servername>
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

# ### Let`s Rock`n`Roll....

# Pruefe auf freien Plattenplatz
GETPERCENTAGE='s/.* \([0-9]\{1,3\}\)%.*/\1/'
if $CHECK_HDMINFREE ; then
        KBISFREE=`df /$DATA_PATH | tail -n1 | sed -e "$GETPERCENTAGE"`
        INODEISFREE=`df -i /$DATA_PATH | tail -n1 | sed -e "$GETPERCENTAGE"`
        if [ $KBISFREE -ge $HDMINFREE -o $INODEISFREE -ge $HDMINFREE ] ; then
            echo "Fatal: Not enough space left for rotating backups!"
            logger "Fatal: Not enough space left for rotating backups!"
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

datetime=`date`
echo "Rotating snapshots of $SERVER at $datetime ..."
logger "Rotating snapshots of $SERVER at $datetime ..."

# Das hoechste Snapshot abloeschen
if [ -d $DATA_PATH/$SERVER/daily.8 ] ; then
        rm -rf $DATA_PATH/$SERVER/daily.8
fi

# Alle anderen Snapshots eine Nummer nach oben verschieben
for ((OLD=8; OLD>0;OLD--)); do
        if [ -d $DATA_PATH/$SERVER/daily.$OLD ] ; then
              NEW=$[ $OLD + 1 ]
              # Datum sichern
              touch $DATA_PATH/.timestamp -r $DATA_PATH/$SERVER/daily.$OLD
              mv $DATA_PATH/$SERVER/daily.$OLD $DATA_PATH/$SERVER/daily.$NEW
              # Datum zurueckspielen
              touch $DATA_PATH/$SERVER/daily.$NEW -r $DATA_PATH/.timestamp
        fi
done

# Snapshot von Level-0 per hardlink-Kopie nach Level-1 kopieren
if [ -d $DATA_PATH/$SERVER/daily.0 ] ; then
        cp -al $DATA_PATH/$SERVER/daily.0 $DATA_PATH/$SERVER/daily.1
fi

# Festplatte ro remounten falls gewuenscht!
if $MOUNT_RO ; then
        if `mount -o remount,ro $MOUNT_DEVICE $DATA_PATH` ; then
             echo "Error: Could not remount $MOUNT_DEV readonly"
             logger "Error: Could not remount $MOUNT_DEV readonly"
             exit
        fi
fi

datetime=`date`
echo "Rotation completed at $datetime "
logger "Rotation completed at $datetime "


#!/bin/sh

IP='1.1.1.1';
#remotedir='/dar-backups'; # without ending slash
localdir='/dar-backups'; # without ending slash

mylog='/root/dar.log';
myerr='/root/dar.err';
filelist='/root/darfiles.list';
darout='/root/dar.out';

webs='/home/www';
dbs='/usr/local/mysql/data';

fulldardb='/root/complete.dar.db';

#Backup Funktion

do_backup () {
    #1 >> $darout;
    backupname=$prefix$week;    
    cd /home
    echo "erstelle Backup"
    
    ##prüfen ob neu...wenn nicht neu....
    ##   prüfen ob volles vorhanden.....
    ##	  	ja -> alter prüfen    -   im namen ist wochenzahl vorhanden
    ##			woche==aktuelle woche, dann diff machen
    ##			zu alt -> neues machen (neu=0)
    ##		nein -> volles machen
    ##			(neu=0)
    
    zeit=`date +%d%H%M`;
    #if [ $neu == 0 ];then
    ls -th1 $localdir/$backupname"full"*1.dar | grep ".dar" -m 1 > filename.$$
    status=$?;
    #fi
    if [ $status -ne 0 ] ; then	# Wenn kein volles existiert
	neu=0;			# volles anlegen
    else
	lastbackup=`cat filename.$$`;	# sonst Namen vom Vollbackup holen um als Referenz zu verwenden
	lastbackup=${lastbackup%%".dar"};
	lastbackup=${lastbackup%%.*};    
        echo "$lastbackup existiert - suche nach neuerem diff..." >> $mylog;
	ls -th1 $localdir/$backupname"diff"*.dar | grep ".dar" -m 1 >filename.$$
	status=$?;
	neu=1;
	if [ $status -eq 0 ]	# Wenn ein diff existiert
	then	
	    lastbackup=`cat filename.$$`	# Namen vom diff als vorheriges backup
	    lastbackup=${lastbackup%%".dar"};
	    lastbackup=${lastbackup%%.*};
	fi
#	rm filename.$$;
	echo "$lastbackup wird als Referenz verwendet - erzeuge jetzt diff Backup" >> $mylog;
    fi
    rm filename.$$;
    
    if [ $neu -eq 0 ]; then # neues backup starten - wochenbeginn
        echo "Beginn volles von $backupname startzeit `date` " >> $mylog ;
	rm $localdir/$prefix$yesterday* >> $mylog 2>$myerr; # alte Backups löschen
        archive=$backupname"full"$zeit;
        dar -w -m 256 -z5 -R $backupdir -c $localdir/$archive -Z "*.gz" -Z "*.zip" -Z "*.mp3" >> $mylog 2>$myerr;
#        dar_manager -B $fulldardb -A $localdir/$archive >> $mylog;
        echo "Ende volles Backup von $backupname `date` " >> $mylog ;
	echo "Loesche alle $local/$prefix$yesterday*" >> $mylog;
    else
        echo "Beginn diff von $backupname start `date`" >> $mylog;
        archive=$backupname"diff"$zeit;
	prevarch=$lastbackup;
#	echo "Ref Backup: $prevarch";
	dar -w -m 256 -z5 -R $backupdir -c $localdir/$archive -Z "*.gz" -Z "*.zip" -Z "*.mp3" -A $prevarch >> $mylog 2>$myerr;
        echo "Ende diff von $backupname `date`" >> $mylog;
#        dar_manager -B $fulldardb -A $localdir/$archive $prevarch >> $mylog;
    fi
    
    basename ${localdir}/${archive}* >> ${filelist}
#    scp $localdir/$archive.1.dar $IP:$remotedir/$archive.1.dar && echo "Backup erstellt" && echo "$archive Backup erstellt vom `date` !!!" >> $mylog;
#    scp $localdir/*.dar.db $IP:$remotedir ; # Datenbank kopieren
}

check_week () {
    week=`date +%V`;
    yesterday=`date +%V --date "1 week ago"`

    if [ $yesterday == $week ]; then
	neu=1; # gestern ist gleiche woche wie heute, dann nicht neu
    else
	neu=0; # neues backup beginnen, da neue woche
	## alte backups von letzter woche löschen damit platz ist
    fi
    
#    if [ $neu == 0 ]; then # neues backup starten - wochenbeginn
#        if [ -s $fulldardb ]; then 
#	    rm $fulldardb; # nur wenn vorhanden
#            dar_manager -C $fulldardb; # nur wenn noch nicht existent
#	else 
#            dar_manager -C $fulldardb; # erstellen, wenn noch nicht existent
#	fi
#    fi

#    backupdir='/home';
#    prefix='webs_';
#    do_backup;

#    backupdir='/usr/local';
#    prefix='usrlocal_';
#    do_backup;

    backupdir='/var/lib/mysql';
    prefix='mysql_';
    do_backup;
    
#    backupdir='/etc';
#    prefix='etc';
#    do_backup;
    
#    backupdir='/root';
#    prefix='rootpsa';
#    do_backup;

#    backupdir='/sbin/firewall.sh';
#    prefix='firewall';
#    do_backup;
}


# Abfrage nach Wochentag
case `date +%w` in
    0) day='so';last="sa";; # Sonntag Backup
    1) day='mo';last="so";; # Wenn Montag volles Backup machen
    2) day='di';last="mo";; # Backup Dienstags
    3) day='mi';last="di";; # Mittwoch Backup
    4) day='do';last="mi";;
    5) day='fr';last="do";; # Wenn Freitag dann Backup machen
    6) day='sa';last="fr";;
    *) echo "heute kein backup";; # sonst kein Backup
esac
rm ${filelist};
check_week;

## Backup script by minigraphx / Andreas Schmidt

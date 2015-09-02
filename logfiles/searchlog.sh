#!/bin/sh
suchtext='tar.gz';
suchort='/home/www/';
suchfiles='access.log.gz';

mydir=`pwd`;
mypid=$$;
tmpdir=$mydir/tmp
resultdir=$mydir/found
mytmp=$tmpdir/searchlog.$$
mytmp2=$tmpdir/searchlog.tmp
myout=$mydir/searchlog.found.txt
myerr=$mydir/searchlog.err

if [ -e $tmpdir ]
then
  echo
  # directory exists
else
  mkdir $tmpdir;
fi

if [ -e $resultdir ]
then
 echo
# :directory exists
else
  mkdir $resultdir;
fi

if [ -e $mytmp ]
then
  rm $mytmp;
fi

if [ -e $myout ]
then
  rm $myout;
fi

# nun enthält temp datei die ganzen namen der logfiles
# TODO: Logfile kopieren - entpacken und durchsuchen, danach kopie löschen und nächstes file

for i in `find $suchort -name $suchfiles`; do
   echo "Datei:"$i;
   cp $i $tmpdir; #datei in tempordner kopieren
   orgname=`basename $i`;

   #tar xvzf $tmpdir/$orgname -C $tmpdir > $mytmp; #gepackte dateien entpacken
   cd $tmpdir
   gunzip $orgname;
   filename=`ls $tmpdir/*log`; #und dateiname in filename
   if [ -e $mytmp ]
   then
     rm $mytmp;
   fi
   filename=`basename $filename`;
   echo "$filename wird untersucht";
   
   cd $tmpdir
   grep -iHn "$suchtext" $filename > $mytmp2 2>> $myerr;
   erg=$?;
   if [ $erg -eq 1 ]
   then
    rm $filename;
   else
    echo "$suchtext gefunden in: $filename : "
    cat $mytmp2;
    echo "Datei: $orgname ($i)" >> $myout;
    cat $mytmp2 >> $myout;
    cp $i $resultdir;
    rm $filename;
   fi
done

rm -r $tmpdir;

<?php

namespace LogAnalyzer;

// Todo: get file by date (time) (range)
//       allow multi file input

include('Logger.php');

/**
 * analyzer for apache combined log to give a summary for the traffic
 */

$maxsize = 0;
$FileName = 'access_log';

switch($argc)
{
    case 3: $maxsize = $argv[2];
        
    case 2: $FileName = $argv[1];
            break;
}

$logformat="%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"";

$firstDate = null;
$lastDate = null;
date_default_timezone_set('Europe/Berlin');
$logger = new Logger();
if (($filehandle = fopen($FileName, "r")) !== FALSE) 
{
    $line = 0;
    $sum = 0;
    while (($content=fgets($filehandle)) !== FALSE)
    {
        $logger->read($content);
        $line++;
        $size = $logger->getField("outbytes"); // get Size not 6 because timezone has zone difference
        $lineDate = $logger->getField("time");
        $lineDate = \DateTime::createFromFormat('d/M/Y G:i:s O',$lineDate);
        if( is_null($firstDate) )
            $firstDate = $lineDate;
        $lastDate = $lineDate;
//        print('errs: '.var_dump(\DateTime::getLastErrors()));
//        print($lineDate->format('d.m.Y H:i:s')." - ");
        if(!is_numeric($size)) 
        {
            print('line:'.$line.PHP_EOL);
            $logger->getAll();
            print('Error in File '.$FileName.PHP_EOL);
            die('size not numeric in line '.$line.PHP_EOL);
        }
        if( $maxsize > 0 && $size > $maxsize )
        {
            print($line.':'.$size.PHP_EOL);
            print($content);
        }
        $sum += $size;
/*
        if( $line % 1000 == 0 ) 
        {
            print("size after $line lines: ".getHumanSize($sum).PHP_EOL);
        }
*/
    }
    fclose($filehandle);
    $humanSum = getHumanSize($sum);
    $humanStartDate = $firstDate->format('d.m.Y H:i:s');
    $humanEndDate = $lastDate->format('d.m.Y H:i:s');
    print('traffic ('.$humanStartDate.' - '.$humanEndDate.' in '.$FileName.'): ');
    print($humanSum);
    print(PHP_EOL);
}

function getHumanSize($bytes) {
    $humansize = null;
    $suffix = array('K', 'M', 'G', 'T');
    $index = 0;
    while($bytes > 1024)
    {
        $bytes = round($bytes / 1024, 2);
        $humansize = $bytes.' '.$suffix[$index];
        $index++;
    }
    if($humansize == null) 
        return $bytes;
    else
        return $humansize;
}

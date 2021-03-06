<?php

namespace LogAnalyzer;

// Todo: get file by date (time) (range)
//       allow multi file input

require_once('Logger.php');

/**
 * analyzer for apache combined log to give a summary for the traffic
 */

$maxsize = 0;
$FileName = 'access_log';

/*
switch($argc) {
    case 3: $maxsize = $argv[2];
        
    case 2: $FileName = $argv[1];
            break;
}
*/
date_default_timezone_set('Europe/Berlin');

$logformat="%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"";

$observers = null;
$parameter = null;

foreach($argv as $key => $argument) {
    if ( $key == 0 ) continue;
    if ( strpos($argument, "-") === false )
        $files[] = $argument;
    else
        $parameter[] = str_replace('-', '', $argument);
}

if( is_array($parameter) ) {
    foreach ($parameter as $param) {
        $fullParam = explode('=', $param);
        $command = $fullParam[0];
        $value = $fullParam[1];
        switch ($command) {
            case 'search':
                $observers['FileCounter'] = $value;
                break;
        }
    }
}

foreach( $files as $file ) {
    $logger = new Logger($file, $logformat);
    if( is_array($observers) ) {
        foreach( $observers as $observer => $observerParam ) {
            require_once($observer.'.php');
            $className = __NAMESPACE__.'\\'.$observer;
            $module = new $className($observerParam);
//            var_dump(get_class_methods($className));
            $logger->attach($module);
        }
    }
    $logger->start();
    $fileSummary = $logger->getSummary();
    // if date is in multiple files summarize the bytes
    foreach( $fileSummary as $datetime => $bytes )
        $summary[$datetime] += $bytes;
}

// convert to human size
foreach( $summary as $datetime => $bytes ) {
    $summary[$datetime] = getHumanSize($bytes);
    ksort($summary);
    print($datetime.' = '.$summary[$datetime].PHP_EOL);
}

/**
* this has to be in another File
*/
function getHumanSize($bytes) {
    $humansize = null;
    $suffix = array('K', 'M', 'G', 'T');
    $index = 0;
    while($bytes > 1024) {
        $bytes = round($bytes / 1024, 2);
        $humansize = $bytes.' '.$suffix[$index];
        $index++;
    }
    if($humansize == null) 
        return $bytes;
    else
        return $humansize;
}
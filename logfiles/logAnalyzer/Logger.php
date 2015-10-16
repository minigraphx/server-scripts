<?php

namespace LogAnalyzer;

/**
 * Description of Logger
 *
 * @author Andreas Schmidt
 */
class Logger {
    private $combinedLog = "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"";
    private $LogSyntax = array('host' => '(\S+)', 
            'time' => '\[([^:]+):(\d+:\d+:\d+) ([^\]]+)\]', 
            'request' => '\"(\S+) (.*?) (\S+)\"',
            'referer' => '"([^"]*)"',
            'agent' => '"(.*)"'
        );
    
    private $data;
    private $logFormat;
    private $summary;
    private $lines;
    private $timeInterval = 'd';
    
    private function readFile(&$fileHandle) {
        $line = 0;
        while (($content=fgets($fileHandle)) !== FALSE) {
            $this->read($content);
            $line++;
            $size = $this->getField("outbytes"); // get Size
            $lineDate = $this->getField("time");
            $lineDate = \DateTime::createFromFormat('d/M/Y G:i:s O',$lineDate);
            if( is_null($firstDate) ) {
                $firstDate = $lineDate;
            }
            $interval = $this->getIntervalFormat();
            $sum[$lineDate->format($interval)] += $size;
            
            $lastDate = $lineDate;
            if(!is_numeric($size)) {
                throw(new \Exception("Can't read Logfile Line: "
                    .PHP_EOL.$line.PHP_EOL
                    ."Error in Logfile: ".$FilenameAccessLog.PHP_EOL
                    ."Size is not numeric: ".$size.PHP_EOL
                    .'Full Line Array:'.PHP_EOL.$this->getLine()));
            }
            if( $maxsize > 0 && $size > $maxsize ) {
                print($line.':'.$size.PHP_EOL);
                print($content);
            }
            /*
            if( $line % 1000 == 0 ) 
            {
                print("size after $line lines: ".getHumanSize($sum).PHP_EOL);
            }
            */
        }
        $this->lines = $line;
        foreach( $sum as $date => $dailySum ) {
            //$sum[$date] = $this->getHumanSize($dailySum);
            $sum[$date] = $dailySum;
        }
//        $humanSum = $this->getHumanSize($sum);
        $humanStartDate = $firstDate->format('d.m.Y H:i:s');
        $humanEndDate = $lastDate->format('d.m.Y H:i:s');
        //return $humanStartDate.' - '.$humanEndDate.': '.$humanSum.PHP_EOL;
        return $sum;
    }
    
    private function getIntervalFormat() {
        switch( strtolower($this->timeInterval) ) {
            case 'd': $setInterval = 'd.m.Y';
                        break;
            case 'm': $setInterval = 'm.Y';
                        break;
            case 'y': $setInterval = 'Y';
                        break;
            case 'h': $setInterval = 'd.m.Y H';
                        break;
            case 'i': $setInterval = 'd.m.Y H:i';
                        break;
            case 's': $setInterval = 'd.m.Y H:i:s';
                        break;
            default: $setInterval = 'd.m.Y';
        }
        return $setInterval;
    }
    
    /**
     * returns regex for speciefied Logging Format, currently only
     * apache combined Log is testet
     *
     * TODO: open mutlipple Files
     * TODO: return Traffic by time periods i.e daily or hourly Traffic through files
     * 
     * param $Logformat: apache syntax Logformat
     * return: String Regex 
     */
    private function getLogSyntax($LogFormat) {
        $format = '';
        // tested Format is combined Log:
        // "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\""
        $LogFormatArray = split(' ', $LogFormat);
        foreach( $LogFormatArray as $token ) {
            $token = str_replace("\"",'',$token);
            if(!empty($format)) $format .= ' ';
            switch($token) {
                case '%h': $format .= $this->LogSyntax['host'];
                            break;
                case '%t': $format .= $this->LogSyntax['time'];
                            break;
                case '%r': $format .= $this->LogSyntax['request'];
                            break;
                case '%{Referer}i': $format .= $this->LogSyntax['referer'];
                            break;
                case '%{User-Agent}i': $format .= $this->LogSyntax['agent'];
                            break;
                default: $format .= '(\S+)';
            }
        }
        $format = '/^'.$format.'$/';
        return $format;
    }
    
    /**
     * Logger constructor
     * opens file, calculates traffic, closes File
     *
     * param string: FilenameAccessLog File Name of the Logfile
     * param string: logFormat Apache Syntax Logformat for the File
     */  
    function __construct($FilenameAccessLog, $logFormat = '') {
        if( empty($logFormat) )
            $this->logFormat = $this->combinedLog;
        else
            $this->logFormat = $logFormat;
        if ( ($logHandle = fopen($FilenameAccessLog, "r")) !== FALSE) {
            $this->summary = $this->readFile($logHandle);
            fclose($logHandle);
        }
        print($fileTraffic);
	}
    
    /**
     * reads a single line and splits it into its values
     * by regular Expression from logFormat
     *
     * param string $line: logfile line
     */
    public function read($line) {
        $regex = $this->getLogSyntax($this->logFormat);
        preg_match($regex ,$line, $matches);
 
        $data['host'] = $matches[1];
        $data['logname'] = $matches[2];
        $data['user'] = $matches[3];
        $data['time'] = $matches[4].' '.$matches[5].' '.$matches[6];
        $data['method'] = $matches[7];
        $data['request'] = $matches[8];
        $data['protocol'] = $matches[9];
        $data['status'] = $matches[10];
        $data['outbytes'] = $matches[11];
        $data['referer'] = $matches[12];
        $data['agent'] = $matches[13];
        $this->data = $data;
    }
    
    /**
     * returns a single entry of the Logfile Line
     */
    public function getField($index) {
        return $this->data[$index];
    }
    
    /**
     * outputs complete Logfile Line as key:value Lines
     */
    public function getLine() {
        $fullLine = '';
        foreach ($this->data as $key => $value) {
            $fullLine = $key.': '.$value.PHP_EOL;
        }
        return $fullLine;        
    }
    
    /**
     * returns result summary
     */
    public function getSummary() {
        return $this->summary;
    }
    
    public function setInterval($interval) {
        $thi->timeInterval = $interval;
    }
    
    
}

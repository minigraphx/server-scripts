<?php

namespace LogAnalyzer;

/**
 * Description of Logger
 *
 * @author andreas
 */
class Logger {
    const host = '%h';
    const logname = '%l'; 
    const user = '%u';
    const time = '%t'; 
    const request = '"%r"';
    const status = '%>s';
    const outbytes = '%O';
    const referer = '"%{Referer}i"';
    const agent = '"%{User-Agent}i"';
    
    private $data;
    
    public function read($line)
    {
        $regex = '/^(\S+) (\S+) (\S+) \[([^:]+):(\d+:\d+:\d+) ([^\]]+)\] \"(\S+) (.*?) (\S+)\" (\S+) (\S+) "([^"]*)" "(.*)"$/';
        preg_match($regex ,$line, $matches);
//      print_r($matches);
 
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
    
    public function getField($index)
    {
        return $this->data[$index];
    }
    
    public function getAll()
    {
        foreach ($this->data as $key => $value)
        {
            print($key.':'.$value.PHP_EOL);
        }        
    }
    
}

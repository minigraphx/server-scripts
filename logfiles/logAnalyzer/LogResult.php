<?php

namespace LogAnalyzer;

/**
 * ResultElement
 * contains:
 * 
 * host, logname, user, time, request, status, outbytes, referer, agent
 * top x hosts or specified host(s) / hostparts 
 * top x lognames usually -
 * top x users or specied user(s) usually -
 * top x dates or times or specified time (range)
 * top x methods (GET, POST, HEAD...)
 * top x requests or specified request parts
 * top x protocols ??
 * top x status codes
 * top x bytes (lowest or highest) or specified bytes (or >= or <=)
 * top x referers
 * top x user agents
 */
class ResultElement {
    private $host;
    private $lognames;
    private $user;
    private $datetime;
    private $method;
    private $request;
    private $protocol;
    private $status;
    private $bytes;
    private $referer;
    private $useragent;
    
    public function getHost() {
      return $this->host;
    }
    
    public function getDateTime($from , $to = null) {
      return $this->;
    }
    
    public function getBytes($size, $operator = "==") {
      return $this->;
    }
    
}

/**
 * LogResult
 * Represents a Definition of a Result the user needs about the Logfile
 * this could be:
 *  consists of ResultElement(s)
 *
 * time based - daily or monthly traffic
 * exception based - show i.e. largest files, special hosts etc 
 * maximum based - show host or file that is most often seen in file 
 * string based - find custom entry in specific column or all columns
 * sum ?  - the sum of bytes ? how stupid and easy is that ??
 *
 * @author Andreas Schmidt
 *
 */
class LogResult {
	
	function __construct()
	{
    
		// first we want full summary file
	}
    
    function getByDateTime($from, $to) {
        
    }
    
    function getByDateInterval($dateinterval){
        
    }
}

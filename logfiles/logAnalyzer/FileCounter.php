<?php
/**
 * Created by PhpStorm.
 * User: andreas
 * Date: 18.10.15
 * Time: 19:46
 */

namespace LogAnalyzer;


class FileCounter implements \SplObserver {

    private $searchstring;
    private $result;

    public function __construct($searchstring = "") {
        $this->searchstring = $searchstring;
        $this->result = null;
    }

    public function printResult() {
        print("gefundene suchmuster: \n");
        foreach( $this->result->getResult() as $request => $findCount ) {
            printf("%s => %d \n", $request, $findCount );
        }
//            $json_result = json_encode();
        $this->printSummary();
    }

    public function printSummary() {
        printf("Gefundene unterschiedliche Einträge mit Suchmuster %s : %d \n", $this->searchstring, count($this->result->getResult()));
    }

    public function update(\SplSubject $logger) {
        $request = $logger->getField('request');
        if( $this->result == null) $this->result = new searchResult();
        if( stristr($request, $this->searchstring) ) {
            $this->result->add($request);
        }
    }
}

class searchResult {

    private $result = null;

    public function add($resultString) {
        print("adding: $resultString \n");
        if( !is_array($this->result) )
            $this->result[$resultString] = 1;
        else {
            if( array_key_exists($resultString, $this->result) )
                $this->result[$resultString] = $this->result[$resultString] +1;
            else
                $this->result[$resultString] = 1;
        }
    }

    public function getResult() {
        return $this->result;
    }
}
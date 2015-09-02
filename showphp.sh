#!/bin/bash
if [ $# == 1 ];then
  user=$1
  echo "pid   filename";
  lsof -u $1 -r 1 -c php 2>/dev/null |grep html | grep REG |awk '{print $2" "$3" "$9}';
else
  echo "pid   user     filename";
  lsof -r 1 -c php 2>/dev/null |grep html | grep REG |awk '{print $2" "$3" "$9}';
fi


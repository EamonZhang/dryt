#!/bin/bash
## drycc resources create myredis(3) redis(1) standard-128(2) -f file.yaml(4) -a myapp(5)
## drycc resources:create redis:standard-128 myredis -f file.yaml -a myapp
if command -v drycc-test &>/dev/null && drycc-test apps -h 2>/dev/null | grep -q "apps:"; 
then 
    drycc-test resources:create "$1":"$2" "$3" -f "$4" -a "$5"
else
    drycc-test resources create "$3" "$1" "$2" -f "$4" -a "$5"
fi

echo " Resource $3 开始创建！" 

#!/bin/bash
if command -v drycc &>/dev/null && drycc apps -h 2>/dev/null | grep -q "apps:"; 
then 
   echo "drycc resources:bind $1 -a $2"
   drycc resources:bind $1 -a $2
else 
   echo "drycc resources bind $1 -a $2"
   drycc resources bind $1 -a $2
fi
sleep 5 ;
#!/bin/bash
name=$1
app=$2

if command -v drycc &>/dev/null && drycc apps -h 2>/dev/null | grep -q "apps:"; 
then 
  DRYCC_CMD="drycc resources:describe"
else 
  DRYCC_CMD="drycc resources describe"
fi
echo "$DRYCC_CMD "${name}" -a "${app}""

[ -d "describe" ] || mkdir -p "describe"

$DRYCC_CMD ${name} -a ${app} |
awk '/Data:/{flag=1; next} /^[^ ]/{flag=0} flag && /^[[:space:]]/{
gsub(/^[[:space:]]+|[[:space:]]+$/, "");
split($0, a, /:[[:space:]]*/);
print a[1] "=" a[2]
}'  > "describe/${app}-${name}.txt"


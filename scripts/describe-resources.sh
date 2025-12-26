#!/bin/bash
name=$1
app=$2

if command -v drycc-test &>/dev/null && drycc-test apps -h 2>/dev/null | grep -q "apps:"; 
then 
  DRYCC_CMD="drycc-test resources:describe"
else 
  DRYCC_CMD="drycc-test resources describe"
fi
echo "$DRYCC_CMD "${name}" -a "${app}""

[ -d "describe" ] || mkdir -p "describe"

$DRYCC_CMD ${name} -a ${app} |
awk '/Data:/{flag=1; next} /^[^ ]/{flag=0} flag && /^[[:space:]]/{
gsub(/^[[:space:]]+|[[:space:]]+$/, "");
split($0, a, /:[[:space:]]*/);
print a[1] "=" a[2]
}'  > "describe/${app}-${name}.txt"


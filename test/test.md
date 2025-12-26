drycc-test apps destroy -a apptest01 --confirm=apptest01

kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get -n apptest01 --ignore-not-found

kubectl -n apptest01 get serviceinstances.servicecatalog.k8s.io -o name | xargs -I {} kubectl -n apptest01 patch {} --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'

kubectl -n apptest01 get servicebindings -o name | xargs -I {} kubectl -n apptest01 patch {} --type=json -p='[{"op": "remove", "path": "/metadata/finalizers"}]'

#!/bin/bash
source config.txt

PGPASSWORD="$PASSWORD" psql -h "$EXTRANET_MASTER_HOST" -p "$PORT" -U "$USERNAME" -d "$DADABASE" <<EOF
-- 创建用户（如果不存在）
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'user1') THEN
        CREATE USER user1 WITH PASSWORD '$PASSWORD';
END IF;
END \$\$;

-- 创建数据库（如果不存在）
CREATE DATABASE db1 OWNER user1;
EOF

echo "操作完成"

# sh: if command -v drycc-test &>/dev/null && drycc-test apps -h 2>/dev/null | grep -q "apps:"; then echo 0; else echo 1; fi

drycc-test resources unbind mysql01 -a apptest01
drycc-test resources destroy mysql01 -a apptest01 --confirm=mysql01

drycc-test resources unbind mongodb01 -a apptest01
drycc-test resources destroy mongodb01 -a apptest01 --confirm=mongodb01

drycc-test resources unbind postgresql17-01 -a apptest01
drycc-test resources destroy postgresql17-01 -a apptest01 --confirm=postgresql17-01
drycc-test apps destroy -a apptest01 --confirm=apptest01

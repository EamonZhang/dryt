#!/bin/bash
resource=$1
name=$2
app=$3
init=$4

if [ "$init" != "true" ]; then
    echo "Initialization not required for resource: $resource"
    exit 0
fi

# 定义初始化PostgreSQL的函数
initialize_postgresql() {
    echo "执行 PostgreSQL 初始化操作..."
    config_file="describe/${app}-${name}.txt"
    source "$config_file"
    PGPASSWORD="$PASSWORD" psql -h "$EXTRANET_MASTER_HOST" -p "$PORT" -U "$USERNAME" -d postgres <<EOF
-- 创建用户（如果不存在）
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'grafana') THEN
        CREATE USER grafana WITH PASSWORD '123456';
    END IF;
END \$\$;
-- 创建数据库
CREATE DATABASE grafanadb OWNER grafana;

EOF

    echo "✅ PostgreSQL 资源 $name 初始化完成"
}

echo "Initializing resource: $resource, name: $name, app: $app"

if [ "$resource" = "postgresql-cluster-17" ]; then
    echo "Initializing PostgreSQL database..."
    initialize_postgresql 
elif [ "$resource" = "redis" ]; then
    echo "Initializing Redis cache..."
    echo "✅ Redis 资源 $name 初始化完成"
else
    echo "No specific initialization steps for resource type: $resource"
fi

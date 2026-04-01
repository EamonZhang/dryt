#!/bin/bash
# @param 1: 资源类型 (RESOURCE_TYPE) - 默认为 "Resource"
# @param 2: 资源名称 (RESOURCE_NAME)
# @param 3: 应用名称 (APP_NAME)
# @param 4: 超时时间 (TIMEOUT) - 默认 1800 秒  
# @param 5: 待检测字段类型 (FIELD_TYPE) - "Status" 或 "Binding"，默认 "Status"
RESOURCE_TYPE="${1:-Resource}"
RESOURCE_NAME="${2}"
APP_NAME="${3}"
TIMEOUT="${4:-1800}"
FIELD_TYPE="${5:-Status}"       # Status 或 Binding，默认是 Status

echo "⏳ 等待 $RESOURCE_TYPE 资源 '$RESOURCE_NAME' [$FIELD_TYPE] 就绪..."

start=$(date +%s)


DRYCC_TYPE=$(if command -v drycc &>/dev/null && drycc apps -h 2>/dev/null | grep -q "apps:"; then echo 0; else echo 1; fi)
while true; do
  status=""
  # 命令解析
  if [ "$DRYCC_TYPE" -eq 1 ]; then
    # 新版 drycc 命令
    status=$(drycc resources describe "$RESOURCE_NAME" -a "$APP_NAME" 2>/dev/null | 
             awk -v f="$FIELD_TYPE" -F': ' '$0 ~ f {print $2}' | xargs echo -n)
  else
    # 旧版 drycc 命令
    status=$(drycc resources:describe "$RESOURCE_NAME" -a "$APP_NAME" 2>/dev/null | 
             awk -v f="$FIELD_TYPE" -F': ' '$0 ~ f {print $2}' | xargs echo -n)
  fi
 
  elapsed=$(( $(date +%s) - start ))
  
  # 超时检查
  if [ $elapsed -ge $TIMEOUT ]; then
    echo "❌ 超时！$RESOURCE_TYPE '$RESOURCE_NAME' 在 ${TIMEOUT}s 内未就绪"
    exit 0
  fi
  
  # 状态处理
  case "${status,,}" in
    "ready")
      printf "\r\033[K ✅  %s '%s [%s]' 就绪 (耗时：%ds)\n" "$RESOURCE_TYPE" "$RESOURCE_NAME" "$FIELD_TYPE" "$elapsed"
      break
      ;;
    "error"|"failed")
      echo "❌ $RESOURCE_TYPE '$RESOURCE_NAME' [$FIELD_TYPE] 状态异常：$status"
      exit 0
      ;;
    "")
      printf "\r\033[K ⏳ [%3ds] 正在获取状态..." "$elapsed"
      ;;
    *)
      printf "\r\033[K ⏳ [%3ds] %s '%s' [%s] 状态：%s" "$elapsed" "$RESOURCE_TYPE" "$RESOURCE_NAME" "$FIELD_TYPE" "$status"
      ;;
  esac
  
  sleep $(shuf -i 3-10 -n 1)
done
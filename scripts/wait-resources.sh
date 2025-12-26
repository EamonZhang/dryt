#!/bin/bash
# 参数
RESOURCE_TYPE="${1:-Resource}"
RESOURCE_NAME="${2}"
APP_NAME="${3}"
TIMEOUT="${4:-1800}"

echo "⏳ 等待 $RESOURCE_TYPE 资源 '$RESOURCE_NAME' 就绪..."

start=$(date +%s)


DRYCC_TYPE=$(if command -v drycc-test &>/dev/null && drycc-test apps -h 2>/dev/null | grep -q "apps:"; then echo 0; else echo 1; fi)
while true; do
  status=""
  # 命令解析
  if [ "$DRYCC_TYPE" -eq 1 ]; then
    # 新版 drycc-test 命令
    status=$(drycc-test resources describe "$RESOURCE_NAME" -a "$APP_NAME" 2>/dev/null | 
             awk -F': ' '/Status/ {print $2}' | 
             xargs echo -n)
  else
    # 旧版 drycc-test 命令
    status=$(drycc-test resources:describe "$RESOURCE_NAME" -a "$APP_NAME" 2>/dev/null | 
             awk -F': ' '/Status/ {print $2}' | 
             xargs echo -n)
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
      printf "\r\033[K ✅  %s '%s' 就绪 (耗时: %ds)\n" "$RESOURCE_TYPE" "$RESOURCE_NAME" "$elapsed"
      break
      ;;
    "error"|"failed")
      echo "❌ $RESOURCE_TYPE '$RESOURCE_NAME' 状态异常: $status"
      exit 0
      ;;
    "")
      printf "\r\033[K ⏳ [%3ds] 正在获取状态..." "$elapsed"
      ;;
    *)
      printf "\r\033[K ⏳ [%3ds] %s '%s' 状态: %s" "$elapsed" "$RESOURCE_TYPE" "$RESOURCE_NAME" "$status"
      ;;
  esac
  
  sleep $(shuf -i 3-10 -n 1)
done

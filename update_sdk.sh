#!/bin/bash
set -e

# --- 設定 ---
SRC_DIR="../openthread-gerrit"
LOG_FILE="changed_files.log"

echo "INFO: SDK sync script started based on 'openthread-gerrit' source."

# --- 1. 清理舊的、由腳本管理的目錄和檔案 (更安全的版本) ---
echo "INFO: Cleaning up previously managed content..."
if [ -d "src" ]; then rm -rf "src"; fi
if [ -d "script" ]; then rm -rf "script"; fi
rm -f third_party/Realtek/tool/FlashMapGenerateCli
rm -f third_party/Realtek/tool/PackCli
rm -f third_party/Realtek/tool/commission.sh
rm -f CMakeLists.txt includepath.cmake

# --- 2. 複製與重組檔案 ---
echo "INFO: Copying and reorganizing new files..."

# 2.1 複製根目錄檔案
echo " -> Copying root files..."
cp "$SRC_DIR/CMakeLists.txt" .
cp "$SRC_DIR/includepath.cmake" .

# 2.2 建立 src 目錄 (主要來自 gerrit 的 vendor 目錄)
echo " -> Creating 'src' directory from '$SRC_DIR/vendor'..."
mkdir -p src
cp "$SRC_DIR/vendor/"*.c ./src/ 2>/dev/null || true
cp "$SRC_DIR/vendor/"*.cpp ./src/ 2>/dev/null || true
cp "$SRC_DIR/vendor/"*.h ./src/ 2>/dev/null || true
cp -rT "$SRC_DIR/vendor/bee4/" ./src/bee4/

# 2.2.1 根據需求，排除 src/bee4 下不需要的子目錄和檔案
echo " -> Excluding specific subdirectories and files from 'src/bee4'..."
if [ -d "./src/bee4/rtl8771gtv" ]; then rm -rf "./src/bee4/rtl8771gtv"; fi
if [ -d "./src/bee4/rtl8771guv" ]; then rm -rf "./src/bee4/rtl8771guv"; fi
if [ -d "./src/bee4/rtl8777g/firmware" ]; then rm -rf "./src/bee4/rtl8777g/firmware"; fi
if [ -d "./src/bee4/rtl8777g/secure" ]; then rm -rf "./src/bee4/rtl8777g/secure"; fi
if [ -d "./src/bee4/rtl8777g_2m" ]; then rm -rf "./src/bee4/rtl8777g_2m"; fi
if [ -d "./src/bee4/rtl8777g_dual" ]; then rm -rf "./src/bee4/rtl8777g_dual"; fi
if [ -d "./src/bee4/rtl8777g_test" ]; then rm -rf "./src/bee4/rtl8777g_test"; fi
if [ -d "./src/bee4/evb" ]; then rm -rf "./src/bee4/evb"; fi
if [ -d "./src/bee4/evb_dual" ]; then rm -rf "./src/bee4/evb_dual"; fi
if [ -d "./src/bee4/evb_old" ]; then rm -rf "./src/bee4/evb_old"; fi
if [ -d "./src/bee4/internal" ]; then rm -rf "./src/bee4/internal"; fi
if [ -f "./src/bee4/arm-none-eabi-ncp.cmake" ]; then rm -f "./src/bee4/arm-none-eabi-ncp.cmake"; fi
if [ -f "./src/bee4/common/common.h" ]; then rm -f "./src/bee4/common/common.h"; fi
if [ -f "./src/bee4/common/power_manager_interface.h" ]; then rm -f "./src/bee4/common/power_manager_interface.h"; fi
if [ -f "./src/bee4/main.c" ]; then rm -f "./src/bee4/main.c"; fi
if [ -f "./src/bee4/ncp-mbedtls-config.h" ]; then rm -f "./src/bee4/ncp-mbedtls-config.h"; fi
if [ -f "./src/bee4/nsc_veneer_customize.h" ]; then rm -f "./src/bee4/nsc_veneer_customize.h"; fi
if [ -f "./src/bee4/peripheral_app.c" ]; then rm -f "./src/bee4/peripheral_app.c"; fi
if [ -f "./src/bee4/simple_ble_config_nus.h" ]; then rm -f "./src/bee4/simple_ble_config_nus.h"; fi
if [ -f "./src/bee4/simple_ble_service_nus.c" ]; then rm -f "./src/bee4/simple_ble_service_nus.c"; fi
if [ -f "./src/bee4/simple_ble_service_nus.h" ]; then rm -f "./src/bee4/simple_ble_service_nus.h"; fi

# 2.3 建立 script 目錄 (來自 gerrit 的 Realtek 目錄下的腳本)
echo " -> Creating 'script' directory from '$SRC_DIR/Realtek'..."
mkdir -p script
cp "$SRC_DIR/Realtek/build" ./script/
cp "$SRC_DIR/Realtek/matter_ota_pack" ./script/
cp "$SRC_DIR/Realtek/post_build" ./script/
cp "$SRC_DIR/Realtek/pre_build" ./script/
cp "$SRC_DIR/Realtek/sdk.cmake" ./script/

# 2.4 填充 third_party/Realtek/tool 目錄 (來自 gerrit 的 tools 目錄)
echo " -> Populating 'third_party/Realtek/tool' directory from '$SRC_DIR/tools'..."
mkdir -p third_party/Realtek/tool
cp "$SRC_DIR/tools/FlashMapGenerateCli" ./third_party/Realtek/tool/
cp "$SRC_DIR/tools/PackCli" ./third_party/Realtek/tool/


# ******************** 修改部分：擴充 .gitignore 處理邏輯 ********************
# --- 3. 產生變更檔案清單並設定 .gitignore ---
echo "INFO: Generating change list and updating .gitignore..."

git status --porcelain > "$LOG_FILE"
echo " -> Change list saved to '$LOG_FILE'."

# 檢查 .gitignore，如果不存在就建立一個
touch .gitignore

# 檢查並加入註解標頭
if ! grep -qFx "# Sync & modification scripts" .gitignore; then
    echo "" >> .gitignore
    echo "# Sync & modification scripts" >> .gitignore
fi

# 檢查並加入 update_sdk.sh
if ! grep -qFx "update_sdk.sh" .gitignore; then
    echo "update_sdk.sh" >> .gitignore
fi

# 檢查並加入 modify_content.sh (修正可能的 typo)
if ! grep -qFx "modify_content.sh" .gitignore; then
    echo "modify_content.sh" >> .gitignore
fi

# 檢查並加入 changed_files.log
if ! grep -qFx "$LOG_FILE" .gitignore; then
    echo "$LOG_FILE" >> .gitignore
fi
# *************************************************************************

# --- 4. 提示與完成 ---
echo -e "\nSUCCESS: SDK content has been updated. Helper scripts are now git-ignored."
echo -e "\nNEXT STEPS:"
echo "1. A file list named '$LOG_FILE' has been generated."
echo "2. You can now run 'modify_content.sh' to fix paths."
echo "3. After all modifications, run 'git status' and 'git diff' to review changes."
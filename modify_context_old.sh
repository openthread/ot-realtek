#!/bin/bash

# ==============================================================================
#  modify_content.sh (Final Corrected Version)
#
#  ... (腳本說明維持不變) ...
# ==============================================================================

set -e

echo "INFO: Starting content modification script for path-related changes..."

# --- 1. Root CMakeLists.txt Modifications ---
TARGET_FILE_CMAKE="CMakeLists.txt"
if [ -f "$TARGET_FILE_CMAKE" ]; then
    echo " -> Fixing paths in '$TARGET_FILE_CMAKE'..."
    sed -i 's/project(ot-bee/project(ot-realtek/' "$TARGET_FILE_CMAKE"
    sed -i 's|include(Realtek/\${BUILD_TYPE}\.cmake)|include(script/\${BUILD_TYPE}\.cmake)|' "$TARGET_FILE_CMAKE"
    sed -i '/include(Realtek\/matter.cmake)/d' "$TARGET_FILE_CMAKE"
    sed -i 's|vendor/\${RT_PLATFORM}|src/\${RT_PLATFORM}|g' "$TARGET_FILE_CMAKE"
else
    echo "WARNING: $TARGET_FILE_CMAKE not found, skipping."
fi

# --- 2. includepath.cmake Modifications ---
TARGET_FILE_INCLUDEPATH="includepath.cmake"
if [ -f "$TARGET_FILE_INCLUDEPATH" ]; then
    echo " -> Fixing paths in '$TARGET_FILE_INCLUDEPATH'..."
    sed -i 's|"${PROJECT_SOURCE_DIR}/vendor/|\"${PROJECT_SOURCE_DIR}/src/|' "$TARGET_FILE_INCLUDEPATH"
else
    echo "WARNING: $TARGET_FILE_INCLUDEPATH not found, skipping."
fi

# --- 3. script/build Modifications ---
TARGET_FILE_BUILD="script/build"
if [ -f "$TARGET_FILE_BUILD" ]; then
    echo " -> Fixing paths in '$TARGET_FILE_BUILD'..."
    sed -i 's|#modify folder to vendor/rtl8777g|#modify folder to src/rtl8777g|' "$TARGET_FILE_BUILD"
    sed -i 's|${OT_SRCDIR}/Realtek/pre_build|${OT_SRCDIR}/script/pre_build|' "$TARGET_FILE_BUILD"
    sed -i 's|${OT_SRCDIR}/Realtek/post_build|${OT_SRCDIR}/script/post_build|' "$TARGET_FILE_BUILD"
    sed -i 's|rm -f ${OT_SRCDIR}/vendor/|rm -f ${OT_SRCDIR}/src/|' "$TARGET_FILE_BUILD"
    sed -i 's|export REALTEK_SDK_PATH="${OT_SRCDIR}/../../"|export REALTEK_SDK_PATH="${OT_SRCDIR}/third_party/Realtek/rtl87x2g_sdk"|' "$TARGET_FILE_BUILD"
    sed -i 's|vendor/\${platform}/arm-none-eabi|src/\${platform}/arm-none-eabi|g' "$TARGET_FILE_BUILD"
    sed -i 's|$PWD/vendor/\${platform}/example_vendor_hook.cpp|$PWD/src/\${platform}/example_vendor_hook.cpp|g' "$TARGET_FILE_BUILD"
    sed -i '/tar zxvf \${OT_SRCDIR}\/Realtek\/v3.0.0.tar.gz/d' "$TARGET_FILE_BUILD"
else
    echo "WARNING: $TARGET_FILE_BUILD not found, skipping."
fi

# --- 4. script/matter_ota_pack Modifications ---
TARGET_FILE_OTA="script/matter_ota_pack"
if [ -f "$TARGET_FILE_OTA" ]; then
    echo " -> Fixing paths in '$TARGET_FILE_OTA'..."
    sed -i 's|/vendor/bee4/|/src/bee4/|g' "$TARGET_FILE_OTA"
else
    echo "WARNING: $TARGET_FILE_OTA not found, skipping."
fi

# --- 5. script/post_build Modifications ---
TARGET_FILE_POST_BUILD="script/post_build"
if [ -f "$TARGET_FILE_POST_BUILD" ]; then
    echo " -> Fixing paths and quotes in '$TARGET_FILE_POST_BUILD'..."
    sed -i 's|arm-none-eabi-objdump -S -C -l \${OUT_FOLDER}/bin/\${CMAKE_TARGET} > \${OUT_FOLDER}/bin/\${CMAKE_TARGET}.asm|arm-none-eabi-objdump -S -C -l "\${OUT_FOLDER}/bin/\${CMAKE_TARGET}" > "\${OUT_FOLDER}/bin/\${CMAKE_TARGET}.asm"|' "$TARGET_FILE_POST_BUILD"
    sed -i 's|arm-none-eabi-objcopy -O binary -S \${OUT_FOLDER}/bin/\${CMAKE_TARGET} \${BIN_FILE}|arm-none-eabi-objcopy -O binary -S "\${OUT_FOLDER}/bin/\${CMAKE_TARGET}" "\${BIN_FILE}"|' "$TARGET_FILE_POST_BUILD"
    sed -i 's|arm-none-eabi-objcopy -O binary -S \${OUT_FOLDER}/bin/\${CMAKE_TARGET} \${TRACE_FILE}|arm-none-eabi-objcopy -O binary -S "\${OUT_FOLDER}/bin/\${CMAKE_TARGET}" "\${TRACE_FILE}"|' "$TARGET_FILE_POST_BUILD"
    sed -i '/if \[ "$(uname -s)" = "Darwin" \];/,/fi/d' "$TARGET_FILE_POST_BUILD"
    sed -i 's|chmod +x "\$PREPEND_HEADER"|chmod +x "\${REALTEK_SDK_PATH}/tools/prepend_header/prepend_header"|' "$TARGET_FILE_POST_BUILD"
    sed -i 's|chmod +x "\$MD5_TOOL"|chmod +x "\${REALTEK_SDK_PATH}/tools/md5/MD5"|' "$TARGET_FILE_POST_BUILD"
    sed -i 's|"\$PREPEND_HEADER"|"\${REALTEK_SDK_PATH}/tools/prepend_header/prepend_header"|' "$TARGET_FILE_POST_BUILD"
    sed -i 's|"\$MD5_TOOL" \${MP_FILE}|"\${REALTEK_SDK_PATH}/tools/md5/MD5" "\${MP_FILE}"|' "$TARGET_FILE_POST_BUILD"
    sed -i 's|vendor/bee4/common/mp.ini|src/bee4/common/mp.ini|' "$TARGET_FILE_POST_BUILD"
else
    echo "WARNING: $TARGET_FILE_POST_BUILD not found, skipping."
fi

# --- 6. script/pre_build Modifications ---
TARGET_FILE_PRE_BUILD="script/pre_build"
if [ -f "$TARGET_FILE_PRE_BUILD" ]; then
    echo " -> Fixing paths, quotes, and logic in '$TARGET_FILE_PRE_BUILD'..."
    sed -i 's|vendor/bee4|src/bee4|g' "$TARGET_FILE_PRE_BUILD"
    sed -i -E 's|^( *arm-none-eabi-gcc -D BUILD_BANK=[01] -E -P -x c ).*(app.ld.gen)$|\1"${OT_SRCDIR}/src/bee4/${BUILD_TARGET}/app.ld" -o "${OT_SRCDIR}/src/bee4/${BUILD_TARGET}/app.ld.gen"|' "$TARGET_FILE_PRE_BUILD"
    if ! grep -q "else" "$TARGET_FILE_PRE_BUILD"; then
        sed -i '/^fi/i \
else\
   echo "Error: Invalid BUILD_BANK value '\''\${BUILD_BANK}'\''. Expected '\''\''bank0'\'' or '\''\''bank1'\''."\
   exit 1' "$TARGET_FILE_PRE_BUILD"
    fi
else
    echo "WARNING: $TARGET_FILE_PRE_BUILD not found, skipping."
fi

# --- 7. script/sdk.cmake Modifications ---
TARGET_FILE_SDK_CMAKE="script/sdk.cmake"
if [ -f "$TARGET_FILE_SDK_CMAKE" ]; then
    echo " -> Fixing REALTEK_SDK_ROOT path in '$TARGET_FILE_SDK_CMAKE'..."
    sed -i '/if(\${RT_PLATFORM} STREQUAL "bee4")/,/endif()/s|\${PROJECT_SOURCE_DIR}/../..|\${PROJECT_SOURCE_DIR}/third_party/Realtek/rtl87x2g_sdk|' "$TARGET_FILE_SDK_CMAKE"
else
    echo "WARNING: $TARGET_FILE_SDK_CMAKE not found, skipping."
fi

# ******************** 最終修正的 src/bee4/CMakeLists.txt 修改部分 ********************
# --- 8. src/bee4/CMakeLists.txt Modifications ---
TARGET_FILE_SRC_CMAKE="src/bee4/CMakeLists.txt"

if [ -f "$TARGET_FILE_SRC_CMAKE" ]; then
    echo " -> Fixing paths in '$TARGET_FILE_SRC_CMAKE'..."

    # 規則 8.1: 修正 mbedtls 函式庫的連結路徑
    sed -i 's|\${REALTEK_SDK_ROOT}/lib/bee4/|\${PROJECT_SOURCE_DIR}/third_party/Realtek/rtl87x2g_sdk/lib/bee4/|g' "$TARGET_FILE_SRC_CMAKE"

    # 規則 8.2: (更穩健的)修正 openthread-bee4 的連結目錄路徑
    # 尋找包含 target_link_directories(openthread-bee4 的那一行，然後只在那行內進行替換
    sed -i '/target_link_directories(openthread-bee4/s|\${REALTEK_SDK_ROOT}/lib/\${RT_PLATFORM}|\${PROJECT_SOURCE_DIR}/third_party/Realtek/rtl87x2g_sdk/lib/\${RT_PLATFORM}|' "$TARGET_FILE_SRC_CMAKE"

    # 規則 8.3: 將其他深層的 SDK 路徑修正回專案的 src 路徑
    sed -i 's|\${REALTEK_SDK_ROOT}/subsys/openthread/vendor/|\${PROJECT_SOURCE_DIR}/src/|g' "$TARGET_FILE_SRC_CMAKE"
    
    # 規則 8.4: 還原被移除的 include 路徑，並將 vendor 修正為 src
    sed -i 's|${PROJECT_SOURCE_DIR}/vendor|${PROJECT_SOURCE_DIR}/src\n        ${PROJECT_SOURCE_DIR}/third_party/Realtek/bee4/common|' "$TARGET_FILE_SRC_CMAKE"
    
else
    echo "WARNING: $TARGET_FILE_SRC_CMAKE not found, skipping."
fi
# **********************************************************************************


echo ""
echo "SUCCESS: All automated path-related modifications are complete."
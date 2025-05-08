#!/bin/bash

# ==============================================================================
#  modify_content.sh (Final Version)
#
#  修正 update_sdk.sh 複製檔案後，造成的內部路徑不一致問題。
#  它會將從來源 repo (openthread-gerrit) 複製過來的、不適用於
#  目標 repo (ot-realtek-yushuo) 結構的路徑，修正回正確的路徑。
#
#  執行時機：在執行完 update_sdk.sh 之後。
# ==============================================================================

set -e

# --- 函數定義 ---

fix_root_cmakelists() {
    local a_file="CMakeLists.txt"
    if [ -f "$a_file" ]; then
        echo " -> Fixing paths in '$a_file'..."
        sed -i 's/project(ot-bee/project(ot-realtek/' "$a_file"
        sed -i 's|include(Realtek/${BUILD_TYPE}\.cmake)|include(script/${BUILD_TYPE}\.cmake)|' "$a_file"
        sed -i '/include(Realtek\/matter.cmake)/d' "$a_file"
        sed -i 's|vendor/${RT_PLATFORM}|src/${RT_PLATFORM}|g' "$a_file"
    else
        echo "WARNING: $a_file not found, skipping."
    fi
}

fix_includepath_cmake() {
    local a_file="includepath.cmake"
    if [ -f "$a_file" ]; then
        echo " -> Fixing paths in '$a_file'..."
        sed -i 's|"${PROJECT_SOURCE_DIR}/vendor/|"${PROJECT_SOURCE_DIR}/src/|' "$a_file"
    else
        echo "WARNING: $a_file not found, skipping."
    fi
}

fix_script_build() {
    local a_file="script/build"
    if [ -f "$a_file" ]; then
        echo " -> Fixing paths in '$a_file'..."
        sed -i 's|#modify folder to vendor/rtl8777g|#modify folder to src/rtl8777g|' "$a_file"
        sed -i 's|${OT_SRCDIR}/Realtek/pre_build|${OT_SRCDIR}/script/pre_build|' "$a_file"
        sed -i 's|${OT_SRCDIR}/Realtek/post_build|${OT_SRCDIR}/script/post_build|' "$a_file"
        sed -i 's|rm -f ${OT_SRCDIR}/vendor/|rm -f ${OT_SRCDIR}/src/|' "$a_file"
        sed -i 's|export REALTEK_SDK_PATH="${OT_SRCDIR}/../../"|export REALTEK_SDK_PATH="${OT_SRCDIR}/third_party/Realtek/rtl87x2g_sdk"|' "$a_file"
        sed -i 's|vendor/${platform}/arm-none-eabi|src/${platform}/arm-none-eabi|g' "$a_file"
        sed -i 's|$PWD/vendor/${platform}/example_vendor_hook.cpp|$PWD/src/${platform}/example_vendor_hook.cpp|g' "$a_file"
        sed -i '/tar zxvf ${OT_SRCDIR}\/Realtek\/v3.0.0.tar.gz/d' "$a_file"
    else
        echo "WARNING: $a_file not found, skipping."
    fi
}

fix_script_matter_ota_pack() {
    local a_file="script/matter_ota_pack"
    if [ -f "$a_file" ]; then
        echo " -> Fixing paths and quotes in '$a_file'..."
        sed -i 's|/vendor/bee4/|/src/bee4/|g' "$a_file"
    else
        echo "WARNING: $a_file not found, skipping."
    fi
}

fix_script_post_build() {
    local a_file="script/post_build"
    if [ -f "$a_file" ]; then
        echo " -> Fixing paths and quotes in '$a_file'..."
        sed -i 's|arm-none-eabi-objdump -S -C -l ${OUT_FOLDER}/bin/${CMAKE_TARGET} > ${OUT_FOLDER}/bin/${CMAKE_TARGET}.asm|arm-none-eabi-objdump -S -C -l "${OUT_FOLDER}/bin/${CMAKE_TARGET}" > "${OUT_FOLDER}/bin/${CMAKE_TARGET}.asm"|' "$a_file"
        sed -i 's|arm-none-eabi-objcopy -O binary -S ${OUT_FOLDER}/bin/${CMAKE_TARGET} ${BIN_FILE}|arm-none-eabi-objcopy -O binary -S "${OUT_FOLDER}/bin/${CMAKE_TARGET}" "${BIN_FILE}"|' "$a_file"
        sed -i 's|arm-none-eabi-objcopy -O binary -S ${OUT_FOLDER}/bin/${CMAKE_TARGET} ${TRACE_FILE}|arm-none-eabi-objcopy -O binary -S "${OUT_FOLDER}/bin/${CMAKE_TARGET}" "${TRACE_FILE}"|' "$a_file"
        sed -i '/if \[ "$(uname -s)" = "Darwin" \];/,/fi/d' "$a_file"
        sed -i 's|chmod +x "$PREPEND_HEADER"|chmod +x "${REALTEK_SDK_PATH}/tools/prepend_header/prepend_header"|' "$a_file"
        sed -i 's|chmod +x "$MD5_TOOL"|chmod +x "${REALTEK_SDK_PATH}/tools/md5/MD5"|' "$a_file"
        sed -i 's|"$PREPEND_HEADER"|"${REALTEK_SDK_PATH}/tools/prepend_header/prepend_header"|' "$a_file"
        sed -i 's|"$MD5_TOOL" ${MP_FILE}|"${REALTEK_SDK_PATH}/tools/md5/MD5" "${MP_FILE}"|' "$a_file"
        sed -i 's|vendor/bee4/common/mp.ini|src/bee4/common/mp.ini|' "$a_file"
    else
        echo "WARNING: $a_file not found, skipping."
    fi
}

fix_script_pre_build() {
    local a_file="script/pre_build"
    if [ -f "$a_file" ]; then
        echo " -> Fixing paths, quotes, and logic in '$a_file'..."
        sed -i 's|vendor/bee4|src/bee4|g' "$a_file"
        sed -i -E 's|^( *arm-none-eabi-gcc -D BUILD_BANK=[01] -E -P -x c ).*(app.ld.gen)$|\1"${OT_SRCDIR}/src/bee4/${BUILD_TARGET}/app.ld" -o "${OT_SRCDIR}/src/bee4/${BUILD_TARGET}/app.ld.gen"|' "$a_file"
        if ! grep -q "else" "$a_file"; then
            sed -i '/^fi/i \
else\
   echo "Error: Invalid BUILD_BANK value '\''${BUILD_BANK}'\''. Expected '\''\''bank0'\'' or '\''\''bank1'\''."\
   exit 1' "$a_file"
        fi
    else
        echo "WARNING: $a_file not found, skipping."
    fi
}

fix_sdk_cmake() {
    local a_file="script/sdk.cmake"
    if [ -f "$a_file" ]; then
        echo " -> Fixing REALTEK_SDK_ROOT path in '$a_file'..."
        sed -i '/if(${RT_PLATFORM} STREQUAL "bee4")/,/endif()/s|${PROJECT_SOURCE_DIR}/../..|${PROJECT_SOURCE_DIR}/third_party/Realtek/rtl87x2g_sdk|' "$a_file"
    else
        echo "WARNING: $a_file not found, skipping."
    fi
}

fix_src_bee4_cmakelists() {
    local a_file="src/bee4/CMakeLists.txt"
    if [ -f "$a_file" ]; then
        echo " -> Fixing paths in '$a_file'..."
        # 規則 1: 修正 mbedtls 和其他 lib 的連結路徑，從 SDK_ROOT 改為指向 submodule
        sed -i 's|${REALTEK_SDK_ROOT}/lib/|\${PROJECT_SOURCE_DIR}/third_party/Realtek/rtl87x2g_sdk/lib/|g' "$a_file"
        # 規則 2: 修正 target_link_directories 的路徑，移除結尾的 /${BUILD_TARGET_VALID}
        sed -i 's|/\${BUILD_TARGET_VALID}||g' "$a_file"
        # 規則 3: 將深層的 SDK 原始碼路徑修正回專案的 src 路徑
        sed -i 's|${REALTEK_SDK_ROOT}/subsys/openthread/vendor/|${PROJECT_SOURCE_DIR}/src/|g' "$a_file"
        # 規則 4: 還原被移除的 include 路徑，並將 vendor 修正為 src
        sed -i 's|${PROJECT_SOURCE_DIR}/vendor|${PROJECT_SOURCE_DIR}/src\n        ${PROJECT_SOURCE_DIR}/third_party/Realtek/bee4/common|' "$a_file"
        sed -i 's|\${PROJECT_SOURCE_DIR}/lib/|\${REALTEK_SDK_ROOT}/lib/|g' "$a_file"
    else
        echo "WARNING: $a_file not found, skipping."
    fi
}


# --- 主執行流程 ---

echo "INFO: Starting content modification script for all files..."

fix_root_cmakelists
fix_includepath_cmake
fix_script_build
fix_script_matter_ota_pack
fix_script_post_build
fix_script_pre_build
fix_sdk_cmake
fix_src_bee4_cmakelists

echo ""
echo "SUCCESS: All automated path-related modifications are complete."
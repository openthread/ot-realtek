# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Fixed
- **RCP Build (rtl87x2g)**: Fixed several build errors that prevented `ot-rcp` from compiling against the public `rtl87x2g_sdk` submodule.
  - Disabled `FEATURE_SUPPORT_CFU` in `openthread-core-rtl8777g-rcp-config.h`; CFU requires internal SDK headers (`cfu.h`) not present in the public submodule.
  - Disabled `FEATURE_SUPPORT_RTK_SIGN` in `openthread-core-rtl8777g-rcp-config.h`; RTK sign is a private security algorithm whose source is not distributed publicly.
  - Fixed format specifier mismatch in `example_vendor_hook.cpp`: changed `%d` to `%lu` for `uint32_t` bitfields of `img_sub_version`.
  - Removed `mac_read_reg` / `mac_write_reg` calls from `example_vendor_hook.cpp` and their declarations from `vendor_hook.h`; these internal debug register functions are no longer exposed in the public SDK (consistent with their removal from `misc.c`).
  - Removed `config_param` runtime configuration references from `example_vendor_hook.cpp` and `vendor_hook.h`; `config_param` and related functions (`rtk_write_config_param`, `rtk_enable_flow_control`, `mac_LoadConfigParam`) are internal SDK symbols not available in the public submodule.
  - Replaced dynamic `config_param`-based pin configuration in `zb_main.c` (`zb_pin_mux_init`, `zb_periheral_drv_init`) with static compile-time pin definitions for RCP builds where runtime config is unavailable.

### Changed
- **Platform Refactor**: Replaced `bee4` platform with `rtl87x2g` to align with public chip naming conventions.
  - Renamed `src/bee4` directory to `src/rtl87x2g`.
  - Updated CMake files and lists to reflect the new platform name (e.g., `openthread-rtl87x2g.cmake`, `rtl87x2g-internal.cmake`).
  - Updated configuration headers and source files to use `rtl87x2g` in filenames and includes.
  - Replaced `RT_PLATFORM_BEE4` macro with `RT_PLATFORM_RTL87X2G` in `src/misc.c`.
  - Removed debug register read/write functions (`mac_read_reg`, `mac_write_reg`) from `src/misc.c`.
- **Platform Renaming**: Replaced `bee3plus` platform references with `rtl8752h`.
  - Updated `src/radio.c` to use `RT_PLATFORM_RTL8752H` instead of `RT_PLATFORM_BEE3PLUS`.
- **Build System**:
  - Updated build scripts (`script/build`, `script/post_build`, etc.) to support `rtl87x2g` and `rtl8752h` platform arguments.
  - Updated SDK paths to point to `third_party/Realtek/rtl87x2g_sdk`.

### Added
- Created `MIGRATION_LOG.md` to document the detailed migration steps and mapping of old paths/files to new ones.

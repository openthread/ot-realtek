# OpenThread on Realtek RTL8777G Example

This repo contains example platform drivers for the [Realtek RTL8777G][RTL8777G].

[RTL8777G]: https://www.realtek.com/

## Download submodule
In a Bash terminal, follow these instructions to clone all submodules.

```bash
$ cd <path-to-ot-realtek>
$ git submodule update --init --recursive
```

## Building

In a Bash terminal, follow these instructions to build the RTL8777G examples.

**CLI (Full Thread Device):**
```bash
$ cd <path-to-ot-realtek>
$ OT_CMAKE_NINJA_TARGET="ot-cli-ftd" ./script/build rtl87x2g sdk rtl8777g
```

**RCP (Radio Co-Processor) for RTL8771GUV dongle:**
```bash
$ cd <path-to-ot-realtek>
$ OT_CMAKE_NINJA_TARGET="ot-rcp" ./script/build rtl87x2g sdk rtl8771guv
```

The RCP image built for `rtl8771guv` is also compatible with the RTL8777G EVB.

## Flash Binaries

If the build completed successfully, the `bin` files may be found in `<path-to-realtek>/build/bin/`.

To flash the images with [MPCli tool][MPCli], copy the application image to the MPCli `bin` directory and update the config file.

[MPCLi]: https://github.com/rtkconnectivity/ot-realtek/tree/main/third_party/Realtek/tool/mpcli

```bash
$ cd <path-to-ot-realtek>
$ cp ./build/bin/<ot-cli-ftd_bank0_MP_dev_0.0.0.0_XXXX.bin> ./third_party/Realtek/tool/mpcli/bin
```

Edit the mptool config file and replace `<ot-cli-ftd.bin>` with the image file name, then set `"enable":"1"`.

```bash
$ vim ./third_party/Realtek/tool/mpcli/mptoolconfig.json
```

The `bin` directory contains the required system firmware (boot patch, sys patch, BT stack, BT host).  The flash layout is:

| Address      | Image                        |
|--------------|------------------------------|
| `0x04001000` | configFile                   |
| `0x04002000` | BANK0 boot patch             |
| `0x0400A000` | BANK1 boot patch             |
| `0x04012000` | OTA header                   |
| `0x04013000` | sys patch                    |
| `0x0401B000` | BT stack patch               |
| `0x0402A000` | BT host                      |
| `0x0405F000` | **ot-cli-ftd** (application) |

Program the device with MPCli.
```bash
$ cd ./third_party/Realtek/tool/mpcli
$ sudo mpcli -f mptoolconfig.json -c <serial port> -a -r
```
Example: `sudo mpcli -f mptoolconfig.json -c /dev/ttyUSB0 -a -r`

## Interact

1. Open terminal to `/dev/ttyACM0` (serial port settings: 115200 8-N-1).
2. Type `help` for list of commands.
3. See [OpenThread CLI Reference README.md][cli] to learn more.

[cli]: https://github.com/openthread/openthread/blob/main/src/cli/README.md

# Contributing

We would love for you to contribute to OpenThread and help make it even better than it is today! See our [Contributing Guidelines](https://github.com/openthread/openthread/blob/main/CONTRIBUTING.md) for more information.

Contributors are required to abide by our [Code of Conduct](https://github.com/openthread/openthread/blob/main/CODE_OF_CONDUCT.md) and [Coding Conventions and Style Guide](https://github.com/openthread/openthread/blob/main/STYLE_GUIDE.md).

# License

OpenThread is released under the [BSD 3-Clause license](https://github.com/openthread/ot-realtek/blob/main/LICENSE). See the [`LICENSE`](https://github.com/openthread/ot-realtek/blob/main/LICENSE) file for more information.

Please only use the OpenThread name and marks when accurately referencing this software distribution. Do not use the marks in a way that suggests you are endorsed by or otherwise affiliated with Nest, Google, or The Thread Group.

# Need help?

OpenThread support is available on GitHub:

- Bugs and feature requests pertaining to the OpenThread on Realtek Example — [submit to the openthread/ot-realtek Issue Tracker](https://github.com/openthread/ot-realtek/issues)
- OpenThread bugs and feature requests — [submit to the OpenThread Issue Tracker](https://github.com/openthread/openthread/issues)
- Community Discussion - [ask questions, share ideas, and engage with other community members](https://github.com/openthread/openthread/discussions)


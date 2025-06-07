# <img src="logo/tor-static-lib-logo.png" wigth="180px">

**tor-static-lib** provides a simple way to compile Tor and its dependencies as static libraries for embedding in applications.  
The build process supports Linux (x86_64 and ARM64) and Windows (x86_64), and can be run from Linux or WSL.

## Supported Targets

- Linux (x86_64)
- Linux (aarch64 / ARM64)
- Windows (x86_64)

After building, the compiled libraries are available in the `libs/` directory.

---

## Prerequisites

On Debian-based systems, install the required build tools:

```bash
sudo apt install git build-essential libtool autopoint po4a mingw-w64 gcc-aarch64-linux-gnu
````

Clone this repository:

```bash
git clone https://github.com/chainpilots/tor-static-lib
cd tor-static-lib
```

Alternatively, create a new directory and copy the Makefile into it.

---

## Usage

### Step 1 – Prepare

Run the following command to download the required repositories and generate Makefiles:

```bash
make prepare
```

This will fetch:

* [OpenSSL](https://github.com/openssl/openssl) → `libcrypto.a`, `libssl.a`
* [libevent](https://github.com/libevent/libevent) → `libevent.a`
* [zlib](https://github.com/madler/zlib) → `libz.a`
* [Tor](https://gitlab.torproject.org/tpo/core/tor) → `libtor.a`, `tor_api.h`

---

## Build Targets

### Build for Linux

To build for **Linux x86\_64**:

```bash
make build_linux_amd64
```

To build for **Linux ARM64 (aarch64)**:

```bash
make build_linux_arm64
```

### Build for Windows

To build for **Windows x86\_64**:

```bash
make build_win_amd64
```

---

## Output

All compiled static libraries will be placed in the `libs/` directory, organized by target architecture.
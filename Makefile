BUILD_DIR := libs
BUILD_DIR_LINUX_64 := $(BUILD_DIR)/linux_amd64
BUILD_DIR_LINUX_64_ARM := $(BUILD_DIR)/linux_arm64
BUILD_DIR_WIN_64 := $(BUILD_DIR)/win_amd64

ARM64 = aarch64-linux-gnu
MINGW = x86_64-w64-mingw32

all: prepare build_linux_amd64 build_win_amd64 build_linux_arm64 clean_libs

prepare:
	-git clone https://github.com/openssl/openssl.git --recursive
	-git clone https://github.com/libevent/libevent.git --recursive
	-git clone https://github.com/madler/zlib.git --recursive
	-git clone https://gitlab.torproject.org/tpo/core/tor.git --recursive
	-mkdir -p $(BUILD_DIR_LINUX_64) $(BUILD_DIR_LINUX_64_ARM) $(BUILD_DIR_WIN_64)
	cp tor/src/feature/api/tor_api.h $(PWD)/$(BUILD_DIR)/tor_api.h && \
	cd libevent && ./autogen.sh
	cd tor && ./autogen.sh

build_linux_amd64: clean_libs
	mkdir -p $(BUILD_DIR_LINUX_64)
# openssl
	-cd openssl && \
		./config \
		--prefix=$(PWD)/openssl/dist \
		--openssldir=$(PWD)/openssl/dist \
		no-shared \
		no-dso \
		no-zlib && \
		make -j$(nproc) && \
		make install_sw && \
		mv dist/lib64 dist/lib && \
		cp dist/lib/libcrypto.a $(PWD)/$(BUILD_DIR_LINUX_64)/libcrypto.a && \
		cp dist/lib/libssl.a $(PWD)/$(BUILD_DIR_LINUX_64)/libssl.a
# libevent
	cd libevent && \
		./configure \
		--prefix=$(PWD)/libevent/dist \
		--disable-shared \
		--enable-static \
		--with-pic \
		--disable-samples \
		--disable-libevent-regress \
		CPPFLAGS=-I../openssl/include \
		LDFLAGS=-L../openssl/dist && \
		make -j$(nproc) && \
		make install && \
		cp dist/lib/libevent.a $(PWD)/$(BUILD_DIR_LINUX_64)/libevent.a
# zlib
	cd zlib && \
		./configure \
		--prefix=$(PWD)/zlib/dist \
		--static \
		--64 && \
		make -j$(nproc) && \
		make install && \
		cp dist/lib/libz.a $(PWD)/$(BUILD_DIR_LINUX_64)/libz.a
# tor
	cd tor && \
		./configure \
		--prefix=$(PWD)/tor/dist \
		--disable-gcc-hardening \
		--disable-system-torrc \
		--disable-asciidoc \
		--enable-static-libevent \
		--with-libevent-dir=$(PWD)/libevent/dist \
		--enable-static-openssl\
		--with-openssl-dir=$(PWD)/openssl/dist \
		--enable-static-zlib \
		--with-zlib-dir=$(PWD)/zlib/dist \
		--disable-systemd \
		--disable-lzma \
		--disable-seccomp \
		--enable-static-tor && \
		make -j$(nproc) && \
		make install && \
		cp libtor.a $(PWD)/$(BUILD_DIR_LINUX_64)/libtor.a

build_linux_arm64: clean_libs
	mkdir -p $(BUILD_DIR_LINUX_64_ARM)
# openssl
	cd openssl && \
		./config linux-aarch64 \
		--prefix=$(PWD)/openssl/dist \
		--openssldir=$(PWD)/openssl/dist \
		--cross-compile-prefix=$(ARM64)- \
		no-shared \
		no-dso \
		no-zlib && \
		make -j$(nproc) && \
		make install_sw && \
		cp dist/lib/libssl.a $(PWD)/$(BUILD_DIR_LINUX_64_ARM)/libssl.a && \
		cp dist/lib/libcrypto.a $(PWD)/$(BUILD_DIR_LINUX_64_ARM)/libcrypto.a
# lebevent
	cd libevent && \
		./configure --host=$(ARM64) \
		--prefix=$(PWD)/libevent/dist \
		--disable-shared \
		--enable-static \
		--with-pic \
		--disable-samples \
		--disable-libevent-regress \
		CPPFLAGS=-I../openssl/dist/include \
		LDFLAGS=-L../openssl/dist/lib && \
		make -j$(nproc) && \
		make install && \
		cp dist/lib/libevent.a $(PWD)/$(BUILD_DIR_LINUX_64_ARM)/libevent.a
# zlib
	cd zlib && \
		CHOST=$(ARM64) ./configure \
		--prefix=$(PWD)/zlib/dist \
		--static && \
		make -j$(nproc)  && \
		make install && \
		cp dist/lib/libz.a $(PWD)/$(BUILD_DIR_LINUX_64_ARM)/libz.a
# tor
	cd tor && \
		./configure --host=$(ARM64) \
		--prefix=$(PWD)/tor/dist \
		--disable-gcc-hardening \
		--disable-system-torrc \
		--disable-asciidoc \
		--enable-static-libevent \
		--with-libevent-dir=$(PWD)/libevent/dist \
		--enable-static-openssl\
		--with-openssl-dir=$(PWD)/openssl/dist \
		--enable-static-zlib \
		--with-zlib-dir=$(PWD)/zlib/dist \
		--disable-systemd \
		--disable-lzma \
		--disable-seccomp \
		--enable-static-tor \
		--disable-tool-name-check && \
		make -j$(nproc) && \
		make install && \
		cp libtor.a $(PWD)/$(BUILD_DIR_LINUX_64_ARM)/libtor.a

build_win_amd64: clean_libs
	mkdir -p $(BUILD_DIR_WIN_64)
	cd openssl && \
		./config mingw64 \
		--prefix=$(PWD)/openssl/dist \
		--openssldir=$(PWD)/openssl/dist \
		--cross-compile-prefix=$(MINGW)- \
		no-shared \
		no-dso \
		no-zlib && \
		make depend && \
		make -j$(nproc) && \
		make install_sw && \
		mv dist/lib64 dist/lib && \
		cp dist/lib/libssl.a $(PWD)/$(BUILD_DIR_WIN_64)/libssl.a && \
		cp dist/lib/libcrypto.a $(PWD)/$(BUILD_DIR_WIN_64)/libcrypto.a
# libevent
	cd libevent && \
		./configure --host=$(MINGW) \
		--prefix=$(PWD)/libevent/dist \
		--disable-shared \
		--enable-static \
		--with-pic \
		--disable-samples \
		--disable-libevent-regress \
		--disable-openssl && \
		make -j$(nproc) && \
		make install && \
		cp dist/lib/libevent.a $(PWD)/$(BUILD_DIR_WIN_64)/libevent.a
# zlib
	cd zlib && \
		CHOST=$(MINGW) ./configure \
		--prefix=$(PWD)/zlib/dist \
		--static && \
		make -j$(nproc)  && \
		make -fwin32/Makefile.gcc libz.a && \
		cp libz.a $(PWD)/$(BUILD_DIR_WIN_64)/libz.a
# tor
	cd tor && \
		./configure mingw64 \
		--prefix=$(PWD)/tor/dist \
		--disable-gcc-hardening \
		--disable-system-torrc \
		--disable-asciidoc \
		--enable-static-libevent \
		--with-libevent-dir=$(PWD)/libevent/dist \
		--enable-static-openssl\
		--with-openssl-dir=$(PWD)/openssl/dist \
		--enable-static-zlib \
		--with-zlib-dir=$(PWD)/zlib \
		--disable-systemd \
		--disable-lzma \
		--disable-seccomp \
		--enable-static-tor \
		--disable-tool-name-check \
		--disable-zstd \
		--enable-fatal-warnings \
		--host=$(MINGW) \
		CC=$(MINGW)-gcc && \
		make -j$(nproc) && \
		make install && \
		cp libtor.a $(PWD)/$(BUILD_DIR_WIN_64)/libtor.a

clean:
	rm -rf openssl
	rm -rf libevent
	rm -rf zlib
	rm -rf tor

clean_libs:
	-cd openssl && make clean && rm -rf dist
	-cd libevent && make clean && rm -rf dist
	-cd zlib && make clean && rm -rf dist
	-cd tor && make clean && rm -rf dist

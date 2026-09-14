# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PHP_EXT_INI="yes"
PHP_EXT_NAME="${PN}"
PHP_EXT_S="${WORKDIR}/swoole-src-${PV}"
PHP_EXT_ZENDEXT="no"
USE_PHP="php8-2 php8-3 php8-4 php8-5"

inherit php-ext-source-r3

DESCRIPTION="Coroutine-based concurrency library for PHP"
HOMEPAGE="https://github.com/swoole/swoole-src"
SRC_URI="https://github.com/${PN}/swoole-src/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/swoole-src-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~riscv ~x86"
IUSE="brotli cares +curl iouring +openssl sockets zstd"

BDEPEND="virtual/pkgconfig"
DEPEND="
	brotli? ( app-arch/brotli:= )
	cares? ( net-dns/c-ares:= )
	curl? (
		net-misc/curl:=
		php_targets_php8-2? ( dev-lang/php:8.2[curl] )
		php_targets_php8-3? ( dev-lang/php:8.3[curl] )
		php_targets_php8-4? ( dev-lang/php:8.4[curl] )
		php_targets_php8-5? ( dev-lang/php:8.5[curl] )
	)
	iouring? ( sys-libs/liburing:= )
	openssl? ( dev-libs/openssl:= )
	zstd? ( app-arch/zstd:= )
	sockets? (
		php_targets_php8-2? ( dev-lang/php:8.2[sockets] )
		php_targets_php8-3? ( dev-lang/php:8.3[sockets] )
		php_targets_php8-4? ( dev-lang/php:8.4[sockets] )
		php_targets_php8-5? ( dev-lang/php:8.5[sockets] )
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	local PHP_EXT_ECONF_ARGS=(
		--enable-swoole
		$(use_enable brotli)
		$(use_enable cares)
		$(use_enable curl swoole-curl)
		$(use_enable iouring)
		$(use_enable sockets)
		$(use_enable zstd)
		$(use_with openssl openssl-dir "${ESYSROOT}/usr")
	)
	php-ext-source-r3_src_configure
}

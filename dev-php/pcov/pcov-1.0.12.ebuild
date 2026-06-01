# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PHP_EXT_ECONF_ARGS=( --enable-${PN} )
PHP_EXT_INI="yes"
PHP_EXT_NAME="${PN}"
PHP_EXT_ZENDEXT="no"
USE_PHP="php8-2 php8-3 php8-4 php8-5"

inherit php-ext-source-r3

DESCRIPTION="CodeCoverage compatible driver for PHP"
HOMEPAGE="https://github.com/krakjoe/pcov"
SRC_URI="https://github.com/krakjoe/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~riscv ~x86"

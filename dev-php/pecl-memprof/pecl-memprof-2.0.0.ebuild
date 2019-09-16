# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PHP_EXT_NAME="memprof"
DOCS=( README.md )

USE_PHP="php5-6 php7-0 php7-1 php7-2" # Pretend to support all three targets...
inherit php-ext-pecl-r3
USE_PHP="php7-0 php7-1 php7-2" # But only truly build for these two.

DESCRIPTION="Memory usage profiler for PHP"
LICENSE="MIT"
SLOT="7"
KEYWORDS="amd64 x86"
IUSE=""

COMMON_DEPEND="dev-libs/judy"

DEPEND="
	php_targets_php7-0? (
		${COMMON_DEPEND} dev-lang/php:7.0[-threads]
	)
	php_targets_php7-1? (
		${COMMON_DEPEND} dev-lang/php:7.1[-threads]
	)
	php_targets_php7-2? (
		${COMMON_DEPEND} dev-lang/php:7.2[-threads]
	)"
RDEPEND="${DEPEND}"

src_prepare(){
	if use php_targets_php7-0 || use php_targets_php7-1 || use php_targets_php7-2 ; then
		php-ext-source-r3_src_prepare
	else
		default_src_prepare
	fi
}

src_configure() {
	php-ext-source-r3_src_configure
}

src_install(){
	if use php_targets_php7-0 || use php_targets_php7-1 || use php_targets_php7-2 ; then
		php-ext-source-r3_src_install
	fi
}

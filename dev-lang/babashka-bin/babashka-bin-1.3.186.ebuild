# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN//-bin}"

DESCRIPTION="Native, fast starting Clojure interpreter for scripting"
HOMEPAGE="https://babashka.org/"
REPO="babashka"
SRC_URI="https://github.com/babashka/${REPO}/releases/download/v${PV}/${MY_PN}-${PV}-linux-${ARCH}.tar.gz"

LICENSE="EPL-1.0"
SLOT="0"
KEYWORDS="amd64 aarch64"

RDEPEND=""
DEPEND=""

S="${WORKDIR}/"

src_install() {
	dobin bb
}

pkg_postinst() {
	elog "To evaluate Clojure code: bb -e '(+ 3 39)' or just execute bb for a REPL"
}

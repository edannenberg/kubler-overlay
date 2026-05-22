# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN//-bin}"

DESCRIPTION="A static analyzer and linter for Clojure code that sparks joy."
HOMEPAGE="https://github.com/clj-kondo/clj-kondo"
REPO="clj-kondo"
SRC_URI="https://github.com/clj-kondo/${REPO}/releases/download/v${PV}/${MY_PN}-${PV}-linux-${ARCH}.zip"

LICENSE="EPL-1.0"
SLOT="0"
KEYWORDS="amd64 aarch64"

RDEPEND=""
DEPEND=""

S="${WORKDIR}/"

src_install() {
	dobin clj-kondo
}

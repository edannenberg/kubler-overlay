# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN//-bin}"
MY_PV="${PV}.1165"

DESCRIPTION="General-purpose programming language with an emphasis on functional programming"
HOMEPAGE="https://clojure.org/"
SRC_URI="https://download.clojure.org/install/clojure-tools-${MY_PV}.tar.gz"

LICENSE="EPL-1.0 Apache-2.0 BSD"
SLOT="1.11"
KEYWORDS="amd64 ~x86 ~x86-linux"
IUSE="+rlwrap"

RDEPEND="
	>=virtual/jre-1.8
	rlwrap? ( app-misc/rlwrap )"

DEPEND=""

S="${WORKDIR}/clojure-tools"

src_install() {
	# replace template marker with actual path in clojure wrapper script
	sed -i -e 's@BINDIR@/usr/bin@g' clj
	sed -i -e 's@PREFIX@/usr/lib/'"${MY_PN}"'@g' clojure

	dobin clj
	dobin clojure

	insinto /usr/lib/${MY_PN}
	doins deps.edn example-deps.edn tools.edn

	insinto /usr/lib/${MY_PN}/libexec
	doins clojure-tools-${MY_PV}.jar exec.jar

	insinto /usr/share/${MY_PN}
	doins clj.1 clojure.1
}

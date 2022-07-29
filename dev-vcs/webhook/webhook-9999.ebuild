# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
EGO_PN="github.com/adnanh/webhook/..."
EGO_SRC="github.com/adnanh/webhook"
S="${WORKDIR}/${P}/src/${EGO_SRC}"

if [[ ${PV} = *9999* ]]; then
	inherit golang-vcs
else
	EGIT_COMMIT="a811db4"
	ARCHIVE_URI="https://github.com/adnanh/webhook/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	inherit golang-vcs-snapshot
fi

DESCRIPTION="Webhook is a lightweight configurable incoming webhook server which can execute shell commands"
HOMEPAGE="https://github.com/adnanh/webhook"
SRC_URI="${ARCHIVE_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+minimal"

DEPEND="dev-lang/go"
RDEPEND=""

src_compile() {
	cd "${S}"
	env GOPATH="${WORKDIR}/${P}" make build || die
}

src_install() {
	dobin webhook
}

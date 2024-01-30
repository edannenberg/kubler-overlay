# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
EGO_PN="github.com/jwilder/docker-gen/..."
EGO_SRC="github.com/jwilder/docker-gen"
S="${WORKDIR}/${P}/src/${EGO_SRC}"

if [[ ${PV} = *9999* ]]; then
	inherit golang-vcs
else
	EGIT_COMMIT="acd79de"
	ARCHIVE_URI="https://github.com/jwilder/docker-gen/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	inherit golang-vcs-snapshot
fi

DESCRIPTION="Generate files from docker container meta-data"
HOMEPAGE="https://github.com/jwilder/docker-gen"
SRC_URI="${ARCHIVE_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

DEPEND="dev-lang/go"
RDEPEND=""

src_compile() {
	cd "${S}"
	env GOPATH="${WORKDIR}/${P}" PATH="${PATH}:${WORKDIR}/${P}/bin" make get-deps docker-gen || die
}

src_install() {
	dobin docker-gen
}

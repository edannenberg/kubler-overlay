# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
EGO_PN="github.com/timonier/syslog-stdout/..."
EGO_SRC="github.com/timonier/syslog-stdout"
S="${WORKDIR}/${P}/src/${EGO_SRC}"

if [[ ${PV} = *9999* ]]; then
	inherit golang-vcs
else
	EGIT_COMMIT="026971e"
	ARCHIVE_URI="https://github.com/timonier/syslog-stdout/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	inherit golang-vcs-snapshot
fi

DESCRIPTION="Minimalistic syslog for Docker containers"
HOMEPAGE="https://github.com/timonier/syslog-stdout"
SRC_URI="${ARCHIVE_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

DEPEND="dev-lang/go"
RDEPEND=""

QA_PRESTRIPPED="/usr/bin/syslog-stdout"

src_install() {
	dobin dist/syslog-stdout
}

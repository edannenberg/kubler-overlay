# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN="github.com/mattermost/mattermost/..."
EGO_SRC="github.com/mattermost/mattermost"
S="${WORKDIR}/${P}/src/${EGO_SRC}"
S_WEBAPP="${WORKDIR}/${P}/src/github.com/mattermost/mattermost-webapp"

if [[ ${PV} = *9999* ]]; then
	inherit golang-vcs
else
	EGIT_COMMIT="72196cd"
	ARCHIVE_URI="https://github.com/mattermost/mattermost/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="amd64"
	inherit golang-vcs-snapshot
fi

inherit systemd epatch

DESCRIPTION="Open source Slack-alternative in Golang and React"
HOMEPAGE="https://mattermost.com/"
SRC_URI="${ARCHIVE_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="+minimal"

DEPEND=">=dev-lang/go-1.13.4 net-libs/nodejs:0/18 media-libs/libpng-compat app-arch/zip dev-lang/nasm media-gfx/pngquant"
RDEPEND="acct-group/mattermost acct-user/mattermost"

src_unpack() {
	golang-vcs-snapshot_src_unpack
}

src_compile() {
	cd "${S}"/server
	env GOPATH="${WORKDIR}/${P}" make LDFLAGS="" setup-go-work build-client build-linux package-linux || die
}

src_install() {
	local dist="${S}/server/dist/mattermost"
	tar xzf "${S}/server/dist"/mattermost-team-linux-amd64.tar.gz -C "${S}/server/dist" || die
	insinto /opt/mattermost
	doins -r "${dist}"/client "${dist}"/config "${dist}"/fonts "${dist}"/i18n "${dist}"/logs "${dist}"/templates

	exeinto /opt/mattermost/bin
	doexe "${dist}"/bin/mattermost

	if ! use minimal; then
		newconfd "${FILESDIR}"/mattermost.confd mattermost
		newinitd "${FILESDIR}"/mattermost.initd.3 mattermost
		systemd_newunit "${FILESDIR}"/mattermost.service mattermost.service
	fi

	fowners mattermost:mattermost /opt/mattermost
	fperms 0750 /opt/mattermost
}

postinst() {
	elog "${PN} installed at /opt/mattermost"
}

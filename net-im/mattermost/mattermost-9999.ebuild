# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN="github.com/mattermost/mattermost-server/..."
EGO_SRC="github.com/mattermost/mattermost-server"
S="${WORKDIR}/${P}/src/${EGO_SRC}"
S_WEBAPP="${WORKDIR}/${P}/src/github.com/mattermost/mattermost-webapp"

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI='https://github.com/mattermost/mattermost-webapp'
	EGIT_CHECKOUT_DIR="${S_WEBAPP}"
	inherit golang-vcs git-r3
else
	WEBAPP_EGIT_COMMIT="5bd990c"
	WEBAPP_ARCHIVE_URI="https://github.com/mattermost/mattermost-webapp/archive/${WEBAPP_EGIT_COMMIT}.tar.gz -> ${PN}-webapp-${PV}.tar.gz"
	SERVER_EGIT_COMMIT="659ce8c"
	SERVER_ARCHIVE_URI="https://github.com/mattermost/mattermost-server/archive/${SERVER_EGIT_COMMIT}.tar.gz -> ${PN}-server-${PV}.tar.gz"
	KEYWORDS="amd64"
	inherit golang-vcs-snapshot
fi

inherit user systemd epatch

DESCRIPTION="Open source Slack-alternative in Golang and React"
HOMEPAGE="https://mattermost.com/"
SRC_URI="${SERVER_ARCHIVE_URI} ${WEBAPP_ARCHIVE_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+minimal"

DEPEND="dev-lang/go net-libs/nodejs sys-apps/yarn media-libs/libpng-compat sys-apps/yarn app-arch/zip dev-lang/nasm media-gfx/pngquant"
RDEPEND=""

pkg_setup() {
	enewgroup mattermost
	enewuser mattermost -1 -1 /usr/share/mattermost mattermost
}

src_unpack() {
	if [[ ${PV} = 9999 ]]; then
		golang-vcs_src_unpack
		git-r3_fetch
		git-r3_checkout
	else
		golang-vcs-snapshot_src_unpack
		mkdir -p "${S_WEBAPP}" || die
		tar xzf "${DISTDIR}/${PN}-webapp-${PV}.tar.gz" -C "${S_WEBAPP}" --strip 1 || die
	fi
}

src_prepare()
{
	epatch "${FILESDIR}/package-individual-platforms-5.16.patch"
	default
}

src_compile() {
	einfo "building webapp, this is gonna take a while :/"
	cd "${S_WEBAPP}"
	make build package || die
	cd "${S}"
	mv config/default.json config/config.json
	env GOPATH="${WORKDIR}/${P}" make LDFLAGS="" build-linux package-linux || die
}

src_install() {
	local dist="${S}/dist/mattermost"
	tar xzf "${S}/dist"/mattermost-team-linux-amd64.tar.gz -C "${S}/dist" || die
	insinto /opt/mattermost
	doins -r "${dist}"/client "${dist}"/config "${dist}"/fonts "${dist}"/i18n "${dist}"/logs "${dist}"/templates

	exeinto /opt/mattermost/bin
	doexe "${dist}"/bin/platform

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

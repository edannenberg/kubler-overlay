# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1

DESCRIPTION="CLI for managing resources in InfluxDB v2"
HOMEPAGE="https://influxdata.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI='https://github.com/influxdata/influx-cli'
else
	inherit vcs-snapshot
	EGIT_COMMIT="3285a03"
	SRC_URI="https://github.com/influxdata/influx-cli/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
fi

DEPEND="dev-lang/go dev-vcs/git "
RDEPEND="acct-group/influxdb acct-user/influxdb"

pkg_setup() {
	enewgroup influxdb
	enewuser influxdb -1 -1 /var/opt/influxdb influxdb
}

src_compile() {
	PATH="${PATH}:${HOME}/go/bin" LDFLAGS="" make || die
}

src_install() {

	dobin bin/linux/influx

	# remove old influx 1.x completion provided by bash-completion package
	#[[ -f /usr/share/bash-completion/completions/influx ]] && { echo "wtf" ; rm /usr/share/bash-completion/completions/influx; }
	#"${S}"/bin/linux/influx completion bash > "${S}"/influx-completion.bash || die
	#newbashcomp influx-completion.bash influx || die
}

pkg_postinst() {
	elog "Start influxd then configure a fresh install via:"
	elog
	elog "    influx setup"
	elog
	elog "To generate a current bash completion file run:"
	elog
	elog "    influx completion bash > /usr/share/bash-completion/completions/influx"
	elog
	elog "To prevent sending usage statistics start influxd with --reporting-disabled"
}


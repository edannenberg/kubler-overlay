# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 user systemd

DESCRIPTION="Scalable datastore for metrics, events, and real-time analytics"
HOMEPAGE="https://influxdata.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="+minimal"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI='https://github.com/influxdata/influxdb'
else
	inherit vcs-snapshot
	EGIT_COMMIT="e91d418"
	SRC_URI="https://github.com/influxdata/influxdb/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
fi

DEPEND="dev-lang/go dev-vcs/git dev-lang/rust sys-devel/clang dev-libs/protobuf"
RDEPEND=""

pkg_setup() {
	enewgroup influxdb
	enewuser influxdb -1 -1 /var/opt/influxdb influxdb
}

src_compile() {
	PATH="${PATH}:${HOME}/go/bin" LDFLAGS="" make || die
}

src_install() {
	#insinto /etc/
	# empty as of now
	#newins "${S}"/chronograf/etc/config.sample.toml influxdb.conf

	dobin bin/linux/influx
	dobin bin/linux/influxd

	! use minimal && newinitd "${FILESDIR}"/influxdb.initd.3 influxdb
	! use minimal && systemd_newunit "${FILESDIR}"/influxdb.service influxdb.service

	keepdir /var/lib/"${PN}"
	fowners influxdb:influxdb /var/lib/"${PN}"
	fperms 0750 /var/lib/"${PN}"

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


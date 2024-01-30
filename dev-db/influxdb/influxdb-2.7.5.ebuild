# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

DESCRIPTION="Scalable datastore for metrics, events, and real-time analytics"
HOMEPAGE="https://influxdata.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="+cli +minimal"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI='https://github.com/influxdata/influxdb'
else
	inherit vcs-snapshot
	EGIT_COMMIT="09a9607"
	SRC_URI="https://github.com/influxdata/influxdb/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
fi

DEPEND="dev-lang/go dev-vcs/git dev-lang/rust sys-devel/clang dev-libs/protobuf"
RDEPEND="acct-group/influxdb acct-user/influxdb cli? ( dev-db/influx-cli )"

src_compile() {
	PATH="${PATH}:${HOME}/go/bin" LDFLAGS="" make || die
}

src_install() {
	#insinto /etc/
	# empty as of now
	#newins "${S}"/chronograf/etc/config.sample.toml influxdb.conf

	dobin bin/linux/influxd

	! use minimal && newinitd "${FILESDIR}"/influxdb.initd.3 influxdb
	! use minimal && systemd_newunit "${FILESDIR}"/influxdb.service influxdb.service

	keepdir /var/lib/"${PN}"
	fowners influxdb:influxdb /var/lib/"${PN}"
	fperms 0750 /var/lib/"${PN}"
}

pkg_postinst() {
	elog
	elog "The influx cli moved to dev-db/influx-cli package."
	elog
}


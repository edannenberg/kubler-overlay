# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
EGO_PN="github.com/influxdata/influxdb"
S="${WORKDIR}/${P}/src/${EGO_PN}"

# the influxdb build script actually requires a git repo for building :/
inherit golang-vcs systemd

DESCRIPTION="Scalable datastore for metrics, events, and real-time analytics"
HOMEPAGE="https://influxdata.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE="+minimal"

DEPEND="dev-lang/go dev-vcs/git dev-vcs/mercurial"
RDEPEND="acct-group/influxdb acct-user/influxdb"

src_compile() {
	[[ ${PV} != *9999* ]] && git checkout "tags/v${PV}"
	env GOPATH="${WORKDIR}/${P}" ./build.py || die
}

src_install() {
	insinto /etc/
	newins "${S}"/etc/config.sample.toml influxdb.conf
	rm "${S}"/etc/config.sample.toml || die

	dobin build/influx
	dobin build/influxd
	dobin build/influx_inspect
	dobin build/influx_stress
	dobin build/influx_tsm

	! use minimal && newinitd "${FILESDIR}"/influxdb.initd.3 influxdb
	! use minimal && systemd_newunit "${FILESDIR}"/influxdb.service influxdb.service

	keepdir /var/opt/"${PN}"
	fowners influxdb:influxdb /var/opt/"${PN}"
	fperms 0750 /var/opt/"${PN}"
}

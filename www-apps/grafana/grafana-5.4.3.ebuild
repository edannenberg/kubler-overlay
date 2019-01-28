# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
EGO_PN="github.com/grafana/grafana/..."
EGO_SRC="github.com/grafana/grafana"
S="${WORKDIR}/${P}/src/${EGO_SRC}"

if [[ ${PV} = *9999* ]]; then
	inherit golang-vcs
else
	EGIT_COMMIT="6539180"
	ARCHIVE_URI="https://github.com/grafana/grafana/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64"
	inherit golang-vcs-snapshot
fi

inherit user systemd

DESCRIPTION="Gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB"
HOMEPAGE="http://grafana.org"
SRC_URI="${ARCHIVE_URI}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="+minimal"

DEPEND="dev-lang/go net-libs/nodejs sys-apps/yarn"
RDEPEND=""

QA_EXECSTACK="usr/share/grafana/vendor/phantomjs/phantomjs"
QA_PRESTRIPPED=${QA_EXECSTACK}

pkg_setup() {
	enewgroup grafana
	enewuser grafana -1 -1 /usr/share/grafana grafana
}

src_compile() {
	go run build.go build || die
	yarn install --pure-lockfile || die
	npm run build || die
}

src_install() {
	keepdir /etc/grafana
	insinto /etc/grafana
	newins "${S}"/conf/defaults.ini grafana.ini

	# Frontend assets
	insinto /usr/share/${PN}
	doins -r public conf
	! use minimal && doins -r vendor

	dobin bin/linux-amd64/grafana-cli
	dobin bin/linux-amd64/grafana-server

	if ! use minimal; then
		newconfd "${FILESDIR}"/grafana.confd grafana
		newinitd "${FILESDIR}"/grafana.initd.3 grafana
		systemd_newunit "${FILESDIR}"/grafana.service grafana.service
	fi

	keepdir /var/{lib,log}/grafana
	keepdir /var/lib/grafana/{dashboards,plugins}
	fowners grafana:grafana /var/{lib,log}/grafana
	fowners grafana:grafana /var/lib/grafana/{dashboards,plugins}
	fperms 0750 /var/{lib,log}/grafana
	fperms 0750 /var/lib/grafana/{dashboards,plugins}
}

postinst() {
	elog "${PN} has built-in log rotation. Please see [log.file] section of"
	elog "/etc/grafana/grafana.ini for related settings."
	elog
	elog "You may add your own custom configuration for app-admin/logrotate if you"
	elog "wish to use external rotation of logs. In this case, you also need to make"
	elog "sure the built-in rotation is turned off."
}

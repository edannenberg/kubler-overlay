# Copyright 2016-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Original ebuild taken from https://github.com/gentoo-mirror/guru

EAPI=8

inherit fcaps go-module tmpfiles systemd flag-o-matic eapi9-ver

DESCRIPTION="A self-hosted lightweight software forge"
HOMEPAGE="https://forgejo.org/ https://codeberg.org/forgejo/forgejo"

SRC_URI="https://codeberg.org/forgejo/forgejo/releases/download/v${PV}/forgejo-src-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-src-${PV}"

# Forgejo itself is GPL-3+ since v9, inherited Gitea code is MIT, rest is vendored deps
LICENSE="GPL-3+ MIT Apache-2.0 BSD BSD-2 ISC MPL-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~riscv ~x86"

IUSE="+acct pam sqlite pie"

DEPEND="
	acct? (
		acct-group/git
		acct-user/git[gitea]
	)
	pam? ( sys-libs/pam )
"
RDEPEND="${DEPEND}
	>=dev-vcs/git-2.34.1
	!www-apps/gitea
"
BDEPEND=">=dev-lang/go-1.26.0"

DOCS=( custom/conf/app.example.ini CONTRIBUTING.md README.md RELEASE-NOTES.md )
FILECAPS=( -m 711 cap_net_bind_service+ep usr/bin/forgejo )

RESTRICT="test"

src_prepare() {
	default

	# The example ini ships with most defaults commented out (;KEY = value),
	# uncomment and set the ones that need to match the FHS layout used here.
	# Repositories default to %(APP_DATA_PATH)s/gitea-repositories.
	local sedcmds=(
		-e "s#^RUN_USER = ; git#RUN_USER = git#"
		-e "s#^;HTTP_ADDR = 0.0.0.0#HTTP_ADDR = 127.0.0.1#"
		-e "s#^;APP_DATA_PATH = data .*#APP_DATA_PATH = ${EPREFIX}/var/lib/gitea/data#"
		-e "s#^;ROOT_PATH =#ROOT_PATH = ${EPREFIX}/var/log/forgejo#"
		-e "s#^MODE = console#MODE = file#"
	)
	sed -i "${sedcmds[@]}" custom/conf/app.example.ini || die

	if ! use sqlite; then
		sed -i -e "s#^DB_TYPE = sqlite3#;DB_TYPE = sqlite3#" custom/conf/app.example.ini || die
	fi
}

src_configure() {
	# bug 832756 - PIE build issues
	filter-flags -fPIE
	filter-ldflags -fPIE -pie
}

src_compile() {
	local forgejo_tags=(
		bindata
		$(usev pam)
		$(usex sqlite 'sqlite sqlite_unlock_notify' '')
	)
	local forgejo_settings=(
		"-X forgejo.org/modules/setting.CustomConf=${EPREFIX}/etc/forgejo/app.ini"
		"-X forgejo.org/modules/setting.CustomPath=${EPREFIX}/var/lib/gitea/custom"
		"-X forgejo.org/modules/setting.AppWorkPath=${EPREFIX}/var/lib/gitea"
	)
	local makeenv=(
		DRONE_TAG="${PV}"
		LDFLAGS="-extldflags \"${LDFLAGS}\" ${forgejo_settings[*]}"
		TAGS="${forgejo_tags[*]}"
	)

	local goflags=""
	use pie && goflags="-buildmode=pie"

	# -j1: the Makefile has a race between its generate targets, the go
	# compiler itself still builds in parallel regardless.
	env "${makeenv[@]}" emake -j1 EXTRA_GOFLAGS="${goflags}" STRIP=0 backend
}

src_install() {
	newbin gitea forgejo

	einstalldocs

	newconfd "${FILESDIR}"/forgejo.confd forgejo
	newinitd "${FILESDIR}"/forgejo.initd forgejo
	systemd_newunit "${FILESDIR}"/forgejo.service forgejo.service
	newtmpfiles - forgejo.conf <<-EOF
		d /run/forgejo 0755 git git
	EOF

	insinto /etc/forgejo
	newins custom/conf/app.example.ini app.ini
	if use acct; then
		fowners root:git /etc/forgejo/{,app.ini}
		fperms g+w,o-rwx /etc/forgejo/{,app.ini}

		diropts -m0750 -o git -g git
		keepdir /var/lib/gitea /var/lib/gitea/custom /var/lib/gitea/data
		keepdir /var/log/forgejo
	fi
}

pkg_postinst() {
	fcaps_pkg_postinst
	tmpfiles_process forgejo.conf

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Forgejo runs as the 'git' user with /var/lib/gitea as its home directory"
		elog "(dictated by acct-user/git[gitea]), so ssh clone URLs use git@<host>."
		elog "Config is in /etc/forgejo/app.ini, logs go to /var/log/forgejo."
		elog "Run 'forgejo web' via the init script and finish the setup in the browser,"
		elog "or use 'forgejo admin' as the git user for a non-interactive setup."
	fi

	if ver_replacing -lt 16.0.0; then
		ewarn "Forgejo 16 release notes:"
		ewarn "https://codeberg.org/forgejo/forgejo/src/branch/forgejo/release-notes-published/16.0.0.md"
	fi
	if ver_replacing -lt 15.0.0; then
		ewarn "Forgejo 15 removed admin-level permissions from repo-specific and public-only access tokens."
		ewarn "https://codeberg.org/forgejo/forgejo/src/branch/forgejo/release-notes-published/15.0.0.md"
	fi
	if ver_replacing -lt 14.0.0; then
		ewarn "Forgejo 14: if SSH is enabled and Forgejo manages an authorized_keys file, the server may fail to start."
		ewarn "See https://codeberg.org/forgejo/forgejo/milestone/27583"
	fi
	if ver_replacing -lt 13.0.0; then
		ewarn "Forgejo 13: make sure your runners are verified before upgrading (runner >= 9.0.0)."
		ewarn "The migration invalidates existing actions artifacts, see https://codeberg.org/forgejo/forgejo/pulls/9023"
	fi
	if ver_replacing -lt 12.0.0; then
		ewarn "Upgrade from 11.0.x LTS detected, this is a nontrivial migration and the database cannot be downgraded!"
		ewarn "https://codeberg.org/forgejo/forgejo/src/branch/forgejo/release-notes-published/12.0.0.md"
	fi
}

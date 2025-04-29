# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A generic, extendable build orchestrator."
HOMEPAGE="https://github.com/edannenberg/kubler.git"
LICENSE="GPL-2"

inherit bash-completion-r1

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI='https://github.com/edannenberg/kubler'
else
	inherit vcs-snapshot
	EGIT_COMMIT="n/a"
	SRC_URI="https://github.com/edannenberg/kubler/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
fi

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~sparc ~x86"
IUSE="+docker podman +rlwrap"
SLOT="0"

DEPEND=""
RDEPEND="dev-vcs/git
         docker? ( app-containers/docker app-containers/docker-cli app-misc/jq )
         podman? ( app-containers/podman app-misc/jq )
         rlwrap? ( app-misc/rlwrap )"

src_install() {
	insinto /usr/share/${PN}
	doins -r bin/ cmd/ engine/ lib/ template/ kubler.conf kubler.sh README.md COPYING

	fperms 0755 /usr/share/${PN}/kubler.sh
	fperms 0755 /usr/share/${PN}/engine/docker/bob-core/build-root.sh
	fperms 0755 /usr/share/${PN}/engine/docker/bob-core/portage-git-sync.sh
	fperms 0755 /usr/share/${PN}/engine/docker/bob-core/sed-or-die.sh
	fperms 0755 /usr/share/${PN}/lib/ask.sh

	dosym /usr/share/${PN}/kubler.sh /usr/bin/kubler

	insinto /etc/
	doins kubler.conf

	newbashcomp lib/kubler-completion.bash ${PN}
}

pkg_postinst() {
	elog
	elog "Kubler's documentation can be found at /usr/share/kubler/README.md"
	elog
	elog "Installing app-shells/bash-completion is highly recommended!"
	elog
}

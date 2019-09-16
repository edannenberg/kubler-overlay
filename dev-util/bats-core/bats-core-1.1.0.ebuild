# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="An automated testing system for bash"
HOMEPAGE="https://github.com/bats-core/bats-core/"
SRC_URI="https://github.com/bats-core/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RDEPEND="!dev-util/bats"

src_test() {
	bin/bats --tap test || die "Tests failed"
}

src_install() {
	einstalldocs

	dobin bin/bats
	
	insinto /usr/libexec/bats-core
	doins libexec/bats-core/*
	fperms 0755 /usr/libexec/bats-core/bats
	fperms 0755 /usr/libexec/bats-core/bats-exec-suite
	fperms 0755 /usr/libexec/bats-core/bats-exec-test
	fperms 0755 /usr/libexec/bats-core/bats-format-tap-stream
	fperms 0755 /usr/libexec/bats-core/bats-preprocess
	
	doman man/bats.1 man/bats.7
}

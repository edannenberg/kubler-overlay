# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd udev

MY_FULLVER="6.2.0-30"
MY_RELEASEDATE="2025-09"

DESCRIPTION="Linux driver for DisplayLink USB graphics devices"
HOMEPAGE="https://www.synaptics.com/products/displaylink-graphics"
SRC_URI="https://www.synaptics.com/sites/default/files/exe_files/${MY_RELEASEDATE}/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu${PV}-EXE.zip -> displaylink-driver-${PV}.zip"

LICENSE="GPL-2 LGPL-2.1 DisplayLink-EULA"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
RESTRICT="bindist mirror"

RDEPEND="
	<x11-drivers/evdi-1.15
	virtual/libusb:1
"
BDEPEND="app-arch/unzip"

S="${WORKDIR}/${PN}-${PV}"

QA_PREBUILT="usr/lib/displaylink/DisplayLinkManager"

src_unpack() {
	unzip "${DISTDIR}/displaylink-driver-${PV}.zip" || die
	chmod +x "${WORKDIR}/displaylink-driver-${MY_FULLVER}.run" || die
	"${WORKDIR}/displaylink-driver-${MY_FULLVER}.run" \
		--noexec \
		--target "${S}" \
		--nox11 \
		--noprogress || die
}

src_install() {
	local arch
	case ${ARCH} in
		amd64) arch="x64-ubuntu-1604" ;;
		x86)   arch="x86-ubuntu-1604" ;;
		arm)   arch="arm-linux-gnueabihf" ;;
		arm64) arch="aarch64-linux-gnu" ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	# Core binary and firmware
	exeinto /usr/lib/displaylink
	doexe "${arch}/DisplayLinkManager"
	insinto /usr/lib/displaylink
	doins ./*.spkg

	# Support tool
	dobin DLSupportTool.sh

	# Log directory
	keepdir /var/log/displaylink

	# Licenses
	insinto /usr/share/licenses/${PN}
	doins LICENSE
	doins "${FILESDIR}/DISPLAYLINK-EULA"

	# udev rules and helper script
	udev_dorules "${FILESDIR}/99-displaylink.rules"
	exeinto /opt/displaylink
	doexe "${FILESDIR}/udev.sh"

	# systemd service and sleep hook
	systemd_dounit "${FILESDIR}/displaylink.service"
	exeinto /usr/lib/systemd/system-sleep
	newexe "${FILESDIR}/displaylink-sleep.sh" displaylink.sh

	# OpenRC init script
	newinitd "${FILESDIR}/displaylink.initd" displaylink
}

pkg_postinst() {
	udev_reload
	elog "To start with systemd:"
	elog "  systemctl enable --now displaylink.service"
	elog ""
	elog "To start with OpenRC:"
	elog "  rc-update add displaylink default"
	elog "  rc-service displaylink start"
	elog ""
	elog "To accept the DisplayLink EULA add to /etc/portage/package.license:"
	elog "  x11-drivers/displaylink DisplayLink-EULA"
}

pkg_postrm() {
	udev_reload
}

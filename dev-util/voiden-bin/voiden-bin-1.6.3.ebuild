# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

MY_PN="Voiden"

DESCRIPTION="Offline-first, file-based API development tool (build, test, document)"
HOMEPAGE="https://voiden.md https://github.com/VoidenHQ/voiden"
SRC_URI="https://github.com/VoidenHQ/voiden/releases/download/v${PV}/${MY_PN}-${PV}.AppImage"
S="${WORKDIR}/squashfs-root"

# The bundled LICENSE only covers Electron (MIT); Voiden itself ships no
# redistribution grant, hence all-rights-reserved + restricted mirroring.
LICENSE="all-rights-reserved MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="suid"

RESTRICT="bindist mirror strip"

# Host libraries the bundled Electron/Chromium dlopens at runtime.
RDEPEND="
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="opt/voiden/*"

src_unpack() {
	# Type-2 AppImage: self-extracts to ./squashfs-root, no FUSE required.
	cp "${DISTDIR}/${A}" "${WORKDIR}/${A}" || die
	chmod +x "${WORKDIR}/${A}" || die
	cd "${WORKDIR}" || die
	"./${A}" --appimage-extract > /dev/null || die "AppImage extraction failed"
}

src_install() {
	local instdir="/opt/voiden"

	# Chromium/Electron runtime payload.
	insinto "${instdir}"
	doins "${S}"/*.pak "${S}"/*.bin "${S}"/*.dat
	doins "${S}"/version "${S}"/vk_swiftshader_icd.json
	doins "${S}"/*.so "${S}"/libvulkan.so.1
	doins -r "${S}"/locales "${S}"/resources

	# Fallback libraries Voiden bundles (appindicator, libnotify, ...).
	# Skip the GTK2 system-tray compat libs (libappindicator, libgconf,
	# libindicator): they carry unresolved soname deps on libgtk-x11-2.0.so.0
	# and libdbus-glib-1.so.2 which are not available on modern Gentoo.
	# Electron falls back gracefully without them.
	insinto "${instdir}/usr/lib"
	local f
	for f in "${S}"/usr/lib/*.so*; do
		case "${f##*/}" in
			libappindicator*|libgconf*|libindicator*) ;;
			*) doins "${f}" ;;
		esac
	done

	# Executables.
	exeinto "${instdir}"
	doexe "${S}"/Voiden "${S}"/chrome_crashpad_handler

	if use suid; then
		# Setuid-root SUID sandbox helper: lets Chromium sandbox itself
		# even where unprivileged user namespaces are disabled (e.g.
		# hardened kernels). Not needed when userns is available.
		newins "${S}"/chrome-sandbox chrome-sandbox
		fowners root:root "${instdir}/chrome-sandbox"
		fperms 4755 "${instdir}/chrome-sandbox"
	else
		doexe "${S}"/chrome-sandbox
	fi

	# Launcher. Mirrors the AppImage's LD_LIBRARY_PATH but, unlike the
	# bundled .desktop, does NOT pass --no-sandbox: the Chromium sandbox
	# stays on (via unprivileged userns, or the setuid helper with USE=suid).
	newbin - voiden <<-'EOF'
		#!/bin/sh
		export LD_LIBRARY_PATH="/opt/voiden:/opt/voiden/usr/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
		exec /opt/voiden/Voiden "$@"
	EOF

	# Icons (renamed Voiden.png -> voiden.png per size).
	local s
	for s in 16 32 48 64 128 256; do
		insinto "/usr/share/icons/hicolor/${s}x${s}/apps"
		newins "${S}/usr/share/icons/hicolor/${s}x${s}/apps/Voiden.png" voiden.png
	done

	# Desktop entry + voiden:// scheme handler.
	insinto /usr/share/applications
	newins - voiden.desktop <<-'EOF'
		[Desktop Entry]
		Name=Voiden
		Comment=Build, Test, Document & Collaborate. Streamline your API development process with Voiden
		Exec=voiden %u
		Icon=voiden
		Terminal=false
		Type=Application
		Categories=Development;Utility;
		MimeType=x-scheme-handler/voiden;
		StartupWMClass=Voiden
		StartupNotify=true
	EOF

	dodoc "${S}"/LICENSE
}

pkg_postinst() {
	xdg_pkg_postinst

	if ! use suid; then
		elog "Voiden relies on Chromium's unprivileged user-namespace sandbox."
		elog "If it fails to start with a sandbox error (typically on a hardened"
		elog "kernel where unprivileged user namespaces are disabled), either:"
		elog "  - re-emerge with USE=suid to install a setuid-root sandbox helper, or"
		elog "  - run 'voiden --no-sandbox' (this disables the Chromium sandbox)."
	fi
}

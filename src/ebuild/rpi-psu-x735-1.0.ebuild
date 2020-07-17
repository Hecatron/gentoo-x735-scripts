# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit systemd git-r3

DESCRIPTION="Scripts for triggering reboots / shutdown via th X735 Rpi Board"
HOMEPAGE="https://github.com/Hecatron/gentoo-x735-scripts/"

EGIT_REPO_URI="https://github.com/Hecatron/gentoo-x735-scripts.git"
EGIT_COMMIT="0cf9a893d2f01b084e8c196b4c614c44ea6aa7bb"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="arm arm64"
IUSE=""

src_install() {
	# User run Script to trigger a shutdown
	dobin "${WORKDIR}/${P}/src/modified/x730-shutdown.sh"
	# Daemon script to handle reboot / shutdown on button press
	dobin "${WORKDIR}/${P}/src/modified/x730-daemon.sh"

	# init scripts
	newinitd "${WORKDIR}/${P}/src/modified/openrc/x730-pwr"
	systemd_dounit "${FILESDIR}/x730-pwr.service"
}

pkg_postinst() {
	elog "To start the service and enable on bootup"
	if use systemd ; then
		elog "  systemctl daemon-reload"
		elog "  systemctl start x730-pwr.service"
		elog "  systemctl enable x730-pwr.service"
	else
		elog "  /etc/init.d/x730-pwr start "
		elog "  rc-update add x730-pwr default "
	fi
}

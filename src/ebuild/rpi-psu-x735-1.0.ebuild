# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit systemd git-r3

DESCRIPTION="Scripts for triggering reboots / shutdown via th X735 Rpi Board"
HOMEPAGE="https://github.com/Hecatron/gentoo-x735-scripts/"

EGIT_REPO_URI="https://github.com/Hecatron/gentoo-x735-scripts.git"
EGIT_COMMIT="06276a1022306e2606a712c726c324dcbf32b080"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="arm arm64"
IUSE=""

src_install() {
	# User run Script to trigger a shutdown
	dobin "${WORKDIR}/${P}/src/modified/x730-shutdown.sh"
	# Daemon script to handle reboot / shutdown on button press
	dobin "${WORKDIR}/${P}/src/modified/x730-daemon.sh"

	# initrd for openrc
	newinitd "${WORKDIR}/${P}/src/modified/openrc/x730-openrc" x730-psu

	# TODO systemd
	#systemd_douserunit contrib/systemd/user/vncserver@.service
}

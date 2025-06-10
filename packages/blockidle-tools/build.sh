TERMUX_PKG_HOMEPAGE="https://github.com/Innovative-CST/blockidle-tools"
TERMUX_PKG_DESCRIPTION="Installer script for BlockIdle development setup (OpenJDK, Gradle, etc.)"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@DevVigilante"
TERMUX_PKG_VERSION=1.0.1
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_ESSENTIAL=true
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_CONFFILES="etc/blockidle/idesetup.sh"
TERMUX_PKG_DEPENDS="unzip, libcurl, zip"

termux_step_make_install() {
	# Create the destination directory
	install -Dm700 "$TERMUX_PKG_BUILDER_DIR/idesetup.sh" "$TERMUX_PREFIX/etc/blockidle/idesetup.sh"

	# Make it executable globally via symlink
	ln -sf "$PREFIX/etc/blockidle/idesetup.sh" "$PREFIX/bin/idesetup.sh"
}

EAPI=8

DESCRIPTION="Command line Teensy Loader"
HOMEPAGE="http://www.pjrc.com/teensy/loader_cli.html"

SRC_URI="https://github.com/PaulStoffregen/$PN/archive/refs/tags/$PV.tar.gz -> $P.tar.gz"

LICENSE="GPL-3"
KEYWORDS="amd64"
SLOT="0"

DEPEND="virtual/libusb:0"
RDEPEND="${DEPEND}"

src_install() {
	dobin teensy_loader_cli
}

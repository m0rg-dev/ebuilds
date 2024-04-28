EAPI=8

DESCRIPTION="A declarative spec for deploying helm charts"
HOMEPAGE="https://github.com/helmfile/helmfile"
SRC_URI="https://github.com/helmfile/helmfile/releases/download/v${PV}/${PN}_${PV}_linux_amd64.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} app-admin/helm"
BDEPEND=""

S="${WORKDIR}"

src_install() {
	dobin helmfile
	dodoc README.md
}

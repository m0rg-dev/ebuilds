# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=(python3_{10..12})

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI="https://github.com/certbot/certbot.git"
	inherit git-r3
	S=${WORKDIR}/${P}/${PN}
else
	SRC_URI="https://github.com/${PN%-dns-route53}/${PN%-dns-route53}/archive/v${PV}.tar.gz -> ${PN%-nginx}-${PV}.tar.gz"
	S=${WORKDIR}/${PN%-dns-route53}-${PV}/${PN}
fi

DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Amazon Route53 plugin for certbot (Let's Encrypt Client)"
HOMEPAGE="https://github.com/certbot/certbot https://letsencrypt.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"

CDEPEND=">=dev-python/setuptools-1.0[${PYTHON_USEDEP}]"
RDEPEND="${CDEPEND}
	~app-crypt/certbot-${PV}[${PYTHON_USEDEP}]
	~app-crypt/acme-${PV}[${PYTHON_USEDEP}]
	dev-python/mock[${PYTHON_USEDEP}]
	dev-python/zope-interface[${PYTHON_USEDEP}]
	dev-python/boto3[${PYTHON_USEDEP}]"
DEPEND="${CDEPEND}"

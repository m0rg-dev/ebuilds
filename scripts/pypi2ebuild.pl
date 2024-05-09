use strict;
use v5.38;
use JSON::Parse 'parse_json';
use Data::Dumper;
use File::Path 'make_path';

my %LICENSES = (
    'Apache Software License 2.0' => 'Apache-2.0',
    'Apache 2' => 'Apache-2.0',
);

my $pkg = shift;

sub gentoo_normalize($pkg) {
    return lc $pkg =~ y/_/-/r;
}

-e "/var/db/repos/gentoo/dev-python/$pkg" and die "$pkg is already in gentoo";
-e "/var/db/repos/gentoo/dev-python/" . gentoo_normalize($pkg) and die "$pkg is already in gentoo";
-e "dev-python/$pkg" and die "$pkg is already in local";
-e "dev-python/" . gentoo_normalize($pkg) and die "$pkg is already in local";

my $pkgdesc = parse_json `curl -s https://pypi.org/pypi/$pkg/json`;

my $description = $pkgdesc->{info}{summary} =~ s/([\\'"])/\\$1/gr;
my $homepage = $pkgdesc->{info}{home_page} =~ s/([\\'"])/\\$1/gr;
my $license = $LICENSES{$pkgdesc->{info}{license}} // $pkgdesc->{info}{license};
my $version = $pkgdesc->{info}{version};

my @remotes = (
    "<remote-id type=\"pypi\">$pkg</remote-id>\n",
);

if ($homepage =~ m(^https://github.com/([^/]+)/([^/]+)/?$)) {
    push @remotes, "<remote-id type=\"github\">$1/$2</remote-id>\n";
}

my $dependcheck = Data::Dumper->Dump([$pkgdesc->{info}{requires_dist}], ["requires_dist"]) =~ s/^(.*)$/# $1/gmr;

my $rdepend = "";
if ($pkgdesc->{info}{requires_dist}) {
    my @rdeps;
    for my $rdep (@{$pkgdesc->{info}{requires_dist}}) {
        my ($require, $when) = split /\s*;\s+/, $rdep;
        if (!$when || lc($when) eq "sys_platform == \"linux\"") {
            $require =~ s/([a-zA-Z0-9_-]+)\s*\(?(>=)(.*?)\)?$/$2dev-python\/$1-$3\[\${PYTHON_USEDEP}]/ or die "couldn't parse version spec $require";
            push @rdeps, $require;
        }
    }
    $rdepend = "RDEPEND=\"\${RDEPEND}\n\t" . join("\n\t", @rdeps) . "\n\"";
}

my $base = "dev-python/" . gentoo_normalize($pkg);

make_path($base);

open my $ebuild, ">", "$base/" . gentoo_normalize($pkg) . "-$version.ebuild";
print $ebuild <<TEMPLATE;
EAPI=8

DESCRIPTION="$description"
HOMEPAGE="$homepage"

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

LICENSE="$license"
SLOT="0"
KEYWORDS="amd64"

$dependcheck
$rdepend
TEMPLATE

open my $meta, ">", "$base/metadata.xml";
print $meta <<TEMPLATE;
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE pkgmetadata SYSTEM "https://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
  <maintainer type="person">
    <email>corp\@m0rg.dev</email>
    <name>Morgan Wolfe</name>
  </maintainer>
  <upstream>
@remotes
  </upstream>
</pkgmetadata>
TEMPLATE

system "xmllint --format $base/metadata.xml -o $base/metadata.xml";
system "cd $base; ebuild " . gentoo_normalize($pkg) . "-$version.ebuild" . " manifest";

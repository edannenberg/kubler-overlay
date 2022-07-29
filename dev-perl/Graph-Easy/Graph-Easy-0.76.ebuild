EAPI=7

DIST_AUTHOR=SHLOMIF
DIST_VERSION=0.76
inherit perl-module

DESCRIPTION="Render/convert graphs in/from various formats"

SLOT="0"
KEYWORDS="alpha amd64 ia64 ppc sparc x86 arm arm64"
IUSE="+graphviz"

RDEPEND="
	dev-perl/Digest-SHA1
	dev-perl/Config-Tiny
	graphviz? ( media-gfx/graphviz )
	"
DEPEND="${RDEPEND}
	dev-perl/Module-Build
	"

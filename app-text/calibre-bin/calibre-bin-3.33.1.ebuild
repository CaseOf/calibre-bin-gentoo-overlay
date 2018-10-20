# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop gnome2-utils xdg-utils

DESCRIPTION="Ebook management application"
HOMEPAGE="https://calibre-ebook.com/"
SRC_URI="
	amd64? ( https://download.calibre-ebook.com/${PV}/${PN/-bin}-${PV}-x86_64.txz )
	x86? ( https://download.calibre-ebook.com/${PV}/${PN/-bin}-${PV}-i686.txz )
"

LICENSE="
	GPL-3+
	GPL-3
	GPL-2+
	GPL-2
	GPL-1+
	LGPL-3+
	LGPL-2.1+
	LGPL-2.1
	BSD
	MIT
	Old-MIT
	Apache-2.0
	public-domain
	|| ( Artistic GPL-1+ )
	CC-BY-3.0
	OFL-1.1
	PSF-2
"
KEYWORDS="-* ~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND="
	dev-libs/expat
	dev-libs/glib
	dev-libs/libbsd
	dev-libs/libffi
	dev-libs/libgpg-error
	dev-libs/libpcre
	dev-libs/libxml2
	dev-libs/libxslt
	media-fonts/liberation-fonts
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libpng
	media-libs/mesa
	sys-apps/dbus
	sys-libs/glibc
	sys-libs/ncurses
	sys-libs/zlib
	virtual/libusb
	virtual/udev
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libxshmfence
	x11-libs/libXxf86vm
"
DEPEND=""

src_unpack() {
	mkdir -p "${WORKDIR}/${P}" || die
	tar -Jxpf "${DISTDIR}/${A}" -C "${WORKDIR}/${P}" || die
}

src_prepare() {
	rm -r resources/fonts/liberation || die
	ln -s "${EPREFIX}/usr/share/fonts/liberation-fonts" resources/fonts/liberation || die
	default
}

src_install() {
	# Install calibre binaries in /opt
	dodir /opt/${PN/-bin}
	cp -pR * "${ED}/opt/${PN/-bin}" || die

	# Symbolic links
	dosym "${EPREFIX}/opt/${PN/-bin}/${PN/-bin}" /usr/bin/${PN/-bin}
	dosym "${EPREFIX}/opt/${PN/-bin}/ebook-viewer" /usr/bin/ebook-viewer
	dosym "${EPREFIX}/opt/${PN/-bin}/ebook-edit" /usr/bin/ebook-edit
	dosym "${EPREFIX}/opt/${PN/-bin}/lrfviewer" /usr/bin/lrfviewer
	dosym "${EPREFIX}/opt/${PN/-bin}/calibre-server" /usr/bin/calibre-server

	# Services
	newinitd "${FILESDIR}"/calibre-server-3.init calibre-server
	newconfd "${FILESDIR}"/calibre-server-3.conf calibre-server

	# Icons
	doicon -s 128 resources/content-server/calibre.png
	newicon -s 256 resources/images/lt.png calibre.png
	newicon -s 256 resources/images/viewer.png calibre-viewer.png
	newicon -s 256 resources/images/tweak.png calibre-ebook-edit.png

	# Desktop entries
	make_desktop_entry ${PN/-bin} "Calibre" ${PN/-bin} "Office;" \
		"GenericName=E-book library management" \
		"Comment=E-book library management: Convert, view, share, catalogue all your e-books" \
		"MimeType=application/x-cbr;application/x-cbc;application/ereader;application/oebps-package+xml;image/vnd.djvu;application/x-sony-bbeb;application/vnd.ms-word.document.macroenabled.12;application/x-mobipocket-subscription;application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/x-mobipocket-ebook;application/vnd.ctc-posml;application/x-mobi8-ebook;application/epub+zip;application/x-cbz;"
	make_desktop_entry ebook-viewer "E-book Viewer" calibre-viewer "Graphics;Viewer;" \
		"GenericName=Viewer for E-books" "Comment=Viewer for E-books in all the major formats" \
		"MimeType=application/x-cbr;application/x-cbc;application/ereader;application/oebps-package+xml;image/vnd.djvu;application/x-sony-bbeb;application/vnd.ms-word.document.macroenabled.12;application/x-mobipocket-subscription;application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/x-mobipocket-ebook;application/vnd.ctc-posml;application/x-mobi8-ebook;application/epub+zip;application/x-cbz;"
	make_desktop_entry ebook-edit "E-book Editor" calibre-ebook-edit "Office;" \
		"GenericName=Editor for E-books" "Comment=Edit E-books in various formats" \
		"MimeType=application/x-mobi8-ebook;application/epub+zip;application/vnd.openxmlformats-officedocument.wordprocessingml.document;text/html;application/xhtml+xml;"
	make_desktop_entry lrfviewer "LRF Viewer" calibre-viewer "Graphics;Viewer;" \
		"GenericName=Viewer for LRF files" "Comment=Viewer for LRF files (SONY ebook format files)" \
		"MimeType=application/x-sony-bbeb;"

}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}

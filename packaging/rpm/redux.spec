Name:           redux
Version:        1.0.0
Release:        1%{?dist}
Summary:        Convert, compress and resize images

License:        GPL-3.0-or-later
URL:            https://github.com/dprietob/redux
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  meson
BuildRequires:  vala
BuildRequires:  gettext
BuildRequires:  desktop-file-utils
BuildRequires:  appstream
BuildRequires:  pkgconfig(gtk4) >= 4.12
BuildRequires:  pkgconfig(libadwaita-1) >= 1.8
BuildRequires:  pkgconfig(gdk-pixbuf-2.0) >= 2.42
BuildRequires:  pkgconfig(libwebp) >= 1.0
# GExiv2 0.14 or 0.16: both are packaged as libgexiv2-devel.
BuildRequires:  libgexiv2-devel
# The tests load images through glycin, which sandboxes its loaders.
BuildRequires:  glycin-loaders
BuildRequires:  bubblewrap

Requires:       hicolor-icon-theme
Requires:       glycin-loaders

%description
Redux converts batches of images to WebP, JPEG or PNG and makes them
lighter: adjust the quality or compression, resize them, rename them with a
pattern and remove their metadata. When it finishes, a report shows how much
space you saved. Your original images are never modified.

%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install
%find_lang %{name}

%check
%meson_test

%files -f %{name}.lang
%license LICENSE
%doc README.md
%{_bindir}/redux
%{_datadir}/applications/io.github.dprietob.redux.desktop
%{_datadir}/metainfo/io.github.dprietob.redux.metainfo.xml
%{_datadir}/glib-2.0/schemas/io.github.dprietob.redux.gschema.xml
%{_datadir}/icons/hicolor/*/apps/io.github.dprietob.redux.*

%changelog
* Sat Nov 21 2026 Daniel Prieto <dprietob@protonmail.com> - 1.0.0-1
- First version of Redux.

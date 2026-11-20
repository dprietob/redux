[![License: GPL-3.0-or-later](https://img.shields.io/badge/License-GPL--3.0--or--later-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Please do not theme this app](https://stopthemingmy.app/badge.svg)](https://stopthemingmy.app)

<img src="data/icons/hicolor/256x256/apps/io.github.dprietob.redux.png?raw=true" width="128" alt="Redux icon">

# Redux

A simple, fast batch image converter for the GNOME desktop.

Redux converts a whole folder of images, or just the ones you pick, to WebP,
JPEG or PNG in one go. Choose the quality, shrink the images if you like, and
see at a glance how much space you saved.

Redux lets you:

- Open a folder of images or add individual image files, and choose which ones
  to convert
- Convert to WebP, JPEG or PNG
- Set the quality of WebP and JPEG images, or the compression level of PNG
  images
- Resize the images in pixels or by percentage, keeping the aspect ratio or not
- Choose the folder where the converted images are written
- Review a report with the number of converted images, the size before and
  after, the space saved and the size change of every image

Redux never modifies your original images: it refuses to convert when an output
file would overwrite one of them.

## Made for GNOME

Redux is built with GTK 4 and libadwaita to feel right at home on the GNOME
desktop, following the GNOME Human Interface Guidelines and respecting the
system style. Contributions are welcome and are expected to follow the
[GNOME Code of Conduct].

## How images are processed

Images are read and written with GdkPixbuf, which uses the image loaders
installed on the system. Lossy WebP images are encoded with libwebp directly,
because GdkPixbuf does not honour the WebP quality. JPEG has no transparency,
so transparent areas become white.

Your conversion options are remembered between sessions with GSettings.
Nothing leaves your computer.

## Developing and Building

Install the build dependencies. On Fedora:

```shell
sudo dnf install vala meson gtk4-devel libadwaita-devel gdk-pixbuf2-devel libwebp-devel
```

Build and run natively with Meson and Ninja:

```shell
meson setup _build
ninja -C _build
./_build/redux
```

Run the tests:

```shell
meson test -C _build
```

To build the Flatpak from the command line:

```shell
flatpak install flathub org.gnome.Platform//50 org.gnome.Sdk//50
flatpak-builder --user --install --force-clean build-flatpak io.github.dprietob.redux.yaml
flatpak run io.github.dprietob.redux
```

[GNOME Code of Conduct]: https://conduct.gnome.org

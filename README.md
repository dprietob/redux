[![License: GPL-3.0-or-later](https://img.shields.io/badge/License-GPL--3.0--or--later-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Please do not theme this app](https://stopthemingmy.app/badge.svg)](https://stopthemingmy.app)

<img src="data/icons/hicolor/256x256/apps/io.github.dprietob.redux.png?raw=true" width="128" alt="Redux icon">

# Redux

A simple, fast batch image converter for the GNOME desktop.

![Redux](screenshots/01_main.png?raw=true)

Redux converts all the images you pick to WebP, JPEG or PNG in one go. Choose the quality, shrink the images if you like, and
see at a glance how much space you saved.

Redux lets you:

- Add the images to convert, or drag them from the file manager, choose which
  ones to include and drag them to reorder them
- Convert to WebP, JPEG or PNG
- Set the quality of WebP and JPEG images, or the compression level of PNG
  images
- Resize the images in pixels or by percentage, keeping the aspect ratio or not
- Choose the folder where the converted images are written
- Optionally rename the converted images with a pattern made of the original
  name, a sequential number, the date and time the photo was taken, a prefix
  and a suffix, with a live example of the result
- Remove the metadata of the images: all of it, everything except the EXIF
  data, or, image by image, whole categories (EXIF, XMP, IPTC, comment) or
  single tags such as the GPS position
- Hover over an image to see a preview of it
- Get a notification when a long conversion finishes (it can be turned off)
- Use it on phones too: on narrow screens the image list and the options
  become two pages
- Review a report with the number of converted images, the size before and
  after, the space saved and the size change of every image

Redux never overwrites a file: when a name is already taken in the output
folder, the converted image gets a numeric suffix, such as `photo-1.webp`. Your
original images are never modified.

Press <kbd>Ctrl</kbd>+<kbd>?</kbd> to see all the keyboard shortcuts.

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

Metadata is read and written with GExiv2. The camera orientation is applied
to the pixels, so the orientation tag is reset, outdated EXIF thumbnails are
dropped and the stored image size is updated. WebP files cannot hold IPTC data.

Your conversion options are remembered between sessions with GSettings.
Nothing leaves your computer.

## Developing and Building

Install the build dependencies. On Fedora:

```shell
sudo dnf install vala meson gtk4-devel libadwaita-devel gdk-pixbuf2-devel libwebp-devel libgexiv2-devel
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

The tests run in GitHub Actions in a Fedora container rather than in the
Flatpak build, because glycin cannot sandbox its image loaders while
`flatpak-builder` builds the app.

To build the Flatpak from the command line:

```shell
flatpak install flathub org.gnome.Platform//51 org.gnome.Sdk//51
flatpak-builder --user --install --force-clean build-flatpak io.github.dprietob.redux.yaml
flatpak run io.github.dprietob.redux
```

[GNOME Code of Conduct]: https://conduct.gnome.org

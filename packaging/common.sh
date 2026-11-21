#!/usr/bin/env bash
# Helpers shared by the package build scripts.

# Prints the version declared in meson.build.
meson_version() {
    sed -n "s/^  version: '\(.*\)',$/\1/p" "$1/meson.build"
}

# Stops when a packaging file declares a version other than meson.build.
check_version() {
    local source_dir="$1" packaged_version="$2" file="$3"
    local version
    version=$(meson_version "$source_dir")
    if [ "$version" != "$packaged_version" ]; then
        echo "Version mismatch: meson.build says $version but $file says $packaged_version." >&2
        exit 1
    fi
}

# Copies the source tree without build output, version control or packages.
copy_sources() {
    local source_dir="$1" destination="$2"
    mkdir -p "$destination"
    tar -C "$source_dir" \
        --exclude-vcs --exclude=./_build --exclude=./build-flatpak --exclude=./.flatpak-builder \
        --exclude=./builddir --exclude=./repo --exclude=./dist \
        -cf - . | tar -C "$destination" -xf -
}

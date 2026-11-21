#!/usr/bin/env bash
# Builds the Debian package inside a Debian or Ubuntu container and runs the
# tests. The package name includes the distribution it was built for.
# Usage: build-deb.sh <source directory> <output directory>
set -euo pipefail

source_dir=$(realpath "$1")
output_dir=$(realpath "$2")
. "$source_dir/packaging/common.sh"

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends build-essential devscripts equivs >/dev/null

version=$(meson_version "$source_dir")
build_dir=$(mktemp -d)
package_dir="$build_dir/redux-$version"
copy_sources "$source_dir" "$package_dir"
rm -rf "$package_dir/debian"
cp -r "$package_dir/packaging/debian" "$package_dir/debian"

cd "$package_dir"
check_version "$source_dir" "$(dpkg-parsechangelog -S Version)" "debian/changelog"
mk-build-deps --install --remove --tool "apt-get -y -qq --no-install-recommends" debian/control >/dev/null
dpkg-buildpackage -us -uc -b

. /etc/os-release
distribution="${ID}${VERSION_ID:-${VERSION_CODENAME:-}}"
architecture=$(dpkg --print-architecture)
mkdir -p "$output_dir"
cp "$build_dir/redux_${version}_${architecture}.deb" "$output_dir/redux_${version}_${distribution}_${architecture}.deb"
ls -1 "$output_dir/redux_${version}_${distribution}_${architecture}.deb"

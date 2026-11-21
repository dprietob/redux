#!/usr/bin/env bash
# Builds the RPM package inside a Fedora container and runs the tests.
# Usage: build-rpm.sh <source directory> <output directory>
set -euo pipefail

source_dir=$(realpath "$1")
output_dir=$(realpath "$2")
. "$source_dir/packaging/common.sh"

spec="$source_dir/packaging/rpm/redux.spec"
version=$(meson_version "$source_dir")
check_version "$source_dir" "$(sed -n 's/^Version: *//p' "$spec")" "redux.spec"

dnf install -y --setopt=install_weak_deps=False rpm-build 'dnf-command(builddep)' >/dev/null
dnf builddep -y --setopt=install_weak_deps=False "$spec" >/dev/null

top_dir=$(mktemp -d)
mkdir -p "$top_dir/SOURCES" "$top_dir/SPECS"
copy_sources "$source_dir" "$top_dir/redux-$version"
tar -C "$top_dir" -czf "$top_dir/SOURCES/redux-$version.tar.gz" "redux-$version"
cp "$spec" "$top_dir/SPECS/"

rpmbuild --define "_topdir $top_dir" --define "debug_package %{nil}" -bb "$top_dir/SPECS/redux.spec"

mkdir -p "$output_dir"
cp "$top_dir"/RPMS/*/redux-"$version"-*.rpm "$output_dir/"
ls -1 "$output_dir"/redux-"$version"-*.rpm

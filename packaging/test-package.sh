#!/usr/bin/env bash
# Installs a built package in a clean Fedora, Debian or Ubuntu container, the
# way a user would, and checks that Redux is usable: the program runs, its
# settings schema is compiled and its desktop entry, metainfo, icons and
# translations are installed.
# Usage: test-package.sh <package file> <source directory>
set -euo pipefail

package=$(realpath "$1")
expected_translations=$(wc -w < "$2/po/LINGUAS")

if command -v dnf >/dev/null; then
    dnf install -y --setopt=install_weak_deps=False "$package" >/dev/null
else
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq --no-install-recommends "$package" >/dev/null
fi

fail() {
    echo "FAILED: $1" >&2
    exit 1
}

# Lists the files inside the package. Container images often skip installing
# translations, so they are checked in the package rather than on disk.
package_files() {
    if command -v rpm >/dev/null && [[ "$package" == *.rpm ]]; then
        rpm -qpl "$package"
    else
        dpkg-deb -c "$package"
    fi
}

redux --help >/dev/null || fail "redux --help does not run"
# The schema is compiled by the distribution's GLib trigger, not by the package.
grep -q "io.github.dprietob.redux" /usr/share/glib-2.0/schemas/gschemas.compiled \
    || fail "the settings schema is not compiled"
for file in \
    /usr/share/applications/io.github.dprietob.redux.desktop \
    /usr/share/metainfo/io.github.dprietob.redux.metainfo.xml \
    /usr/share/icons/hicolor/scalable/apps/io.github.dprietob.redux.svg; do
    [ -f "$file" ] || fail "$file is missing"
done
translations=$(package_files | grep -c "LC_MESSAGES/redux.mo" || true)
[ "$translations" -eq "$expected_translations" ] \
    || fail "the package has $translations translations instead of $expected_translations"

echo "OK: $(basename "$package") installs and runs, with $translations translations."

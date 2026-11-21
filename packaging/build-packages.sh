#!/usr/bin/env bash
# Builds the .rpm and .deb packages of Redux, one per supported distribution,
# each inside a clean container of that distribution. The packages are left
# in dist/. Containers run privileged because the tests load images through
# glycin, which sandboxes its loaders with bubblewrap.
#
# Usage: packaging/build-packages.sh [target...]
# Targets: fedora:43 fedora:44 fedora:45 ubuntu:26.04 debian:testing
set -euo pipefail

root=$(realpath "$(dirname "$0")/..")
targets=("$@")
if [ ${#targets[@]} -eq 0 ]; then
    targets=(fedora:43 fedora:44 fedora:45 ubuntu:26.04 debian:testing)
fi

engine=$(command -v podman || command -v docker || true)
if [ -z "$engine" ]; then
    echo "podman or docker is needed to build the packages." >&2
    exit 1
fi

mkdir -p "$root/dist"
for target in "${targets[@]}"; do
    case "$target" in
        fedora:*) image="registry.fedoraproject.org/$target"; script=build-rpm.sh ;;
        ubuntu:* | debian:*) image="docker.io/library/$target"; script=build-deb.sh ;;
        *) echo "Unknown target: $target" >&2; exit 1 ;;
    esac
    echo "==> Building for $target"
    "$engine" run --rm --privileged \
        -v "$root":/source:ro,Z -v "$root/dist":/dist:Z \
        "$image" bash "/source/packaging/$script" /source /dist
done

#!/usr/bin/env bash
# Build this fork of Pinta as a Flatpak and install it for the current user,
# replacing any existing com.github.PintaProject.Pinta install.
#
# Builds the *committed* state of the current branch (uncommitted changes are
# not included). Build output goes to packaging/flatpak/.build (gitignored).
#
# One-time prerequisites (no sudo needed):
#   flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
#   flatpak install --user flathub org.flatpak.Builder org.gnome.Sdk//50 org.freedesktop.Sdk.Extension.dotnet10//25.08
set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=$(git -C "$HERE" rev-parse --show-toplevel)
BRANCH=$(git -C "$REPO" rev-parse --abbrev-ref HEAD)
APP=com.github.PintaProject.Pinta
OUT="$HERE/.build"
BUNDLE="$OUT/pinta-fork.flatpak"

if [ "$BRANCH" = HEAD ]; then
	echo "Detached HEAD: check out a branch first." >&2
	exit 1
fi
if [ -n "$(git -C "$REPO" status --porcelain --untracked-files=no)" ]; then
	echo "Warning: uncommitted changes will NOT be included in this build." >&2
fi
echo "Building $APP from branch '$BRANCH' ($(git -C "$REPO" rev-parse --short HEAD))"

# Fill in the repo path and branch, writing the manifest next to the original
# so its relative shared-modules path still resolves.
mkdir -p "$OUT"
MANIFEST="$HERE/.manifest.generated.yaml"
sed -e "s|@REPO_DIR@|$REPO|" -e "s|@BRANCH@|$BRANCH|" "$HERE/$APP.yaml" > "$MANIFEST"
trap 'rm -f "$MANIFEST"' EXIT

cd "$HERE"
flatpak run --filesystem="$REPO" org.flatpak.Builder \
	--force-clean --repo="$OUT/repo" --state-dir="$OUT/state" \
	"$OUT/build" "$MANIFEST"
flatpak build-bundle "$OUT/repo" "$BUNDLE" "$APP"

# Remove a Flathub (system) copy if one has come back; it would compete with ours.
if flatpak info --system "$APP" >/dev/null 2>&1; then
	echo "Removing system-wide (Flathub) $APP (asks for your password)..."
	flatpak kill "$APP" 2>/dev/null || true
	flatpak uninstall --system -y "$APP"
fi

flatpak kill "$APP" 2>/dev/null || true
flatpak install --user -y --noninteractive --reinstall "$BUNDLE"

flatpak info --user "$APP" | grep -E "Branch|Commit"
echo "Done. Note: launchers must use --branch=master (see ~/.local/share/applications)."

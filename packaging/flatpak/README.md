# Building and installing this fork

This machine (Linux Mint 22.3) has GTK 4.14 and libadwaita 1.5, older than
Pinta needs (GTK ≥ 4.18, libadwaita ≥ 1.8). A plain `dotnet run` starts but
shows a blank, non-working canvas. Run and install Pinta through the GNOME 50
Flatpak runtime instead, as described below.

## One-time setup

1. **.NET 10 SDK**, installed per-user in `~/.dotnet` (no sudo):
   ```bash
   curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
   bash /tmp/dotnet-install.sh --channel 10.0 --install-dir ~/.dotnet
   ```
   It isn't on `PATH` by default. In each shell (or in `~/.bashrc`):
   ```bash
   export DOTNET_ROOT=$HOME/.dotnet PATH=$HOME/.dotnet:$PATH
   ```

2. **Flatpak build tools**, installed per-user (no sudo):
   ```bash
   flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   flatpak install --user flathub org.flatpak.Builder org.gnome.Sdk//50 org.freedesktop.Sdk.Extension.dotnet10//25.08
   ```

## Day-to-day development

Build and run the tests:
```bash
dotnet build
dotnet test
```

To run the dev build without installing it, run it inside the installed Pinta
Flatpak's runtime, which has a new enough GTK:
```bash
dotnet build
flatpak run --filesystem=$HOME/.dotnet:ro --filesystem="$PWD" \
  --env=DOTNET_ROOT=$HOME/.dotnet --command=$HOME/.dotnet/dotnet \
  com.github.PintaProject.Pinta "$PWD/build/bin/Pinta.dll"
```
Run this from the repo root. The dev build shares settings with the installed
Pinta (`~/.var/app/com.github.PintaProject.Pinta`).

## Installing the fork as your Pinta

Commit your changes first, then from the repo root:
```bash
packaging/flatpak/build-and-install.sh
```

- It builds the **committed** state of the **current branch**. Uncommitted
  changes are left out, and the script prints a warning if there are any.
- It replaces the installed `com.github.PintaProject.Pinta` (user install,
  Flatpak branch `master`). If a Flathub system-wide copy is present, the
  script removes it first and asks for your password.
- NuGet packages are downloaded during the build. Build output and the
  `.flatpak` bundle go in `packaging/flatpak/.build/` (gitignored).
- `flatpak info` reports the version from the app metadata, which can lag
  behind the actual code.

### App menu launcher

There's a customized launcher at
`~/.local/share/applications/com.github.PintaProject.Pinta.desktop`. It
overrides the one Flatpak exports, and its `Exec=` line must use
`--branch=master`. The Flathub install used `--branch=stable`, so if Pinta
won't open from the menu after a reinstall, check this line first.

### Going back to the official Flathub version

```bash
flatpak uninstall --user com.github.PintaProject.Pinta
flatpak install --system flathub com.github.PintaProject.Pinta
```
Then change the launcher back to `--branch=stable`.

## Files

- `com.github.PintaProject.Pinta.yaml`: manifest based on
  [flathub/com.github.PintaProject.Pinta](https://github.com/flathub/com.github.PintaProject.Pinta).
  `@REPO_DIR@` and `@BRANCH@` are filled in by the script. When upstream's
  Flathub manifest moves to a new GNOME runtime or .NET extension, update
  `runtime-version`, `sdk-extensions`, and the SDK versions under
  "One-time setup" to match.
- `shared-modules/intltool/`: intltool build module copied from Flathub's
  `shared-modules`.
- `build-and-install.sh`: builds the bundle and installs it.

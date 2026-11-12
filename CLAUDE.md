# Pinta fork

Personal fork of PintaProject/Pinta. Remotes: `origin` = fork
(anthonyhauck/Pinta), `upstream` = PintaProject/Pinta. Do feature work on a
branch, not `master`. To sync: `git fetch upstream && git merge upstream/master`.

## Build, run, install

Follow `packaging/flatpak/README.md` for building, testing, running, and
installing this fork. Key points:

- .NET 10 lives in `~/.dotnet` and is not on PATH. Prefix commands with
  `export DOTNET_ROOT=$HOME/.dotnet PATH=$HOME/.dotnet:$PATH`.
- The system GTK is too old: `dotnet run` shows a blank canvas. To run the dev
  build, use the `flatpak run ... Pinta.dll` command in the README.
- To install the fork as the user's Pinta, commit and then run
  `packaging/flatpak/build-and-install.sh`. Claude Code's auto-mode classifier
  blocks Claude from running Flatpak builds, so give the user the command to
  run with `! packaging/flatpak/build-and-install.sh` and read its output
  afterwards.
- When killing Pinta, don't use `pkill -f build/bin/Pinta.dll`: the pattern
  also matches the shell running the command and kills it. Use
  `pkill -f "[b]uild/bin/Pinta.dll"` or `flatpak kill com.github.PintaProject.Pinta`.

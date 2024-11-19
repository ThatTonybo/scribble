# Scribble
Manage your notes

## Build
Requires sqlite3:
```
sudo apt-get install libsqlite3-dev
```
Build with meson and ninja:
```
meson build --prefix=/usr
cd build
ninja
```
Install and execute:
```
ninja install
com.thattonybo.scribble
```

## Build (Flatpak)
Ensure the SDK is installed:
```
flatpak install --user io.elementary.Sdk//7.2
```
Build with flatpak-builder:
```
flatpak-builder flatpak-build com.thattonybo.scribble.yml --user --install --force-clean
```

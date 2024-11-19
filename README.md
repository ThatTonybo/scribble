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

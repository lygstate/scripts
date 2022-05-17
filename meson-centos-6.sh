pip3 install meson mako
rm -f /usr/bin/python3
ln -s /usr/bin/python3.10 /usr/bin/python3

# For libdrm
yum install -y libpciaccess-devel


# Build drm
CC=clang CXX=clang++ meson --prefix=/usr

# For wayland
yum install -y libxml2-devel libdot-devel

# Build wayland
git reset --hard 1.20.0
CC=clang CXX=clang++ meson --prefix=/usr -Ddocumentation=false

# Build wayland-protocols
git reset --hard 1.25
CC=clang CXX=clang++ meson --prefix=/usr

# For mesa
yum install -y expat-devel flex bison
yum install -y libX11-devel --setopt=protected_multilib=false
# Build mesa
CC=clang CXX=clang++ meson --prefix=/usr -D llvm=enabled -Dshared-llvm=disabled

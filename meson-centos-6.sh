pip3 install meson mako
rm -f /usr/bin/python3
ln -s /usr/bin/python3.10 /usr/bin/python3

# For libdrm
yum install -y libpciaccess-devel

# For mesa
yum install -y expat-devel


# Build drm
meson --prefix=/usr

# Build mesa
CC=clang CXX=clang++ meson

sudo su
pip3 install meson mako
rm -f /usr/bin/python3
ln -s /usr/bin/python3.10 /usr/bin/python3

# Reset yum cache
sudo ls
sudo rm -rf /var/cache/yum/*
sudo yum clean all
sudo yum update

# Install clang
sudo tar xf llvm-install.tar.xz -C /usr
sudo cp -rf /usr/lib/x86_64-unknown-linux-gnu/* /usr/lib64/

# For git clone
sudo yum install -y ca-certificates

# For libdrm
yum install -y libpciaccess-devel

# Build drm
git clone https://gitlab.freedesktop.org/mesa/drm.git drm
mkdir drm/build
pushd drm/build
CC=clang CXX=clang++ meson --prefix=/usr
meson --prefix=/usr

# For wayland
yum install -y libxml2-devel libffi-devel expat-devel

# Build wayland
git clone https://gitlab.freedesktop.org/wayland/wayland wayland
mkdir wayland/build
pushd wayland/build
git reset --hard 1.20.0
CC=clang CXX=clang++ meson --prefix=/usr -Ddocumentation=false
sudo ninja install

# Build wayland-protocols
git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git wayland-protocols
git reset --hard 1.25
mkdir wayland-protocols/build
pushd wayland-protocols/build
CC=clang CXX=clang++ meson --prefix=/usr
ninja
sudo ninja install

# mesa deps
git clone https://github.com/KhronosGroup/glslang.git glslang
mkdir glslang/build
pushd glslang/build
CC=clang CXX=clang++  cmake .. -DCMAKE_INSTALL_PREFIX=/usr -GNinja
ninja
sudo ninja install

# For mesa
sudo yum install -y flex bison pixman-devel libXrandr-devel xorg-x11-server-devel xorg-x11-server-Xorg
sudo yum install -y libxshmfence-devel
# Build mesa
git clone https://gitlab.freedesktop.org/mesa/mesa.git mesa
CC=clang CXX=clang++ meson --prefix=/usr -D llvm=enabled -Dshared-llvm=disabled

# xf86-video-amdgpu
sudo yum install -y xorg-x11-util-macros
 ./autogen.sh --prefix=/usr
 make
 sudo make install
 
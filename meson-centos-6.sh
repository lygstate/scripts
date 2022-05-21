sudo rm -f /usr/bin/python3.10
sudo rm -rf /tmp/*
sudo bash python3-centos-6.sh

sudo ls
sudo rm -f /usr/bin/python3
sudo ln -s /usr/bin/python3.10 /usr/bin/python3
sudo pip3 install meson mako

sudo bash cmake-ninja-centos-6.sh

# Reset yum cache
sudo ls
sudo rm -rf /var/cache/yum/*
sudo yum clean all
sudo yum update 1>out.txt 2>err.txt

# Install clang
cd ~/work
sudo tar xf llvm-install.tar.xz -C /usr
sudo cp -rf /usr/lib/x86_64-unknown-linux-gnu/* /usr/lib64/
ls /usr/lib64/libc++* 

# For git clone
sudo yum install -y ca-certificates

# For libdrm
sudo yum install -y libpciaccess-devel

# Build drm
git clone https://gitlab.freedesktop.org/mesa/drm.git drm
rm -rf drm/build 
mkdir drm/build
pushd drm/build
git reset --hard libdrm-2.4.109
CC=clang CXX=clang++ meson --prefix=/usr
ninja
sudo ninja install
popd

# For wayland
sudo yum install -y libxml2-devel xz-devel libffi-devel expat-devel

# 

# Build wayland
git clone https://gitlab.freedesktop.org/wayland/wayland wayland
rm -rf wayland/build
mkdir wayland/build
pushd wayland/build
git reset --hard 1.20.0
CC=clang CXX=clang++ meson --prefix=/usr -Ddocumentation=false
ninja
sudo ninja install
popd

# Build wayland-protocols
git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git wayland-protocols
rm -rf wayland-protocols/build
mkdir wayland-protocols/build
pushd wayland-protocols/build
git reset --hard 1.25
CC=clang CXX=clang++ meson --prefix=/usr
ninja
sudo ninja install
popd

# mesa deps
git clone https://github.com/KhronosGroup/glslang.git glslang
rm -rf glslang/build
mkdir glslang/build
pushd glslang/build
git reset --hard sdk-1.3.211.0
CC=clang CXX=clang++ cmake .. -DCMAKE_INSTALL_PREFIX=/usr -GNinja
ninja
sudo ninja install
popd

# libva-devel need build from source, it's too old
# Dependency libva found: NO found 0.38.0 but need: '>= 1.8.0'

git clone https://github.com/intel/libva.git libva
rm -rf libva/build
mkdir -p libva/build
pushd libva/build
git reset --hard 2.14.0
CC=clang CXX=clang++ meson --prefix=/usr
ninja
sudo ninja install
popd

# For mesa
sudo yum install -y flex bison \
    pixman-devel \
    xorg-x11-server-devel xorg-x11-server-Xorg libxshmfence-devel libXrandr-devel \
    libvdpau-devel libXvMC-devel libXv-devel libomxil-bellagio-devel elfutils-libelf-devel


# Build mesa
git clone https://gitlab.freedesktop.org/lygstate/mesa.git mesa
mkdir -p mesa/build
pushd mesa/build
git checkout origin/22.0 
CC=clang CXX=clang++ meson --prefix=/usr \
-D llvm=enabled \
-Dshared-llvm=enabled \
-D glx=dri \
-D gbm=enabled \
-D egl=enabled \
-D platforms=x11,wayland \
-D dri3=enabled \
-D gallium-extra-hud=true \
-D gallium-vdpau=enabled \
-D gallium-va=enabled \
-D gallium-xa=enabled \
-D gallium-omx=bellagio \
-D osmesa=true \
-D buildtype=release \
-D b_lto=true \
-D b_lto_mode=thin

DESTDIR=~/work/mesa-install ninja install
cd ~/work/mesa-install/usr
tar cf ../mesa-install.tar .
cd ..
xz -T0 mesa-install.tar

# clang++ -v --for-linker --threads=64 test.cpp -o test
# ps af | cat 

ninja
sudo ninja install
popd

# For xf86-video-amdgpu
sudo yum install -y mesa-libgbm-devel

# xf86-video-amdgpu
git clone https://gitlab.freedesktop.org/xorg/driver/xf86-video-amdgpu.git xf86-video-amdgpu
pushd xf86-video-amdgpu
git reset --hard xf86-video-amdgpu-22.0.0
 ./autogen.sh --prefix=/usr
make
sudo make install
popd

export DISPLAY=":0.0"
vblank_mode=0 glxinfo
vblank_mode=0 glxgears


# Restart journal
sudo cat /var/log/messages
sudo cat /var/log/Xorg.0.log
dmesg
sudo find /var/log/journal -name "*.journal" | xargs sudo rm 
sudo systemctl restart systemd-journald

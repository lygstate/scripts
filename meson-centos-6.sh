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
ls -la /usr/lib64/libc++* 

# For git clone
sudo yum install -y ca-certificates

# For libdrm
sudo yum install -y libpciaccess-devel

# Build drm
git clone https://gitlab.freedesktop.org/mesa/drm.git drm
rm -rf drm/build 
mkdir drm/build
pushd drm/build
# git reset --hard libdrm-2.4.109
git reset --hard libdrm-2.4.110
CC=clang CXX=clang++ meson --prefix=/usr
ninja
sudo ninja install
popd

# For wayland
sudo yum install -y libxml2-devel xz-devel libffi-devel expat-devel

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

# For spirv tools
if [[ ! -f "SPIRV-Headers-sdk-1.3.211.0.tar.gz" ]]; then
    curl -LJO https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/sdk-1.3.211.0.tar.gz
fi
rm -rf SPIRV-Headers-sdk-1.3.211.0
tar xf SPIRV-Headers-sdk-1.3.211.0.tar.gz

# spirv tools
if [[ ! -f "SPIRV-Tools-2022.2.tar.gz" ]]; then
    curl -LJO https://github.com/KhronosGroup/SPIRV-Tools/archive/refs/tags/v2022.2.tar.gz
fi
rm -rf SPIRV-Tools-2022.2
tar xf SPIRV-Tools-2022.2.tar.gz
mkdir SPIRV-Tools-2022.2/build
pushd SPIRV-Tools-2022.2/build
CC=clang CXX=clang++ cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -GNinja \
    -DSPIRV-Headers_SOURCE_DIR=`pwd`/../../SPIRV-Headers-sdk-1.3.211.0

ninja
sudo ninja install
popd

# mesa deps
git clone https://github.com/KhronosGroup/glslang.git glslang
rm -rf glslang/build
mkdir glslang/build
pushd glslang/build
git reset --hard sdk-1.3.211.0
CC=clang CXX=clang++ cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -GNinja
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

if [[ ! -f "SPIRV-LLVM-Translator-14.0.0.tar.gz" ]]; then
    curl -LJO https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/refs/tags/v14.0.0.tar.gz
fi
rm -rf SPIRV-LLVM-Translator-14.0.0
tar xf SPIRV-LLVM-Translator-14.0.0.tar.gz
mkdir -p SPIRV-LLVM-Translator-14.0.0/build
pushd SPIRV-LLVM-Translator-14.0.0/build
CC=clang CXX=clang++ cmake .. \
-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -GNinja \
-DLLVM_LIBDIR_SUFFIX=64 \
-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=`pwd`/../../SPIRV-Headers-sdk-1.3.211.0

ninja llvm-spirv
sudo ninja install
sudo cp tools/llvm-spirv/llvm-spirv /usr/bin/
popd

if [[ ! -f "libclc-14.0.3.src.tar.xz" ]]; then
    curl -LJO https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.3/libclc-14.0.3.src.tar.xz
fi
rm -rf libclc-14.0.3.src
tar xf libclc-14.0.3.src.tar.xz
mkdir -p libclc-14.0.3.src/build
pushd libclc-14.0.3.src/build
CC=clang CXX=clang++ cmake .. \
-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo -GNinja

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
git checkout origin/22.1 
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
-D gallium-xvmc=enabled \
-D gallium-omx=bellagio \
-D gallium-va=enabled \
-D gallium-xa=enabled \
-D gallium-nine=true \
-D gallium-opencl=icd \
-D opencl-spirv=true \
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

sudo yum install -y xorg-x11-xtrans-devel libxkbfile-devel libXfont2-devel \
    nettle-devel libxkbcommon-devel libepoxy-devel libXdmcp-devel libinput-devel \
    libtirpc-devel dbus-devel

# Building X Server
# https://gitlab.freedesktop.org/xorg/xserver
rm -rf xserver/build
mkdir xserver/build
pushd xserver/build
git reset --hard xorg-server-1.20.14
CC=clang CXX=clang++ meson --prefix=/usr
ninja
sudo ninja install
popd

export DISPLAY=":0.0"
vblank_mode=0 glxinfo | grep renderer
vblank_mode=0 glxgears
export LIBGL_ALWAYS_SOFTWARE=true
vblank_mode=0 glxinfo | grep renderer
vblank_mode=0 glxgears

# Restart journal
sudo cat /var/log/messages
sudo cat /var/log/Xorg.0.log
dmesg
sudo find /var/log/journal -name "*.journal" | xargs sudo rm 
sudo systemctl restart systemd-journald
journalctl -b -1

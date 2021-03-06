###############################################################################
# CMake
###############################################################################

# Selecting a compiler must be done on the first run in an empty directory.
# It's not CMake syntax per se, but you might not be familiar with it. To pick Clang:
#   CC=clang CXX=clang++ cmake ..
cmg() {
    compdef cmb=cmake
    compdef cmg=cmake
    compdef cmc=cmake

    logAndRun cmake ${CMG_BUILD_TOOL:+-G"$CMG_BUILD_TOOL"} "${CMG_COMPILER_OPTS[@]}" $CMG_OPTS -S . -B "$CMG_BUILD_DIR" "$@"
    echo
}

cmb() {
    compdef cmb=cmake
    compdef cmg=cmake
    compdef cmc=cmake

    [ -e build ] || cmg || return 1

    if (( $# ==0 )); then
        logAndRun cmake $CMB_OPTS --build "$CMG_BUILD_DIR" # CMake 3.15+ only
    else
        logAndRun cmake $CMB_OPTS --build "$CMG_BUILD_DIR" --target "$@"
    fi
}

alias cmc='cmb clean'

__swCMakeCompiler() {
    local compiler="$1"

    case "$compiler" in
    mac*)
        unset CMG_COMPILER_OPTS
        CMG_COMPILER=mac-clang
        CMG_BUILD_DIR="build-cmake-$CMG_COMPILER${CMG_BT:+-$CMG_BT}"
        ;;
    *gcc)
        CMG_COMPILER_OPTS=(
            -DCMAKE_C_COMPILER=$(echo /usr/local/opt/gcc/bin/gcc-[0-9]*)
            -DCMAKE_CXX_COMPILER=$(echo /usr/local/opt/gcc/bin/c++-[0-9]*)
        )
        CMG_COMPILER=brew-gcc
        CMG_BUILD_DIR="build-cmake-$CMG_COMPILER${CMG_BT:+-$CMG_BT}"
        ;;
    *clang)
        CMG_COMPILER_OPTS=(
            -DCMAKE_C_COMPILER=/usr/local/opt/llvm/bin/clang
            -DCMAKE_CXX_COMPILER=/usr/local/opt/llvm/bin/clang++
        )
        CMG_COMPILER=brew-clang
        CMG_BUILD_DIR="build-cmake-$CMG_COMPILER${CMG_BT:+-$CMG_BT}"
        ;;
    *)
        return 1
    esac
}

__swCMakeCompiler "mac clang"

swCMakeCompiler() {
    local compiler
    select compiler in 'mac default' 'brew gcc' 'brew clang'; do
        __swCMakeCompiler "$compiler" && break
    done
}

__swCMakeBuildTool() {
    local bt="$1"

    case "$bt" in
    make*)
        unset CMG_BUILD_TOOL CMG_BT
        CMG_BUILD_DIR="build-cmake-$CMG_COMPILER${CMG_BT:+-$CMG_BT}"
        ;;
    ninja*)
        CMG_BUILD_TOOL='Ninja'
        CMG_BT='ninja'
        CMG_BUILD_DIR="build-cmake-$CMG_COMPILER${CMG_BT:+-$CMG_BT}"
        ;;
    *)
        return 1
    esac
}

###############################################################################
# vcpkg
###############################################################################

alias vp='vcpkg'
alias vps='vcpkg search'
alias vpi='vcpkg install'
alias vpl='vcpkg list'

#VP_CM_OPT='-DCMAKE_TOOLCHAIN_FILE=/Users/jerry/Codes/practices/cpp/vcpkg/scripts/buildsystems/vcpkg.cmake'
VP_CM_PATH='/usr/local/opt/vcpkg/libexec/scripts/buildsystems/vcpkg.cmake'
VP_CM_OPT="-DCMAKE_TOOLCHAIN_FILE=$VP_CM_PATH"
# CMG_OPTS="$VP_CM_OPT"

# Enable VCpkg CMake Generation support
evcmg() {
    logAndRun set "CMG_OPTS=$CMG_OPTS"
}

# Disable VCpkg CMake Generation support
dvcmg() {
    logAndRun unset CMG_OPTS
}

attach_vcpkg_gcc() {
    export CPATH=/usr/local/var/vcpkg/installed/x64-osx/include
    export LIBRARY_PATH=/usr/local/var/vcpkg/installed/x64-osx/lib
}

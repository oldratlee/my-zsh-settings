# Selecting a compiler must be done on the first run in an empty directory.
# It's not CMake syntax per se, but you might not be familiar with it. To pick Clang:
#   CC=clang CXX=clang++ cmake ..
alias cmg='cmake -S . -B build'

cmb() {
    if (( $# ==0 )); then
        cmake --build build # CMake 3.15+ only
    else
        cmake --build build --target "$@"
    fi
}
#compdef cmb=cmake

alias cmc='cmb clean'

my_update() {
    my_update_npm

    echo
    pp brew update -v && logAndRun brew upgrade -y

    echo
    pp sdk selfupdate && logAndRun sdk update && yes | logAndRun sdk upgrade

    echo
    my_update_git_repo
}

my_update_git_repo() {
    gur $OS_SKILL_REPO_DIR ~/.oh-my-zsh ~/.tmux* ~/.vim* ~/.spf13-vim-3
}

my_update_npm() {
    infoInteractive npm check global package update:
    local o
    o=$(ncu -g)
    echo "$o"
    o=$(command rg '^npm -g install' <<<"$o")
    if [ -n "$o" ]; then
        logAndRun $=o
    fi
}

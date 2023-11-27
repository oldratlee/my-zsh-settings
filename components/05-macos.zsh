# macOS 10.15 Catalina xxx.app已损坏，无法打开，你应该将它移到废纸篓解决方法
# https://www.macwk.com/article/mac-catalina-1015-file-damage

[[ "$(uname)" = Darwin* ]] || return 0

disableAppSecurity() {
    sudo spctl --master-disable

    local app
    for app; do
        logAndRun sudo xattr -rd com.apple.quarantine "$app"
    done

    {
        sleep 30
        sudo spctl --master-enable
    } &
}

enableAppSecurity() {
    sudo spctl --master-enable
}

# mac辅助功能授权无效
# https://blog.csdn.net/nicekwell/article/details/117768278
alias ResetAccessibility='sudo tccutil reset Accessibility'


# mdfind - Disable debug output: [UserQueryParser] Loading keywords and predicates for locale
# https://developer.apple.com/forums/thread/728927
mdfind() {
    command mdfind "$@" 2> >(
        rg --line-buffered -Fv ' [UserQueryParser] Loading keywords and predicates for locale ' >&2
    )
}

# MdFind Directories
mfd() {
    local f
    mdfind -name "$@" | while IFS= read -r f; do
        [ -d "$f" ] && printf '%s\n' "$f"
    done | sort
}
compdef mfd=mdfind


###############################################################################
# Brew
###############################################################################

# help/man within brew
hb() {
    [ -z "$__hb_man_path_" ] && __hb_man_path_=$(echo /usr/local/opt/*/share/man | tr ' ' :)
    (
        export MANPATH="$__hb_man_path_:$MANPATH"
        run-help "$@"
        # man "$@"
    )
}
compdef hb=run-help


# Ubuntu’s command-not-found equivalent for Homebrew on macOS
# https://github.com/Homebrew/homebrew-command-not-found
#if [ -e "$ZSH/cache/homebrew-command-not-found-init" ]; then
#    eval "$(cat "$ZSH/cache/homebrew-command-not-found-init")"
#
#    (( $(date -r "$ZSH/cache/homebrew-command-not-found-init" +%s) < $(date -d 'now - 7 days' +%s) )) && (
#        touch "$ZSH/cache/homebrew-command-not-found-init"
#        # backgroud proccess that run in subshell will not output job control message
#        brew command-not-found-init > "$ZSH/cache/homebrew-command-not-found-init" &
#    )
#else
#    # backgroud proccess that run in subshell will not output job control message
#    ( brew command-not-found-init > "$ZSH/cache/homebrew-command-not-found-init" & )
#fi


export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_AUTO_UPDATE_SECS=$((3600 * 48))
#export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
# https://docs.brew.sh/FAQ#how-can-i-keep-old-versions-of-a-formula-when-upgrading
export HOMEBREW_NO_INSTALL_CLEANUP=1

alias b=brew

alias bi='brew info'
alias bci='brew info --cask'
alias bls='brew list'

alias bs='brew search'
alias bh='brew home'

alias bin='brew install'
alias bcin='brew install --cask'
alias bui='brew uninstall'
alias bcui='brew uninstall --cask'
alias bri='brew reinstall'
alias bcri='brew reinstall --cask'


upMyBrew() {
    local fast_mode=false
    if [ "$1" = fast ]; then
        local fast_mode=true
    fi
(
    unset HOMEBREW_NO_AUTO_UPDATE
    unset HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK

    if ! $fast_mode; then
        #logAndRun brew unlink homebrew/cask/macvim &&
        pp logAndRun brew update &&
        logAndRun brew upgrade vim &&
        logAndRun brew unlink vim &&
        logAndRun brew upgrade homebrew/cask/macvim &&
        logAndRun brew link --overwrite vim
    fi
    logAndRun brew upgrade
    # && pp brew upgrade $(brew ls --cask) &&
)
}

baddpath() {
    local formula="$1"
    for formula in "$@"; do
        local bin="/usr/local/opt/$formula/bin"
        [ -d "$bin" ] || {
            errorEcho "$formula($bin) not existed!"
            continue
        }

        PATH=${PATH//$bin} # remove existed in PATH
        PATH="$bin:$PATH"  # add to first element in PATH
        export PATH=${PATH//::/:} # cleanup
    done
}

brmpath() {
    local formula="$1"
    for formula in "$@"; do
        local bin="/usr/local/opt/$formula/bin"

        PATH=${PATH//$bin} # remove existed in PATH
        export PATH=${PATH//::/:} # cleanup
    done
}

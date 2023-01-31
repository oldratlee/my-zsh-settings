###############################################################################
# Env settings
###############################################################################

# Disable CTRL-D from closing my window with the terminator terminal emulator)
#   https://unix.stackexchange.com/a/139121/136953
(( $SHLVL == 1 )) && set -o ignoreeof

export LANG=en_US.UTF-8
export LC_CTYPE=UTF-8
export EDITOR=vim

# iTerm2 supports true colors, however, there's no official way of advertising this feature.
#   https://gitlab.com/gnachman/iterm2/-/issues/5294
# Variables are used to communicate information between components such as Python scripts and shell scripts.
#   https://iterm2.com/documentation-variables.html
# enable true-color support by default #1271
#   https://github.com/helix-editor/helix/issues/1271
[ -n "$ITERM_PROFILE" ] && export COLORTERM=truecolor

export WINEDEBUG=-all

HISTSIZE=50000
SAVEHIST=50000

# ignore commands that start with space
setopt hist_ignore_space

# https://superuser.com/questions/519596/share-history-in-multiple-zsh-shell
# To save every command before it is executed (this is different from bash's history -a solution):
setopt inc_append_history
#To retrieve the history file everytime history is called upon.
setopt share_history

# append brew man
# export MANPATH="$(cat $ZSH_CACHE_DIR/man_path_cache):$MANPATH"

# man with brew
mb() { (
    export MANPATH="$(echo /usr/local/opt/*/share/man | tr ' ' :):$MANPATH"
    man "$@"
) }

# linux - How can I read documentation about built in zsh commands? - Stack Overflow
# https://stackoverflow.com/questions/4405382
# Is there a zsh equivalent to the bash `help` builtin? - Super User
# https://superuser.com/questions/1563825
alias help=run-help
alias h=run-help

export PATH="$HOME/.local/bin:$HOME/bin:$HOME/bin/useful-scripts/bin:$PATH"
# Calibre utils, brew texinfo
#export PATH="/usr/local/opt/texinfo/bin:$PATH:/Applications/calibre.app/Contents/MacOS"

###############################################################################
# Shell Imporvement
###############################################################################

### shell settings ###

# set color theme of ls in terminal to GNU/Linux Style
# use `which gdircolors` instead of `brew list | grep coreutils -q` for speedup
which gdircolors &> /dev/null && {
    alias ls='ls --show-control-chars --color=auto'
    eval `gdircolors -b <(gdircolors --print-database)`
}

# how to make ctrl+p behave exactly like up arrow in zsh?
# http://superuser.com/questions/583583
#bindkey '^P' up-line-or-search
#bindkey '^N' down-line-or-search

# https://github.com/zdharma/history-search-multi-word#introduction
zstyle :plugin:history-search-multi-word reset-prompt-protect 1

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

# open file with default application
for ext in doc{,x} ppt{,x} xls{,x} key pdf png jp{,e}g htm{,l} m{,k}d markdown asta txt xml xmind java c{,pp} .h{,pp}; do
    alias -s $ext=open
done

### core utils ###

export LESS="${LESS}iXF"

pt() {
    pstree "$@" | coat -n
}

pts() {
    pt -s "$@"
}

ptp() {
    pt -p "${@:-$$}"
}
compdef ptp=kill
ptpp() {
    pt -p $PPID
}


alias du='du -h'
alias nd='ncdu --confirm-quit --show-percent --graph-style=half-block'
#alias df='command df -h'
alias df='/bin/df -h | sort -k3,3h'

if which lsd &> /dev/null; then
    unalias ls &> /dev/null
    alias ls='command lsd'
fi

alias ll='ls -lh'

alias lld='ll -d'
alias lsd='ls -d'

alias lsr='ls -r'
alias llr='ll -r'

# sort by size
alias lss='ls -Sr'
alias lls='ll -Sr'
# sort by version
alias lsv='ls -v'
alias llv='ll -v'
# sort by modification time
alias lst='ls -tr'
alias llt='ll -tr'
# sort by creation time
alias lsc='command ls --color=auto -t --time=creation -r'
alias llc='command ls --color=auto -l -t --time=creation -r'


alias rr=ranger

alias tailf='tail -f'
alias btee='col -b | tee'
compdef btee=tee

alias D=colordiff
alias diff=colordiff
alias bcp=bcompare

alias grep='grep --color=auto --exclude-dir={.git,.hg,.svn,.cvs,bzr,CVS,target,.mvn,.gradle,.settings,build,_site,.idea,Pods,taobao-tomcat} --exclude=\*.{ipr,iml,iws,jar,war,zip,tmp}'
export GREP_COLORS='mt=1;7;33'

alias rg='rg --colors=match:bg:yellow --colors=match:fg:0,0,0'
alias rgw='rg -w'
alias rgi='rg -i'
alias rgF='rg -F'
alias rgP='rg -P'
alias rgl='rg -l'
alias rgv='rg -v'
alias rga='rg -uuu'

alias fdi='fd -i'
alias fda='fd -HI'
alias fdd='fd --type d'

# https://github.com/facebook/zstd/issues/1526
alias tzst='tar --use-compress-program zstd -cvf'


# MdFind Directories
mfd() {
    local clear_line=$'\033[2K\r' f
    mdfind "$@" | while IFS= read -r f; do
        [ -d "$f" ] && {
            echo "$f"
        }
    done | sort
}

# Remove duplicate entries in a file without sorting
# http://www.commandlinefu.com/commands/view/4389
# alias uq="awk '!x[\$0]++'"

# show type -a and which -a info together, very convenient!
ta() {
    echo "type -a:\n"
    # type buildin command can output which file the function is definded. COOL!
    type -a "$@"
    echo "\nwhich -a:\n"
    # which buildin command can output the function implementation. COOL!
    which -a "$@"
}
# Tab completion for aliased sub commands in zsh: alias gco='git checkout'
# Reload auto completion
#   zsh -f && autoload -Uz compinit && compinit
# http://stackoverflow.com/questions/14307086
compdef ta=type

### editor ###

alias vi=vim

alias v=vim
alias v8='vim -c "set tabstop=8"'
alias v4='vim -c "set tabstop=4"'

alias vv='col -b | v -'
alias vv8='col -b | v -c "set tabstop=8 | retab" -'
alias vv4='col -b | v -c "set tabstop=4 | retab" -'
alias vw='v -R'
alias vd='v -d'

alias nv=nvim
alias nvv='col -b | nv -'
alias nvv8='col -b | nv -c "set tabstop=8 | retab" -'
alias nvv4='col -b | nv -c "set tabstop=4 | retab" -'
alias nvw='nv -R'
alias nvd='nv -d'

alias lv=lvim
alias lvv='col -b | lv -'
alias lvv8='col -b | lv -c "set tabstop=8 | retab" -'
alias lvv4='col -b | lv -c "set tabstop=4 | retab" -'
alias lvw='lv -R'
alias lvd='lv -d'

#alias gv=gvim
gv() {
    gvim "$@"
    return

    local im=$(xkbswitch -g)

    if [ $im != 0 ]; then
        xkbswitch -s 0
        sleep 0.1
    fi

    gvim "$@"

    if [ $im != 0 ]; then
        sleep 0.1
        xkbswitch -s $im
    fi
}

alias gvv='col -b | gv -'
alias gvv8='col -b | gv -c "set tabstop=8 | retab" -'
alias gvv4='col -b | gv -c "set tabstop=4 | retab" -'
alias gvw='gv -R'
alias gvd='gv -d'

alias note='(cd ~/notes; gv)'

vc() {
    (( $# == 0 )) && local -a files=( . ) || local -a files=( "$@" )

    local vc_app_dirs=(
        '/Applications/Visual Studio Code.app'
        "$HOME/Applications/Visual Studio Code.app"
    )
    local vc_app
    for vc_app in "${vc_app_dirs[@]}"; do
        [ -d "$vc_app" ] && break
    done

    local f isFirst=true
    for f in "${files[@]}"; do
        $isFirst && isFirst=false || sleep 1

        echo "Visual Studio Code open $f"
        open -a "$vc_app" "$f"
    done
}

vs() {
    (( $# == 0 )) && local -a files=( . ) || local -a files=( "$@" )
    for f in "${files[@]}"; do
        echo "Visual Studio open $f"
        open -a '/Applications/Visual Studio.app' "$f"
    done
}

### mac utils ###

o() {
    if (( $# == 0 )); then
        open .
    else
        open "$@"
    fi
}
compdef o=open
alias o..='open ..'


#export HOMEBREW_NO_AUTO_UPDATE=1
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
(
    unset HOMEBREW_NO_AUTO_UPDATE
    unset HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK

    #logAndRun brew unlink homebrew/cask/macvim &&
    pp logAndRun brew update &&
    logAndRun brew upgrade vim &&
    logAndRun brew unlink vim &&
    logAndRun brew upgrade homebrew/cask/macvim &&
    logAndRun brew link --overwrite vim &&
    logAndRun brew upgrade
    # && pp brew upgrade $(brew ls --cask) &&
)
}

upMyConfGitRepo() {
    # update config git repo
    #
    # ~/.config/lvim is contained in ~/.config
    logAndRun gur \
        ~/.*vim/ \
        ~/.local/share/lunarvim/ \
        ~/.config/ \
        ~/.oh-my-zsh/ \
        ~/.tmux*/ \
        ~/.vcpkg/

}


### zsh/oh-my-zsh redefinition ###

# improve alias d of oh-my-zsh: colorful lines, near index number and dir name(more convenient for human eyes)
alias d="dirs -v | head | sed 's/\t/ <=> /' | coat"

### tools ###

alias t=tmux

# tmux create or attach
tca() {
    if tmux ls &> /dev/null; then
        tmux attach
    else
        exec tmux
    fi
}

alias scc='scc -s Code'
alias ts='trash -F'

# speed up download
alias ax='axel -n8'
alias axl='axel -n16'

# fpp is an awesome toolkit: https://github.com/facebook/PathPicker
## reduce exit time of fpp by resetting shell to bash
alias fpp='SHELL=/bin/bash fpp'
alias p=fpp

alias f=fzf
alias pwsh='pwsh -NoLogo'

### network ###

isTcpPortListening() {
    # How to check whether a particular port is open on a machine from a shell script and perform action based on that?
    # https://unix.stackexchange.com/questions/149419
    local port="$1"
    lsof -nPi :$port -sTCP:LISTEN -t &> /dev/null
}

lstcp() {
    local is_interactive=false
    [ "$1" = -i ] && {
        is_interactive=true
        shift
    }

    local stcp="$1" s
    [[ -z "$stcp" && $is_interactive == true ]] && {
        select s in ESTABLISHED SYN_SENT SYN_RCDV LAST_ACK TIME_WAIT FIN_WAIT1 FIN_WAIT_2 CLOSE_WAIT CLOSING CLOSED LISTEN IDLE BOUND; do
            [ -n "$s" ] && {
                stcp="$s"
                break
            }
        done
    }

    lsof -n -P -iTCP ${stcp:+"-sTCP:$stcp"}
}

# List tcp listen port info(very useful on mac)
#
# inhibits the conversion so as to run faster
#   -P inhibits the conversion of port numbers to port names
#   -n inhibits the conversion of network numbers to host names
alias tcplisten='lstcp LISTEN'


alias pc='proxychains4 -q'
pp() {
    if [ -n "${SKIP_PP+defined}" ]; then
        echoInteractiveInfo "run without proxy: $*"
        "$@"
        return
    fi

    local port
    [ "$1" = "-p" ] && {
        port=$2
        shift 2
    }

    if [ -z "$port" ]; then
        local -r proxy_ports=(7070)

        for port in $proxy_ports; do
            isTcpPortListening $port && break
        done
    fi

    [ -n "$port" ] || {
        errorEcho "proxy ports is not opened: $proxy_ports"
        return 1
    }

    echoInteractiveInfo "use proxy port $port: $*"
    (
        export https_proxy=http://127.0.0.1:$port
        export http_proxy=http://127.0.0.1:$port
        export ftp_proxy="$https_proxy"
        export JAVA_OPTS="${JAVA_OPTS:+$JAVA_OPTS }-DproxySet=true -DsocksProxyHost=127.0.0.1 -DsocksProxyPort=$port"
        "$@"
    )
}
compdef pp=time

### markdown ###

# adjust indent for space 4
toc () {
  command doctoc --notitle "$@" &&
    sed '/<!-- START doctoc generated TOC/,/<!-- END doctoc generated TOC/s/^( +)/\1\1/' -ri "$@"
}

badges() {
    printf 'githubstar: ![GithubStar](https://img.shields.io/github/stars/%s.svg?style=social&label=Star&maxAge=3600)\n' "$1"
    printf 'maven version: ![MavenCentral](https://img.shields.io/maven-central/v/%s.svg)\n' "$1"
}

# generate an image showing a mathematical formula, using the TeX language by Google Charts
# https://developers.google.com/chart/infographics/docs/formulas
fml() {
    local url=$(printf 'http://chart.googleapis.com/chart?cht=tx&chf=bg,s,00000000&chl=%s\n' "$(urlencode "$1")")
    printf '<img src="%s" style="border:none;" alt="%s" />\n' "$url" "$1" | c
    # imgcat <(curl -s "$url")
    # o $url
}

alias otv=octave-cli

### my utils ###

alias cap='c ap'

# print and copy full path of command bin
capw() {
    local arg
    for arg; do
        ap "$(whence -p "$arg")"
    done | c
}
compdef capw=type

alias cq='c -q'
compdef coat=cat
alias awl=a2l

coatOneScreen() {
    if [ -t 1 ]; then
        head -n $((LINES - 5)) | coat "$@"
    else
        cat "$@"
    fi
}

catOneScreen() {
    if [ -t 1 ]; then
        head -n $((LINES - 5)) | cat "$@"
    else
        cat "$@"
    fi
}

tailOneScreen() {
    if [ -t 1 ]; then
        gtail "$@" -n $((LINES - 5))
    else
        gtail "$@"
    fi
}

tailOneScreen() {
    tail -n $((LINES - 5))
}

alias vzshrc='v ~/.zshrc'

# ReStart SHell
rsh() {
    # just rerun zsh
    exec "$SHELL" -li

    # How to reset a shell environment? https://unix.stackexchange.com/questions/14885
    exec env -i \
        TERM=$TERM TERM_PROGRAM=$TERM_PROGRAM TERM_PROGRAM_VERSION=$TERM_PROGRAM_VERSION TERM_SESSION_ID=$TERM_SESSION_ID \
        ITERM_PROFILE=$ITERM_PROFILE ITERM_SESSION_ID=$ITERM_SESSION_ID \
        TMUX=$TMUX TMUX_PANE=$TMUX_PANE \
        XPC_FLAGS=$XPC_FLAGS XPC_SERVICE_NAME=$XPC_SERVICE_NAME \
        __CF_USER_TEXT_ENCODING=$__CF_USER_TEXT_ENCODING \
        Apple_PubSub_Socket_Render=$Apple_PubSub_Socket_Render \
        SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
        USER=$USER LOGNAME=$LOGNAME SHELL=$SHELL \
        TMPDIR=$TMPDIR DISPLAY=$DISPLAY COLORFGBG=$COLORFGBG \
        "$@" \
        zsh --login -i
}


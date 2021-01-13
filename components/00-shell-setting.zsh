###############################################################################
# Env settings
###############################################################################

export EDITOR=vim
export LANG=en_US.UTF-8
export LC_CTYPE=UTF-8
export WINEDEBUG=-all

HISTSIZE=50000
SAVEHIST=50000

# append brew man
#export MANPATH="$(cat $ZSH_CACHE_DIR/man_path_cache):$MANPATH"

export PATH="$HOME/bin:$HOME/bin/useful-scripts/bin:$PATH"
# Calibre utils, brew texinfo
#export PATH="/usr/local/opt/texinfo/bin:$PATH:/Applications/calibre.app/Contents/MacOS"

###############################################################################
# Shell Imporvement
###############################################################################

### shell settings ###

# set color theme of ls in terminal to GNU/Linux Style
# use `which gdircolors` instead of `brew list | grep coreutils -q` for speedup
which gdircolors &> /dev/null && {
    alias ls='ls -F --show-control-chars --color=auto'
    eval `gdircolors -b <(gdircolors --print-database)`
}

# how to make ctrl+p behave exactly like up arrow in zsh?
# http://superuser.com/questions/583583
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

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

alias pt=pstree
alias du='du -h'
#alias df='df -h'
alias df='/bin/df -h | sort -k3,3h'

alias ll='ls -lh'
alias lls='ll -Sr'
alias llv='ll -v'
alias llt='ll -tr'
alias llr='ll -r'

alias rr=ranger

alias tailf='tail -f'
alias btee='col -b | tee'
compdef btee=tee

alias D=colordiff
alias diff=colordiff

alias grep='grep --color=auto --exclude-dir={.git,.hg,.svn,.cvs,bzr,CVS,target,.mvn,.settings,build,_site,.idea,Pods,taobao-tomcat} --exclude=\*.{ipr,iml,iws,jar,war,zip,tmp}'
export GREP_COLOR='1;7;33'

export LESS="${LESS}iXF"

# Remove duplicate entries in a file without sorting
# http://www.commandlinefu.com/commands/view/4389
alias uq="awk '!x[\$0]++'"

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
alias vv='col -b | v -'
alias vw='v -R'
alias vd='v -d'

alias nv=nvim
alias nvv='col -b | nv -'
alias nvw='nv -R'
alias nvd='nv -d'

alias gv=gvim
alias gvv='col -b | gv -'
alias gvw='gv -R'
alias gvd='gv -d'

alias note='(cd ~/notes; gv)'

function vc {
    (( $# == 0 )) && local -a files=( . ) || local -a files=( "$@" )
    open -a "$HOME/Applications/Visual Studio Code.app" "${files[@]}"
    echo "Visual Studio Code open ${files[@]}"
}

### mac utils ###

alias o=open
alias o.='open .'
alias o..='open ..'


export HOMEBREW_NO_AUTO_UPDATE=1

alias b=brew

alias bi='brew info'
alias bci='brew cask info'
alias bls='brew list'

alias bs='brew search'
alias bh='brew home'

alias bin='brew install'
alias bcin='brew cask install'
alias bui='brew uninstall'
alias bcui='brew cask uninstall'
alias bri='brew reinstall'
alias bcri='brew cask reinstall'

### zsh/oh-my-zsh redefinition ###

# improve alias d of oh-my-zsh: colorful lines, near index number and dir name(more convenient for human eyes)
alias d="dirs -v | head | sed 's/\t/ <=> /' | coat"

### tools ###

alias t=tmux
alias tma='exec tmux attach'

alias sl=sloccount
alias ts=trash

# speed up download
alias ax='axel -n8'
alias axl='axel -n16'

# fpp is an awesome toolkit: https://github.com/facebook/PathPicker
## reduce exit time of fpp
alias fpp='SHELL=/bin/bash fpp'
alias p=fpp

alias pc='proxychains4 -q'
pp() {
    (
        export https_proxy=socks5://127.0.0.1:7070 http_proxy=socks5://127.0.0.1:7070
        export JAVA_OPTS="${JAVA_OPTS:+$JAVA_OPTS }-DproxySet=true -DsocksProxyHost=127.0.0.1 -DsocksProxyPort=7070"
        "$@"
    )
}
compdef pp=time

lstcp() {
    lsof -n -P -iTCP ${1:+"-sTCP:$1"}
}

ilstcp() {
    local st
    select st in ESTABLISHED SYN_SENT SYN_RCDV LAST_ACK TIME_WAIT FIN_WAIT1 FIN_WAIT_2 CLOSE_WAIT CLOSING CLOSED LISTEN IDLE BOUND; do
        [ -n "$st" ] && {
            lstcp "$st"
            break
        }
    done
}

# List tcp listen port info(very useful on mac)
#
# inhibits the conversion so as to run faster
#   -P inhibits the conversion of port numbers to port names
#   -n inhibits the conversion of network numbers to host names
alias tcplisten='lstcp LISTEN'

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
#
# print and copy full path of command bin
capw() {
    local arg
    for arg; do
        ap "$(whence -p "$arg")" | c
    done
}
compdef capw=type

compdef coat=cat
alias awl=a2l

alias vzshrc='v ~/.zshrc'

# ReStart SHell
# How to reset a shell environment? https://unix.stackexchange.com/questions/14885
rsh() {
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

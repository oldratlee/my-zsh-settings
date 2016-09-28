###############################################################################
# Env settings
###############################################################################

export SVN_EDITOR=vim
export EDITOR=vim
#export SHELL=/bin/bash
export LANG=en_US.UTF-8
export LESS="${LESS}iXF"


###############################################################################
# Shell Imporvement
###############################################################################

### shell settings ###

if brew list | grep coreutils > /dev/null ; then
    alias ls='ls -F --show-control-chars --color=auto'
    eval `gdircolors -b <(gdircolors --print-database)`
fi

# Use Ctrl-Z to switch back to backgroud proccess(Vim)
# https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# how to make ctrl+p behave exactly like up arrow in zsh?
# http://superuser.com/questions/583583/how-to-make-ctrlp-behave-exactly-like-up-arrow-in-zsh
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

### shell alias ###

alias d="dirs -v | head | tr '\t' ' ' | colines"

alias wa='which -a'
alias ta='type -a'
alias o=open
alias o.='open .'
alias o..='open ..'
alias du='du -h'
alias df='df -h'
alias ll='ls -lh'
alias tailf='tail -f'
# alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=target --exclude-dir=.idea'
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=target --exclude-dir=build --exclude-dir=_site --exclude-dir=.idea --exclude-dir=taobao-tomcat --exclude=\*.ipr --exclude=\*.iml --exclude=\*.iws --exclude=\*.jar'
export GREP_COLOR='07;31'

alias diff=colordiff
alias D=colordiff

alias cap='c ap'

alias v=vim
# http://stackoverflow.com/questions/14307086/tab-completion-for-aliased-sub-commands-in-zsh-alias-gco-git-checkout
compdef v=vim
alias vd=vimdiff
alias vi=vim
compdef vi=vim
alias gv=gvim
alias nv=nvim
alias gvd=gvimdiff

alias e=emacs
# compdef e=emacs

alias a='atom'
alias a.='atom .'
alias a..='atom ..'
alias t=tmux
compdef t=tmux

# speed up download
alias axel='axel -n8'
# reduce exit time of fpp
alias fpp='SHELL=sh fpp'
alias p='SHELL=sh fpp'

# adjust indent for space 4
toc() {
    command doctoc --notitle "$@" && sed '/<!-- START doctoc generated TOC/,/<!-- END doctoc generated TOC/s/^( +)/\1\1/' -ri "$@"
}

###############################################################################
# Java
###############################################################################

export MAVEN_OPTS="-Xmx512m"

switchJavaNetProxy() {
    [ -z "$JAVA_OPTS_BEFORE_NET_PROXY"] && {
        export JAVA_OPTS_BEFORE_NET_PROXY="$JAVA_OPTS"
        export JAVA_OPTS="$JAVA_OPTS -DproxySet=true -DsocksProxyHost=127.0.0.1 -DsocksProxyPort=7070"
        echo "turn ON java net proxy!"
    }|| {
        export JAVA_OPTS="$JAVA_OPTS_BEFORE_NET_PROXY"
        unset JAVA_OPTS_BEFORE_NET_PROXY
        echo "turn off java net proxy!"
    }
}

ads-jre-link2idea() {
    (cd /Applications/Android*Studio.app/Contents && ln -s /Users/jerry/ProgFiles/idea-jre jre)
}

alias j6='export JAVA_HOME=$JAVA6_HOME'
alias j7='export JAVA_HOME=$JAVA7_HOME'
alias j8='export JAVA_HOME=$JAVA8_HOME'


###############################################################################
# Erlang
###############################################################################

alias r2=rebar
compdef r2=rebar
alias r3=rebar3
# compdef r3=rebar3

# Run erlang MFA(Module-Function-Args) conveniently
erun() {
    if [ $# -lt 2 ]; then
        echo "Error: at least 2 args!"
        return 1
    fi
    erl -s "$@" -s init stop -noshell
}

# Run erlang one-line script conveniently
erline() {
    if [ $# -ne 1 ]; then
        echo "Error: Only need 1 arg!"
        return 1
    fi
    erl -eval "$1" -s init stop -noshell
}

###############################################################################
# Python
###############################################################################

alias py='python'
alias py2='python2'
alias py3='python3'
alias ipy='ipython'
alias ipy2='ipython2'
alias ipy3='ipython3'

ZSH_PIP_INDEXES='http://pypi.douban.com/simple/'

alias pip='pip --trusted-host pypi.douban.com'
alias pip2='pip2 --trusted-host pypi.douban.com'
alias pip3='pip3 --trusted-host pypi.douban.com'
compdef pip=pip
compdef pip2=pip
compdef pip3=pip

# use default virtualenv of python 2
type deactivate > /dev/null && deactivate
source /Users/jerry/.virtualenv/default/bin/activate
# Python Virtaul Env
pve() {
    local venv_path=/Users/jerry/.virtualenv
    echo "current VIRTUAL_ENV: $VIRTUAL_ENV"

    echo "select python virtual env to activate:"
    local venv
    select venv in `find $venv_path -maxdepth 1 -mindepth 1 -type d`; do
        [ -n "$venv" ] && {
            [ -n "$VIRTUAL_ENV" ] && deactivate
            source "$venv/bin/activate"
            break
        }
    done
}

relink_virtualenv() {
    (
        cd /Users/jerry/.virtualenv
        find -type l -xtype l -delete
        local d
        for d in *; do
            virtualenv $d
        done
    )
}

###############################################################################
# Prolog
###############################################################################
alias gpl='gprolog'
alias sp='/Applications/SWI-Prolog.app/Contents/MacOS/swipl'
alias bp='/Users/jerry/ProgFiles/BProlog/bp'

###############################################################################
# Lisp
###############################################################################

CLISP_DOC=/usr/local/Cellar/clisp/2.49/share/doc/clisp/doc

alias schm='rlwrap -p 1\;32 -r -c -f $HOME/.scheme_completion.rlwrap scheme'
alias scl='scala -Dscala.color -feature'

###############################################################################
# Gradle
###############################################################################

#export GRADLE_OPTS="-Xmx1024m -Xms256m -XX:MaxPermSize=512m"
# --daemon
alias grd='gradle'
function grw() {
    local d="$PWD"
    while true; do
        [ "/" = "$d" ] && {
            echo "fail to find gradlew" 2>&1
            return 1
        }
        [ -f "$d/gradlew" ] && {
            break
        }
        d=`dirname "$d"`
    done

    [ $d != $PWD ] && echo "use gradle wrapper: $(realpath "$d" --relative-to="$PWD")/gradlew"
    "$d/gradlew" "$@"
}
alias grwf='grw --refresh-dependencies'
alias grwb='grw build'
alias grwfb='grw --refresh-dependencies build'
alias grwc='grw clean'
alias grwfc='grw --refresh-dependencies clean'
alias grwcb='grw clean build'
alias grwfcb='grw --refresh-dependencies clean build'

alias grwt='grw test'
alias grwd='grw -q dependencies'
alias grwdc='grw -q dependencies --configuration compile'
alias grwdr='grw -q dependencies --configuration runtime'
alias grwdtc='grw -q dependencies --configuration testCompile'

alias kgrdm="jps -l | awk '\$2==\"org.gradle.launcher.daemon.bootstrap.GradleDaemon\"{print \$1}' | xargs -r kill -9"
alias sgrdm="jps -l | awk '\$2==\"org.gradle.launcher.daemon.bootstrap.GradleDaemon\"{print \$0}'"

###############################################################################
# Git
###############################################################################
compdef g=git

alias gu='git up'

alias ga.='git add .'
alias ga..='git add ..'
alias gcoh='git checkout HEAD'

# alias gd > /dev/null && unalias gd
function gdc() {
    git diff --cached --color "$@" | diff-so-fancy | less --tabs=1,5 -iRFX
}
function gds() {
    if [ $# -eq 0 ]; then
        from=@^
        to=@
    elif [ $# -eq 1 ]; then
        from="$1^"
        to="$1"
    else
        from="$1"
        to="$2"
    fi
    git diff --color "$from" "$to" | diff-so-fancy | less --tabs=1,5 -iRFX
}
function gdh() {
    git diff --color HEAD "$@" | diff-so-fancy | less --tabs=1,5 -iRFX
}
alias gdorigin='git diff origin/$(git_current_branch)'

alias gssi='git status -s --ignored'
alias gsti='git status --ignored'
alias gg='glog -15'
alias sg='open -a /Applications/SmartGit.app'

alias grb='git rebase'
alias grs='git reset'
alias grshd='git reset --hard'
alias grsorigin='git reset --hard origin/$(git_current_branch)'

alias gam='git commit --amend -v'
alias gamno='git commit --amend --no-edit'

alias ga.c='git add . && git commit -v'
alias ga.m='git add . && git commit --amend -v'
alias ga.mno='git add . && git commit --amend --no-edit'

alias gpf='git push -f'
alias ga.cp='git add . && git commit -v && git push'

alias gampf='git commit --amend --no-edit && git push -f'
alias ga.mpf='git add . && git commit --amend --no-edit && git push -f'

alias gcn='git clone'

## Branch

alias gbd='git branch -d'
alias gbD='git branch -D'
gbb() {
    git branch -a "$@" | sed "/->/b; s#remotes/origin/#remotes/origin => #"
}
gbT() {
    git branch -a "$@" | sed "/->/b; \/tags\//d; /\/releases\//d; s#remotes/origin/#remotes/origin => #"
}

# http://stackoverflow.com/questions/1419623/how-to-list-branches-that-contain-a-given-commit
alias gbc='git branch --contains'
alias gbrc='git branch -r --contains'

## URL

ghc() {
    local url="${1:-$(git remote get-url origin)}"
    if [ -z "$url" ]; then
        echo "No arguement and Not a git repository!"
        return 1
    fi

    if [[ "$url" =~ '^http' ]]; then
        echo "$url" | sed 's#^https?://#git@#; s#$#\.git#; s#(\.com|\.org)/#\1:#' -r | c
    else
        echo "$url" | sed 's#^git@#http://#; s#http://github.com#https://github.com#; s#\.git##; s#(\.com|\.org):#\1/#' -r | c
    fi
}

###############################################################################
# JetBrains
###############################################################################
alias idea='open -a /Applications/IntelliJ\ IDEA.app'
alias pych='open -a /Applications/PyCharm.app'
alias apcd='open -a /Applications/AppCode.app'
alias cln='open -a /Applications/CLion.app'
alias wbs='open -a /Applications/WebStorm.app'
alias phs='open -a /Applications/PhpStorm.app'
alias dtg='open -a /Applications/DataGrip.app'

alias ads='open -a /Applications/Android\ Studio.app'

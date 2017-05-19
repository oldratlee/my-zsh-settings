###############################################################################
# Env settings
###############################################################################

export EDITOR=vim
#export SHELL=/bin/bash
export LANG=en_US.UTF-8
export LESS="${LESS}iXF"
export WINEDEBUG=-all


###############################################################################
# Shell Imporvement
###############################################################################

### shell settings ###

# set color theme of ls in terminal to GNU/Linux Style
if brew list | grep coreutils > /dev/null ; then
    alias ls='ls -F --show-control-chars --color=auto'
    eval `gdircolors -b <(gdircolors --print-database)`
fi

# User configuration
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
#export MANPATH="$(find /usr/local/Cellar -maxdepth 4 -type d -name man | tr '\n' :)$MANPATH"

# Use Ctrl-Z to switch back to backgroud proccess(eg: Vim)
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

# core utils

alias du='du -h'
alias df='df -h'
alias ll='ls -lh'
alias tailf='tail -f'
alias diff=colordiff
D() {
    diff "$@" | diff-so-fancy | less --tabs=4 -RFX
}
# alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=target --exclude-dir=.idea'
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=target --exclude-dir=build --exclude-dir=_site --exclude-dir=.idea --exclude-dir=taobao-tomcat --exclude=\*.ipr --exclude=\*.iml --exclude=\*.iws --exclude=\*.jar --exclude-dir=Pods'
export GREP_COLOR='07;31'

# show type -a and which -a info together, very convenient!
ta() {
    echo "type -a:\n"
    # type buildin command can output which file the function is definded. COOL!
    type -a "$@"
    echo "\nwhich -a:\n"
    # which buildin command can output the function implementation. COOL!
    which -a "$@"
}

# restart shell
alias rssh='exec $SHELL -l'

# zsh/oh-my-zsh

# improve alias d of oh-my-zsh: colorful lines, near index number and dir name(more convenient for human eyes)
alias d="dirs -v | head | tr '\t' ' ' | colines"

# editor

alias v=vim
alias 'v-'='vim -'
# http://stackoverflow.com/questions/14307086/tab-completion-for-aliased-sub-commands-in-zsh-alias-gco-git-checkout
compdef v=vim
alias vd=vimdiff
alias vi=vim
compdef vi=vim
alias gv=gvim
alias 'gv-'='gvim -'
alias nv=nvim
alias gvd=gvimdiff

alias a='atom'
alias a.='atom .'
alias a..='atom ..'

# mac utils

alias o=open
alias o.='open .'
alias o..='open ..'

# my utils

alias cap='c ap'
# print and copy full path of command bin
capw() {
    local arg
    for arg; do
        ap "$(which "$arg")" | c
    done
}

alias t=tmux
compdef t=tmux

alias b=brew
compdef b=brew

alias sl=sloccount

# speed up download
alias ax='axel -n8'
alias axl='axel -n16'

## reduce exit time of fpp
# fpp is an awesome toolkit: https://github.com/facebook/PathPicker
alias fpp='SHELL=sh fpp'
alias p='SHELL=sh fpp'

# adjust indent for space 4
toc() {
    command doctoc --notitle "$@" && sed '/<!-- START doctoc generated TOC/,/<!-- END doctoc generated TOC/s/^( +)/\1\1/' -ri "$@"
}

# create formula image by TeX
fml() {
    local url=$(printf 'http://chart.googleapis.com/chart?cht=tx&chl=%s\n' $(urlencode "$1"))
    printf '<img src="%s" style="border:none;" alt="%s" />\n' "$url" "$1"
    # imgcat <(curl -s "$url")
    o $url
}

alias pt=pstree

###############################################################################
# Git
###############################################################################

compdef g=git

# git diff

alias gdc='git diff --cached'
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
    git diff "$from" "$to"
}
alias gdh='git diff HEAD'
alias gdorigin='git diff origin/$(git_current_branch)'

# git status

alias gssi='git status -s --ignored'
alias gsti='git status --ignored'

# git log

alias gg='glog -20'

## git branch

gbb() {
    git branch -a "$@" | sed "/->/b; s#remotes/origin/#remotes/origin => #"
}

gbT() {
    # http://stackoverflow.com/questions/5188320/how-can-i-get-a-list-of-git-branches-ordered-by-most-recent-commit
    # --sort=-committerdate : sort branch by commit date in descending order
    # --sort=committerdate : sort branch by commit date in ascending order
    git branch -a --sort=committerdate "$@" | sed -r "/->/b; /\/tags\//d; /\/releases\//d; /\/backups?\//d; /\/bkps?\//d"
}

gbt() {
    # http://stackoverflow.com/questions/5188320/how-can-i-get-a-list-of-git-branches-ordered-by-most-recent-commit
    # --sort=-committerdate : sort branch by commit date in descending order
    # --sort=committerdate : sort branch by commit date in ascending order
    git branch -a --sort=committerdate "$@" | sed -r "/->/b; /\/tags\//d; /\/releases\//d; /\/backups?\//d; /\/bkps?\//d; s#remotes/origin/#remotes/origin => #"
}

# http://stackoverflow.com/questions/1419623/how-to-list-branches-that-contain-a-given-commit
alias gbc='git branch --contains'
alias gbrc='git branch -r --contains'

alias gbd='git branch -d'
alias gbD='git branch -D'

# git add

alias ga.='git add .'
alias ga..='git add ..'

# git checkout

alias gcoh='git checkout HEAD'
alias gcop='git checkout -'

# git reset/rebase

alias grb='git rebase'
alias grs='git reset'
alias grshd='git reset --hard'
alias grsorigin='git reset --hard origin/$(git_current_branch)'

# git clone

alias gcn='git clone'
alias gcnr='git clone --recurse-submodules'

# git commit

alias gam='git commit --amend -v'
alias gamno='git commit --amend --no-edit'

# git push

alias gpf='git push -f'

# compound git command

alias ga.c='git add . && git commit -v'
alias ga.m='git add . && git commit --amend -v'
alias ga.mno='git add . && git commit --amend --no-edit'

alias ga.cp='git add . && git commit -v && git push'

alias gampf='git commit --amend --no-edit && git push -f'
alias ga.cpf='git add . && git commit -v && git push -f'
alias ga.mpf='git add . && git commit --amend --no-edit && git push -f'

# misc
alias gbw='git browse'
alias sg='open -a /Applications/SmartGit.app'


## URL shower/switcher

# show swithed git repo addr(git <=> http)
shg() {
    local url="${1:-$(git remote get-url origin)}"
    if [ -z "$url" ]; then
        echo "No arguement and Not a git repository!"
        return 1
    fi

    if [[ "$url" =~ '^http' ]]; then
        echo "$url" | sed 's#^https?://#git@#; s#(\.com|\.org)/#\1:#; s#(\.git)?$#\.git#' -r | c
    else
        echo "$url" | sed 's#^git@#http://#; s#http://github.com#https://github.com#; s#(\.com|\.org):#\1/#; s#\.git$##' -r | c
    fi
}
# show git repo addr http addr recursively
shgr() {
    local d
    for d in `find -iname .git -type d`; do
        (
            cd $d/..
            echo "$PWD : $(git remote get-url origin)"
        )
    done
}
# change git repo addr http addr recursively
chgr() {
    local d
    for d in `find -iname .git -type d`; do
        (
            cd $d/..
            echo "Found $PWD"
            local url=$(git remote get-url origin)
            [[ "$url" =~ '^http'  ]] && {
                local gitUrl=$(shg)
                echo "CHANGE $PWD : $url to $gitUrl"
                git remote set-url origin $gitUrl
            } || {
                echo -e "\tIgnore $PWD : $url"
            }
        )
    done
}


# git up
alias gu='git-up'
# git up recursively
gur() {
    local d
    local -a failedDirs=()
    for d in `find -iname .git -type d`; do
        d="$(readlink -f "$d/..")"
        (
            cd $d && {
                echo
                echo "================================================================================"
                echo -e "Update Git repo:\n\trepo path: $PWD\n\trepo url: $(git remote get-url origin)"
                # below command info see https://github.com/aanand/git-up
                git-up

            }
        ) || failedDirs=( "$failedDirs[@]" "$d")
    done
    if [ "${#failedDirs[@]}" -gt 0 ]; then
        echo
        echo
        echo "================================================================================"
        echo "Failed dirs:"
        for d in "$failedDirs[@]"; do
            echo "    $d"
        done
    fi
}


###############################################################################
# Java/JVM Languages
###############################################################################

swJavaNetProxy() {
    # How to check if a variable is set in Bash?
    # http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    [ -z "${JAVA_OPTS_BEFORE_NET_PROXY+if_undefined_will_output}" ] && {
        export JAVA_OPTS_BEFORE_NET_PROXY="$JAVA_OPTS"
        export JAVA_OPTS="$JAVA_OPTS -DproxySet=true -DsocksProxyHost=127.0.0.1 -DsocksProxyPort=7070"
        echo "turn ON java net proxy!"
    }|| {
        export JAVA_OPTS="$JAVA_OPTS_BEFORE_NET_PROXY"
        unset JAVA_OPTS_BEFORE_NET_PROXY
        echo "turn off java net proxy!"
    }
}

#export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)
export JAVA6_HOME='/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home'
export JAVA7_HOME=$(echo /Library/Java/JavaVirtualMachines/jdk1.7.0_*.jdk/Contents/Home)
export JAVA8_HOME=$(echo /Library/Java/JavaVirtualMachines/jdk1.8.0_*.jdk/Contents/Home)
export JAVA9_HOME='/Library/Java/JavaVirtualMachines/jdk-9.jdk/Contents/Home'

export JAVA_HOME="$JAVA7_HOME"

# jenv is an awesome tool for managing parallel Versions of Java Development Kits!
# https://github.com/linux-china/jenv
[[ -s "/Users/jerry/.jenv/bin/jenv-init.sh" ]] && ! type jenv > /dev/null &&
source "/Users/jerry/.jenv/bin/jenv-init.sh" &&
source "/Users/jerry/.jenv/commands/completion.sh"

# JAVA_HOME switcher
alias j6='export JAVA_HOME=$JAVA6_HOME'
alias j7='export JAVA_HOME=$JAVA7_HOME'
alias j8='export JAVA_HOME=$JAVA8_HOME'
alias j9='export JAVA_HOME=$JAVA9_HOME'

alias scl='scala -Dscala.color -feature'

###############################################################################
# Maven
###############################################################################

export MAVEN_OPTS="-Xmx512m"

alias mc='mvn clean'
alias mi='mvn install -Dmaven.test.skip -Dautoconf.skip -Dautoconfig.skip -Denv=release -Dscm.app.name=faked'
alias mio='mvn install -o -Dmaven.test.skip -Dautoconf.skip -Dautoconfig.skip -Denv=release -Dscm.app.name=faked'
alias mci='mvn clean && mvn install -Dmaven.test.skip -Dautoconf.skip -Dautoconfig.skip -Denv=release -Dscm.app.name=faked'
alias mcio='mvn clean && mvn install -o -Dmaven.test.skip -Dautoconf.skip -Dautoconfig.skip -Denv=release -Dscm.app.name=faked'
alias mdt='mvn dependency:tree'
alias mds='mvn dependency:sources'
alias mcv='mvn versions:display-dependency-updates versions:display-plugin-updates versions:display-property-updates'
alias mcdeploy='mvn clean && mvn deploy -Dmaven.test.skip -Dautoconf.skip -Dautoconfig.skip -Denv=release'

muv() {
    [ $# -ne 1 ] && {
        echo "Only 1 argument for verson!"
        exit 1
    }
    mvn org.codehaus.mojo:versions-maven-plugin:2.3:set -DgenerateBackupPoms=false -DnewVersion="$1"
}


###############################################################################
# Gradle
###############################################################################

#export GRADLE_OPTS="-Xmx1024m -Xms256m -XX:MaxPermSize=512m"
# --daemon
alias grd='gradle'

# shortcut for executing gradlew:
# find gradlew automatically and execute.
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

alias grwb='grw build'
alias grwc='grw clean'
alias grwcb='grw clean build'
alias grwt='grw test'

alias grwf='grw --refresh-dependencies'
alias grwfb='grw --refresh-dependencies build'
alias grwfc='grw --refresh-dependencies clean'
alias grwfcb='grw --refresh-dependencies clean build'

alias grwd='grw -q dependencies'
alias grwdc='grw -q dependencies --configuration compile'
alias grwdr='grw -q dependencies --configuration runtime'
alias grwdtc='grw -q dependencies --configuration testCompile'

# kill all gradle deamon processes on mac
alias kgrdm="jps -l | awk '\$2==\"org.gradle.launcher.daemon.bootstrap.GradleDaemon\"{print \$1}' | xargs -r kill -9"
# show all gradle deamon processes on mac
alias sgrdm="jps -l | awk '\$2==\"org.gradle.launcher.daemon.bootstrap.GradleDaemon\"{print \$0}'"


###############################################################################
# Javascript
###############################################################################

# NVM: https://github.com/creationix/nvm
export NVM_DIR="$HOME/.nvm"
source "/usr/local/opt/nvm/nvm.sh"

###############################################################################
# Python
###############################################################################
ZSH_PIP_INDEXES='http://pypi.douban.com/simple/'

alias py='python'
alias ipy='ipython'
alias pip='pip --trusted-host pypi.douban.com'
compdef pip=pip

alias py3='echo use python instead! && false'
alias ipy3='echo use ipython instead! && false'
alias pip3='echo use pip instead! && false'

alias pyenv='python3 -m venv'

pipup() {
    pip list --outdated | awk 'NR>2{print $1}' | xargs pip install --upgrade
}
# pip3up() {
#     pip3 list --outdated | awk 'NR>2{print $1}' | xargs pip3 install --upgrade
# }

# use default virtualenv of python 2
type deactivate > /dev/null && deactivate
source $HOME/.virtualenv/default/bin/activate
# Python Virtaul Env
pve() {
    echo "current VIRTUAL_ENV: $VIRTUAL_ENV"

    echo "select python virtual env to activate:"
    local venv
    select venv in `find $HOME/.virtualenv -maxdepth 1 -mindepth 1 -type d` \
                   `find $HOME/.pyenv -maxdepth 1 -mindepth 1 -type d` ; do
        [ -n "$venv" ] && {
            [ -n "$VIRTUAL_ENV" ] && deactivate
            source "$venv/bin/activate"
            break
        }
    done
}

relink_virtualenv() {
    # relink python 2
    (
        cd $HOME/.virtualenv
        find -type l -xtype l -delete
        local d
        for d in *; do
            virtualenv $d
        done
    )
    # relink python 3
    (
        cd $HOME/.pyenv
        find -type l -xtype l -delete
        local d
        for d in *; do
            python3 -m venv $d
        done
    )
}

eval "$(thefuck --alias f)"

###############################################################################
# Go
###############################################################################
export GOPATH=/Users/jerry/.gopath

###############################################################################
# Ruby
###############################################################################
source /Users/jerry/.rvm/scripts/rvm

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
# Lisp
###############################################################################

CLISP_DOC=/usr/local/Cellar/clisp/2.49/share/doc/clisp/doc

alias schm='rlwrap -p 1\;32 -r -c -f $HOME/.scheme_completion.rlwrap scheme'

###############################################################################
# Prolog
###############################################################################
alias sp='/Applications/SWI-Prolog.app/Contents/MacOS/swipl'
alias gpl='gprolog'
alias bp='$HOME/Applications/BProlog/bp'


###############################################################################
# JetBrains
###############################################################################
# JetBrains Toolbox: The right tool for the job — every time!
# https://www.jetbrains.com/toolbox/
JB_TOOL_HOME="$HOME/Library/Application Support/JetBrains/Toolbox/apps"

_jb_ide() {
    local ide="$1"
    shift
    (
        cd $JB_TOOL_HOME
        local -a candidates=("$ide"/*/*/*.app)
        cd "$OLDPWD"
        [ "$#candidates[@]" -gt 1 ] && {
            echo "Find multi candidates!"
            select ide in "$candidates[@]" ; do
                [ -n "$ide" ] && {
                    [ -n "$ide" ] && open -a "$JB_TOOL_HOME/$ide" "$@"
                    break
                }
            done
        } || open -a "$JB_TOOL_HOME/$candidates" "$@"
    )
}

#alias idea='open -a /Applications/IntelliJ\ IDEA.app'
alias idea='_jb_ide IDEA-U'
#alias apcd='open -a /Applications/AppCode.app'
alias apc='_jb_ide AppCode'
alias ads='open -a /Applications/Android\ Studio.app'

#alias pyc='open -a /Applications/PyCharm.app'
alias pyc='_jb_ide PyCharm-P'
alias wbs='_jb_ide WebStorm'
alias rbm='_jb_ide RubyMine'

alias cln='_jb_ide CLion'
alias gol='_jb_ide Gogland'
alias rdr='_jb_ide Rider'

alias dtg='_jb_ide datagrip'
#alias phs='open -a /Applications/PhpStorm.app'
alias mps='_jb_ide MPS'

jb() {
    (
        cd $JB_TOOL_HOME
        select ide in */*/*/*.app ; do
            [ -n "$ide" ] && {
                cd "$OLDPWD"
                [ -n "$ide" ] && open -a "$JB_TOOL_HOME/$ide" "$@"
                break
            }
        done
    )
}

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
# use `which gdircolors` instead of `brew list | grep coreutils -q` for speedup
which gdircolors &> /dev/null && {
    alias ls='ls -F --show-control-chars --color=auto'
    eval `gdircolors -b <(gdircolors --print-database)`
}

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
alias D=colordiff

alias grep='grep --color=auto --exclude-dir={.git,.hg,.svn,.cvs,bzr,CVS,target,build,_site,.idea,Pods,taobao-tomcat} --exclude=\*.{ipr,iml,iws,jar,war,zip}'
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
compdef ta=type

# Remove duplicate entries in a file without sorting
# http://www.commandlinefu.com/commands/view/4389
alias uq="awk '!x[\$0]++'"

# ReStart SHell
alias rsh='exec $SHELL -l'

# zsh/oh-my-zsh

# improve alias d of oh-my-zsh: colorful lines, near index number and dir name(more convenient for human eyes)
alias d="dirs -v | head | tr '\t' ' ' | colines"

# editor

alias v=vim
alias 'v-'='vim -'
alias vv='col -b | vim -'
alias vw=view
alias vd=vimdiff
# http://stackoverflow.com/questions/14307086/tab-completion-for-aliased-sub-commands-in-zsh-alias-gco-git-checkout
compdef v=vim
alias vi=vim
compdef vi=vim

alias nv=nvim

alias gv=gvim
alias 'gv-'='gvim -'
alias gvv='gvim -'
alias gvm=gview
alias gvd=gvimdiff
alias note='(cd ~/notes; gvim)'

alias a='atom'
alias a.='atom .'
alias a..='atom ..'
alias vc='open -a /Applications/Visual\ Studio\ Code\ -\ Insiders.app'
alias vc.='open -a /Applications/Visual\ Studio\ Code\ -\ Insiders.app .'
alias vc..='open -a /Applications/Visual\ Studio\ Code\ -\ Insiders.app ..'

# find texinfo
export PATH="/usr/local/opt/texinfo/bin:$PATH"

# mac utils

alias o=open
alias o.='open .'
alias o..='open ..'

alias b=brew
alias bi='brew install'
alias bri='brew reinstall'
alias bs='brew search'
compdef b=brew

# docker

alias dk=docker
alias dkc='docker create'

alias dkr='docker run'
alias dkrr='docker run --rm'

alias dkri='docker run -i -t'
alias dkrri='docker run --rm -i -t'

alias dkrd='docker run -d'
alias dkrrd='docker run --rm -d'

alias dkrm='docker rm'
alias dkrmi='docker rmi'

alias dks='docker start'
alias dksi='docker start -i'
alias dkrs='docker restart'
alias dkstop='docker stop'

alias dki='docker inspect'
alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dktop='docker top'

alias dke='docker exec'
alias dkei='docker exec -i -t'
alias dkl='docker logs'
alias dklf='docker logs -f'

alias dkimg='docker images'
alias dkp='docker pull'
alias dksh='docker search'

dkcleanupimg() {
    local images="$(docker images | awk 'NR>1 && $2=="<none>" {print $3}')"
    [ -z "$images" ] && {
        echo "No images need to cleanup!"
        return
    }

    echo "$images" | xargs --no-run-if-empty docker rmi
}

dkupimg() {
    local images="$(docker images | awk 'NR>1 && $2="latest"{print $1}')"
    [ -z "$images" ] && {
        echo "No images need to upgrade!"
        return
    }

    echo "$images" | xargs --no-run-if-empty -n1 docker pull
}

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
alias tma='exec tmux attach'
compdef t=tmux

alias sl=sloccount

# speed up download
alias ax='axel -n8'
alias axl='axel -n16'

# List tcp listen port info(very useful on mac)
#
# inhibits the conversion so as to run faster
#   -P inhibits the conversion of port numbers to port names
#   -n inhibits the conversion of network numbers to host names
alias tcplisten='lsof -n -P -iTCP -sTCP:LISTEN'

# fpp is an awesome toolkit: https://github.com/facebook/PathPicker
## reduce exit time of fpp
alias fpp='SHELL=sh fpp'
alias p=fpp

# adjust indent for space 4
toc() {
    command doctoc --notitle "$@" && sed '/<!-- START doctoc generated TOC/,/<!-- END doctoc generated TOC/s/^( +)/\1\1/' -ri "$@"
}

# generate an image showing a mathematical formula, using the TeX language by Google Charts
# https://developers.google.com/chart/infographics/docs/formulas
fml() {
    local url=$(printf 'http://chart.googleapis.com/chart?cht=tx&chf=bg,s,00000000&chl=%s\n' $(urlencode "$1"))
    printf '<img src="%s" style="border:none;" alt="%s" />\n' "$url" "$1" | c
    # imgcat <(curl -s "$url")
    o $url
}

alias pt=pstree

alias asma=asciinema
alias asma2gif='docker run --rm -v $PWD:/data asciinema/asciicast2gif -s2 -S1 -t monokai'

# open file with default application
for ext in doc{,x} ppt{,x} xls{,x} key pdf png jp{,e}g htm{,l} m{,k}d markdown txt xml xmind java c{,pp} .h{,pp}; do
    alias -s $ext=open
done

alias otv=octave-cli
alias vzshrc='vim ~/.zshrc'

###############################################################################
# Git
###############################################################################

compdef g=git

# git diff

alias gd='git diff --ignore-space-change --ignore-space-at-eol --ignore-blank-lines'
alias gD='git diff'
alias gdc='gd --cached'
alias gDc='git diff --cached'
alias gdh='gd HEAD'
alias gDh='git diff HEAD'
alias gdorigin='gd origin/$(git_current_branch)'
alias gDorigin='git diff origin/$(git_current_branch)'

function gds() {
    if [ $# -eq 0 ]; then
        2=HEAD
        1='HEAD^'
    elif [ $# -eq 1 ]; then
        2="$1"
        1="$1^"
    fi
    git diff "$@" $__git_diff_ignore_options
}

function gDs() {
    if [ $# -eq 0 ]; then
        2=HEAD
        1='HEAD^'
    elif [ $# -eq 1 ]; then
        2="$1"
        1="$1^"
    fi
    git diff "$@"
}

# git status

alias gssi='git status -s --ignored'
alias gsti='git status --ignored'
alias gs='git status -s' # I never use gs command but will mistype :)

# git log

alias gg='glog -20'

## git branch

alias __git_remove_bkp_rel_branches='sed -r "/->/b; /\/tags\//d; /\/releases\//d; /\/backups?\//d; /\/bkps?\//d"'
alias __git_output_local_branch='sed -r "/->/b; s#remotes/([^/]+)/(.*)#remotes/\1/\2 => \2#"'

__gbb() {
    # How can I get a list of git branches, ordered by most recent commit?
    #   http://stackoverflow.com/questions/5188320
    # --sort=-committerdate : sort branch by commit date in descending order
    # --sort=committerdate : sort branch by commit date in ascending order
    git branch --sort=committerdate "$@" | __git_remove_bkp_rel_branches | __git_output_local_branch
}

__gbB() {
    git branch --sort=committerdate "$@" | __git_remove_bkp_rel_branches
}

alias gbt='__gbb -a'
alias gbtr='__gbb --remote'
alias gbT='__gbB -a'
alias gbTr='__gbB --remote'

# How to list branches that contain a given commit?
# http://stackoverflow.com/questions/1419623
alias gbc='git branch --contains'
alias gbrc='git branch -r --contains'

alias gbd='git branch -d'
alias gbD='git branch -D'

# git add

alias ga.='git add .'
alias ga..='git add ..'

# git checkout

alias gcoh='git checkout HEAD'
# checkout previous branch
alias gcop='git checkout -'
# checkout most recent modified branch
alias gcor="git checkout \$(gbt | awk -rF' +=> +' '/=>/{print \$2}' | tail -1)"

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
gbw() {
    # git browse
    local url="${1:-$(git remote get-url origin)}"
    if ! [[ "$url" =~ '^http' ]]; then
        url=$(echo "$url" | sed 's#^git@#http://#; s#http://github.com#https://github.com#; s#(\.com|\.org):#\1/#; s#\.git$##' -r)
    fi

    echo "open $url"
    open "$url"
}

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
# https://github.com/msiemens/PyGitUp
#
# git pull has two problems:
#   It merges upstream changes by default, when it's really more polite to rebase over them, unless your collaborators enjoy a commit graph that looks like bedhead.
#   It only updates the branch you're currently on, which means git push will shout at you for being behind on branches you don't particularly care about right now.
# Solve them once and for all.
alias gu='git-up'

# git up recursively
# Usage: gur [<dir1>  [<dir2> ...]]
gur() {
    local -a files
    [ $# -eq 0 ] && files=(.) || files=("$@")

    local -a failedDirs=()

    local f
    local d
    for f in "${files[@]}" ; do
        [ -d "$f" ] || {
            echo
            echo "================================================================================"
            echo "$f is not a directory, ignore and skip!!"
            continue
        }
        for d in `find $f -iname .git -type d`; do
            d="$(readlink -f "$d/..")"
            (
                cd $d && {
                    echo
                    echo "================================================================================"
                    echo -e "Update Git repo:\n\trepo path: $PWD\n\trepo url: $(git remote get-url origin)"
                    git-up
                }
            ) || failedDirs=( "${failedDirs[@]}" "$d")
        done
    done

    if [ "${#failedDirs[@]}" -gt 0 ]; then
        echo
        echo
        echo "================================================================================"
        echo "Failed dirs:"
        local idx=0
        for d in "${failedDirs[@]}"; do
            echo "    $((++idx)): $d"
        done
    fi
}


###############################################################################
# Java/JVM Languages
###############################################################################

swJavaNetProxy() {
    # How to check if a variable is set in Bash?
    # http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    [ -z "${JAVA_OPTS_BEFORE_NET_PROXY+if_check_var_defined_will_got_output_or_nothing}" ] && {
        export JAVA_OPTS_BEFORE_NET_PROXY="$JAVA_OPTS"
        export JAVA_OPTS="$JAVA_OPTS -DproxySet=true -DsocksProxyHost=127.0.0.1 -DsocksProxyPort=7070"
        echo "turn ON java net proxy!"
    } || {
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
# default JAVA_HOME
export JAVA0_HOME="$HOME/.jenv/candidates/java/current"

export JAVA_HOME="$JAVA0_HOME"
export MANPATH="$JAVA_HOME/man:$MANPATH"

# jenv is an awesome tool for managing parallel Versions of Java Development Kits!
# https://github.com/linux-china/jenv
[[ -s "$HOME/.jenv/bin/jenv-init.sh" ]] && ! type jenv > /dev/null &&
source "$HOME/.jenv/bin/jenv-init.sh" &&
source "$HOME/.jenv/commands/completion.sh"

# JAVA_HOME switcher
alias j6='export JAVA_HOME=$JAVA6_HOME'
alias j7='export JAVA_HOME=$JAVA7_HOME'
alias j8='export JAVA_HOME=$JAVA8_HOME'
alias j9='export JAVA_HOME=$JAVA9_HOME'
alias j0='export JAVA_HOME=$JAVA0_HOME'

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

# Update project version
muv() {
    [ $# -ne 1 ] && {
        echo "Only 1 argument for verson!"
        exit 1
    }
    mvn org.codehaus.mojo:versions-maven-plugin:2.4:set -DgenerateBackupPoms=false -DnewVersion="$1"
}

# create maven wrapper
# http://mvnrepository.com/artifact/io.takari/maven
mwrapper() {
    local version=${1:-3.5.0}
    mvn -N io.takari:maven:0.4.3:wrapper -Dmaven="$version"
}

###############################################################################
# Gradle
###############################################################################

#export GRADLE_OPTS="-Xmx1024m -Xms256m -XX:MaxPermSize=512m"
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
#
# NVM init is slowwwwww! about 1.2s on my machine!!
# manually activate when needed.
export PATH="$HOME/.nvm/versions/node/v8.1.2/bin:$PATH"
anvm() {
    export NVM_DIR="$HOME/.nvm"
    source "/usr/local/opt/nvm/nvm.sh"
    source <(npm completion)
}

###############################################################################
# Python
###############################################################################

ZSH_PIP_INDEXES='http://pypi.douban.com/simple/'

alias py='python'
alias ipy='ipython'

alias py3='echo use python instead! && false'
alias ipy3='echo use ipython instead! && false'
alias pip3='echo use pip instead! && false'

alias pyenv='python3 -m venv'

pipup() {
    pip list --outdated | awk 'NR>2{print $1}' | xargs pip install --upgrade
}

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

# activate/deactivate anaconda3
aa() {
    declare -f deactivate > /dev/null && {
        echo "Activate anaconda3!"

        deactivate
        # append anaconda3 to PATH
        export PATH=$HOME/.anaconda3/bin:$PATH
    } || {
        echo "Deactivate anaconda3!"

        # remove anaconda3 from PATH
        export PATH="$(echo "$PATH" | sed 's/:/\n/g' | grep -Fv .anaconda3/bin | paste -s -d:)"
        source $HOME/.pyenv/default/bin/activate
    }
}

# activate anaconda3 python
export PATH=$HOME/.anaconda3/bin:$PATH

###############################################################################
# Go
###############################################################################

export GOPATH=$HOME/.gopath
export PATH=$PATH:$GOPATH/bin

###############################################################################
# Ruby
###############################################################################

source $HOME/.rvm/scripts/rvm

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

alias sp='swipl'
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

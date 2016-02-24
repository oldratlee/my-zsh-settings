export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
#export GRADLE_OPTS="-Xmx1024m -Xms256m -XX:MaxPermSize=512m"
export SVN_EDITOR=vim
export EDITOR=vim
export LANG=en_US.UTF-8

CLISP_DOC=/usr/local/Cellar/clisp/2.49/share/doc/clisp/doc

if brew list | grep coreutils > /dev/null ; then
    alias ls='ls -F --show-control-chars --color=auto'
    eval `gdircolors -b <(gdircolors --print-database)`
fi

####################################
# My Config
####################################

export LESS="${LESS}i"

###############################################################################
# Shell misc
###############################################################################
alias d="dirs -v | head | tr '\t' ' ' | colines"

alias wa='which -a'
alias ta='type -a'
alias o=open
alias du='du -h'
alias df='df -h'
alias ll='ls -lh'
alias tailf='tail -f'
# alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=target --exclude-dir=.idea'
alias grep='grep --color=auto --exclude-dir=.cvs --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=target --exclude-dir=build --exclude-dir=_site --exclude-dir=.idea --exclude=\*.ipr --exclude=\*.iml --exclude=\*.iws --exclude=\*.jar'
export GREP_COLOR='07;31'

alias diff=colordiff

alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'
alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])"'

alias cap='c ap'

alias v=vim
# http://stackoverflow.com/questions/14307086/tab-completion-for-aliased-sub-commands-in-zsh-alias-gco-git-checkout
compdef v=vim
alias vd=vimdiff
alias vi=vim
alias gv=gvim
alias nv=nvim
alias gvd=gvimdiff

alias e=emacs
# compdef e=emacs

alias a='atom'
alias t=tmux
compdef t=tmux

# adjust indent for space 4
doctoc() {
    command doctoc --notitle "$@" && sed '/<!-- START doctoc generated TOC/,/<!-- END doctoc generated TOC/s/^( +)/\1\1/' -ri "$@"
}

###############################################################################
# Python
###############################################################################
alias py='python'
alias py3='python3'
alias ipy='ipython'
alias ipy3='ipython3'

###############################################################################
# Prolog
###############################################################################
alias gpl='gprolog'
alias sp='/Applications/SWI-Prolog.app/Contents/MacOS/swipl'
alias bp='/Users/jerry/ProgFiles/BProlog/bp'

###############################################################################
# Lisp
###############################################################################
alias schm='rlwrap -p 1\;32 -r -c -f $HOME/.scheme_completion.rlwrap scheme'
alias srepl='scala -nc -Dscala.color'

###############################################################################
# Gradle
###############################################################################
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
alias ga.='git add .'
alias ga..='git add ..'
alias gcoh='git checkout HEAD'

alias gd > /dev/null && unalias gd
function gd() {
    git diff --color "$@" | diff-so-fancy | less --tabs=1,5 -iRFX
}
function gdc() {
    git diff --cached --color "$@" | diff-so-fancy | less --tabs=1,5 -iRFX
}

alias gssi='git status -s --ignored'
alias gsti='git status --ignored'
alias glog5='glog -5'
alias glg5='glg -5'

alias grb='git rebase'
alias grs='git reset'
alias grsh='git reset HEAD'
alias grshard='git reset --hard'

alias gam='git commit --amend -v'
alias gamno='git commit --amend --no-edit'

alias ga.c='git add . && git commit -v'
alias ga.m='git add . && git commit --amend -v'
alias ga.mno='git add . && git commit --amend --no-edit'

alias gpf='git push -f'
alias ga.cp='git add . && git commit -v && git push'

alias gampf='git commit --amend --no-edit && git push -f'
alias ga.mpf='git add . && git commit --amend --no-edit && git push -f'
###############################################################################
# JetBrains
###############################################################################
alias idea='open -a /Applications/IntelliJ\ IDEA\ 15.app'
alias pych='open -a /Applications/PyCharm.app'
alias apcd='open -a /Applications/AppCode.app'
alias cln='open -a /Applications/CLion.app'
alias wbs='open -a /Applications/WebStorm.app'
alias phs='open -a /Applications/PhpStorm.app'
alias dtg='open -a /Applications/DataGrip.app'

alias ads='open -a /Applications/Android\ Studio.app'
alias adsp='open -a /Applications/AndroidStudioPreview.app'

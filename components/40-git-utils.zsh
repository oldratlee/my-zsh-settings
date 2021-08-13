
###############################################################################
# Git
###############################################################################

# git diff

alias gd='git diff --ignore-cr-at-eol --ignore-space-at-eol --ignore-space-change --ignore-all-space --ignore-blank-lines'
alias gD='git diff'

alias gdc='gd --cached'
alias gDc='gD --cached'
alias gdh='gd HEAD'
alias gDh='gD HEAD'

alias gdorigin='gd origin/$(git_current_branch)'
alias gDorigin='gD origin/$(git_current_branch)'

function gdl() {
    local from to
    if [ $# -eq 0 ]; then
        from='HEAD^'
        to=HEAD
    elif [ $# -eq 1 ]; then
        from="$1^"
        to="$1"
    elif [ $# -eq 2 ]; then
        from="$1"
        to="$2"
    fi
    gd "$from" "$to"
}

function gdls() {
    local from to
    if [ $# -eq 0 ]; then
        from='HEAD^'
        to=HEAD
    elif [ $# -eq 1 ]; then
        from="$1^"
        to="$1"
    elif [ $# -eq 2 ]; then
        from="$1"
        to="$2"
    fi
    gd "$from" "$to" --stat
}

function gDl() {
    local from to
    if [ $# -eq 0 ]; then
        from='HEAD^'
        to=HEAD
    elif [ $# -eq 1 ]; then
        from="$1^"
        to="$1"
    elif [ $# -eq 2 ]; then
        from="$1"
        to="$2"
    fi
    gD "$from" "$to"
}

function gDls() {
    local from to
    if [ $# -eq 0 ]; then
        from='HEAD^'
        to=HEAD
    elif [ $# -eq 1 ]; then
        from="$1^"
        to="$1"
    elif [ $# -eq 2 ]; then
        from="$1"
        to="$2"
    fi
    gD "$from" "$to" --stat
}

# git status

alias gssi='git status -s --ignored'
alias gsti='git status --ignored'
alias gs='git status -s' # I never use gs command but will mistype :)

alias gcignore='git check-ignore -v'

# git log

alias gg='glog -15'
alias ggg='glgg -4'
alias gggg='glgg -6'

ggonepage() {
    glog --color "$@" | catOneScreen
}
compdef _git ggonepage=git-log

## git branch

alias __git_remove_bkp_rel_branches='sed -r "/->/b; /\/tags\//d; /\/releases\//d"'
alias __git_output_local_branch='sed -r "/->/b; s#remotes/([^/]+)/(.*)#remotes/\1/\2 => \2#"'

__gb() {
    # How can I get a list of git branches, ordered by most recent commit?
    #   http://stackoverflow.com/questions/5188320
    # --sort=-committerdate : sort branch by commit date in descending order
    # --sort=committerdate : sort branch by commit date in ascending order
    git branch --sort=committerdate "$@"
}

__gbb() {
    [ -t 1 ] && local force_color_option=--color
    __gb $force_color_option "$@" | __git_remove_bkp_rel_branches | __git_output_local_branch
}

__gbB() {
    [ -t 1 ] && local force_color_option=--color
    __gb $force_color_option "$@" | __git_output_local_branch
}

alias gbt='__gbb -a'
alias gbtr='__gbb --remote'
alias gbtl='__gbb'
alias gbT='__gbB -a'
alias gbTr='__gbB --remote'
alias gbTl='__gbB'

# How to list branches that contain a given commit?
# http://stackoverflow.com/questions/1419623
gbc() {
    echo "contained branches:"
    git branch --contains "$@"
    echo
    echo "contained tags:"
    git tag --contains "$@"
}
alias gbrc='git branch -r --contains'
alias gbac='git branch -a --contains'

alias gbd='git branch -d'
alias gbD='git branch -D'
gbdd() {
    git branch -d "$@"
    git push -d origin "$@"
}
gbDD() {
    git branch -D "$@"
    git push -d origin "$@"
}

gtdd() {
    git tag -d "$@"
    git push -d origin "$@"
}

# git add

alias ga.='git add .'
alias ga..='git add ..'
alias gaf='git add -f'

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

# git commit

alias gam='git commit --amend -v'
alias gamno='git commit --amend --no-edit'

# git push

alias gpf='git push -f'

# compound git command

alias ga.c='git add . && git commit -v'
alias gaac='git add -A && git commit -v'

alias ga.cp='git add . && git commit -v && git push'
alias gaacp='git add -A && git commit -v && git push'


alias ga.m='git add . && git commit --amend -v'
alias gaam='git add -A && git commit --amend -v'

alias ga.mno='git add . && git commit --amend --no-edit'
alias gaamno='git add -A && git commit --amend --no-edit'

alias gampf='git commit --amend --no-edit && git push -f'

alias ga.mpf='git add . && git commit --amend --no-edit && git push -f'
alias gaampf='git add -A && git commit --amend --no-edit && git push -f'

alias lg='lazygit'

# misc

__heavyOpenFileByApp() {
    [ $# -eq 0 ] && {
        echo "at least 1 app args" 1>&2
        exit 1
    }

    readonly app="$1"
    shift
    [ $# -eq 0 ] && readonly files=(.) || readonly files=("$@")

    local -a absolute_files
    local f
    for f in "${files[@]}"; do
        absolute_files=("${absolute_files[@]}" $(readlink -f "$f"))
    done

    logAndRun open --new -a "$app" --args "${absolute_files[@]}"
}

st() {
    (( $# == 0 )) && local -a files=( . ) || local -a files=( "$@" )
    local f isFirst=true
    for f in "${files[@]}"; do
        $isFirst && isFirst=false || echo
        (
            cd "${f}"
            local git_root
            git_root="$(git rev-parse --show-toplevel)" || {
                echo "Error: $PWD($f) is NOT a git repo!"
                return 2
            }
            open -a /Applications/Sourcetree.app "$git_root"
            echo "Sourcetree open $git_root ( $f )"
        )
    done
}

## URL shower/switcher

__gitUrl_Http2Git() {
    local git_user="${1:-git}"
    echo "$url" | sed -r '
        s#^https?://#'"$git_user"'@#
        s#(\.com|\.org)/#\1:#
        s#(\.git)?$#\.git#
    '
}

__gitUrl_Git2Http() {
    echo "$url" | sed -r '
        s#^\w*@#https://#
        s#(\.com|\.org):#\1/#
        s#(\.wiki)?\.git$##
    '
}

# show switched git repo address(git protocol <=> http protocol)
shg() {
    local git_user
    [ "$1" = "-u" ] && {
        git_user="${2:-git}"
        shift 2
    }

    local -r url="${1:-$(git remote get-url origin)}"
    if [ -z "$url" ]; then
        echo "No arguments and Not a git repository directory!"
        return 1
    fi

    if [[ "$url" =~ '^http' ]]; then
        local -r switched_url=$(__gitUrl_Http2Git ${git_user})
    else
        local -r switched_url=$(__gitUrl_Git2Http)
    fi

    if [ -t 1 ]; then
        echo "$url\n->\n$(echo "$switched_url" | c)"
    else
        echo "$switched_url"
    fi
}

# show git repo address recursively
shgr() {
    local d
    for d in `find -maxdepth 6 -iname .git`; do
        (
            cd "$(dirname $d)"
            warnEcho "\n$PWD :"
            shg
        )
    done
}

# change git repo address of http protocol to git protocol recursively
chgr() {
    local d
    for d in `find -maxdepth 6 -iname .git`; do
        (
            cd "$(dirname $d)"
            # echo "Found $PWD"
            local url=$(git remote get-url origin)
            if [[ "$url" =~ '^http'  ]]; then
                local gitUrl=$(__gitUrl_Http2Git)
                echo -e "CHANGE $PWD :\n\t$url\n\tto\n\t$gitUrl"
                git remote set-url origin $gitUrl
            else
                echo -e "Ignore $PWD :\n\t$url"
            fi
        )
    done
}

gitBatchClone() {
    local git_user
    [ "$1" = "-u" ] && {
        git_user="${2:-git}"
        shift 2
    }

    local url
    for url in "$@"; do
        if [[ "$url" =~ '^http' ]]; then
            url=$(__gitUrl_Http2Git "$git_user")
        fi

        logAndRun git clone "$url"
    done
}

# git browse
gbw() {
    local url
    if ((# > 1)); then
        errorEcho "at most 1 argument, too many arguments: $*"
        return 1
    elif ((# == 1)); then
        if [ -d "$1" ]; then
            [ ! -d "$1/.git" ] && {
                errorEcho "dir $1 is not git repo!"
                return 1
            }
            url=$(cd "$1" && git remote get-url origin)
        else
            url=$1
        fi
    else # $# == 0
        url=$(git remote get-url origin)
    fi
    [ -n "$url" ] || return 1

    if ! [[ "$url" =~ '^http' ]]; then
        url=$(__gitUrl_Http2Git)
    fi

    echo "open $url"
    open "$url"
}

# git up
# https://github.com/msiemens/PyGitUp
#
# git pull has two problems:
#   It merges upstream changes by default, when it's really more polite to rebase over them, unless your collaborators enjoy a commit graph that looks like bedhead.
#   It only updates the branch you're currently on, which means git push will shout at you for being behind on branches you don't particularly care about right now.
# Solve them once and for all.
alias gu='git-up && git fetch --tags'
# alias gu='git pull --rebase --autostash'

# git up recursively
# Usage: gur [<dir1>  [<dir2> ...]]
gur() {
    local maxdepth="6"
    if [ "$1" = "-d" ]; then
        local maxdepth="$2"
        shift 2
    fi

    [ $# -eq 0 ] && local -a files=(.) || local -a files=("$@")

    local -a failedDirs=()

    local f d isFirst=true idx=0
    for f in "${files[@]}" ; do
        [ -d "$f" ] || {
            $isFirst && isFirst=false || echo

            errorEcho "$f is not a directory, ignore and skip!!"
            continue
        }

        find "$f" -maxdepth $maxdepth -follow -name .git -type d -o \( -name .svn -o -name target \) -prune -false |
        while read d; do
            $isFirst && isFirst=false || echo

            d="$(readlink -f "$(dirname $d)")"
            warnEcho "$((++idx)): Update Git repo: $(basename "$d")"
            (
                cd "$d" && {
                    echo -e "\trepo path: $PWD\n\trepo url: $(git remote get-url origin)"
                    gu
                }
            ) || failedDirs=( "${failedDirs[@]}" "$d")
        done
    done

    if [ "${#failedDirs[@]}" -gt 0 ]; then
        echo
        echo
        errorEcho "Failed dirs:"
        local idx=0
        for d in "${failedDirs[@]}"; do
            echo "    $((++idx)): $d"
        done
    fi
}


# TODO
repush() {
    [ -z "$1" ] && {
        echo "count"
    }
    local count="$1"

    git log --oneline -"$count"

    echo
    echo "force repush above commit?[C(omfirm)/Q(uit)]"
    local s
    select s in C Q; do

    done

    select opt in "${options[@]}"
    do
        case $opt in
            "Option 1")
                echo "you chose choice 1"
                ;;
            "Option 2")
                echo "you chose choice 2"
                ;;
            "Option 3")
                echo "you chose choice $REPLY which is $opt"
                ;;
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

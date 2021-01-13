
###############################################################################
# Git
###############################################################################

# git diff

alias gd='git diff --ignore-space-change --ignore-space-at-eol --ignore-blank-lines'
alias gD='git diff'

alias gdc='gd --cached'
alias gDc='gD --cached'
alias gdh='gd HEAD'
alias gDh='gD HEAD'

alias gdorigin='gd origin/$(git_current_branch)'
alias gDorigin='gD origin/$(git_current_branch)'

#unalias gdl
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

# git log

alias gg='glog -15'
alias ggg='glgg -4'
alias gggg='glgg -6'

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
alias ga.m='git add . && git commit --amend -v'
alias ga.mno='git add . && git commit --amend --no-edit'

alias ga.cp='git add . && git commit -v && git push'

alias gampf='git commit --amend --no-edit && git push -f'
alias ga.cpf='git add . && git commit -v && git push -f'
alias ga.mpf='git add . && git commit --amend --no-edit && git push -f'

alias lg='lazygit'

# misc
gbw() {
    # git browse
    local url="${1:-$(git remote get-url origin)}"
    [ -n "$url" ] || return 1

    if ! [[ "$url" =~ '^http' ]]; then
        url=$(echo "$url" | sed -r '
            s%:%/%
            s%^git@%https://%
            s/(\.wiki)?\.git$//
        ')
    fi

    echo "open $url"
    open "$url"
}

__heaveyOpenFileByApp() {
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

# show swithed git repo addr(git <=> http)
shg() {
    local -r url="${1:-$(git remote get-url origin)}"
    if [ -z "$url" ]; then
        echo "No arguement and Not a git repository!"
        return 1
    fi

    if [[ "$url" =~ '^http' ]]; then
        local -r url2=$(echo "$url" | sed -r 's#^https?://#git@#
            s#(\.com|\.org)/#\1:#
            s#(\.git)?$#\.git#'
        )
    else
        local -r url2=$(echo "$url" | sed -r '
            s#^git@#http://#
            s#http://github.com#https://github.com#
            s#(\.com|\.org):#\1/#
            s#(\.wiki)?\.git$##'
        )
    fi

    echo "$url"
    echo "$url2" | c
}
# show git repo addr http addr recursively
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
# change git repo addr http addr recursively
chgr() {
    local d
    for d in `find -maxdepth 6 -iname .git`; do
        (
            cd "$(dirname $d)"
            # echo "Found $PWD"
            local url=$(git remote get-url origin)
            [[ "$url" =~ '^http'  ]] && {
                local gitUrl=$(shg)
                echo -e "CHANGE $PWD :\n\t$url\n\tto\n\t$gitUrl"
                git remote set-url origin $gitUrl
            } || {
                echo -e "Ignore $PWD :\n\t$url"
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
alias gu='git-up && git fetch --tags'
# alias gu='git pull --rebase --autostash'

# git up recursively
# Usage: gur [<dir1>  [<dir2> ...]]
gur() {
    [ $# -eq 0 ] && local -a files=(.) || local -a files=("$@")

    local -a failedDirs=()

    local f d isFirst=true idx=0
    for f in "${files[@]}" ; do
        [ -d "$f" ] || {
            $isFirst && isFirst=false || echo

            errorEcho "$f is not a directory, ignore and skip!!"
            continue
        }

        find "$f" -maxdepth 6 -iname .git -type d -follow | while read d; do
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

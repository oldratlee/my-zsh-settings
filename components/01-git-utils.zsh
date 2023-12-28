
###############################################################################
# Git
###############################################################################


unalias gup &>/dev/null
alias gup='git pull --rebase'

# git diff

alias gd='logAndRun git diff --ignore-cr-at-eol --ignore-space-at-eol --ignore-space-change --ignore-all-space --ignore-blank-lines'
alias gD='logAndRun git diff'

alias gdc='gd --cached'
alias gDc='gD --cached'
alias gdh='gd HEAD'
alias gdhs='gd --stat HEAD'
alias gDh='gD HEAD'
alias gDhs='gD --stat HEAD'
alias gdbc='git difftool --tool=bc4 -y'
alias gdbch='git difftool --tool=bc4 -y HEAD --'
alias gdi='git difftool --tool=idea -y --'
alias gdih='git difftool --tool=idea -y HEAD --'

alias gdorigin='gd origin/$(git_current_branch)'
alias gDorigin='gD origin/$(git_current_branch)'
alias gdhorigin='gd HEAD origin/$(git_current_branch)'
alias gDhorigin='gD HEAD origin/$(git_current_branch)'

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
    gd --stat "$from" "$to"
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
    gD --stat "$from" "$to"
}

# git status

alias gssi='git status -s --ignored'
alias gsti='git status --ignored'
alias gs='git status -s' # I never use gs command but will mistype :)

alias gcignore='git check-ignore -v'

# git log
unalias gg
gg() {
    local -a options_when_console
    [ -t 1 ] && options_when_console=(--color -$LINES)
    glog $options_when_console "$@" | catOneScreen
}
compdef _git gg=git-log

alias ggg='glgg -4'
alias GG='glgg -4'
alias gggg='glgg -7'
alias GGG='glgg -7'


## git branch

unalias gco
gco() {
    local remote=origin
    [ "$1" = "-r" ] && {
        remote="$2"
        shift 2
    }
    local branch=${1##remotes/$remote/}

    git checkout "$branch" || {
        git fetch "$remote" &&
        git checkout "$branch"
    }
}
compdef _git gco=git-checkout


__git_remove_bkp_rel_branches() {
    sed -r '/->/b; \#/tags/#d; \#/release(s/|-)#d'
}

__gb_sc() {
    # How can I get a list of git branches, ordered by most recent commit?
    #   http://stackoverflow.com/questions/5188320
    # --sort=-committerdate : sort branch by commit date in descending order
    # --sort=committerdate : sort branch by commit date in ascending order
    git branch --sort=committerdate "$@"
}

gbt() {
    [ -t 1 ] && local force_color_option=--color
    __gb_sc $force_color_option -a "$@" | hint_git_simple_branch_name
}

gbtr() {
    [ -t 1 ] && local force_color_option=--color
    __gb_sc $force_color_option -r "$@" | hint_git_simple_branch_name -v IS_REMOTE_MODE=1
}

gbtl() {
    [ -t 1 ] && local force_color_option=--color
    __gb_sc $force_color_option "$@" | hint_git_simple_branch_name
}

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

# How to find/identify large commits in git history?
#   https://stackoverflow.com/a/42544963/922688
lsGitFileSizeInHis() {
    git rev-list --objects --all |
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
    sed -n 's/^blob //p' |
    sort --numeric-sort --key=2 |
    cut -c 1-12,41- |
    $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}

# misc

__heavyOpenFileByApp() {
    [ $# -eq 0 ] && {
        echo "at least 1 app args" 1>&2
        return 1
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

# GitHub Desktop.app
ghd() {
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
            open -a '/Applications/GitHub Desktop.app' "$git_root"
            echo "GitHub Desktop open $git_root ( $f )"
        )
    done
}

## URL shower/switcher

__gitUrl_Http2Git() {
    local git_user="${1:-git}"
    echo "$url" | sed -r '
        s#^https?://#'"$git_user"'@#
        s#(\.com|\.org|\.net)/#\1:#
        s#/$##
        s#(\.git)?$#\.git#
    '
}

__gitUrl_Git2Http() {
    echo "$url" | sed -r '
        s#^\w*@#https://#
        s#(\.com|\.org|\.net|\.io):#\1/#
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
    [ $# -eq 0 ] && local -a files=(.) || local -a files=("$@")
    local d
    for d in "${files[@]}"; do
        (cd "$d" && __chgr)
    done
}

__chgr() {
    local d
    for d in `find -maxdepth 6 -iname .git`; do
        (
            cd "$(dirname $d)"
            # echo "Found $PWD"
            local url=$(git remote get-url origin)
            if [[ "$url" =~ '^http'  ]]; then
                local gitUrl=$(__gitUrl_Http2Git)
                warnEcho "CHANGE $PWD :"
                echo -e "\t$url\n\tto\n\t$gitUrl"

                git remote set-url origin $gitUrl
            else
                echo "Ignore $PWD :"
                echo -e "\t$url"
            fi
        )
    done
}

wgcl() {
    local git_user force_ssh_protocol=false
    local -a git_options=()

    # parse options
    while true; do
        case "$1" in
        -u)
            git_user="${2:-git}"
            shift 2
            ;;
        -r)
            git_options+=--recurse-submodules
            shift
            ;;
        -s)
            force_ssh_protocol=true
            shift
            ;;
        *)
            break
            ;;
        esac
    done

    local url
    for url in "$@"; do
        if [[ $force_ssh_protocol && "$url" =~ '^http' ]]; then
            url=$(__gitUrl_Http2Git "$git_user")
        fi
        whl git clone $git_options "$url"
    done
}

# git clone batch
gclb() {
    local git_user force_git=false
    [ "$1" = "-u" ] && {
        git_user="${2:-git}"
        shift 2
    }
    [ "$1" = '-fg' ] && {
        force_git=true
        shift
    }

    local -a failedUrls=()
    local url git_url target_dir_name
    for url in "$@"; do
        if ! [[ $url =~ '\.git$' ]]; then
            git_url="$url.git"
        fi
        if $force_git && [[ "$url" =~ '^http' ]]; then
            git_url=$(__gitUrl_Http2Git "$git_user")
        fi

        target_dir_name=$(echo $git_url | sed 's/\.git$//' | awk -F/ '{print $(NF)}')
        if [ -d "$target_dir_name" ]; then
            infoInteractive "SKIP $url"
            continue
        fi

        logAndRun git clone "$git_url" || failedUrls=( "${failedUrls[@]}" "$url")
    done

    if [ "${#failedUrls[@]}" -gt 0 ]; then
        echo
        echo
        errorEcho "Failed dirs:"
        local idx=0
        for url in "${failedUrls[@]}"; do
            printf '%4s: %s\n' $((++idx)) "$url"
        done
    fi
}

alias glabclb='gclb -u gitlab -fg'

# git browse
gbw() {
    local args=("$@") arg url
    args=${args:-.}

    for arg in "${args[@]}"; do
        if [ -d "$arg" ]; then
            (
                cd "$arg"
                url=$(cd "$1" && git remote get-url origin)
                if ! [[ "$url" =~ '^http' ]]; then
                    url=$(__gitUrl_Git2Http)
                fi

                echo "open $url @ dir $arg"
                open "$url"
            )
        else
            url="$arg"
            if ! [[ "$url" =~ '^http' ]]; then
                url=$(__gitUrl_Git2Http)
            fi

            echo "open $url @ dir $arg"
            open "$url"
        fi
    done
}

# git up
# https://github.com/msiemens/PyGitUp
#
# git pull has two problems:
#   It merges upstream changes by default, when it's really more polite to rebase over them, unless your collaborators enjoy a commit graph that looks like bedhead.
#   It only updates the branch you're currently on, which means git push will shout at you for being behind on branches you don't particularly care about right now.
# Solve them once and for all.
gu() {
    git-up "$@"
}
# alias gu='git pull --rebase --autostash'

gut() {
    git-up "$@" && git fetch --tags
}

# git up recursively
# Usage: gur [<dir1>  [<dir2> ...]]
gur() {
    local maxdepth=6
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


        # find "$f" -maxdepth $maxdepth -follow -name .git -type d -o \( -name .svn -o -name target \) -prune -false |
        fd '^\.git$' --type=d -HI --max-depth="$maxdepth" "$f" |
        while read d; do
            $isFirst && isFirst=false || echo

            d="$(readlink -f "$(dirname $d)")"
            infoEcho "$((++idx)): Update Git repo $(basename "$d"): $d"
            (
                cd "$d" && {
                    printf  "repo url: $(git remote get-url origin)"
                    gut
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
            printf '%4s: %s\n' $((++idx)) "$d"
        done
    fi
}

alias gsa='git submodule add'

gpc() {
    local c
    for c; do
        logAndRun git push origin "$c:$(git_current_branch)"
    done
}

gpcf() {
    [ $# != 1 ] && {
        echo "only 1 argument, but $@"
        return 1
    }
    local c
    logAndRun git push -f origin "$1:$(git_current_branch)"
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

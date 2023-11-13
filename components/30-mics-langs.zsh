###############################################################################
# Python
###############################################################################

# ZSH_PIP_INDEXES='http://pypi.douban.com/simple/'

unalias ipython
alias ipy='ipython --matplotlib --pylab'
alias bpy=bpython

alias nb='LANGUAGE="" LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 jupyter-notebook'
alias lab='LANGUAGE="" LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 jupyter-lab'

alias pyenv='"${PY:-python3}" -m venv'

unalias pip
pip() {
    [ -n "${PY:-}" ] && interactiveInfo "use \$PY: $PY"
    "${PY:-python3}" -m pip "$@"
}
pip3() {
    pip "$@"
}


pipup() {
    pip list --outdated | awk 'NR>2{print $1}' | xargs pip install --upgrade
}

unalias pipir

pipir() {
    local req="${1:-requirements.txt}"
    pip install -r "$req"
}

# export PATH="$HOME/.miniconda3/bin:$PATH"

__setupMiniconda3() {
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    local __conda_setup="$("$HOME/.miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"

    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/.miniconda3/etc/profile.d/conda.sh" ]; then
            . "$HOME/.miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/.miniconda3/bin:$PATH"
        fi
    fi
    # unset __conda_setup
    # <<< conda initialize <<<

    __setupMiniconda3_mark=true
}

# activate miniconda3 environment
ame() {
    [ -z $__setupMiniconda3_mark ] && __setupMiniconda3

    local a_env="$1"
    if [ -n "$a_env" ]; then
        dme
        echo
        #logAndRun source activate "$a_env"
        logAndRun conda activate "$a_env"
    else
        # select a_env in `conda info --envs | awk '/^[^#]/{print $1}'`; do
        select a_env in `find $HOME/.miniconda3/envs -maxdepth 1 -mindepth 1 -type d | xargs -n1 basename`; do
            if [ -n "$a_env" ]; then
                dme
                echo
                #logAndRun source activate "$a_env"
                logAndRun conda activate "$a_env"
                break
            fi
        done
    fi
}

# deactivate miniconda3 environment
dme() {
    [ -n "$CONDA_DEFAULT_ENV" ] && conda deactivate
}


# Python Venv Create
pvc() {
    local recreate=false req_file=requirements.txt
    while true; do
        case "$1" in
        -r)
            recreate=true
            shift
            ;;
        -f)
            req_file="$2"
            shift 2
            ;;
        *)
            break
            ;;
        esac
    done

    [ -n "${PY:-}" ] && interactiveInfo "use \$PY: $PY"
    local python="${PY:-python3}"
    if command -v "$python" &> /dev/null; then
        python=$(command -v "$python")
        python=$(readlink -f "$python")
    else
        errorEcho "$python command not found!"
        return 1
    fi

    local venv_dir_name="${1:-venv}"
    if [ -e "$venv_dir_name" ]; then
        if [ -d "$venv_dir_name" ] && $recreate; then
            rm -rf "$venv_dir_name"
        else
            errorEcho "$venv_dir_name is not a directory, can NOT recreate!"
            return 1
        fi
    fi

    local moreVenvOption=
    "$python" -c 'import sys; sys.version_info >= (3, 9) or exit(1)' && moreVenvOption=(--upgrade-deps)
    # create virtualenv
    logAndRun "$python" -m venv $moreVenvOption "$venv_dir_name" || {
        errorEcho "fail to create venv!"
        return 1
    }

    # install requirements.txt
    if [ -f "$req_file" ]; then
        logAndRun "$venv_dir_name/bin/pip" install -r "$req_file" ||
            errorEcho "fail to install $req_file!"
    fi

    # activate virtualenv
    logAndRun source "$venv_dir_name/bin/activate"
}

# Python Venv Activate
pva() {
    local d="$PWD/dummy"
    while true; do
        d=$(dirname "$d")
        [ "/" = "$d" ] && {
            errorEcho "No python virtualenv found!"
            return 1
        }

        local activate_file="$(set -o nullglob; echo $d/*/bin/activate)"
        [[ -n "$activate_file" && -f "$activate_file" ]] ||
            activate_file="$(set -o nullglob; echo $d/.venv/bin/activate)"
        [[ -n "$activate_file" && -f "$activate_file" ]] || continue

        local activate_bin_dir=$(dirname "$activate_file")
        [[ -f "$activate_bin_dir/python" && -f "$activate_bin_dir/pip" ]] || {
            interactiveError "find $activate_file, but without related python or pip file, IGNORED!"
            continue
        }

        logAndRun source "$activate_file"
        return
    done
}

# Python Venv Deactivate
alias pvd=deactivate

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


export POETRY_HOME="$HOME/.pypeotry"

alias po=poetry
alias por='poetry run'

alias poa='poetry add'

alias pock='poetry lock'
alias pock='poetry lock'

alias pdt='poetry show --tree'

alias pocdenv='$(poetry env info --path)'

poreq() {
    local -r req_file=requirements.txt
    local dev_groups=dev
    local -a options=(--without-urls --without-hashes -f "$req_file")
    while true; do
        case "$1" in
        -d)
            dev_groups="$2"
            shift 2
            ;;
        *)
            break
            ;;
        esac
    done

    logAndRun poetry export "${options[@]}" --output requirements-main.txt "$@"
    # && sed -i -r 's/\s*;.*$//' requirements-main.txt

    logAndRun poetry export "${options[@]}" --output requirements-dev.txt --with="$dev_groups" "$@"
    # && sed -i -r 's/\s*;.*$//' requirements-dev.txt

    if [ ! -f "$req_file" ]; then
        logAndRun ln -sr requirements-dev.txt "$req_file"
    fi
}

pova() {
    source "$(poetry env info --path)/bin/activate"
}

###############################################################################
# R
###############################################################################

alias R='R --quiet --no-save --no-restore-data'
# https://github.com/randy3k/radian
alias rn='radian --quiet'
alias Rscript='Rscript --vanilla'

rst() {
    local cmd=(open -a /Applications/RStudio.app)
    if (($# == 0)); then
        if [[ -n "$(echo *.Rproj(N))" ]]; then
            # https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers
            logAndRun "${cmd[@]}" *.Rproj
        else
            echo "No R Project found!"
            return 1
        fi
    else
        logAndRun "${cmd[@]}" "$@"
    fi
}


alias q=quarto

###############################################################################
# Ruby
###############################################################################

#source $HOME/.rvm/scripts/rvm


###############################################################################
# Javascript
###############################################################################

# NVM: https://github.com/creationix/nvm
#
# NVM init is slowwwwww! about 1.2s on my machine!!
# manually activate when needed.
#export PATH="$HOME/.nvm/versions/node/v8.1.2/bin:$PATH"
anvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    source <(npm completion)
}

__node_switch_clear() {
    [ -z "$__node_switch_before_version" ] && return 0

    local arr_excluding=("/usr/local/opt/node@${__node_switch_before_version}/bin" "$@")
    # https://stackoverflow.com/a/52188874/922688
    path=(${path:|arr_excluding})
    export PATH

    unset __node_switch_before_version
}

__node_switch() {
    local node_version="$1"
    local node_home_bin="/usr/local/opt/node@${node_version}/bin"
    [ ! -d "$node_home_bin" ] && {
        errorEcho "switch target $node_version is NOT existed: $node_home_bin"
        return 1
    }

    __node_switch_clear "$node_home_bin"

    export PATH="$node_home_bin:$PATH"

    __node_switch_before_version="$node_version"
}

alias n16='__node_switch 16'
alias n0='__node_switch_clear'

unalias npmg
alias nr='npm run'
alias ni='npm install'

alias ng='npm -g'
alias nig='npm install -g'


# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true


###############################################################################
# Haskell
###############################################################################

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env


###############################################################################
# Erlang
###############################################################################

alias rb2=rebar
alias rb=rebar3


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

export MANPATH=/usr/local/opt/erlang/lib/erlang/man:$MANPATH


###############################################################################
# Lisp
###############################################################################

CLISP_DOC=/usr/local/opt/clisp/share/doc/clisp/doc

alias schm='rlwrap -p 1\;32 -r -c -f $HOME/.scheme_completion.rlwrap scheme'


###############################################################################
# Prolog
###############################################################################

alias sp='swipl'
alias gpl='gprolog'
alias bp='$HOME/Applications/BProlog/bp'

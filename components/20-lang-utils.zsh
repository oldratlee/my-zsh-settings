###############################################################################
# Go
###############################################################################

export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin

###############################################################################
# Rust
###############################################################################

export PATH=$HOME/.cargo/bin:$PATH

###############################################################################
# Erlang
###############################################################################

alias rb2=rebar
alias rb=rebar3

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

CLISP_DOC=/usr/local/opt/clisp/share/doc/clisp/doc

alias schm='rlwrap -p 1\;32 -r -c -f $HOME/.scheme_completion.rlwrap scheme'

###############################################################################
# Prolog
###############################################################################

alias sp='swipl'
alias gpl='gprolog'
alias bp='$HOME/Applications/BProlog/bp'

###############################################################################
# Python
###############################################################################

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
            [ -n "$a_env" ] && {
                dme
                echo
                #logAndRun source activate "$a_env"
                logAndRun conda activate "$a_env"
                break
            }
        done
    fi
}

# deactivate miniconda3 environment
dme() {
    [ -n "$CONDA_DEFAULT_ENV" ] && conda deactivate
}


ZSH_PIP_INDEXES='http://pypi.douban.com/simple/'

alias py=python
alias py3=python3

unalias ipython
alias ipy=ipython --matplotlib
alias bpy=bpython

alias nb='LANGUAGE="" LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 jupyter-notebook'
alias lab='LANGUAGE="" LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 jupyter-lab'

alias R='R --no-save --no-restore'

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
#anvm() {
#    export NVM_DIR="$HOME/.nvm"
#    source "/usr/local/opt/nvm/nvm.sh"
#    source <(npm completion)
#}


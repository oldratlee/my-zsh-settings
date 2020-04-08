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

# activate/deactivate anaconda3
#aa() {
#    declare -f deactivate > /dev/null && {
#        echo "Activate anaconda3!"
#
#        deactivate
#        # append anaconda3 to PATH
#        export PATH=$HOME/.anaconda3/bin:$PATH
#    } || {
#        echo "Deactivate anaconda3!"
#
#        # remove anaconda3 from PATH
#        export PATH="$(echo "$PATH" | sed 's/:/\n/g' | grep -Fv .anaconda3/bin | paste -s -d:)"
#        source $HOME/.pyenv/default/bin/activate
#    }
#}

# activate anaconda environment
aae() {
    local a_env="$1"
    if [ -n "$a_env" ]; then
        dae
        echo
        logAndRun source activate "$a_env"
    else
        # select a_env in `conda info --envs | awk '/^[^#]/{print $1}'`; do
        select a_env in `find $HOME/.anaconda3/envs -maxdepth 1 -mindepth 1 -type d | xargs -n1 basename`; do
            [ -n "$a_env" ] && {
                dae
                echo
                logAndRun source activate "$a_env"
                break
            }
        done
    fi
}

# deactivate anaconda environment
dae() {
    [ -n "$CONDA_DEFAULT_ENV" ] && conda deactivate
}

# activate anaconda3 python
#export PATH=$HOME/.anaconda3/bin:$PATH

ZSH_PIP_INDEXES='http://pypi.douban.com/simple/'

alias py=python
alias ipy=ipython --matplotlib
alias nb='LANGUAGE="" LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 jupyter-notebook'
alias lab='LANGUAGE="" LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 jupyter-lab'
alias R='R --no-save --no-restore'

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


###############################################################################
# Go
###############################################################################

export GOPATH=$HOME/.gopath
export PATH=$PATH:$GOPATH/bin

###############################################################################
# Ruby
###############################################################################

#source $HOME/.rvm/scripts/rvm

###############################################################################
# Erlang
###############################################################################

alias r2=rebar
alias r3=rebar3

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

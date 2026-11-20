########################################
# CLI
########################################

export PATH="$HOME/.claude/my-bin:$PATH"
alias cld='claude'
alias cldc='claude --continue'
alias cldr='claude --resume'
alias clda='PWD=$HOME/tmp/cld-agents-base claude agents'


alias codex='pp command codex'
alias cx='codex'
alias cxc='codex resume --last'
alias cgpt='open -a /Applications/ChatGPT.app'


alias cursor-agent='pp command cursor-agent'
alias agent=cursor-agent
alias cs='cursor-agent'
alias csc='cursor-agent --continue'
alias csr='cursor-agent --resume'
alias grok='pp command grok'
alias gk='grok'
alias gkc='grok --continue'
alias gkr='grok --resume'


alias devin='pp command devin'
alias dv=devin
alias dvc='devin --continue'
alias dvc='devin --continue'
alias dvr='devin --resume'

alias agy='pp command agy'

alias opencode='pp command opencode'
alias oc='opencode'
alias occ='opencode -c'


alias junie='pp command junie'
alias jn='junie'
alias jnc='junie --resume'


# alias ocl='pp command openclaw'
# OpenClaw Completion
#source "$HOME/.openclaw/completions/openclaw.zsh"


upgrade_coding_agents() {
    time pp command claude upgrade
    time pp command codex update

    time pp command cursor-agent upgrade
    time pp command grok update

    time pp command opencode upgrade
    time pp command devin update
    time pp command agy update

    time pp command junie update

    logAndRun -p comagic upgrade

    gen_coding_agents_completion
}

gen_coding_agents_completion() {
    local completion_dir=$ZSH_CUSTOM/completions
    logAndRun command codex completion zsh > $completion_dir/_codex
    logAndRun command opencode --completions zsh > $completion_dir/_opencode
    logAndRun command comagic completion zsh > $completion_dir/_comagic
}

########################################
# skills tools
########################################

OS_SKILL_REPO_DIR=$HOME/codes/os-skills-repos

alias skills='DISABLE_TELEMETRY=1 skills'
alias skl='skills'
alias skls='skills list'

alias sklfd='skills find'
alias skla='skills add'
alias sklrm='skills remove'

########################################
# code indexer
########################################

# https://github.com/jgravelle/jcodemunch-mcp
alias jm='uvx jcodemunch-mcp'

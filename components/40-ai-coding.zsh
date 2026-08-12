########################################
# AI editor
########################################

alias cursor-agent='pp command cursor-agent'
alias csa='cursor-agent'
alias csc='cursor-agent --continue'

alias wds='windsurf'

########################################
# CLI
########################################

export PATH="$HOME/.claude/my-bin:$PATH"

alias codex='pp command codex'
alias cx='codex'


_findCldSettingsLocal__() {
  readonly SETTING_LOCAL=settings.local.json
  local d=$PWD target=
  while true; do
    [ -z "$d" ] && {
      return
    }
    target=$d/$SETTING_LOCAL
    if [ -f "$target" ]; then
      echo "$target"
      break
    fi
    target=$d/.claude/$SETTING_LOCAL
    if [ -f "$target" ]; then
      echo "$target"
      break
    fi

    d=${d%/*}
  done
}

# claude() {
#     local settings_local x
#     settings_local=$(_findCldSettingsLocal__)
#     if [ -n "$settings_local" ]; then
#         x=$(jq .env.ANTHROPIC_BASE_URL "$settings_local")
#         [ -n "$x" ] && https_proxy="http://127.0.0.1:7080" http_proxy="http://127.0.0.1:7080" command claude "$@"
#         return
#     fi
#
#         # ANTHROPIC_MODEL='kimi-k2.5[256k]'
#         # ANTHROPIC_DEFAULT_OPUS_MODEL='kimi-k2.5[256k]'
#         # ANTHROPIC_DEFAULT_SONNET_MODEL='kimi-k2.5[256k]'
#         # ANTHROPIC_DEFAULT_HAIKU_MODEL='kimi-k2.5[256k]'
#
#         # CLAUDE_CODE_SUBAGENT_MODEL='kimi-k2.5[256k]'
#     local default_configs=(
#         # https://www.kimi.com/code
#         # https://www.kimi.com/code/docs/
#         # https://www.kimi.com/code/docs/more/third-party-agents.html
#         ANTHROPIC_BASE_URL='https://api.kimi.com/coding/'
#         ANTHROPIC_API_KEY='sk-kimi-wAHawyQfQNGBp8vlrrtEJWKVZCZyG3mkRlpcEjmD8Lk4ATad1Jn6dvOFYCkvydN3'
#
#         ANTHROPIC_MODEL='K2.6-code-preview'
#         ANTHROPIC_DEFAULT_OPUS_MODEL='kimi-k2.6'
#         ANTHROPIC_DEFAULT_SONNET_MODEL='kimi-k2.6'
#         ANTHROPIC_DEFAULT_HAIKU_MODEL='kimi-k2.5'
#         CLAUDE_CODE_SUBAGENT_MODEL='kimi-k2.6'
#
#         # ENABLE_TOOL_SEARCH=false
#
#         API_TIMEOUT_MS=4000000
#
#         CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
#
#         # CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1
#         # https://code.claude.com/docs/en/data-usage#session-quality-surveys
#         CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
#         CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
#         DISABLE_TELEMETRY=1
#
#         https_proxy="http://127.0.0.1:7080"
#         http_proxy="http://127.0.0.1:7080"
#     )
#
#     logAndRun env ${default_configs} claude "$@"
#     # logAndRun env \
#     # $(jsonnet $HOME/.claude/my-bin/env-settings.jsonnet | jq '.settings.mimo | to_entries[] | [.key, .value] | join("=")') \
#     # claude "$@"
# }

alias cld='claude'
alias cldc='claude -c'
alias cldr='claude -r'
alias clda='PWD=/Users/jerry/tmp/cld-agents-base claude agents'


alias oc=opencode
alias occ='opencode -c'
source <(opencode completion zsh)


alias gemini='pp command gemini'
alias gmn='gemini'

alias juniec='junie --resume'

# alias ocl='pp command openclaw'

# OpenClaw Completion
#source "$HOME/.openclaw/completions/openclaw.zsh"

#exporm MINIMAX_API_KEY='sk-api-o56HPjo_aPWMUrhBWHinjdcbHnaVB9RABWpwn8LUNEpSQee4f8rYxv0tj_IM9SgVS_kWnWsgVolyVnRqlH9NaEm7ByFC9ry3nxD78PJw9D8kFfEEzLced9A'
# MINIMAX_API_KEY='sk-api-NfFQcNqqoh-SEGSca-N38qgy7i7OUFbKsE6ZZA9SnQ4riiAHWipemqhACXigBm_YKqkybe5Sa1aw5a8CV6lY7TZvf8kDFgnBes7-yDIkLqDStPhs1BLrRHU'

alias skl='DISABLE_TELEMETRY=1 skills'

########################################
# code indexer
########################################

# https://github.com/jgravelle/jcodemunch-mcp
alias jm='uvx jcodemunch-mcp'

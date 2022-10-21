export DOTNET_ROOT="/usr/local/share/dotnet"

# export DOTNET_ROOT="$HOME/.dotnet"
# export PATH="$DOTNET_ROOT:$PATH"

###############################################################################
# .NET Languages
###############################################################################

# https://docs.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete#zsh

_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  reply=( "${(ps:\n:)completions}" )
}

compctl -K _dotnet_zsh_complete dotnet

# Aliases bellow are here for backwards compatibility
# added by Shaun Tabone (https://github.com/xontab)

alias dn='dotnet new'
alias dr='dotnet run'
alias dt='dotnet test'
alias dw='dotnet watch'
alias dwr='dotnet watch run'
alias ds='dotnet sln'
alias da='dotnet add'
alias dp='dotnet pack'
alias dng='dotnet nuget'
alias db='dotnet build'

# my new aliases

alias n=dotnet
alias dmb='dotnet msbuild'

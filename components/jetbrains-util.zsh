###############################################################################
# JetBrains
###############################################################################

# JetBrains Toolbox: The right tool for the job — every time!
# https://www.jetbrains.com/toolbox/
JB_TOOL_HOME="$HOME/Library/Application Support/JetBrains/Toolbox/apps"

_jb_ide() {
    local ide="$1"
    shift
    [ $# -eq 0 ] && local files=(.) || local files=("$@")
    local f
    for f in "${files[@]}"
    (
        cd $JB_TOOL_HOME
        local -a candidates=("$ide"/*/*/*.app)
        cd -
        local count="$#candidates[@]"
        if (( count == 0 )); then
            echo "No candidates!"
        elif (( count == 1 )); then
            logAndRun open -a "$JB_TOOL_HOME/$candidates" "$f"
        else
            echo "Find multi candidates!"
            select ide in "$candidates[@]" ; do
                [ -n "$ide" ] && {
                    [ -n "$ide" ] && logAndRun open -a "$JB_TOOL_HOME/$ide" "$f"
                    break
                }
            done
        fi
    )
}

#alias idea='open -a /Applications/IntelliJ\ IDEA.app'
alias idea='_jb_ide IDEA-U'
#alias idc='_jb_ide IDEA-C'
#alias apcd='open -a /Applications/AppCode.app'
alias apc='_jb_ide AppCode'
alias ads='open -a /Applications/Android\ Studio*.app'

#alias pyc='open -a /Applications/PyCharm.app'
alias pyc='_jb_ide PyCharm-P'
alias wbs='_jb_ide WebStorm'
alias rbm='_jb_ide RubyMine'

alias cln='_jb_ide CLion'
alias gol='_jb_ide Goland'
alias rdr='_jb_ide Rider'

alias dtg='_jb_ide datagrip'
alias mps='_jb_ide MPS'

jb() {
    (
        cd $JB_TOOL_HOME
        local -a candidates=(*/*/*/*.app)
        cd -
        select ide in "$candidates[@]" ; do
            [ -n "$ide" ] && {
                [ -n "$ide" ] && logAndRun open -a "$JB_TOOL_HOME/$ide" "$@"
                break
            }
        done
    )
}

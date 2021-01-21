###############################################################################
# JetBrains
###############################################################################

# JetBrains Toolbox: The right tool for the job — every time!
# https://www.jetbrains.com/toolbox/
JB_TOOLBOX_HOME="$HOME/Library/Application Support/JetBrains/Toolbox/apps"

_jb_ide() {
    local ide_name="$1"
    shift
    local interactive=false
    [ "$1" = "-i" ] && {
        interactive=true
        shift
    }

    local f ide_vers_dir="$JB_TOOLBOX_HOME/$ide_name"
    [ $# -eq 0 ] && local -a files=(.) || local -a files=("$@")
    for f in "${files[@]}"; (
        cd "$ide_vers_dir"
        local -a candidates=(*/*/*.app)
        cd - &>/dev/null

        local count="$#candidates[@]"
        if (( count == 0 )); then
            echo "No candidates!"
        elif (( count == 1 )); then
            logAndRun open -a "$ide_vers_dir/$candidates" "$f"
        else
            if $interactive; then
                echo "Find multi candidates!"
                select ide in "${candidates[@]%/*}" ; do
                    [ -n "$ide" ] && {
                        [ -n "$ide" ] && logAndRun open -a "$ide_vers_dir/${candidates[REPLY]}" "$f"
                        break
                    }
                done
            else
                local lastVersionIde="${candidates[$#candidates]}"
                logAndRun open -a "$ide_vers_dir/$lastVersionIde" "$f"
            fi
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

___jb() {
    (
        cd $JB_TOOLBOX_HOME
        local -a candidates=(*/*/*/*.app)
        cd -
        select ide in "$candidates[@]" ; do
            [ -n "$ide" ] && {
                [ -n "$ide" ] && logAndRun open -a "$JB_TOOLBOX_HOME/$ide" "$@"
                break
            }
        done
    )
}

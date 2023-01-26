###############################################################################
# JetBrains
###############################################################################

# JetBrains Toolbox: The right tool for the job — every time!
# https://www.jetbrains.com/toolbox/
JB_IDE_HOME="$HOME/Library/Application Support/JetBrains/Toolbox/apps"

__jb_ide() {
    local ide_name="$1"
    shift
    local interactive=false
    [ "$1" = "-i" ] && {
        interactive=true
        shift
    }

    local f ide_vers_dir="$JB_IDE_HOME/$ide_name"
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

# Command-line interface
#   https://www.jetbrains.com/help/idea/working-with-the-ide-features-from-command-line.html
# Open a file in the LightEdit mode
#   https://www.jetbrains.com/help/idea/lightedit-mode.html
alias ie='idea -e'
alias pe='pycharm -e'

#alias idea='open -a /Applications/IntelliJ\ IDEA.app'
#alias idc='__jb_ide IDEA-C'
alias ij='__jb_ide IDEA-U'
# Command-line interface
# https://www.jetbrains.com/help/idea/working-with-the-ide-features-from-command-line.html

#alias apc='open -a /Applications/AppCode.app'
alias apc='__jb_ide AppCode'
#alias ads='open -a /Applications/Android\ Studio*.app'
alias ads='__jb_ide AndroidStudio'

#alias pyc='open -a /Applications/PyCharm.app'
alias pyc='__jb_ide PyCharm-P'
alias wbs='__jb_ide WebStorm'
alias rbm='__jb_ide RubyMine'

alias cln='__jb_ide CLion'
alias gld='__jb_ide Goland'
alias rdr='__jb_ide Rider'

alias dtg='__jb_ide datagrip'
alias mps='__jb_ide MPS'

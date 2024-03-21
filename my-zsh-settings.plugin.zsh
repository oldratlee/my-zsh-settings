###############################################################################
# common util functions
###############################################################################

__uEcho() {
    local color="$1"
    shift
    if [ -t 1 ]; then
        printf '\e[%sm%s\e[0m\n' "$color" "$*"
    else
        printf '%s\n' "$*"
    fi
}

infoEcho() {
    # 0;30;46
    __uEcho '1;7;36' "$*"
}

warnEcho() {
    # 1;30;43
    __uEcho '1;7;33' "$*"
}

errorEcho() {
    # 1;36;41
    # 1;7;31
    __uEcho '1;36;41' "$*"
}

__uInteractive() {
    __uEcho "$@" >&2
}

infoInteractive() {
    __uInteractive '1;7;36' "$*"
}

warnInteractive() {
    __uInteractive '1;7;33' "$*"
}

errorInteractive() {
    __uInteractive '1;36;41' "$*"
}


printOneLineResponsive() {
    if [ ! -t 1 ]; then
        cat >/dev/null
        return
    fi

    local line clear_line='\e[2K\r'
    while read -r line; do
        printf %b%s "$clear_line" "${line:0:$COLUMNS}"
    done
    printf %b "$clear_line"
} >&2


_p_logAndRun() {
    local msg profileMode=false quiet=false
    while true; do
        case "$1" in
        -m)
            msg="$2"
            shift 2
            ;;
        -p)
            profileMode=true
            shift
            ;;
        -q)
            quiet=true
            shift
            ;;
        *)
            break
            ;;
        esac
    done

    if ! $quiet; then
        msg=${msg:+$msg$'\n'}
        local infoMsg dirMsg=
        $profileMode && dirMsg="Run under work directory $PWD"$'\n'
        printf -v infoMsg '%s%s%s' "$msg" "$dirMsg" "run cmd: $*"
        infoInteractive "$infoMsg"
    fi
    # use quoted command for eval, so can call alias
    local quoted_command_for_eval
    printf -v quoted_command_for_eval '%q ' "$@"
    if $profileMode; then
        eval time $quoted_command_for_eval
    else
        eval $quoted_command_for_eval
    fi
}

logAndRun() {
    IFS=$' \t\n\C-@' _p_logAndRun "$@"
}

# run debug
rund() {
    local quoted_command_for_eval
    printf -v quoted_command_for_eval '%q ' "$@"

    set -x
    eval $quoted_command_for_eval
    local exit_code=$?
    set +x
    return "$exit_code"
}

# Find local bin first to execute; if not found, then the fallback global bin.
# Util funtion for executing wrapper(gradlew, mvnw, etc), find wrapper automatically and execute.
findLocalBinOrDefaultToRun() {
    local local_bin="$1" default_bin="$2"
    shift 2

    local d="$PWD" target
    while true; do
        [ "/" = "$d" ] && {
            if target="$(whence -p $default_bin)"; then
                infoInteractive "use default bin $default_bin: $target"
                break
            else
                errorEcho "No default bin($default_bin) found!"
                return 1
            fi
        }

        [ -f "$d/$local_bin" ] && {
            target="$(realpath "$d" --relative-to="$PWD")/$local_bin"
            infoInteractive "use local bin $local_bin: $target"
            break
        }

        d=`dirname "$d"`
    done

    logAndRun "$target" "$@"
}

# while
whl() {
    local loopEvenSuccess=false sleepTime=1 max_try=20
    local ignore_exit_codes=()
    while true; do
        case "$1" in
        -t)
            sleepTime="$2"
            shift 2
            ;;
        -i)
            ignore_exit_codes+="$2"
            shift 2
            ;;
        -f)
            loopEvenSuccess=true
            shift
            ;;
        -m)
            max_try="$2"
            shift 2
            ;;
        *)
            break
            ;;
        esac
    done

    local counter lastExitCode=0 quoted_command_for_eval
    printf -v quoted_command_for_eval '%q ' "$@"

    for ((counter = 0; counter < max_try; ++counter)) ; do
        if (( counter == 0 )); then
            infoInteractive "[$((counter + 1))] Try: $*"
        elif ((lastExitCode != 0)) ; then
            errorInteractive "[$((counter + 1))] Retry(last status: $lastExitCode): $*"
        else
            infoInteractive "[$((counter + 1))] Force loop: $*"
        fi
        eval $quoted_command_for_eval

        lastExitCode=$?
        if ((lastExitCode == 0)) && ! $loopEvenSuccess ; then
            break
        fi

        sleep $sleepTime
    done

    infoInteractive "stopped after $counter try: $*"
}
compdef whl=time

addToPath() {
    removeFromPath "$@"

    local new_eles
    printf -v new_eles '%s:' "$@"
    printf -v PATH "%s%s" "$new_eles" "$PATH"
    PATH=${PATH%:}
}

removeFromPath() {
    local ele="$1"
    for ele in "$@"; do
        PATH=${PATH//$ele}
        PATH=${PATH//::/:}
    done
    PATH=${PATH#:}
    PATH=${PATH%:}
}

###############################################################################
# source sub-components
###############################################################################

for ___my_setting_component_name__ in "${0%/*}/components"/*.zsh; do
    source "$___my_setting_component_name__"
done
unset ___my_setting_component_name__

# https://github.com/hyperupcall/autoenv
# if functions autoenv_init &>/dev/null; then
#     autoenv_init
# fi

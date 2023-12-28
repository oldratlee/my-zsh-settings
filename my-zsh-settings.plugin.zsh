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
    __uEcho '0;30;46' "$*"
}

warnEcho() {
    __uEcho '1;34;43' "$*"
}

errorEcho() {
    __uEcho '1;36;41' "$*"
}

__uInteractive() {
    local color="$1"
    shift
    if [ -t 2 ]; then
        printf '\e[%sm%s\e[0m\n' "$color" "$*" >&2
    fi
}

infoInteractive() {
    __uInteractive '0;30;46' "$*"
}

warnInteractive() {
    __uInteractive '1;34;43' "$*"
}

errorInteractive() {
    __uInteractive '1;36;41' "$*"
}


printOneLineResponsive() {
    local line clear_line='\033[2K\r'
    while read -r line; do
        printf %b%s "$clear_line" "$line"
    done
    printf %b "$clear_line"
} >&2


logAndRun() {
    local msg profileMode=false
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
        *)
            break
            ;;
        esac
    done

    local infoMsg="${msg:+$msg\n}$($profileMode && echo -E "Run under work directory $PWD\\n")run cmd: $*"
    infoInteractive "$infoMsg"
    if $profileMode; then
        time "$@"
    else
        "$@"
    fi
}

# run debug
rund() {
    set -x
    "$@"
    set +x
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

    local counter lastExitCode=0
    for ((counter = 0; counter < max_try; ++counter)) ; do
        if (( counter == 0 )); then
            infoInteractive "[$((counter + 1))] Try: $*"
        elif ((lastExitCode != 0)) ; then
            errorInteractive "[$((counter + 1))] Retry(last status: $lastExitCode): $*"
        else
            infoInteractive "[$((counter + 1))] Force loop: $*"
        fi
        "$@"

        lastExitCode=$?
        if ((lastExitCode == 0)) && ! $loopEvenSuccess ; then
            break
        fi

        sleep $sleepTime
    done

    infoInteractive "stopped after $counter try: $*"
}
compdef whl=time


###############################################################################
# source sub-components
###############################################################################

___my_setting_plugin_dir_name___="$(dirname "$0")"

for ___my_setting_plugin_name___ in "$___my_setting_plugin_dir_name___/components"/*.zsh; do
    source "$___my_setting_plugin_name___"
done

unset ___my_setting_plugin_dir_name___ ___my_setting_plugin_name___

###############################################################################
# more actions
###############################################################################

# [[ -o login && -o interactive ]] && neofetch

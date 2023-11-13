###############################################################################
# util functions
###############################################################################

warnEcho() {
    if [ -t 1 ]; then
        printf '\e[1;33;44m%s\e[0m\n' "$*"
    else
        printf '%s\n' "$*"
    fi
}

errorEcho() {
    if [ -t 1 ]; then
        printf '\e[1;36;41m%s\e[0m\n' "$*"
    else
        printf '%s\n' "$*"
    fi
}

interactiveInfo() {
    if [ -t 2 ]; then
        printf '\e[1;37;44m%s\e[0m\n' "$*" >&2
    fi
}

interactiveError() {
    if [ -t 2 ]; then
        printf '\e[1;36;41m%s\e[0m\n' "$*" >&2
    fi
}

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
    interactiveInfo "$infoMsg"
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
                interactiveInfo "use default bin $default_bin: $target"
                break
            else
                errorEcho "No default bin($default_bin) found!"
                return 1
            fi
        }

        [ -f "$d/$local_bin" ] && {
            target="$(realpath "$d" --relative-to="$PWD")/$local_bin"
            interactiveInfo "use local bin $local_bin: $target"
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
            interactiveInfo "[$((counter + 1))] Try: $*"
        elif ((lastExitCode != 0)) ; then
            interactiveError "[$((counter + 1))] Retry(last status: $lastExitCode): $*"
        else
            interactiveInfo "[$((counter + 1))] Force loop: $*"
        fi
        "$@"

        lastExitCode=$?
        if ((lastExitCode == 0)) && ! $loopEvenSuccess ; then
            break
        fi

        sleep $sleepTime
    done

    interactiveInfo "stopped after $counter try: $*"
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

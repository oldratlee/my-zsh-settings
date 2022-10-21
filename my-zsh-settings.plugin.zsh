###############################################################################
# util functions
###############################################################################

warnEcho() {
    [ -t 1 ] && echo "\033[1;33;44m$*\033[0m" || echo "$*"
}

errorEcho() {
    [ -t 1 ]  && echo "\033[1;36;41m$*\033[0m" || echo "$*"
}

echoInteractiveInfo() {
    [ -t 2 ] && warnEcho "$*" 1>&2
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
    echoInteractiveInfo "$infoMsg"
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
                echoInteractiveInfo "use default bin $default_bin: $target"
                break
            else
                errorEcho "No default bin($default_bin) found!"
                return 1
            fi
        }

        [ -f "$d/$local_bin" ] && {
            target="$(realpath "$d" --relative-to="$PWD")/$local_bin"
            echoInteractiveInfo "use local bin $local_bin: $target"
            break
        }

        d=`dirname "$d"`
    done

    logAndRun "$target" "$@"
}

whl() {
    local loopEvenSuccess=false sleepTime=1
    local ignore_exit_codes=()
    while true; do
        case "$1" in
        -f)
            loopEvenSuccess=true
            shift
            ;;
        -t)
            sleepTime="$2"
            shift 2
            ;;
        -i)
            ignore_exit_codes+="$2"
            shift 2
            ;;
        *)
            break
            ;;
        esac
    done

    local counter=1 lastExitCode=0
    while true ; do
        if ((counter == 1)) || ((lastExitCode != 0)) ; then
            echoInteractiveInfo "Try $counter: $*"
        else
            echoInteractiveInfo "Force loop $counter: $*"
        fi
        "$@"

        lastExitCode=$?

        if ((lastExitCode == 0)) && ! $loopEvenSuccess ; then
            break
        fi

        ((counter++))
        sleep $sleepTime
    done

    echoInteractiveInfo "finished after $counter try: $*"
}
compdef whl=time


###############################################################################
# source sub-components
###############################################################################

___my_setting_plugin_dir_name___="$(dirname "$0")"

for ___my_setting_plugin_name___ in "$___my_setting_plugin_dir_name___/components"/*; do
    source "$___my_setting_plugin_name___"
done

unset ___my_setting_plugin_dir_name___ ___my_setting_plugin_name___

###############################################################################
# more actions
###############################################################################

# [[ -o login && -o interactive ]] && neofetch

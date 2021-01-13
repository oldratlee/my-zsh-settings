###############################################################################
# Util functions
###############################################################################

warnEcho() {
    $is_console && echo "\033[1;33;44m$*\033[0m" || echo "$*"
}

errorEcho() {
    $is_console && echo "\033[1;36;41m$*\033[0m" || echo "$*"
}

echoInteractiveInfo() {
    [ -t 2 ] && warnEcho "$@" 1>&2
}

logAndRun() {
    echoInteractiveInfo "$@"
    echoInteractiveInfo

    "$@"
}

debugAndRun() {
    set -x
    "$@"
    set +x
}

# Find local bin first to execute; if not found, then the fallback global bin.
# Util funtion for executing wrapper(gradlew, mvnw, etc), find wrapper automatically and execute.
function find_local_bin_or_default_to_run() {
    local local_bin="$1" default_bin="$2"
    shift 2

    local d="$PWD" target
    while true; do
        [ "/" = "$d" ] && {
            target="$(whence -p $default_bin)"
            echoInteractiveInfo "use default bin $default_bin: $target"
            break
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
    local loopEvenSuccess=false
    [[ '-f' = "$1" ]] && loopEvenSuccess=true
    local counter=0
    while true ; do
        ((counter++))

        echoInteractiveInfo "$counter try:\n\t$@\n"

        if "$@" && ! $loopEvenSuccess ; then
            break
        fi

        sleep 0.5
        echoInteractiveInfo
    done

    echoInteractiveInfo
    echoInteractiveInfo "finished:\n\t$@\nafter $counter try"
}
compdef whl=time


###############################
# source components
###############################

___my_setting_plugin_dir_name___="$(dirname "$0")"

for ___my_setting_plugin_name___ in "$___my_setting_plugin_dir_name___/components"/*; do
    source "$___my_setting_plugin_name___"
done

unset ___my_setting_plugin_dir_name___ ___my_setting_plugin_name___

neofetch

###############################################################################
# Util functions
###############################################################################

echoInteractiveInfo() {
    [ -t 2 ] && echo "$@" 1>&2
}

logAndRun() {
    echoInteractiveInfo "$@"
    echoInteractiveInfo

    "$@"
}

# Find local bin first to execute; if not found, then the fallback global bin.
# Util funtion for executing wrapper(gradlew, mvnw, etc), find wrapper automatically and execute.
function find_local_bin_or_default_to_run() {
    local local_bin="$1"
    local default_bin="$2"
    shift 2

    local d="$PWD"
    local target
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
    local counter=0
    while true ; do
        ((counter++))

        echoInteractiveInfo "$counter try:\n\t$@\n"
        "$@" && break

        sleep 0.5
        echechoInteractiveInfo
    done

    echoInteractiveInfo
    echoInteractiveInfo "finished:\n\t$@\nafter $counter try"
}
compdef whl=time


###############################
# source components
###############################

___plugin_dir_name___="$(dirname "$0")"

source "$___plugin_dir_name___/"components/shell-setting.zsh
source "$___plugin_dir_name___/"components/git-utils.zsh

source "$___plugin_dir_name___/"components/java-utils.zsh
source "$___plugin_dir_name___/"components/jetbrains-util.zsh
source "$___plugin_dir_name___/"components/lang-utils.zsh

source "$___plugin_dir_name___/"components/docker-helper.zsh

unset ___plugin_dir_name___

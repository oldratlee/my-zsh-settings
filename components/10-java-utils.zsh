###############################################################################
# Java/JVM Languages
###############################################################################

alias java='java -Duser.language=en_US'
alias javac='javac -J-Duser.language=en_US'

alias jstack='jstack -J-Duser.language=en_US'
alias jstat='jstat -J-Duser.language=en_US'

alias jcmd='jcmd -J-Duser.language=en_US'
alias jshell='jshell -J-Duser.language=en_US'


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

__getLatestJavaHomeForVersion() {
    local version="$1"
    [ -n "$SDKMAN_CANDIDATES_DIR" ] || {
        errorEcho "\$SDKMAN_CANDIDATES_DIR is empty!"
        return 1
    }

    (set -o nullglob; printf '%s\n' "${SDKMAN_CANDIDATES_DIR}/java/$version"[.-]*) |
        command grep -vE '\.fx-|-(gln|grl|mandrel|nik)$' |
        command sort -V |
        command tail -1
}

# set JAVA_HOME
setjh(){
    local java_home="$1"

    if [ -z "$java_home" ]; then
        local -r sdk_mvn_path=~/.sdkman/candidates/java
        local jh
        select jh in  $(command ls -v "$sdk_mvn_path" | command grep -v current); do
            [ -n "$jh" ] && break
        done
        [ -n "$jh" ] || return 1
        java_home="$sdk_mvn_path/$jh"
        echo "set JAVA_HOME=$java_home"
        echo "add PATH: $java_home/bin"
        echo "\nsetjh $java_home"
    fi

    if [ ! -e "$java_home" ]; then
        errorEcho "java home($java_home) not existed"
        return 1
    fi

    export JAVA_HOME="$java_home"

    local old_java_path=${commands[java]}
    local old_java_dir=${old_java_path%/java}

    if [ '/usr/bin/java' != "$old_java_path" ]; then
        PATH=${PATH//$old_java_dir}
    fi
    PATH="$JAVA_HOME/bin:$PATH"
    export PATH=${PATH//::/:}

    # export JAVA_OPTS="${JAVA_OPTS:+$JAVA_OPTS }-Duser.language=en -Duser.country=US -Xverify:none"
    local ver major_ver
    ver="$("$JAVA_HOME/bin/java" -version 2>&1 | awk -F\" 'NR==1{print $2}')"
    major_ver=${ver%%.*}
    if ((major_ver < 13)); then
        export JAVA_OPTS='-Duser.language=en -Duser.country=US -Xverify:none'
    else
        export JAVA_OPTS='-Duser.language=en -Duser.country=US'
    fi
}

alias cdjh='cd $JAVA_HOME'

export_java_env_vars() {
    #export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)
    #export JAVA6_HOME='/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home'
    local jv_version jv_home expr
    for jv_version in 6 8 11 17 19 {20..25}; do
        jv_home=$(__getLatestJavaHomeForVersion $jv_version)
        if [ -z "$jv_home" ]; then
            unset JAVA${jv_version}_HOME JAVA${jv_version}HOME
            unset JDK${jv_version}_HOME JDK_${jv_version}
            unalias j${jv_version} 2>/dev/null
            continue
        fi

        # export JAVAn_HOME, JAVAnHOME, like JAVA8_HOME, JAVA8HOME
        printf -v expr '%q=%q' "JAVA${jv_version}_HOME" "$jv_home"
        export "$expr"
        printf -v expr '%q=%q' "JAVA${jv_version}HOME" "$jv_home"
        export "$expr"

        # export JDKn_HOME, JDK_n, like JDK8_HOME, JDK_8
        printf -v expr '%q=%q' "JDK${jv_version}_HOME" "$jv_home"
        export "$expr"
        printf -v expr '%q=%q' "JDK_${jv_version}" "$jv_home"
        export "$expr"

        # add JAVA_HOME switcher jn, like j9, j16
        printf -v expr '%q=setjh "$%q"' "j${jv_version}" "JAVA${jv_version}_HOME"
        alias "$expr"
    done

    # default JAVA_HOME
    export JAVA0_HOME="$SDKMAN_CANDIDATES_DIR/java/current"
    alias j0='setjh "$JAVA0_HOME"'
    setjh "$JAVA0_HOME"

    export MANPATH="$JAVA_HOME/man:$MANPATH"
}
export_java_env_vars
j0

showJavaInfos() {
    logAndRun gradle --version
    echo
    logAndRun mvn -v
    echo
    logAndRun type -a java
    logAndRun which -a java
    echo
    infoInteractive "\$JAVA_HOME:"
    echo "$JAVA_HOME\nAbsulate path:\n$(ap "$JAVA_HOME")"
    echo
    logAndRun java -version
}


alias jvp='javap -J-Duser.language=en -J-Duser.country=US -cp .'
alias jvpp='javap -J-Duser.language=en -J-Duser.country=US -cp . -p'
alias jcc='$HOME/Codes/open/japi-compliance-checker/japi-compliance-checker.pl -skip-internal-packages internal -skip-internal-packages util -skip-internal-packages utils'
#alias jad='jad -nonlb -space -ff -s java'

swJavaNetProxy() {
    # How to check if a variable is set in Bash?
    # http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    [ -z "${JAVA_OPTS_BEFORE_NET_PROXY+if_check_var_defined_will_got_output_or_nothing}" ] && {
        export JAVA_OPTS_BEFORE_NET_PROXY="$JAVA_OPTS"
        export JAVA_OPTS="$JAVA_OPTS -DproxySet=true -DsocksProxyHost=127.0.0.1 -DsocksProxyPort=7070"
        echo "turn ON java net proxy!"
    } || {
        export JAVA_OPTS="$JAVA_OPTS_BEFORE_NET_PROXY"
        unset JAVA_OPTS_BEFORE_NET_PROXY
        echo "turn off java net proxy!"
    }
}

# decompile java
dcj() {
    local dcj_quit dcj_class_path
    while (($# > 0)); do
        case "$1" in
        -q)
            dcj_quit=-q
            shift
            ;;
        -cp)
            dcj_class_path="${dcj_class_path:+$dcj_class_path:}$2"
            shift 2
            ;;
        *)
            break
            ;;
        esac
    done

    logAndRun cfr-decompiler --removedeadmethods false \
        ${dcj_class_path:+--extraclasspath} \
        ${dcj_class_path:+"$dcj_class_path"} \
        "$@" | c ${dcj_quit:-}
}

alias dcjq='dcj -q'


export JREBEL_HOME=$HOME/Applications/jrebel7.0.2

###############################################################################
# Scala
###############################################################################

alias scl='scala -Dscala.color -feature'
alias amd='$SDKMAN_CANDIDATES_DIR/ammonite/2.4.0_3.0/amm'

# decompile scala
dcs() {
    local scala_version args=()
    while (($# > 0)); do
        case "$1" in
        -sv)
            scala_version="$2"
            shift 2
            ;;
        *)
            args+=$1
            shift
            ;;
        esac
    done
    set -- $args

    local -r scala_candidates="$SDKMAN_CANDIDATES_DIR/scala"
    [ -z "${scala_version:-}" ] && {
        scala_version=$(builtin cd "$scala_candidates" && command ls -v -d *(/) | tail -1)
    }

    dcj -cp "$scala_candidates/$scala_version/lib" "$@"
}

alias dcsq='dcs -q'


# Scala CLI

sc() {
    compdef sc=scala-cli

    # https://scala-cli.virtuslab.org/docs/reference/cli-options/
    #
    # scala-cli --power config httpProxy.address http://127.0.0.1:7070
    scala-cli --java-home="/Users/jerry/.sdkman/candidates/java/17" "$@"
}
# alias sc='scala-cli --java-home="/Users/jerry/.sdkman/candidates/java/17"'

# >>> scala-cli completions >>>
fpath=("/Users/jerry/Library/Application Support/ScalaCli/completions/zsh" $fpath)
compinit
# <<< scala-cli completions <<<

compdef sc=scala-cli


###############################################################################
# Maven
###############################################################################

# export MAVEN_OPTS="${MAVEN_OPTS:+$MAVEN_OPTS }-Xmx768m -Duser.language=en -Duser.country=US"
export MAVEN_OPTS="-Xmx768m -Duser.language=en -Duser.country=US"

unalias mvn &> /dev/null

# installed mvnd
# https://github.com/mvndaemon/mvnd/#set-up-completion
# unalias mvnd

function mvn() {
    local args=(${MVN_REPO_LOCAL:+"-Dmaven.repo.local=$MVN_REPO_LOCAL"} "$@")

    if [ "${USE_M2+defined}" ]; then
        local M2_BIN="$SDKMAN_CANDIDATES_DIR/maven/2.2.1/bin/mvn"
        infoInteractive "use maven 2: $M2_BIN"

        logAndRun "$M2_BIN" ${MVN_REPO_LOCAL:+"-Dmaven.repo.local=$MVN_REPO_LOCAL"} "$@"
    elif [ -n "${USE_MVND+defined}" ]; then
        infoInteractive "use mvnd: $(which mvnd)"

        logAndRun mvnd "${args[@]}"
    else
        findLocalBinOrDefaultToRun mvnw mvn "${args[@]}"
    fi
}

# quick and dirty mode(qdm)
#
# apache-rat-plugin : rat.skip
#   https://creadur.apache.org/rat/apache-rat-plugin/check-mojo.html
#
# What is the difference between "-Dmaven.test.skip.exec" vs "-Dmaven.test.skip=true" and "-DskipTests"?
#   https://stackoverflow.com/questions/21933895
# Maven - How to compile tests without running them ?
#   https://stackoverflow.com/questions/4768660
__mvn_qdm_options=(
    -DskipTests
    -Dmaven.javadoc.skip
    -Drat.skip
    -Dautoconf.skip -Dautoconfig.skip
    -Dscm.app.name=faked -DappName=faked
)

mvnq() {
    mvn $__mvn_qdm_options "$@"
}
mc() {
    mvnq clean "$@"
}
mi() {
    mvnq install "$@"
}
mci() {
    mc && mi "$@"
}


__mdep() {
    local goal="$1"
    shift
    mvn org.apache.maven.plugins:maven-dependency-plugin:3.6.0:$goal "$@"
}

mdt() {
    __mdep tree "$@"
}
alias mdtr='mdt -Dscope=runtime'
mmdt() {(
    logAndRun mdt -B "$@" | tee mdt-origin.log

    echo
    infoInteractive "tidy result: "
    echo
    command grep '(\+-|\\-).*:.*:|\bBuilding\b|(^\[INFO\] -----------+\[)' --line-buffered -E |
        sed -r 's/^\[\w*\] //' mdt-origin.log | tee mdt.log |
        command grep --line-buffered -Pv ':test( \(version managed|$)' |
        tee mdt-exclude-test.log
)}

mda() {
    __mdep analyze "$@"
}
mmda() {
    logAndRun mda -B "$@" | tee mda-origin.log

    echo
    infoInteractive "tidy result: "
    echo
    command sed -r -n '
            /\bBuilding\b|^\[ERROR\] /p
            /Used undeclared dependencies found:|Unused declared dependencies found:/,/^\[INFO\]/ {
                /^\[INFO\]/b
                p
            }
        ' mda-origin.log | tee mda.log
}

alias mds='__mdep sources'

alias mdc='__mdep copy-dependencies -DincludeScope=runtime'
alias mdct='__mdep copy-dependencies -DincludeScope=test'

# Check dependencies update
mcv() {
    local g goals=() versions_maven_plugin_version=2.16.2
    for g in display-dependency-updates display-plugin-updates display-property-updates; do
        goals+="org.codehaus.mojo:versions-maven-plugin:$versions_maven_plugin_version:$g"
    done

    local ignore_version_option ignore_versions=(
        # netty 5.0.0.Alpha2
        '.*[-.][Aa]lpha([-.]?\d+)?'
        '.*[-.][Bb]eta([-.]?\d+)?'
        # '(?i).*-rc(-?\d+(-.*)?)?'
        '(?i).*-rc(-?\d+)?'

        # '(?i).*-dev-?\d+(-.*)?'
        # '.*-[Mm](ilestone)?-?\d+(-.*)?'
        '(?i).*-dev-?\d+'
        '.*-[Mm](ilestone)?-?\d+'

        '.*(-does)?-not-exist'

        # commons-cli:commons-cli 1.5.0 -> 20040117.000000
        # commons-io:commons-io 2.13.0 -> 20030203.000550
        '\d{8}\.\d{6}'
    )
    ignore_version_option="$(IFS=,; echo "$ignore_versions")"

    # https://www.mojohaus.org/versions/versions-maven-plugin/display-dependency-updates-mojo.html
    mvn "-Dmaven.version.ignore=$ignore_version_option" "${goals[@]}" "$@"
}

mmcv() {
    local show_original=false
    if [ "$1" = -O ]; then
        show_original=true
        shift
    fi

    mcv -B "$@" | if $show_original; then
        tee mcv-origin.log

        echo
        infoInteractive "tidy result: "
        echo
    else
        tee mcv-origin.log | printOneLineResponsive
    fi

    command rg '^\[INFO\].*->|^\[INFO\] Building\b|^\[INFO\] Require Maven |^\[ERROR\]|^\[WARNING\]' mcv-origin.log | tee mcv.log
    # command rg '\[(INFO|ERROR)\].*->' | sort -k4,4V -k2,2 -u | tee mcv.log
}

# https://github.com/ferstl/depgraph-maven-plugin
alias mdg='mvn com.github.ferstl:depgraph-maven-plugin:4.0.2:aggregate -DgraphFormat=puml'

# Update project version
muv() {
    [ $# -ne 1 ] && {
        echo "Only 1 argument for version!"
        return 1
    }
    mvn org.codehaus.mojo:versions-maven-plugin:2.15.0:set -DgenerateBackupPoms=false -DnewVersion="$1"
}
# create maven wrapper
# http://mvnrepository.com/artifact/io.takari/maven
mwrapper() {
    local -r sdk_mvn_path=~/.sdkman/candidates/maven
    local latest_ver
    latest_ver=$(command ls -vr "$sdk_mvn_path" | command grep -v current | command head -1)

    local wrapper_mvn_version="${1:-$latest_ver}"
    # https://maven.apache.org/wrapper/
    logAndRun "$sdk_mvn_path/$latest_ver/bin/mvn" wrapper:wrapper -Dmaven="$wrapper_mvn_version"

    # http://mvnrepository.com/artifact/io.takari/maven
    # command mvn -N io.takari:maven:0.7.7:wrapper -Dmaven="$wrapper_mvn_version"
}

# Runs duplicate check on the maven classpaths
# https://github.com/basepom/duplicate-finder-maven-plugin
alias mcd='mvn org.basepom.maven:duplicate-finder-maven-plugin:2.0.0:check'

mmcd() {
    mcd -B "$@" | tee mcd-origin.log

    echo
    infoInteractive "tidy result: "
    echo
    sed -n '
        /^\[WARNING\] Found duplicate /,/^\[INFO\] /p
        /^\[INFO\] Building /p
        /^\[INFO\] Checking .* classpath/p
    ' mcd-origin.log | tee mcd.log
}

mmd() {
    (( $# == 0 )) && local -a dirs=( . ) || local -a dirs=( "$@" )
    local d

    for d in "${dirs[@]}"; do
    (
        md "$d"
        cd "$d"
        md src/main/java
        md src/main/resources
        md src/test/java
        md src/test/resources
    )
    done
}

# maven artifact version
mav() {
    (($# == 1)) || {
        errorEcho "need only one coordinate argment! but provided: $*"
        return 1
    }

    local coordinate="$1"
    coordinate="${coordinate//://}"
    coordinate="${coordinate//.//}"
    command http "https://repo1.maven.org/maven2/$coordinate/maven-metadata.xml" |
        awk -F'</?release>' '/<release>/{print $2}'
    # coordinate="${coordinate//://}"
    # command http --follow "https://img.shields.io/maven-central/v/$coordinate.svg"  |
    #     command rg '(?<="maven-central: v)[^"]+(?=")' -Po
}

# maven artifact versions
mavs() {
    (($# == 1)) || {
        errorEcho "need only one coordinate argment! but provided: $*"
        return 1
    }

    local coordinate="$1"
    coordinate="${coordinate//://}"
    coordinate="${coordinate//.//}"
    command http "https://repo1.maven.org/maven2/$coordinate/maven-metadata.xml" |
        awk -F'</?version>' '/<version>/{print $2}'
}

# swith maven settings.xml
sms() {
    local name="$1"
    (
        cd ~/.m2
        cp settings.xml."$name" settings.xml
    )
}
smOpen() {
    sms open
}
smMinOpen() {
    sms open.min
}

###############################################################################
# sbt
###############################################################################

function sbt() {
    # auto use java on JAVA_HOME instead of PATH by -java-home option
    findLocalBinOrDefaultToRun sbt sbt -java-home "$JAVA_HOME" "$@"
}

###############################################################################
# Gradle
###############################################################################

unalias gradle &> /dev/null
function gradle() {
    findLocalBinOrDefaultToRun gradlew gradle "$@"
}

#export GRADLE_OPTS="-Xmx1024m -Xms256m -XX:MaxPermSize=512m"
alias grw=gradle

alias grwq='grw -q'
alias grwi='grw -q -I <(echo -n)'
alias grwb='grw build -x test'
alias grwB='grw build'
alias grwc='grw clean'
alias grwcb='grw clean build -x test'
alias grwcB='grw clean build'
alias grwt='grw test'

alias grwf='grw --refresh-dependencies'
alias grwfb='grw --refresh-dependencies build -x test'
alias grwfB='grw --refresh-dependencies build'
alias grwfc='grw --refresh-dependencies clean'
alias grwfcb='grw --refresh-dependencies clean build -x test'
alias grwfcB='grw --refresh-dependencies clean build'

alias grwd='grw -q dependencies'
alias grwdd='grw -q dependencies --configuration'
alias grwdc='grw -q dependencies --configuration compile'
alias grwdr='grw -q dependencies --configuration runtime'
alias grwdtc='grw -q dependencies --configuration testCompile'

gwrapper() {
    local ver="${1:-4}"
    local major_ver="${ver%%.*}"
    local -a gradle_args=(wrapper --distribution-type=all)
    if ((major_ver == 2)); then
        logAndRun "$SDKMAN_DIR/candidates/gradle/2.14.1/bin/gradle" wrapper
    elif ((major_ver == 4)); then
        logAndRun "$SDKMAN_DIR/candidates/gradle/4.10.3/bin/gradle" "${gradle_args[@]}"
    elif ((major_ver > 4)); then
        local gradle_installs=("$SDKMAN_DIR/candidates/gradle"/[0-9]*/bin/gradle)
        local latest_ver
        latest_ver=$(printf '%s\n' "${gradle_installs[@]}" | sort -V | tail -n 1)
        logAndRun "$latest_ver" "${gradle_args[@]}"
    else
        errorInteractive "gradle version $ver NOT supported!"
        return 1
    fi
}

# kill all gradle deamon processes on mac
alias kgrdm="jps -l | awk '\$2==\"org.gradle.launcher.daemon.bootstrap.GradleDaemon\"{print \$1}' | xargs -r kill -9"
# show all gradle deamon processes on mac
alias sgrdm="jps -mlvV | awk '\$2==\"org.gradle.launcher.daemon.bootstrap.GradleDaemon\"{print \$0}' | coat -n"


###############################################################################
# Lein
###############################################################################

lein() {
    LEIN_USE_BOOTCLASSPATH=y findLocalBinOrDefaultToRun lein lein "$@"
}

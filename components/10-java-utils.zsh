###############################################################################
# Java/JVM Languages
###############################################################################

__getLatestJavaHomeForVersion() {
    local version="$1"
    {
    command ls -d $HOME/.sdkman/candidates/java/"$version".* |
        grep -vF '.fx-' |
        tail -1
    } 2> /dev/null
}

export_java_env_vars() {
    #export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)
    #export JAVA6_HOME='/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home'
    export JAVA6_HOME="$HOME/.sdkman/candidates/java/1.6"
    export JAVA6HOME="$JAVA6_HOME"

    export JDK6_HOME="$JAVA6_HOME"
    export JDK_6="$JAVA6_HOME"
    export JDK_16="$JAVA6_HOME"
    alias j6='setjvhm $JAVA6_HOME'

    local jv_version jv_home
    for jv_version in {7..42}; do
        jv_home=$(__getLatestJavaHomeForVersion $jv_version)
        [ -n "$jv_home" ] || continue

        eval export JAVA"$jv_version"_HOME="'$jv_home'"
        eval export JAVA"$jv_version"HOME="'$jv_home'"

        eval export JDK"$jv_version"_HOME="'$jv_home'"
        eval export JDK_"$jv_version"="'$jv_home'"

        # add JAVA_HOME switcher, j9, j16
        eval "alias j${jv_version}='setjvhm \$JAVA${jv_version}_HOME'"

        if ((jv_version < 10)); then
            eval export JDK_$((jv_version + 10))="'$jv_home'"
        else
            # JAVA_HOME switcher
            local jv_version_x=$((jv_version - 10))
            (( jv_version_x == 0 )) && jv_version_x=
            eval "alias jx${jv_version_x}='setjvhm \$JAVA${jv_version}_HOME'"
        fi
    done

    # default JAVA_HOME
    export JAVA0_HOME="$HOME/.sdkman/candidates/java/current"
    alias j0='setjvhm $JAVA0_HOME'

    export JAVA_HOME="$JAVA0_HOME"
    # export JAVA_OPTS="${JAVA_OPTS:+$JAVA_OPTS }-Duser.language=en -Duser.country=US -Xverify:none"
    export JAVA_OPTS="-Duser.language=en -Duser.country=US -Xverify:none"
    export MANPATH="$JAVA_HOME/man:$MANPATH"
}

export_java_env_vars

# set JAVA_HOME
setjvhm(){
    export JAVA_HOME="$1"
}

alias jvp='javap -J-Duser.language=en -J-Duser.country=US -cp .'
alias jvpp='javap -J-Duser.language=en -J-Duser.country=US -cp . -p'
alias jcc='$HOME/Codes/open/japi-compliance-checker/japi-compliance-checker.pl -skip-internal-packages internal -skip-internal-packages util -skip-internal-packages utils'
alias jad='jad -space -nonlb -t 2 -ff'
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

export JREBEL_HOME=$HOME/Applications/jrebel7.0.2

export PATH="$HOME/.sdkman/candidates/gatling/3.3.1/bin:$PATH"

###############################################################################
# Scala
###############################################################################

alias scl='scala -Dscala.color -feature'

# decompile scala class
dsc() {
    local dsc_quit scala_version scala_candidates=~/.sdkman/candidates/scala
    while (($# > 0)); do
        [ "$1" = "-q" ] && {
            dsc_quit=-q
            shift
            continue
        }
        [ "$1" = "-sv" ] && {
            scala_version="$1"
            shift 2
            continue
        }
        break
    done

    [ -z "${scala_version:-}" ] && {
        scala_version=$(builtin cd "$scala_candidates" && command ls -v -d *(/) | tail -1)
    }

    cfr-decompiler --removedeadmethods false \
        --extraclasspath "$scala_candidates/$scala_version/lib" \
        "$@" | expand | c ${dsc_quit:-}
}

alias dscq='dsc -q'

###############################################################################
# Maven
###############################################################################

# export MAVEN_OPTS="${MAVEN_OPTS:+$MAVEN_OPTS }-Xmx768m -Duser.language=en -Duser.country=US"
export MAVEN_OPTS="-Xmx768m -Duser.language=en -Duser.country=US"

unalias mvn &> /dev/null
function mvn() {
    if [ -n "${USE_M2+defined}" ]; then
        local M2_BIN="$HOME/.sdkman/candidates/maven/2.2.1/bin/mvn"
        echoInteractiveInfo "use maven 2: $M2_BIN"
        logAndRun "$M2_BIN" ${MVN_REPO_LOCAL:+"-Dmaven.repo.local=$MVN_REPO_LOCAL"} "$@"
    else
        findLocalBinOrDefaultToRun mvnw mvn ${MVN_REPO_LOCAL:+"-Dmaven.repo.local=$MVN_REPO_LOCAL"} "$@"
    fi
}

# quick and dirty mode(qdm)
#
#   apache-rat-plugin : rat.skip
#   https://creadur.apache.org/rat/apache-rat-plugin/check-mojo.html
__mvn_qdm_options=(
    -Dmaven.test.skip
    -Drat.skip
    -Dautoconf.skip -Dautoconfig.skip
    -Denv=release
    -Dscm.app.name=faked -DappName=faked
)

alias mvnq='mvn $__mvn_qdm_options'
alias mc='mvnq clean'
alias mi='mvnq install'
alias mio='mi -o'
alias mci='mc && mi'
alias mcio='mc && mio'
alias mcdeploy='mc && mvnq deploy'

mdt() {
    mvn dependency:tree
}
mmdt() {
    logAndRun mdt -B "$@" | tee mdt-origin.log |
        command grep '(\+-|\\-).*:.*:|Building ' --line-buffered -E | tee mdt.log |
        command grep --line-buffered -Pv ':test( \(version managed|$)' | tee mdt-exclude-test.log
}


mda() {
    mvn dependency:analyze -B "$@" | tee mda-origin.log |
        command sed -r -n '
            /^\[INFO\] Building/p
            /Used undeclared dependencies found:|Unused declared dependencies found:/,/^\[INFO\]/ {
                /^\[INFO\]/b
                p
            }
        ' | tee mda.log
}

alias mds='mvn dependency:sources'

alias mdc='mvn dependency:copy-dependencies -DincludeScope=runtime'
alias mdct='mvn dependency:copy-dependencies -DincludeScope=test'

# Check dependencies update
alias mcv='mvn versions:display-dependency-updates versions:display-plugin-updates versions:display-property-updates -DperformRelease -U'
mmcv() {
    mcv -B "$@" | tee mcv-origin.log |
        command grep -- '\[INFO\].*->' | sort -k4,4V -k2,2 -u | tee mcv.log
}
alias mdg='mvn com.github.ferstl:depgraph-maven-plugin:3.3.0:aggregate -DgraphFormat=puml'

# Update project version
muv() {
    [ $# -ne 1 ] && {
        echo "Only 1 argument for version!"
        exit 1
    }
    mvn org.codehaus.mojo:versions-maven-plugin:2.8.1:set -DgenerateBackupPoms=false -DnewVersion="$1"
}
# create maven wrapper
# http://mvnrepository.com/artifact/io.takari/maven
mwrapper() {
    local wrapper_mvn_version="${1:-$(
        # the version of maven command on the path
        command mvn -v | awk '/^Apache Maven/ {print $3}'
    )}"
    # http://mvnrepository.com/artifact/io.takari/maven
    command mvn -N io.takari:maven:0.7.7:wrapper -Dmaven="$wrapper_mvn_version"
}

# Runs duplicate check on the maven classpaths
# https://github.com/basepom/duplicate-finder-maven-plugin
alias mcd='mvn org.basepom.maven:duplicate-finder-maven-plugin:1.4.0:check'

mmcd() {
    mcd -B "$@" | tee mcd-origin.log | sed -n '
        /^\[WARNING\] Found duplicate /,/^\[INFO\] /p
        /^\[INFO\] Building /p
        /^\[INFO\] Checking .* classpath/p
    ' | tee mcd.log
}

mmd() {
    md src/main/java
    md src/main/resources
    md src/test/java
    md src/test/resources
}


###############################################################################
# sbt
###############################################################################

# auto use java on JAVA_HOME instead of PATH
alias sbt='sbt --java-home "$(eval echo \"\$JAVA_HOME\")"'


###############################################################################
# Gradle
###############################################################################

unalias gradle &> /dev/null
function gradle() {
    findLocalBinOrDefaultToRun gradlew gradle "$@"
}

#export GRADLE_OPTS="-Xmx1024m -Xms256m -XX:MaxPermSize=512m"
alias grd='gradle'
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

###############################################################################
# Java/JVM Languages
###############################################################################

export_java_homes() {
    #export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)
    #export JAVA6_HOME='/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home'
    export JAVA6_HOME="$HOME/.sdkman/candidates/java/1.6"
    export JAVA6HOME="$JAVA6_HOME"
    export JDK_16="$JAVA6_HOME"

    export JAVA7_HOME=$(a2l $HOME/.sdkman/candidates/java/7.* | tail -1)
    export JAVA7HOME="$JAVA7_HOME"
    export JDK_17="$JAVA7_HOME"

    export JAVA8_HOME=$(a2l $HOME/.sdkman/candidates/java/8.* | tail -1)
    export JAVA8HOME="$JAVA8_HOME"
    export JDK_8="$JAVA8_HOME"

    export JAVA9_HOME=$(a2l $HOME/.sdkman/candidates/java/9.* | tail -1)
    export JAVA9HOME="$JAVA9_HOME"
    export JDK_9="$JAVA9_HOME"

    export JAVA10_HOME=$(a2l $HOME/.sdkman/candidates/java/10.* | tail -1)
    export JAVA10HOME="$JAVA10_HOME"
    export JDK_10="$JAVA10_HOME"

    export JAVA11_HOME=$(a2l $HOME/.sdkman/candidates/java/11.* | tail -1)
    export JAVA11HOME="$JAVA11_HOME"
    export JDK_11="$JAVA11_HOME"

    export JAVA12_HOME=$(a2l $HOME/.sdkman/candidates/java/12.* | tail -1)
    export JAVA12HOME="$JAVA12_HOME"
    export JDK_12="$JAVA12_HOME"

    export JAVA13_HOME=$(a2l $HOME/.sdkman/candidates/java/13* | tail -1)
    export JAVA13HOME="$JAVA13_HOME"
    export JDK_13="$JAVA13_HOME"

    export JAVA14_HOME=$(a2l $HOME/.sdkman/candidates/java/14* | tail -1)
    export JAVA14HOME="$JAVA14_HOME"
    export JDK_14="$JAVA14_HOME"

    export JAVA15_HOME=$(a2l $HOME/.sdkman/candidates/java/15* | tail -1)
    export JAVA15HOME="$JAVA15_HOME"
    export JDK_15="$JAVA15_HOME"

    # default JAVA_HOME
    export JAVA0_HOME="$HOME/.sdkman/candidates/java/current"

    export JAVA_HOME="$JAVA0_HOME"
    #export JAVA_OPTS="${JAVA_OPTS:+$JAVA_OPTS }-Duser.language=en -Duser.country=US"
    export JAVA_OPTS="${JAVA_OPTS:+$JAVA_OPTS }-Duser.language=en -Duser.country=US -Xverify:none"
    export MANPATH="$JAVA_HOME/man:$MANPATH"
}

export_java_homes

# set JAVA_HOME
setjvhm(){
    export JAVA_HOME="$1"
}

# JAVA_HOME switcher
alias j6='setjvhm $JAVA6_HOME'
alias j7='setjvhm $JAVA7_HOME'
alias j8='setjvhm $JAVA8_HOME'
alias j9='setjvhm $JAVA9_HOME'
alias jx='setjvhm $JAVA10_HOME'
alias jx1='setjvhm $JAVA11_HOME'
alias jx2='setjvhm $JAVA12_HOME'
alias jx3='setjvhm $JAVA13_HOME'
alias jx4='setjvhm $JAVA14_HOME'
alias jx5='setjvhm $JAVA15_HOME'
alias j0='setjvhm $JAVA0_HOME'

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

alias scl='scala -Dscala.color -feature'

export JREBEL_HOME=$HOME/Applications/jrebel7.0.2

# Android
#export ANDROID_HOME=$HOME/Library/Android/sdk
#export ANDROID_SDK_HOME=$ANDROID_HOME
#export ANDROID_NDK_HOME=$ANDROID_HOME/ndk-bundle
#export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools"


###############################################################################
# Maven
###############################################################################

export MAVEN_OPTS="${MAVEN_OPTS:+$MAVEN_OPTS }-Xmx768m -Duser.language=en -Duser.country=US"

__mvn__options='-Dmaven.test.skip -Dautoconf.skip -Dautoconfig.skip -Denv=release -Dscm.app.name=faked -DappName=faked'
alias mc="mvn clean $__mvn__options"
alias mi="mvn install $__mvn__options"
alias mio="mi -o"
alias mci="mc && mi"
alias mcio="mc && mio"
alias mcdeploy="mc && mvn deploy $__mvn__options"

alias mdt='mvn dependency:tree'
alias mds='mvn dependency:sources'
alias mcd='mvn dependency:copy-dependencies -DincludeScope=runtime'
alias mcdt='mvn dependency:copy-dependencies -DincludeScope=test'

alias mcv='mvn versions:display-dependency-updates versions:display-plugin-updates versions:display-property-updates'
alias mdg='mvn com.github.ferstl:depgraph-maven-plugin:3.3.0:aggregate -DgraphFormat=puml'

unalias mvn &> /dev/null
function mvn() {
    find_bin_or_default_then_run mvnw mvn "$@"
}

# Update project version
muv() {
    [ $# -ne 1 ] && {
        echo "Only 1 argument for verson!"
        exit 1
    }
    mvn org.codehaus.mojo:versions-maven-plugin:2.7:set -DgenerateBackupPoms=false -DnewVersion="$1"
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

mmd() {
    md src/main/java
    md src/main/resources
    md src/test/java
    md src/test/resources
}


###############################################################################
# Gradle
###############################################################################

function gradle() {
    find_bin_or_default_then_run gradlew gradle "$@"
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
    LEIN_USE_BOOTCLASSPATH=y find_bin_or_default_then_run lein lein "$@"
}

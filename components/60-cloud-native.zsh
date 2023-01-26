# docker

alias dk=docker
alias dkc='docker create'

alias dkr='docker run'
alias dkrr='docker run --rm'

alias dkri='docker run -i -t'
alias dkrri='docker run --rm -i -t'

alias dkrd='docker run -d'
alias dkrrd='docker run --rm -d'

alias dkrm='docker rm'
alias dkrmi='docker rmi'

alias dks='docker start'
alias dksi='docker start -i'
alias dkrs='docker restart'
alias dkstop='docker stop'

alias dki='docker inspect'
alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dktop='docker top'

alias dke='docker exec'
alias dkei='docker exec -i -t'
alias dkl='docker logs'
alias dklf='docker logs -f'

alias dkim='docker image'
alias dkims='docker images'
alias dkp='docker pull'
alias dksh='docker search'

dkcleanimg() {
    local images="$(docker images | awk 'NR>1 && $2=="<none>" {print $3}')"
    [ -z "$images" ] && {
        echo "No images need to cleanup!"
        return
    }

    echo "$images" | xargs --no-run-if-empty docker rmi
}

dkupimg() {
    local images="$(docker images | awk 'NR>1 && $2="latest"{print $1}')"
    [ -z "$images" ] && {
        echo "No images need to upgrade!"
        return
    }

    echo "$images" | sort -u | xargs --no-run-if-empty -n1 docker pull
}

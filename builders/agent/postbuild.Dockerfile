
ADD builders/docker-postbuild.tmp /nodevops/docker-postbuild.sh

ENV ENV="/root/.bash_profile" 

RUN /nodevops/docker-postbuild.sh

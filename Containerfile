FROM fedora:36

RUN dnf update -y \
    && \
    dnf groupinstall -y \
        "Development Tools" \
        "Development Libraries"
RUN dnf update -y \
    && \
    dnf install -y \
        ldc \
        rsync \
        cmake \
        gcc \
        gcc-c++ \
        SDL2-devel \
        freetype-devel \
        dub \
        git

RUN dnf -y install 'dnf-command(copr)'
RUN dnf -y copr enable grillo-delmal/dub-hack
RUN dnf -y update
RUN dnf -y install setgittag

ADD scripts/build.sh /opt/build/build.sh
ADD scripts/semver.sh /opt/build/semver.sh

WORKDIR /opt/build/

CMD ./build.sh

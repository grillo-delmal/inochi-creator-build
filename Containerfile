FROM fedora:37

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

ADD scripts/build.sh /opt/build/build.sh
ADD scripts/semver.sh /opt/build/semver.sh

WORKDIR /opt/build/

CMD ./build.sh

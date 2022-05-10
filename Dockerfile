FROM docker.io/library/ruby:slim

RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends build-essential libjemalloc2 fonts-liberation wget gnupg2 libc6
RUN rm -rf /var/lib/apt/lists/*

# Use sqlite >= 3.38 for returns keyword
RUN wget https://www.sqlite.org/2022/sqlite-autoconf-3380200.tar.gz && \
    tar xvfz sqlite-autoconf-3380200.tar.gz && \
    cd sqlite-autoconf-3380200 && \
    ./configure && \
    make && \
    make install && \
    rm -rf sqlite-autoconf-3380200

RUN wget https://github.com/watchexec/watchexec/releases/download/cli-v1.18.11/watchexec-1.18.11-x86_64-unknown-linux-gnu.tar.xz && \
    tar xf watchexec-1.18.11-x86_64-unknown-linux-gnu.tar.xz && \
    mv watchexec-1.18.11-x86_64-unknown-linux-gnu/watchexec /usr/local/bin/ && \
    rm -rf watchexec-1.18.11-x86_64-unknown-linux-gnu

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

ARG USER=app
ARG GROUP=app
ARG UID=1101
ARG GID=1101
ARG DIR=/home/app

RUN groupadd --gid $GID $GROUP
RUN useradd --uid $UID --gid $GID --groups $GROUP -ms /bin/bash $USER

RUN chown -R $USER:$GROUP $DIR

USER $USER
WORKDIR $DIR

COPY --chown=$USER Gemfile Gemfile.lock $DIR

RUN bundle install

COPY --chown=$USER . $DIR

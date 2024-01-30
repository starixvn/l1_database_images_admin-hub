FROM ubuntu:jammy AS base
ARG UID=40312
ARG GID=403

RUN groupadd \
        --system \
        --gid 403 \
        -- admin \
 && useradd \
        --no-log-init \
        --create-home \
        --no-user-group \
        --uid ${UID} \
        --gid ${GID} \
        --shell /bin/bash \
        --key UMASK=007 \
        --key HOME_MODE=0770 \
        -- admin \
 && chmod 2770 /home/admin \
 && install \
        --directory \
        --mode 2770 \
        --owner ${UID} \
        --group ${UID} \
        -- /repo

FROM base AS mongosh
RUN apt update \
 && apt install --yes wget
RUN wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc \
  | tee /etc/apt/trusted.gpg.d/server-7.0.asc \
 && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
  | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
RUN apt update \
 && apt install --yes mongodb-mongosh-shared-openssl3

FROM base
ARG UID=40312
ARG GID=403

WORKDIR /home/admin
RUN apt update \
 && apt upgrade --yes \
 && apt install --yes \
        --no-install-recommends \
        -- openssh-server ca-certificates \
 && rm -r /var/lib/apt/lists \
 && mkdir /run/sshd

COPY --from=mongosh /usr/bin/mongosh /usr/bin/mongosh
COPY --from=mongosh /usr/lib/mongosh_crypt_v1.so /usr/lib/mongosh_crypt_v1.so

COPY --chmod=444 sshd_config.d/* /etc/ssh/sshd_config.d/

COPY --chown=0:0 --chmod=440 home/.mongodb/mongosh/config /root/.mongodb/mongosh/config

COPY --chown=${UID}:${GID} --chmod=550 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=${UID}:${GID} --chmod=440 mongoshrc /mongoshrc

COPY --chown=${UID}:${GID} --chmod=440 home/.mongodb/mongosh/config .mongodb/mongosh/config
COPY --chown=${UID}:${GID} --chmod=440 home/.ssh/authorized_keys .ssh/authorized_keys
COPY --chown=${UID}:${GID} --chmod=440 home/.mongoshrc.js .mongoshrc.js

RUN ln -s /dev/null .bash_history \
 && ln -s /dev/null .mongodb/mongosh

VOLUME [ "/repo", "/mongoshrc" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-d", "-D"]

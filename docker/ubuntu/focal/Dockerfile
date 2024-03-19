FROM ubuntu:focal AS base
ARG UID=40312
ARG GID=403

RUN groupadd \
        --system \
        --gid ${GID} \
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
        --password '*' \
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
 && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" \
  | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
RUN apt update \
 && apt install --yes mongodb-mongosh-shared-openssl11

FROM base AS mongoshrc
ARG UID=40312
ARG GID=403
COPY mongoshrc /mongoshrc
RUN chown -R ${UID}:${GID} /mongoshrc \
 && find /mongoshrc -type d -exec chmod 550 {} \; \
 && find /mongoshrc -type f -exec chmod 440 {} \;

FROM base AS home-admin
ARG UID=40312
ARG GID=403
COPY home-admin /home-admin
RUN chown -R ${UID}:${GID} /home-admin \
 && find /home-admin -type d -exec chmod 550 {} \; \
 && find /home-admin -type f -exec chmod 440 {} \;

FROM base AS home-root
COPY home-root /home-root
RUN chown -R 0:0 /home-root \
 && find /home-root -type d -exec chmod 550 {} \; \
 && find /home-root -type f -exec chmod 440 {} \;

# Main image
FROM base
ARG UID=40312
ARG GID=403

WORKDIR /home/admin
RUN apt update \
 && apt upgrade --yes \
 && apt install --yes \
        --no-install-recommends \
        -- openssh-server ca-certificates tmux \
 && rm -r /var/lib/apt/lists \
 && mkdir /run/sshd

COPY --from=mongosh /usr/bin/mongosh /usr/bin/mongosh
COPY --from=mongosh /usr/lib/mongosh_crypt_v1.so /usr/lib/mongosh_crypt_v1.so

COPY --from=mongoshrc /mongoshrc /mongoshrc

COPY --from=home-admin /home-admin/ /home/admin/
COPY --from=home-root /home-root/ /root/

COPY --chmod=400 hostkey/* /etc/ssh/
COPY --chmod=444 sshd_config.d/* /etc/ssh/sshd_config.d/

COPY --chown=${UID}:${GID} --chmod=550 docker/docker-entrypoint.sh /docker-entrypoint.sh

RUN ln -s /dev/null /root/.bash_history \
 && ln -s /dev/null /home/admin/.bash_history \
 && ln -s /dev/null .mongodb/mongosh/mongosh_repl_history

VOLUME [ "/repo", "/mongoshrc/modules/configs" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]

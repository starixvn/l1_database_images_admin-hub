#!/bin/bash
set -Eeuo pipefail

if [ "${1:0:1}" = '-' ]; then
    set -- /usr/sbin/sshd "$@"
fi

exec "$@"

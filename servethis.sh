#!/bin/bash

if [[ -n "${KP_PASS}" ]]
then
    echo "[$(date)] reusing already defined KP_PASS env."
else
    echo 'type a password and then hit the Enter key:'
    read KP_PASS
    export KP_PASS
fi

# Current directory by Dave Dopson - https://stackoverflow.com/a/246128
cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "[$(date)] listening for connection..."
(cd "${cwd}"; tar czf - .) | openssl enc -aes-256-cbc -pass env:KP_PASS -base64 -md sha256 | nc -l 127.0.0.1 8080 && echo "[$(date)] done"

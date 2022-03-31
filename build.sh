#!/bin/bash -e
if [[ -z "$MINER_RELEASE" ]]; then
    export MINER_RELEASE=2022.02.10.1
fi
if [[ -z "$MINER_PKG_VER" ]]; then
    echo "MINER_PKG_VER must be defined"
    false
fi
if [[ -z "$MINER_STAGING_DIR" ]]; then
    echo "MINER_STAGING_DIR must be defined"
    false
fi
SCRIPTDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
mkdir $MINER_STAGING_DIR
$SCRIPTDIR/otp-build.sh
$SCRIPTDIR/miner-build.sh
$SCRIPTDIR/pkg-build.sh

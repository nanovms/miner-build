#!/bin/bash
set -e
if [[ -z "$MINER_RELEASE" ]]; then
	echo "MINER_RELEASE must be defined"
	false
fi
if [[ -z "$MINER_STAGING_DIR" ]]; then
	echo "MINER_STAGING_DIR must be defined"
	false
fi
SCRIPTDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $MINER_STAGING_DIR
export PATH=$PATH:$MINER_STAGING_DIR/usr/local/lib/erlang/erts-11.0/bin/
git clone http://github.com/helium/miner miner -b $MINER_RELEASE
cd miner
patch -p1 < $SCRIPTDIR/0001-miner-config.patch
./rebar3 as test_validator release
cp config/sys.config _build/test_validator/rel/miner/releases/$MINER_RELEASE/
#pushd _build/default/lib/blockchain/_build/default/lib/libp2p
#patch -p1 < $SCRIPTDIR/0002-miner-libp2p_transport_tcp.patch
#popd
#pushd _build/default/lib/sibyl/_build/default/lib/libp2p
#patch -p1 < $SCRIPTDIR/0002-miner-libp2p_transport_tcp.patch
#popd
pushd _build/default/lib/libp2p
patch -p1 < $SCRIPTDIR/0002-miner-libp2p_transport_tcp.patch
popd
find . -name libp2p_transport_tcp.beam |xargs rm
pushd _build/default/lib/nat
patch -p1 < $SCRIPTDIR/0003-miner-natupnp_v2.patch
popd
find . -name natupnp_v2.beam |xargs rm
./rebar3 as test_validator release

#!/bin/bash
set -e
if [[ -z "$MINER_STAGING_DIR" ]]; then
	echo "MINER_STAGING_DIR must be defined"
	false
fi
cd $MINER_STAGING_DIR
mkdir -p usr/local/lib
wget http://erlang.org/download/otp_src_23.0.tar.gz
tar xvfz otp_src_23.0.tar.gz
git clone http://github.com/nanovms/erlang erlang-patches -b erlang-patches-for-miner
cd otp_src_23.0
patch -p1 -N < ../erlang-patches/0001-BEAM-embed-erlexec-and-EPMD.patch
patch -p1 -N < ../erlang-patches/0002-kernel-auth-erl-skip-cookie-file-permission-checks.patch
patch -p1 -N < ../erlang-patches/0003-erl_child_setup_thread.patch
patch -p1 -N < ../erlang-patches/0004-erlexec-nodename-from-ifaddr.patch
patch -p1 -N < ../erlang-patches/0005-erl_child_setup_thread-netstat-for-inet_ext.patch
./configure --prefix=$MINER_STAGING_DIR/usr/local
make
make install

#!/bin/bash -xe
if [[ -z "$MINER_RELEASE" ]]; then
	echo "MINER_RELEASE must be defined"
	false
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
PKGNAME=miner-validator_$MINER_RELEASE-$MINER_PKG_VER
PKGDIR=$MINER_STAGING_DIR/pkg/$PKGNAME
mkdir -p $PKGDIR
cd $PKGDIR
SEDEXP='s/<MINER_RELEASE>/'$MINER_RELEASE'/;s/<MINER_PKG_VER>/'$MINER_PKG_VER'/'
sed -e $SEDEXP $SCRIPTDIR/package.manifest.pkg > package.manifest
sed -e $SEDEXP $SCRIPTDIR/README.md.pkg > README.md
mkdir -p sysroot/etc
# XXX remove passwd?
#cp $SCRIPTDIR/etc/passwd sysroot/etc/
#mkdir -p sysroot/etc/ssl/certs
#cp /etc/ssl/certs/ca-certificates.crt sysroot/etc/ssl/certs/
mkdir -p sysroot/lib64
cp /lib64/ld-linux-x86-64.so.2 sysroot/lib64/

# copy erlang/OTP
cp -ra $MINER_STAGING_DIR/usr sysroot/

# copy libraries
mkdir -p sysroot/lib/x86_64-linux-gnu
cp -aL /lib/x86_64-linux-gnu/{libc.so.6,libm.so.6,libnss_dns.so.2,libpthread.so.0,libtinfo.so.6,libz.so.1,libgcc_s.so.1,libsctp.so.1,libdbus-1.so.3,libdl.so.2,libsystemd.so.0,liblzma.so.5,libzstd.so.1,liblz4.so.1,libcap.so.2,libgcrypt.so.20,libgpg-error.so.0,libsodium.so.23,libcrypto.so.1.1,libstdc++.so.6,librt.so.1,libresolv.so.2,libnss_files.so.2,libnss_mdns4_minimal.so.2,libnss_mdns4.so.2,libnss_mdns6_minimal.so.2,libnss_mdns6.so.2,libnss_mdns_minimal.so.2,libnss_mdns.so.2} sysroot/lib/x86_64-linux-gnu

# copy miner
cp -ra $MINER_STAGING_DIR/miner/_build/test_validator/rel/miner/{config,lib,releases} sysroot/

# download the genesis block for Helium Testnet
wget -P sysroot https://snapshots.helium.wtf/genesis.testnet

# create tarfile
cd ..
tar cvfz $MINER_STAGING_DIR/$PKGNAME.tar.gz $PKGNAME

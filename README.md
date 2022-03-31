# miner-build

This is an automated build to produce an OPS package archive for Helium
Miner.

## Requirements

These scripts have been tested on Debian 11 (bullseye). Running on another
distribution may require editing the list of libraries in pkg-build.sh under
the comment "copy libraries".

[TODO: enumerate dependencies for erlang and miner builds]

## Building

The build scripts use three environment variables:

MINER_RELEASE     - optional, defaults to 2022.02.10.1
MINER_PKG_VER     - required, indicates the package minor version for ops repo
MINER_STAGING_DIR - required, indicates the directory to contain the build

Simply run the "build.sh" script to produce a package, e.g.:

```
$ MINER_PKG_VER=5 MINER_STAGING_DIR=/tmp/miner-build ./build.sh
```

This produces the tar file "miner-validator_2022.02.10.1-5.tar.gz" in
/tmp/miner-build, which may be uploaded to the ops package repo.

To test the package build locally, you can use ops to import the package build
directory as a local package:

```
$ cd /tmp/miner-build/pkg
$ ops pkg add miner-validator_2022.02.10.1-5/
0084439f9afdf58d
```

The hash produced by ops may then be used to load and run the package locally:

[Note, the following command requires bridging, tap devices and a DHCP server
to be configured. Please see the "Bridged Network" section under
https://docs.ops.city/ops/networking for more details.]

```
$ ops pkg load --local 0084439f9afdf58d -n -b -t tap0
booting /home/wjhun/.ops/images/erlexec ...
/bin/miner: waiting for address assignment for interface "en1"...
en1: assigned 192.168.42.79

/bin/miner: node name is "val_miner@192.168.42.79"
en1: assigned FE80::7CB8:7EFF:FE87:4BEA
```

You may now communicate with the running miner instance using the miner binary
from the package build. But, first, the node name in the "vm.args" file must
be replaced with the address of the instance reported above:

```
$ cd /tmp/miner-build/miner/_build/test_validator/rel/miner
$ sed -i.backup -e 's/%en1/192.168.42.79/' releases/2022.02.10.1/vm.args
$ bin/miner peer addr
/p2p/112LtYR1SuHNxY3pWuNoSrvef3wVP2bEfZaHc2FHb6TfCbNAUf5x
```

This shows that the miner instance is running and responding to requests over
erlang RPC.

Next you will need to load the genesis miner block. The genesis block (for
Helium Testnet) has been downloaded by the build scripts and included in your
image root directory.

```
$ bin/miner genesis load /genesis.testnet
Integrating genesis block from file...ok
```

For more information on setting up the Validator node, see
https://docs.helium.com/mine-hnt/validators/testnet/deployment-guide/

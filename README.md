# Fula Testnet

## Requirements

- A linux host OS for running docker (linux is required for 'host' network mode)

- Install [Docker](https://docs.docker.com/engine/install)

- Install [Docker Compose](https://docs.docker.com/compose/install)



## Running

- Clone the repository with the configuration

```
git clone https://github.com/functionland/fula-testnet.git
```

- Run with docker-compose

```
docker-compose up -d
```

- The following services will be available after everything is running

1. [Sugarfunge Node](https://github.com/functionland/sugarfunge-node/tree/functionland/fula): Local blockchain node (Accessible at `ws://localhost:9944`) 
2. [Sugarfunge API](https://github.com/functionland/sugarfunge-api/tree/functionland/fula): Blockchain API (API available at http://localhost:4000)
3. [IPFS](https://ipfs.io): Distributed storage (API available at http://localhost:8001)
6. [Proof Engine](https://github.com/functionland/proof-engine): Proof of Storage validator for the chain.
7. [Box App](https://github.com/functionland/fula/tree/main/apps/box): The server API that is used by Fotos
8. [IPFS Cluster](https://ipfscluster.io/): Used as a proxy between the Box app and IPFS for logging the CID when a file is uploaded with Fotos

## Steps

After performing the following steps you wil have uploaded a file to your node and get rewarded on the Fula testnet for storing the file.

### Add a file to the IPFS service running inside Docker

- Copy the file that you want to add to the IPFS docker container

```
docker cp examples/meet_box.jpg ipfs:/
```

- Add the file to IPFS by running `ipfs add`

```
docker exec ipfs ipfs add /meet_box.jpg
```

- The console should have a similar output showing the progress, the CID and the file added.

```
84.88 KiB / 84.88 KiB  100.00%added QmcwQBzZcFVa7gyEQazd9WryzXKVMK2TvwBweruBZhy3pf meet_box.jpg
```

- Keep the CID for the next section. In this case the CID is `QmcwQBzZcFVa7gyEQazd9WryzXKVMK2TvwBweruBZhy3pf`.


### Find your Account ID

- Wait a few minutes after the `docker-compose.yaml` starts the services so it can configure everything for you and get the account ID by running the following command on the same folder as the `docker-compose.yaml`.

```bash
docker-compose logs proof-engine | grep Account 
```

The console should output logs similar to these
```bash
2022-07-20T00:35:06.668944Z  INFO proof_engine::sugarfunge: Account("5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j")
2022-07-20T00:35:06.766789Z  INFO proof_engine::sugarfunge: operator: Account("5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY")
2022-07-20T00:35:06.847557Z  INFO proof_engine::sugarfunge: AccountExistsOutput { account: Account("5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j"), exists: false }
2022-07-20T00:35:06.847596Z  WARN proof_engine::sugarfunge: invalid: Account("5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j")
2022-07-20T00:35:06.847604Z  WARN proof_engine::sugarfunge: registering: Account("5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j")
```

The Account ID in this case is `5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j`.

### Upload a Manifest

- A manifest is required to confirm to the proof engine that a file was stored in your IPFS storage. You will need to do a `POST` request to `http://localhost:4000/fula/update_manifest`.

1. `seed`: The operator that is owner of the asset pool (Default: `//Alice`)
2. `from`: The account ID of the owner of the asset pool (Default: `5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY` which represents `//Alice`)
3. `to:`: The account ID that contains the IPFS file stored. (In this example it is `5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j` which is your own account)
4. `manifest`.`job`.`uri`: The CID of a file that is stored in the account used in the `to` field (In this example the CID is `QmcwQBzZcFVa7gyEQazd9WryzXKVMK2TvwBweruBZhy3pf` from the file that we added above)

```json
{
    "seed": "//Alice",
    "from": "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY",
    "to": "5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j",
    "manifest": {
        "job": {
            "work": "Storage",
            "engine": "IPFS",
            "uri": "QmcwQBzZcFVa7gyEQazd9WryzXKVMK2TvwBweruBZhy3pf"
        }
    }
}
```

### Restart the proof engine

In order for the proof engine to pick up the new manifest it must be restarted.

```
$ docker-compose restart proof-engine
```

## Viewing your rewards

There are two options for seeing your rewards for storing a file.

### Mint output from proof engine logs


```
proof-engine_1  | 2022-07-29T18:36:37.851570Z  INFO proof_engine::sugarfunge: MintOutput {
proof-engine_1  |     to: Account(
proof-engine_1  |         "5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j",
proof-engine_1  |     ),
proof-engine_1  |     class_id: ClassId(
proof-engine_1  |         1000000,
proof-engine_1  |     ),
proof-engine_1  |     asset_id: AssetId(
proof-engine_1  |         13510586523404404513,
proof-engine_1  |     ),
proof-engine_1  |     amount: Balance(
proof-engine_1  |         590768,
proof-engine_1  |     ),
proof-engine_1  |     who: Account(
proof-engine_1  |         "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY",
proof-engine_1  |     ),
proof-engine_1  | }
```

Where `5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j` is your account ID (as acquired in the previous step).

### View rewards in the testnet explorer

After the manifest is added to the chain you should see it in the testnet explorer at https://explorer.testnet.fx.land/#/explorer and the account ID (as acuiqred in the previous step) is getting rewarded.

## Fula Integration Notes

### Find the CID for files uploaded via the Fula File API

If you are not adding files directly to IPFS as  mentioned in the previous steps (eg/ using the Fotos mobile app), you will need to find the CID for the file that was added through the Fula File API.  You can use the IPFS Cluster proxy for this.

```
$ docker-compose logs -f cluster |  grep 'new pin added:'
```

### Ensure the file you added is part of IPFS MFS

In order for the proof engine to verify your file is being stored by  IPFS it must be part of the IPFS mutable file system.

```
$ docker exec ipfs ipfs files cp /ipfs/QmcwQBzZcFVa7gyEQazd9WryzXKVMK2TvwBweruBZhy3pf /
```

Where `QmcwQBzZcFVa7gyEQazd9WryzXKVMK2TvwBweruBZhy3pf` is the CID you captured in the previous step.



## Useful docker-compose commands

```bash
# Update latest tagged images
$ docker-compose pull
# Stop the images
$ docker-compose down
# Remove any persistent storage
$ sudo rm -r data/ ipfs/
```

## Running IPFS outside of docker-compose (Optional)

By default, the IPFS WebUI is disabled on private swarm networks since it fetches the app from the public network. There is a workaround by installing IPFS Desktop.

- Install and Start [IPFS Desktop](https://docs.ipfs.io/install/ipfs-desktop)

- Disconnect from the public network: 

```
ipfs bootstrap rm --all
```

- Copy the `swarm.key` from the `fula-testnet repository` to your IPFS Folder. The folder can be opened by clicking `IFPS tray icon > Advanced > Open Repository Directory`.

- Add the private swarm node: `ipfs bootstrap add /dns4/ipfs.testnet.fx.land/tcp/4001/ipfs/12D3KooWBNonCBdf689W94wbBhvm39LGeoP5FZDNNh8j8qwy5M3B`

- Restart IPFS Desktop by clicking `IPFS tray icon > Restart`

- Comment the `ipfs` service secion in the `docker-compose.yaml` file.

- Start the services after excluding IPFS.

```
docker-compose up -d
```


## Getting Box multiaddress / Peer ID

Depending on the client you are using you may need to supply either the Box's Peer ID or the Box's multiaddress.


### Generate the logs

Run the following commands in this directory.

```
 > docker-compose logs -f box
```

The log should contain something like this:

```
box0      | 2022-07-14T15:31:09.133Z box:info Box peerID 12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.134Z box:info Box Listen On /dns4/wrtc-star1.par.dwebops.pub/tcp/443/wss/p2p-webrtc-star/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /dns4/wrtc-star2.sjc.dwebops.pub/tcp/443/wss/p2p-webrtc-star/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /ip4/127.0.0.1/tcp/4002/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /ip4/192.168.65.3/tcp/4002/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /ip4/192.168.65.4/tcp/4002/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /ip4/172.19.0.1/tcp/4002/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /ip4/127.0.0.1/tcp/4003/ws/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /ip4/192.168.65.3/tcp/4003/ws/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /ip4/192.168.65.4/tcp/4003/ws/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
box0      | 2022-07-14T15:31:09.135Z box:info Box Listen On /ip4/172.19.0.1/tcp/4003/ws/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
```

In this example, the Peer ID is `12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH` and the multiaddress is the one reachable from your client on the same network.

Depending on the client support you can use either the TCP and websockets transport multiaddresses:

```
/ip4/192.168.65.4/tcp/4002/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
/ip4/192.168.65.4/tcp/4003/ws/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
```

### Modify the multiaddress so that it is reachable from your client

Because the Box is running inside Docker, the network interface that the container sees is a different subnet than your host machine and is therefore probably not reachable from outside the container.  

As a result, the multiaddress that the Box reports is also not reachable.

To work around this, change the IP portion of the multiaddress to the IP address of your host machine.

For example, on macOS do the following to obtain your ipv4 address: 

Click the 'network' icon -> network preferences and your wifi or ethernet connection should list your network IP address. (eg/ 192.168.4.42)

Next update the multiaddress in the Box server log from the previous step.

Change:

```
/ip4/127.0.0.1/tcp/4003/ws/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
```

To:

```
/ip4/192.168.4.42/tcp/4003/ws/p2p/12D3KooWMNV3ANQq5NE94ArVJDRd6rCk53hUTbVuhqQfrNGF54HH
```

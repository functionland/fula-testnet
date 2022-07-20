# Fula Testnet

## Software requirements

- Install [Docker](https://docs.docker.com/engine/install)

- Install [Docker Compose](https://docs.docker.com/compose/install)

## Usage

- Clone the repository with the configuration
```
git clone https://github.com/functionland/fula-testnet.git
```

- Run with docker compose
```
docker compose up -d
```

- The following services will be available after docker compose is running

1. [Sugarfunge Node](https://github.com/functionland/sugarfunge-node/tree/functionland/fula): Local blockchain node (Accessible at `ws://localhost:9944`) 
2. [Sugarfunge API](https://github.com/functionland/sugarfunge-api/tree/functionland/fula): Blockchain API (API available at http://localhost:4000)
3. [IPFS](https://ipfs.io): Distributed storage (API available at http://localhost:8001)
6. [Proof Engine](https://github.com/functionland/proof-engine): Proof of Storage validator for the chain.

## Useful docker compose commands

```bash
# Update latest tagged images
$ docker compose pull
# Stop the images
$ docker compose down
# Remove any persistent storage
$ sudo rm -r data/ ipfs/
```

## Running IPFS outside of docker compose (Optional)

By default, the IPFS WebUI is disabled on private swarm networks since it fetches the app from the public network. There is a workaround by installing IPFS Desktop.

- Install and Start [IPFS Desktop](https://docs.ipfs.io/install/ipfs-desktop)

- Disconnect from the public network: `ipfs bootstrap rm --all`

- Copy the `swarm.key` from the `fula-testnet repository` to your IPFS Folder. The folder can be opened by clicking `IFPS tray icon > Advanced > Open Repository Directory`.

- Add the private swarm node: `ipfs bootstrap add /dns4/ipfs.testnet.fx.land/tcp/4001/ipfs/12D3KooWBNonCBdf689W94wbBhvm39LGeoP5FZDNNh8j8qwy5M3B`

- Restart IPFS Desktop by clicking `IPFS tray icon > Restart`

- Comment the `ipfs` service secion in the `docker-compose.yaml` file.

- Start the services after excluding IPFS.

```
docker compose up -d
```

## Proof Engine

### Initial setup

- Wait a few minutes after the `docker-compose.yaml` starts the services so it can configure everything for you and get the account key by running the following command on the same folder as the `docker-compose.yaml`.

```bash
docker compose logs proof-engine | grep Account 
```

The console should output logs similar to these
```bash
2022-07-20T00:35:06.668944Z  INFO proof_engine::sugarfunge: Account("5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j")
2022-07-20T00:35:06.766789Z  INFO proof_engine::sugarfunge: operator: Account("5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY")
2022-07-20T00:35:06.847557Z  INFO proof_engine::sugarfunge: AccountExistsOutput { account: Account("5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j"), exists: false }
2022-07-20T00:35:06.847596Z  WARN proof_engine::sugarfunge: invalid: Account("5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j")
2022-07-20T00:35:06.847604Z  WARN proof_engine::sugarfunge: registering: Account("5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j")
```

The IPFS Account Key in this case is `5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j`.

### Manifest

- A manifest is required to confirm to the proof engine that a file was stored in your IPFS storage. You will need to do a `POST` request to `http://localhost:4000/fula/update_manifest`.

1. `seed`: The operator that is owner of the asset pool (Default: `//Alice`)
2. `from`: The account key of the owner of the asset pool (Default: `5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY` which represents `//Alice`)
3. `to:`: The IPFS Account key that contains the IPFS file stored. (In this example is `5HDndLhyKjfxSZHb9zz88pPN3RPmBpaaz8PFbgmKQZz5LJ7j` which is your own IFPS Account)
4. `manifest`.`job`.`uri`: The CID of a file that is stored in the IPFS Account used in the `to` field.

```json
{
    "seed": "//Alice",
    "from": "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY",
    "to": "(IPFS ACCOUNT KEY)",
    "manifest": {
        "job": {
            "work": "Storage",
            "engine": "IPFS",
            "uri": "(CID OF A FILE STORED IN YOUR IPFS NODE)"
        }
    }
}
```

- After the manifest is added to the chain you should see in the testnet explorer at https://explorer.testnet.fx.land/#/explorer that the IFPS Storage account is getting rewards.

- Another way is to check the logs of the proof engine service with `docker compose logs proof-engine logs` in the same folder as the `fula-testnet` repository, be aware that this will show the rewards being minted if the `to` field is your own IPFS Account Key that was created for your ipfs service.
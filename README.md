# fula-testnet

Connect to the fula testnet chain with docker-compose.

## Software requirements

- Install [Docker](https://docs.docker.com/engine/install)

- Install [Docker Compose](https://docs.docker.com/compose/install)

## Usage

- Clone the project
```
git clone https://github.com/functionland/fula-docker.git
```

- Run with docker compose
```
docker-compose up -d
```

- The following services will be available after docker compose is running

1. [Sugarfunge Node](https://github.com/functionland/sugarfunge-node/tree/functionland/fula): Local blockchain node (Accessible at `ws://localhost:9944`) 
2. [Sugarfunge API](https://github.com/functionland/sugarfunge-api/tree/functionland/fula): Blockchain API (API available at http://localhost:4000)
3. [IPFS](https://ipfs.io): Distributed storage ([Click here to access the WebUI](http://localhost:5001/webui)) (API available at http://localhost:8001)
6. [Proof Engine](https://github.com/functionland/proof-engine): Proof of Storage validator for the chain.

- Useful commands
```bash
# Update latest tagged images
$ docker-compose pull
# Stop the images
$ docker-compose down
# Remove any persistent storage
$ sudo rm -r data/ ipfs/
```

# AdminHub

## Deploy AdminHub

### Start AdminHub

```bash
docker run \
    --name AdminHub \
    --hostname AdminHub \
    --restart always \
    --network host \
    -v ./configs/mongoshrc/config.js:/mongoshrc/modules/configs/configs.js \
    -v ./configs/authorized_keys:/home/admin/.ssh/authorized_keys \
    -d \
    hub-old.lumigame.com/ldb/admin-hub:latest
```

or `docker-compose.yml`
```yml
services:
  admin-hub:
    image: hub-old.lumigame.com/ldb/admin-hub:latest
    container_name: AdminHub
    hostname: AdminHub
    restart: always
    network_mode: host
    volumes:
      - ./configs/mongoshrc/config.js:/mongoshrc/modules/configs/config.js:ro
      - ./configs/authorized_keys:/home/admin/.ssh/authorized_keys:ro
```

### Configure AdminHub

#### `./configs/mongoshrc/config.js`
Contains information of initial connections.


## Connect to AdminHub

### Generate ssh key for access authorization

```bash
ssh-keygen -a 128 -t ed25519 -f "./<output-file>" -C "<your-name>@admin-hub";
```

```bash
ssh-keygen -a 128 -t ed25519 -f "./<output-file>" -C "<your-name>@admin-hub" -N "";
```

Put `<output-file>.pub` content in `authorized_keys`.

### Run `mongosh` inside AdminHub

```bash
ssh -l admin -i "./<output-file>" -p 554 10.10.50.12 -t "mongosh --nodb --quiet"
```

or `~/.ssh/config`

```
Host AdminHub
  HostName 10.10.50.12
  Port 554
  User admin
  IdentityFile ./<output-file>
  RequestTTY force
  RemoteCommand mongosh --nodb --quiet
```

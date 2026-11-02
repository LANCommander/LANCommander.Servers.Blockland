# Blockland Server (Docker)

This repository provides a Dockerized **Blockland Rebuilt** (v2.1) dedicated server. Blockland has no Linux server, so the image runs the game's own dedicated LAN mode (`BLRebuilt.exe -dedicatedLAN`) under Wine.
The image builds on [`lancommander/wine`](https://github.com/LANCommander/LANCommander.Servers.WINE). It supports file overlaying using OverlayFS.

---

## Features

- Runs the retail game's dedicated LAN server. It needs no master server or online authentication.
- Server name, player limit, passwords, map and game mode are environment variables
- Supplies the server key the game asks for on startup automatically
- The game log (`console.log`) is streamed to `docker logs`
- Supports file overlaying using OverlayFS (no file copying required)

## Docker Compose Example

```yaml
services:
  blockland:
    image: lancommander/blockland:latest
    container_name: blockland

    ports:
      - "28050:28050/udp"

    volumes:
      - ./config:/config

    environment:
      BLOCKLAND_SERVER_NAME: "My Blockland Server"
      BLOCKLAND_MAX_PLAYERS: "32"
      # BLOCKLAND_GAMEMODE: "Add-Ons/GameMode_SpeedKart/gamemode.txt"

    cap_add:
      - SYS_ADMIN
    security_opt:
      - apparmor:unconfined

    restart: unless-stopped
```

Clients find the server from the in-game LAN list, which broadcasts to UDP 28050, 28000 and 28051. If you use port mapping, LAN broadcasts don't reach the container. Give the container its own LAN address (macvlan/ipvlan, or `network_mode: host`) so it shows up in the list. Otherwise clients have to join by IP.

---

## Game Files

Blockland is retail software with no public download. You must provide a **Blockland Rebuilt v2.1** install:

- copy the game folder (the one containing `BLRebuilt.exe`, `base/` and `Add-Ons/`) to `config/Server/`, **or**
- set `BLOCKLAND_ARCHIVE_URL` to a zip of that folder, such as a LANCommander archive. It is downloaded and extracted on first start if `Server/BLRebuilt.exe` doesn't exist yet.

## Directory Layout (Host)

```text
.
└── config/
    ├── Server/            # Blockland install (BLRebuilt.exe, base/, Add-Ons/)
    ├── Overlay/           # Your files, layered on top of Server/ (config/, saves/, key.dat and console.log also land here)
    ├── Merged/            # Overlayfs merged view (auto-created, the server runs here)
    ├── wineprefix/        # Wine prefix (auto-created)
    └── Scripts/
        └── Hooks/         # PowerShell scripts run at container lifecycle hooks
```

---

## Environment Variables

These are in addition to the [WINE image's variables](https://github.com/LANCommander/LANCommander.Servers.WINE#environment).

| Variable | Description | Default |
|----------|-------------|---------|
| `BLOCKLAND_SERVER_NAME` | Server name (`$Pref::Server::Name`) | `Blockland Server` |
| `BLOCKLAND_MAX_PLAYERS` | Player limit (`$Pref::Server::MaxPlayers`) | `32` |
| `BLOCKLAND_PASSWORD` | Join password | |
| `BLOCKLAND_ADMIN_PASSWORD` | Admin password | |
| `BLOCKLAND_SUPER_ADMIN_PASSWORD` | Super admin password | |
| `BLOCKLAND_MAP` | Mission file, passed as `-map` | `Add-Ons/Map_RebuiltPlate/RebuiltPlate.mis` |
| `BLOCKLAND_GAMEMODE` | Game mode file, passed as `-gamemode`. Takes precedence over `BLOCKLAND_MAP`. | |
| `BLOCKLAND_KEY` | Key passed to `setKey()` at startup. LAN mode doesn't validate it. | `AAAAA-BBBB-CCCC-DDDD` |
| `BLOCKLAND_EXTRA_ARGS` | Raw arguments appended to the command line | |
| `BLOCKLAND_ARCHIVE_URL` | Zip of the game folder, used if `Server/BLRebuilt.exe` is missing | |

Bundled maps: `Add-Ons/Map_RebuiltPlate/RebuiltPlate.mis`, `Add-Ons/Map_Slopes/slopes.mis`, `Add-Ons/Map_Bedroom/bedroom.mis`, `Add-Ons/Map_BedroomDark/bedroomDark.mis`, `Add-Ons/Map_Kitchen/kitchen.mis`, `Add-Ons/Map_KitchenDark/kitchenDark.mis`, `Add-Ons/Map_Tutorial/tutorial.mis`.
Bundled game mode: `Add-Ons/GameMode_SpeedKart/gamemode.txt`.

The game splits its arguments on whitespace, so paths can't contain spaces.

See [Documentation/Docker.md](Documentation/Docker.md) for more detail.

---

## Building

The image is built `FROM lancommander/wine:latest` by default. To build against a local base image:

```bash
docker build --build-arg BASE_IMAGE=lancommander/wine:local -t lancommander/blockland:local .
```

---

## License

Blockland and Wine are distributed under their respective licenses.
This repository contains only Docker build logic and helper scripts licensed under MIT.

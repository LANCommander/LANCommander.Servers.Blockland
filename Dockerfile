# syntax=docker/dockerfile:1.7

# Override to build against a locally built base, e.g. lancommander/wine:local
ARG BASE_IMAGE=lancommander/wine:latest
FROM ${BASE_IMAGE}

# ----------------------------
# Server settings
#   - The game files are not downloadable; put a Blockland Rebuilt v2.1 install in /config/Server,
#     or set BLOCKLAND_ARCHIVE_URL to a zip of one
#   - The server always runs in LAN mode, which listens on UDP 28050 (hardcoded by the game)
#   - BLOCKLAND_GAMEMODE takes precedence over BLOCKLAND_MAP when set
# ----------------------------
ENV BLOCKLAND_ARCHIVE_URL="" \
    BLOCKLAND_SERVER_NAME="Blockland Server" \
    BLOCKLAND_MAX_PLAYERS="32" \
    BLOCKLAND_PASSWORD="" \
    BLOCKLAND_ADMIN_PASSWORD="" \
    BLOCKLAND_SUPER_ADMIN_PASSWORD="" \
    BLOCKLAND_MAP="Add-Ons/Map_RebuiltPlate/RebuiltPlate.mis" \
    BLOCKLAND_GAMEMODE="" \
    BLOCKLAND_KEY="AAAAA-BBBB-CCCC-DDDD" \
    BLOCKLAND_EXTRA_ARGS="" \
    START_EXE="/usr/local/bin/blockland-server" \
    START_ARGS=""

COPY Scripts/blockland-server /usr/local/bin/blockland-server
RUN chmod +x /usr/local/bin/blockland-server

COPY Hooks/ "${BASE_HOOKS}/"

# 28050/udp: game and LAN discovery (LAN servers always bind 28050)
EXPOSE 28050/udp

WORKDIR /config
ENTRYPOINT ["/usr/local/bin/entrypoint.ps1"]

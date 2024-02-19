#!/bin/ash
# Pufferfish Installation Script
# Server Files: /mnt/server

if [ -n "$DL_PATH" ]; then
    echo "Using supplied download url: $DL_PATH"
    DOWNLOAD_URL=$(eval echo $(echo "$DL_PATH" | sed -e 's/{{/${/g' -e 's/}}/}/g'))
else
    
    # Quick fix with wanting to use 1.20.1
    if [ "$MINECRAFT_VERSION" == "1.20.1" ]; then
        BUILD_NUMBER="27"
    fi

    if echo "$MINECRAFT_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        MINECRAFT_VERSION=$(echo "$MINECRAFT_VERSION" | awk -F. '{print $1"."$2}')
    fi

    VERSIONS=$(curl -s "https://ci.pufferfish.host/api/json" | jq -r '.jobs[].name | select(test("Pufferfishplus|Pufferfish-Purpur"; "i") | not)')
    VERSION=""
    for v in $VERSIONS; do

    if echo "$v" | grep -qE ".*$MINECRAFT_VERSION.*"; then
        VERSION="$v"
        break
    fi

done
    VER_EXISTS=$([ "$VERSION" != "" ] && echo true || echo false)
    LATEST_VERSION=$(echo "$VERSIONS" | tr ' ' '\n' | sort -rV | head -n 1)
    
    if [ "$VER_EXISTS" = "true" ]; then
        echo "Version is valid. Using version $MINECRAFT_VERSION"
    else
        echo "Specified version not found. Defaulting to the latest Pufferfish version"
        MINECRAFT_VERSION="$LATEST_VERSION"
        VERSION="$LATEST_VERSION"
    fi

    BUILD_EXISTS=$(curl -s "https://ci.pufferfish.host/job/$VERSION/api/json/" | jq -r --arg BUILD "$BUILD_NUMBER" '.builds[].number | tostring | contains($BUILD)' | grep -m1 true)
    LATEST_BUILD=$(curl -s "https://ci.pufferfish.host/job/$VERSION/api/json" | jq -r '.builds[0].number')

    if [ "$BUILD_EXISTS" = "true" ]; then
        echo "Build is valid for version $MINECRAFT_VERSION. Using build $BUILD_NUMBER"
    else
        echo "Using the latest Pufferfish build for version $MINECRAFT_VERSION"
        BUILD_NUMBER="$LATEST_BUILD"
    fi

    JAR_NAME=$(curl -s "https://ci.pufferfish.host/job/$VERSION/$BUILD_NUMBER/api/json/" | jq -r '.artifacts[0].fileName')

    echo -e "Version being downloaded"
    echo -e "MC Version: $MINECRAFT_VERSION"
    echo -e "Build: $BUILD_NUMBER"
    echo -e "JAR Name of Build: $JAR_NAME"
    DOWNLOAD_URL="https://ci.pufferfish.host/job/$VERSION/$BUILD_NUMBER/artifact/build/libs/$JAR_NAME"
fi

cd /mnt/server

echo -e "Running curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}"

if [ -f ${SERVER_JARFILE} ]; then
	mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

# server-icon.png

if [ ! -f server-icon.png ]; then
    echo -e "Downloading server-icon.png"
    curl -o server-icon.png https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/server-icon.png
fi

# server.properties

if [ ! -f server.properties ]; then
	echo -e "Downloading server.properties"
    curl -o server.properties https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/server.properties
fi

# bukkit.yml

if [ ! -f bukkit.yml ]; then
	echo -e "Downloading bukkit.yml"
    curl -o bukkit.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/bukkit.yml
fi

# spigot.yml

if [ ! -f spigot.yml ]; then
	echo -e "Downloading spigot.yml"
    curl -o spigot.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/spigot.yml
fi

# config

if [ ! -d config ]; then
	echo -e "Creating folder config"
    mkdir config
fi

# config/paper-global.yml

if [ ! -f config/paper-global.yml ]; then
	echo -e "Downloading paper-global.yml"
    curl -o config/paper-global.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/config/paper-global.yml
fi

# paper-world-defaults.yml

if [ ! -f config/paper-world-defaults.yml ]; then
	echo -e "Downloading paper-world-defaults.yml"
    curl -o config/paper-world-defaults.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/config/paper-world-defaults.yml
fi

# pufferfish.yml

if [ ! -f pufferfish.yml ]; then
	echo -e "Downloading pufferfish.yml"
    curl -o pufferfish.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/pufferfish.yml
fi

echo -e "Installation Finished"

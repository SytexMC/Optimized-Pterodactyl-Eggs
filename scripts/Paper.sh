#!/bin/ash
# Paper Installation Script
# Server Files: /mnt/server

if [ -n "${DL_PATH}" ]; then
	echo -e "Using supplied download url: ${DL_PATH}"
	DOWNLOAD_URL=`eval echo $(echo ${DL_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
else
	VER_EXISTS=`curl -s https://api.papermc.io/v2/projects/paper | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep -m1 true`
	LATEST_VERSION=`curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions' | jq -r '.[-1]'`

	if [ "${VER_EXISTS}" == "true" ]; then
		echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
	else
		echo -e "Specified version not found. Defaulting to the latest paper version"
		MINECRAFT_VERSION=${LATEST_VERSION}
	fi

	BUILD_EXISTS=`curl -s https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION} | jq -r --arg BUILD ${BUILD_NUMBER} '.builds[] | tostring | contains($BUILD)' | grep -m1 true`
	LATEST_BUILD=`curl -s https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION} | jq -r '.builds' | jq -r '.[-1]'`

	if [ "${BUILD_EXISTS}" == "true" ]; then
		echo -e "Build is valid for version ${MINECRAFT_VERSION}. Using build ${BUILD_NUMBER}"
	else
		echo -e "Using the latest paper build for version ${MINECRAFT_VERSION}"
		BUILD_NUMBER=${LATEST_BUILD}
	fi

	JAR_NAME=paper-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar

	echo "Version being downloaded"
	echo -e "MC Version: ${MINECRAFT_VERSION}"
	echo -e "Build: ${BUILD_NUMBER}"
	echo -e "JAR Name of Build: ${JAR_NAME}"
	DOWNLOAD_URL=https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}
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
    curl -o server-icon.png https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/Java/server-icon.png
fi

# server.properties

if [ ! -f server.properties ]; then
	echo -e "Downloading server.properties"
    curl -o server.properties https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/Java/server.properties
fi

# bukkit.yml

if [ ! -f bukkit.yml ]; then
	echo -e "Downloading bukkit.yml"
    curl -o bukkit.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/Java/bukkit.yml
fi

# spigot.yml

if [ ! -f spigot.yml ]; then
	echo -e "Downloading spigot.yml"
    curl -o spigot.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/Java/spigot.yml
fi

# config

if [ ! -d config ]; then
	echo -e "Creating folder config"
    mkdir config
fi

# config/paper-global.yml

if [ ! -f config/paper-global.yml ]; then
	echo -e "Downloading paper-global.yml"
    curl -o config/paper-global.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/Java/config/paper-global.yml
fi

# paper-world-defaults.yml

if [ ! -f config/paper-world-defaults.yml ]; then
	echo -e "Downloading paper-world-defaults.yml"
    curl -o config/paper-world-defaults.yml https://raw.githubusercontent.com/sytexmc/optimized-pterodactyl-eggs/main/configs/Java/config/paper-world-defaults.yml
fi

echo -e "Installation Finished"

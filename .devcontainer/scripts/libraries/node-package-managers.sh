#!/usr/bin/env bash
# Installs & Configures Global Node Dependencies & Command Line Tools.
# Syntax: ./package-manager.sh

NVM_EXPORTS=$(which -a nvm)
unset ${NVM_EXPORTS}
echo "NVM has been removed."

update-global-packages()
{
    OUTDATED_PACKAGES= npm outdated -g | grep "node_modules/*" | awk '{ print $1 }'
    if [ -z "${OUTDATED_PACKAGES}" ]; then
        echo "Updating package managers..."
        npm install --global --quiet ${OUTDATED_PACKAGES}
    fi
    yarn global upgrade
    echo "The following node dependencies have been updated: ${OUTDATED_PACKAGES}"
}

# # Install latest package managers.
if [ "${PACKAGE_MANAGERS_ALREADY_INSTALLED}" != "true" ]; then
    echo "Installing Package Managers: npm & yarn"
    npm install --global --quiet npm yarn
    $PACKAGE_MANAGERS_ALREADY_INSTALLED = "true"
    echo "All package managers are installed to the latest version."
fi

update-global-packages

# Insall binaries as dependencies for specific Node command line tools.
if [ "$NODE_BINARIES_ARE_ALREADY_INSTALLED" != "true" ]; then
    NODE_BINARIES_LIST="\
        node-sass \
    "
    echo "Installing Node Binaries: ${NODE_BINARIES_LIST}"
    npm install --global --quiet --unsafe-perm $NODE_BINARIES_LIST
    $NODE_BINARIES_ARE_ALREADY_INSTALLED = "true"
    echo "All node binaries are installed to the latest version."
fi

# # Install global npm command line tools.
if [ "${GLOBAL_TOOLS_ARE_ALREADY_INSTALLED}" != "true" ]; then
    GLOBAL_TOOLS="\
        npm-check \
        npm-check-updates \
        rimraf \
        snyk \
        pm2 \
    "
    echo "Installing Global NPM Tools: ${GLOBAL_TOOLS}"
    npm install --global --quiet $GLOBAL_TOOLS
    $GLOBAL_TOOLS_ARE_ALREADY_INSTALLED = "true"
    echo "All Global NPM Tools Are Installed."
fi

# Configures Yarn.
yarn config set ignore-engines true
yarn config set workspaces-experimental true
yarn config set cache-folder /home/node/.cache
echo "Configured Yarn for development."
yarn config list

update-global-packages

#!/usr/bin/env bash
# Setting up Debian/Linux OS CLI tools and setting up system configurations & permissions.
# Syntax: ./debian-setup.sh [root node vscode <username> ...] [1000 ...] [1000 ...] [boolean]

USERNAME=${1:-"node"}
USER_GID=${2:-"1000"}
USER_UID=${3:-"1000"}
UPGRADE_PACKAGES=${4:-"true"}

# Function to call apt-get if needed
apt-get-update-if-needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
        apt-get update --fix-missing
    else
        echo "Skipping apt-get update."
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive


if [ "${PACKAGES_ALREADY_INSTALLED}" != "true" ]; then

    PACKAGES_LIST="\
        apt-transport-https \
        bzip2 \
        ca-certificates \
        curl \
        git \
        gnupg2 \
        iptables \
        libfontconfig1 \
        lsb-release \
        libgtk2.0-0 \
        libgtk-3-0 \
        libgbm-dev \
        libnotify-dev \
        libgconf-2-4 \
        libnss3 \
        libxss1 \
        libasound2 \
        libxtst6 \
        lxc \
        make \
        net-tools \
        openssh-server \
        xauth \
        xvfb"

    apt-get-update-if-needed

    echo "Packages to verify are installed: ${PACKAGES_LIST}"
    apt-get -y install --no-install-recommends ${PACKAGES_LIST}
    PACKAGES_ALREADY_INSTALLED="true"

fi

# Get to latest versions of all packages
if [ "${UPGRADE_PACKAGES}" = "true" ]; then
    apt-get-update-if-needed
    apt-get -y upgrade --no-install-recommends
    apt-get autoremove -y
fi

# Setting up Node as User.
if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then
    groupmod --gid $USER_GID $USERNAME
    usermod --uid $USER_UID --gid $USER_GID $USERNAME
fi

# Checks to see if there is an active SSH Agent so to share SSH keys
# to perform tasks like accessing private GitHub repos.
if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "An SSH Agent was not detected."
else
    echo $SSH_AUTH_SOCK
    ssh-add -l
fi

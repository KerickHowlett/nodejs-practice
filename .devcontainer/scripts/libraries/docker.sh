#!/usr/bin/env bash
# This script is to set up Docker CLI / Moby CLI and Docker Compose CLI.
# Syntax: ./docker.sh [enable non-root docker access flag] [use moby] [root node vscode <username> ...]

ENABLE_NONROOT_DOCKER=${1:-"true"}
USERNAME=${3:-"node"}

# Swap to legacy iptables for compatibility
if type iptables-legacy > /dev/null 2>&1; then
    update-alternatives --set iptables /usr/sbin/iptables-legacy
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi

# Install Docker / Moby CLI if not already installed
if type docker > /dev/null 2>&1 && type dockerd > /dev/null 2>&1; then
    echo "Docker CLI and Engine already installed."
else
    curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT)
        echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
        apt-get update
        apt-get -y install --no-install-recommends docker-ce-cli docker-ce
        echo "Finished installing Docker CLI."
fi

# Install Docker Compose if not already installed.
if type docker-compose > /dev/null 2>&1; then
    echo "Docker Compose already installed."
else
    LATEST_COMPOSE_VERSION=$(basename "$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/docker/compose/releases/latest)")
    curl -fsSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed."
fi

# If init file already exists, exit
if [ -f "/usr/local/share/docker-init.sh" ]; then
    echo "/usr/local/share/docker-init.sh already exists, so exiting."
    exit 0
fi
echo "docker-init doesnt exist..."

# Add Node as a User to the docker group
if [ "${ENABLE_NONROOT_DOCKER}" = "true" ]; then

    if ! getent group docker > /dev/null 2>&1; then
        groupadd docker
    fi

    usermod -aG docker node

fi

tee /usr/local/share/docker-init.sh > /dev/null \
<< 'EOF'
#!/usr/bin/env bash
sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# explicitly remove dockerd and containerd PID file to ensure that it can start properly if it was stopped uncleanly
# ie: docker kill <ID>
sudoIf find /run /var/run -iname 'docker*.pid' -delete || :
sudoIf find /run /var/run -iname 'container*.pid' -delete || :

set -e

## Dind wrapper script from docker team
# Maintained: https://github.com/moby/moby/blob/master/hack/dind

export container=docker

if [ -d /sys/kernel/security ] && ! sudoIf mountpoint -q /sys/kernel/security; then
	sudoIf mount -t securityfs none /sys/kernel/security || {
		echo >&2 'Could not mount /sys/kernel/security.'
		echo >&2 'AppArmor detection and --privileged mode might break.'
	}
fi

# Mount /tmp (conditionally)
if ! sudoIf mountpoint -q /tmp; then
	sudoIf mount -t tmpfs none /tmp
fi

# cgroup v2: enable nesting
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
	# move the init process (PID 1) from the root group to the /init group,
	# otherwise writing subtree_control fails with EBUSY.
	sudoIf mkdir -p /sys/fs/cgroup/init
	sudoIf echo 1 > /sys/fs/cgroup/init/cgroup.procs
	# enable controllers
	sudoIf sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers \
		> /sys/fs/cgroup/cgroup.subtree_control
fi
## Dind wrapper over.

# Handle DNS
set +e
cat /etc/resolv.conf | grep -i 'internal.cloudapp.net'
if [ $? -eq 0 ]
then
  echo "Setting dockerd Azure DNS."
  CUSTOMDNS="--dns 168.63.129.16"
else
  echo "Not setting dockerd DNS manually."
  CUSTOMDNS=""
fi
set -e

# Start docker/moby engine
( sudoIf dockerd $CUSTOMDNS > /tmp/dockerd.log 2>&1 ) &

set +e

# Execute whatever commands were passed in (if any). This allows us
# to set this script to ENTRYPOINT while still executing the default CMD.
exec "$@"
EOF


if [ "${ENABLE_NONROOT_DOCKER}" = "true" ]; then
    DOCKER_OWNER="${USERNAME}"
else
    DOCKER_OWNER="root"
fi

chmod +x /usr/local/share/docker-init.sh
chown ${DOCKER_OWNER}:root /usr/local/share/docker-init.sh

echo "Docker/Docker-Compose CLI setup is complete."

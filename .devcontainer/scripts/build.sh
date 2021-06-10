#!/usr/bin/env bash
# Installs all the necessary libraries so that it is done in a single layer during the Docker build process.
# More about what each script does can be found in their respective comments section located at the top of the files.
# Syntax: ./build.sh

source /home/tmp/config.sh
cat /home/tmp/config.sh

/bin/bash /home/tmp/libraries/pre-check.sh

/bin/bash /home/tmp/libraries/set-bash-aliases.sh

/bin/bash /home/tmp/libraries/debian-setup.sh "${USERNAME}" "${USER_GID}" "${USER_UID}"

/bin/bash /home/tmp/libraries/docker.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}"

/bin/bash /home/tmp/libraries/node-package-managers.sh

/bin/bash /home/tmp/libraries/clean-house.sh

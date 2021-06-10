ARG NODE_VARIANT="14-buster"
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:0-${NODE_VARIANT}
LABEL author="Kerick Howlett"

# Set permissions arguments.
ARG USER_GID="1000"
ARG USER_UID="1000"

# Copy over files needed for DevContainer's configuration & setup.
COPY ./scripts /home/tmp

# Install Global Node dependencies.
RUN /bin/bash /home/tmp/build.sh

# A second cleaning sweep to ensure environment is as slimmed down as possible.
RUN rm -rf /home/tmp

# Setting home (~/) directory as non-root (particularly the cache needed for Cypress).
RUN chown -R ${USER_GID}:${USER_UID} /home/node

USER node

# Execute container and launch
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

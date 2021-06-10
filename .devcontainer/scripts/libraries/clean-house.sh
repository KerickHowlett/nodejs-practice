#!/usr/bin/env bash
# This is to clean everything up after the build process is complete.
# Syntax: ./clean-house.sh

apt-get clean -y
apt-get autoremove -y
apt-get clean -y
rm -rf /home/tmp  /var/lib/apt/lists/*
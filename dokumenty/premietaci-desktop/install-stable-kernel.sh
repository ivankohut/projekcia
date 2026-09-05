#!/bin/bash

set -ex

# Installation of the original LTS stable kernel and removal of the HWE kernel

sudo apt install -y linux-generic
sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y --autoremove -o Apt::Cmd::Disable-Script-Warning=true linux-generic-hwe-24.04 linux-hwe-* linux-modules-6.1* linux-modules-7.*

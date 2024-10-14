#!/bin/bash -e

# OpenOffice 4 installation for RPM based Linux distributions

wget -O install.tar.gz https://archive.apache.org/dist/openoffice/4.1.13/binaries/sk/Apache_OpenOffice_4.1.13_Linux_x86-64_install-rpm_sk.tar.gz
tar xzfv install.tar.gz
cd sk/RPMS/
rpm -Uvh *.rpm

#!/bin/bash -e

# LibreOffice 3 installation for RPM based Linux distributions

# Base package
zypper install gnome-vfs2
wget -O install.tar.gz https://downloadarchive.documentfoundation.org/libreoffice/old/3.6.7.2/rpm/x86_64/LibO_3.6.7.2_Linux_x86-64_install-rpm_en-US.tar.gz
tar xzfv install.tar.gz
cd LibO_3.6.7.2_Linux_x86-64_install-rpm_en-US/RPMS/
rpm -Uvh *.rpm

# Slovak language package
wget -O langpack.tar.gz https://downloadarchive.documentfoundation.org/libreoffice/old/3.6.7.2/rpm/x86_64/LibO_3.6.7.2_Linux_x86-64_langpack-rpm_sk.tar.gz
tar xzfv langpack.tar.gz
cd LibO_3.6.7.2_Linux_x86-64_langpack-rpm_sk/RPMS/
rpm -Uvh *.rpm

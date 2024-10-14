
# openSUSE Leap 15.6 specific installation of OpenLP utilizing Python virtual environment since distro package is not available and pure source code version does not work because of python packages conflicts
# Run the script from within a folder you want OpenLP to be installed into

OPENLP_VERSION=3.1.3

# Install Python 3.11 environment
zypper -n install python311-devel gcc-c++ libicu-devel dbus-1-devel glib2-devel
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install alembic beautifulsoup4 chardet dbus-python distro flask flask-cors lxml Mako packaging platformdirs PyICU 'pymediainfo>=2.2' 'PyQt5>=5.12' PyQtWebEngine QtAwesome qrcode requests SQLAlchemy waitress websockets python-vlc

# Install OpenLP
OPENLP_PACKAGE="OpenLP-$OPENLP_VERSION.tar.gz"
wget https://get.openlp.org/3.1.3/$OPENLP_PACKAGE
tar -xvzf $OPENLP_PACKAGE
rm -f $OPENLP_PACKAGE

# Create run script
cat >run.sh <<EOL
#!/bin/bash
source .venv/bin/activate
./run_openlp.py
EOL
chmod +x run.sh

# Toto asi netreba: sudo zypper install python3-PyICU python3-pkgconfig

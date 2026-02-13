#!/bin/bash

set -ex

# Installation of programs after basic openSUSE Leap installation to setup the system and the current user for "projekcia"

function add-menu-entry-to-kde-panel {
  # Note. Panel icons (*.desktop files) are stored in ~/.local/share/plasma_icons
  DESKTOP_FILE=$1
  qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
  var panel = panelById('org.kde.plasma.panel') || panels()[0];
  var launcher = panel.addWidget('org.kde.plasma.icon');
  launcher.currentConfigGroup = ['General'];
  launcher.writeConfig('url', 'applications:$DESKTOP_FILE');
  launcher.reloadConfig();
  "
}

function create-menu-entry {
  APPLICATION_NAME=$1
  EXEC_COMMAND=$2
  ICON_PATH=$3
  MENU_ENTRIES_DIR=~/.local/share/applications
  mkdir --parents $MENU_ENTRIES_DIR
  cat > $MENU_ENTRIES_DIR/${APPLICATION_NAME}.desktop << EOF
[Desktop Entry]
Comment=
Exec=${EXEC_COMMAND}
Icon=${ICON_PATH}
Name=${APPLICATION_NAME}
NoDisplay=false
Path=
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
EOF
  add-menu-entry-to-kde-panel ${APPLICATION_NAME}
}

function install-video-software {
  # VLC and other "restricted" packages
  sudo apt install -y ubuntu-restricted-extras vlc smplayer
  # DVD playback
  sudo apt install -y libdvd-pkg
  sudo dpkg-reconfigure libdvd-pkg
}

function install-deskreen {
  DESKREEN_DIR="$1"
  DESKREEN_FILE=Deskreen.AppImage
  curl --show-error --location --output $DESKREEN_FILE "https://www.dropbox.com/scl/fi/sorz2egjuqnemowmdmqaf/Deskreen-2.0.4.AppImage?rlkey=licmgk2rcufdzrknfn8flkd4y&st=cg9f4xq2&dl=0"
  chmod +x $DESKREEN_FILE
  mkdir --parents "$DESKREEN_DIR"
  mv $DESKREEN_FILE "$DESKREEN_DIR"
  DESKREEN_ICON=deskreen.png
  curl --show-error --location --output $DESKREEN_ICON "https://www.dropbox.com/scl/fi/xkbe1jgkpjz3sgpbv243n/deskreen-logo-icon_512x512.png?rlkey=243u3siohoqcbaavpxep12bkp&st=wht81lwe&dl=0"
  mv $DESKREEN_ICON "$DESKREEN_DIR"
  create-menu-entry Deskreen "$DESKREEN_DIR/$DESKREEN_FILE --no-sandbox" "$DESKREEN_DIR/$DESKREEN_ICON"
  sudo ufw allow 3131/tcp
}

# Installation of OpenLP utilizing Python virtual environment.
# Originally created for openSUSE Leap 15.6 since distro package is not available
# and pure source code version does not work because of Python packages conflicts
function install-openlp {
  OPENLP_DIR=$1
  OPENLP_VERSION=3.1.7

  # Install Python environment
  mkdir --parents "$OPENLP_DIR"
  sudo apt install -y python3-dev libicu-dev libdbus-1-dev libglib2.0-dev python3-venv
  python3 -m venv "$OPENLP_DIR/.venv"
  source "$OPENLP_DIR/.venv/bin/activate"
  python3 -m pip install --upgrade pip
  python3 -m pip install alembic beautifulsoup4 chardet dbus-python distro flask flask-cors lxml Mako packaging platformdirs PyICU 'pymediainfo>=2.2' 'PyQt5>=5.12' PyQtWebEngine QtAwesome qrcode requests SQLAlchemy waitress websockets python-vlc

  # Install OpenLP
  OPENLP_PACKAGE="OpenLP-$OPENLP_VERSION.tar.gz"
  curl --show-error --location --remote-name https://get.openlp.org/$OPENLP_VERSION/$OPENLP_PACKAGE
  tar --extract --gzip --verbose --file="$OPENLP_PACKAGE" --directory="$OPENLP_DIR"
  rm --force $OPENLP_PACKAGE

  # Create run script
  cat > "$OPENLP_DIR/run.sh" <<EOL
#!/bin/bash
cd $OPENLP_DIR
source .venv/bin/activate
./run_openlp.py
EOL
  chmod +x "$OPENLP_DIR/run.sh"
  create-menu-entry OpenLP "$OPENLP_DIR/run.sh" "$OPENLP_DIR/resources/images/OpenLP.ico"
}

function install-obs-with-ndi {
  # OBS
  sudo add-apt-repository -y ppa:obsproject/obs-studio
  sudo apt update
  sudo apt install -y obs-studio

  # NDI library
  curl --show-error --location --remote-name https://raw.githubusercontent.com/DistroAV/DistroAV/refs/heads/master/CI/libndi-get.sh
  chmod +x libndi-get.sh
  ./libndi-get.sh install
  rm libndi-get.sh

  # DistroAV - OBS plugin providing NDI
  DISTROAV_VERSION=6.1.1
  DISTROAV_DEB=distroav-${DISTROAV_VERSION}-x86_64-linux-gnu.deb
  curl --show-error --location --remote-name https://github.com/DistroAV/DistroAV/releases/download/${DISTROAV_VERSION}/${DISTROAV_DEB}
  sudo apt install ./${DISTROAV_DEB}
  rm ${DISTROAV_DEB}

  # Firewall setup
  # Open TCP and UDP port ranges for NDI
  sudo ufw allow 5960:5970/tcp
  sudo ufw allow 5960:5970/udp
  sudo ufw allow 6960:6970/tcp
  sudo ufw allow 6960:6970/udp
  sudo ufw allow 7960:7970/tcp
  sudo ufw allow 7960:7970/udp
  # Allow mDNS (needed for auto-discovery)
  sudo ufw allow 5353/udp
  # Optional: Allow PTP time sync
  sudo ufw allow 319/udp
  sudo ufw allow 320/udp
}

function install-xnview-classic {
  DESTINATION_DIR=$1
  mkdir --parents $DESTINATION_DIR
  PACKAGE_FILE=xnview.zip
  curl --show-error --location --output ${PACKAGE_FILE} https://www.xnview.com/download.php?file=XnView-win-full.zip
  7z x ${PACKAGE_FILE}
  mv XnView/* -t ${DESTINATION_DIR}
  EXE_PATH="${DESTINATION_DIR}/xnview.exe"
  ICON_PATH="${DESTINATION_DIR}/xnview.ico"
  wrestool --extract --type=14 "${EXE_PATH}" > "${ICON_PATH}"
  WINEPREFIX="$HOME/.wine-xnview"
  create-menu-entry XnView "WINEPREFIX=${WINEPREFIX} wine ${EXE_PATH}" "${ICON_PATH}"
  XNVIEW_CONFIG_DIR="$WINEPREFIX/drive_c/users/${USER}/AppData/Roaming/XnView"
  mkdir --parents $XNVIEW_CONFIG_DIR
  cp xnview.ini $XNVIEW_CONFIG_DIR/xnview.ini
  rm --dir XnView
  rm ${PACKAGE_FILE}
}

function clone-git-repo {
  git clone https://github.com/ivankohut/${2}.git "$1/$3"
}

function install-opensong {
  DESTINATION_DIR=$1
  mkdir --parents $DESTINATION_DIR
  PACKAGE_FILE=opensong.7z
  curl --show-error --location --output ${PACKAGE_FILE} "https://www.dropbox.com/scl/fi/7v2ynw8kqugre0d7xdbxc/opensong-portable-configured-nocontent.7z?rlkey=zxctstsxegfgg7akv2scyzwfb&st=dd3b1s9m&dl=0"
  7z x ${PACKAGE_FILE}
  mv OpenSong-portable/* --target-directory=${DESTINATION_DIR}
  DOCUMENTS_DIR=$(xdg-user-dir DOCUMENTS)
  ln --symbolic --no-dereference --force "${DESTINATION_DIR}/OpenSong Data/Sets" "$DOCUMENTS_DIR/Sets"
  SONGS_DIR="${DESTINATION_DIR}/OpenSong Data/Songs"
  ln --symbolic --no-dereference --force "${SONGS_DIR}" "$DOCUMENTS_DIR/Songs"
  clone-git-repo "${SONGS_DIR}" 400 400
  clone-git-repo "${SONGS_DIR}" bratske-piesne Bratske\ piesne
  clone-git-repo "${SONGS_DIR}" chvalte-pana-jezisa Chvalte\ Pana\ Jezisa
  clone-git-repo "${SONGS_DIR}" chvaly Chvaly
  clone-git-repo "${SONGS_DIR}" oranzovy-spevnicek Oranzovy\ Spevnicek
  clone-git-repo "${SONGS_DIR}" detske-piesne Ine/Detske\ piesne
  clone-git-repo "${SONGS_DIR}" matuzalem Ine/Matuzalem
  clone-git-repo "${SONGS_DIR}" spevokol Ine/Spevokol
  mkdir --parents "${SONGS_DIR}/Ine/Rozne"
  clone-git-repo "${DESTINATION_DIR}" opensong-bibles OpenSong\ Scripture
  create-menu-entry OpenSong "WINEPREFIX=$HOME/.wine-opensong wine ${DESTINATION_DIR}/OpenSong.exe" "${DESTINATION_DIR}/OpenSong2.ico"
  rm --dir OpenSong-portable
  rm ${PACKAGE_FILE}
}

function install-fonts {
  FONTS_DIR=~/.local/share/fonts
  mkdir --parents $FONTS_DIR

  # Windows 7 fonts
  FONT_FILE=windows7-latin-ttf-fonts.7z
  curl --show-error --location --output $FONT_FILE "https://www.dropbox.com/scl/fi/g0xt8q1yvyr0f1lg57svq/windows7-latin-ttf-fonts.7z?rlkey=nhoj1updclytnufol6012sxm0&st=5jk35cjw&dl=0"
  7z x $FONT_FILE -o$FONTS_DIR
  rm $FONT_FILE
  # Bahnschrift
  curl --show-error --location --output $FONTS_DIR/bahnschrift.ttf "https://www.dropbox.com/scl/fi/e7s5yyt7ktehix104q183/bahnschrift.ttf?rlkey=dg3ny56emrc1d6vi3hirxxn0g&st=hl5mggdn&dl=0"
  # Centaur
  curl --show-error --location --output $FONTS_DIR/centaur.ttf "https://www.dropbox.com/scl/fi/s71zpy0qqsoduci5oclla/centaur.ttf?rlkey=upgrn367tfoh86flsnotxzbqt&st=k7nbp1vz&dl=0"
  # Century Gothic
  FONT_FILE=century-gothic-cufonfonts.zip
  curl --show-error --location --output $FONT_FILE "https://www.dropbox.com/scl/fi/9yap9hr7qn1g858950ko3/century-gothic-cufonfonts.zip?rlkey=lyxjwu6dhewh2esw4kgpqz0er&st=1jzjzzlg&dl=0"
  unzip $FONT_FILE -d $FONTS_DIR
  rm $FONT_FILE

  fc-cache --force --verbose
}

function install-firefox {
  # Uninstall snap version and install apt version, source: https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
  sudo snap remove firefox
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/mozilla
  sudo apt update && sudo apt remove -y firefox
  sudo apt install firefox firefox-l10n-sk
  # Video Download Helper
  firefox --headless --createprofile default
  PROFILE_DIR=$(find ~/.config/mozilla/firefox/ -iname *.default)
  EXTENSIONS_DIR=$PROFILE_DIR/extensions
  mkdir --parents $EXTENSIONS_DIR
  curl --show-error --location --output $EXTENSIONS_DIR/{b9db16a4-6edc-47ec-a1f4-b86292ed211d}.xpi https://addons.mozilla.org/firefox/downloads/file/4502183/video_downloadhelper-9.5.0.2.xpi
  # Video Download Helper CoApp
  curl --silent --show-error --location --fail https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash
}

function install-optional-software {
  # General
  sudo apt install -y mc htop krename zip arj unrar keepassxc audacity arandr dcraw exiftool
  # XnViewMP via flatpak - with full filesystem access
  sudo flatpak install -y flathub com.xnview.XnViewMP
  sudo flatpak override com.xnview.XnViewMP --filesystem=host
}

function configure-software {
  # Okular
  cp okularpartrc ~/.config/
  # Krusader
  cp krusaderrc ~/.config/
}

function remove-icon-from-panel {
  qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
  var panels = panels();
  for (i = 0; i < panels.length; ++i) {
    var widgets = panels[i].widgets();
    for (j = 0; j < widgets.length; ++j) {
      if (widgets[j].type === '$1') {
          widgets[j].remove();
      }
    }
  }"
}

function sed-appletsrc {
  # The file is sometimes not updated after running "sed", I guess it gets overwritten by some other process,
  # therefore I repeatedly update it
  FILE=~/.config/plasma-org.kde.plasma.desktop-appletsrc
  echo "Ensuring appletsrc contains $2"
  while ! perl -0777 -pe "exit 1 unless /$2/s" "$FILE"; do
    echo "Updating appletsrc"
    sed --in-place "s/^plugin=$1/plugin=$1\n\n$2/" "$FILE"
    sleep 3s
  done
}

function configure-kde-plasma {
  rm -d ~/Music ~/Pictures ~/Public ~/Templates ~/Videos

  # Requires relogin, since:
  # - reloading config via qdbus no longer supported since Plasma 5.27
  # - reloading Plasma itself is not sufficient for some reason

  # Set desktop background to black color
  qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
    var allDesktops = desktops();
    for (i=0; i<allDesktops.length; i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = "org.kde.color";
        d.currentConfigGroup = Array("Wallpaper", "org.kde.color", "General");
        d.writeConfig("Color", "#000000");
    }
  '

  # Virtual Desktops - set the number to 1 and remove desktop switcher
  kwriteconfig5 --file kwinrc --group Desktops --key Number 1
  kwriteconfig5 --file kwinrc --group Desktops --key Rows 1
  kwriteconfig5 --file kwinrc --group Desktops --key Id_2 --delete
  qdbus org.kde.KWin /KWin reconfigure
  remove-icon-from-panel org.kde.plasma.pager

  # Task manager
  # - remove icons
  # - do not allow grouping windows
  # - do not hide other windows while hovering over thumbnails
  sed-appletsrc 'org\.kde\.plasma\.icontasks' '\[Containments\]\[2\]\[Applets\]\[5\]\[Configuration\]\[General\]\nlaunchers=\ngroupingStrategy=0\nonlyGroupWhenFull=false\nhighlightWindows=false'

  # Display seconds in digital clock
    sed-appletsrc 'org\.kde\.plasma\.digitalclock' '\[Containments\]\[2\]\[Applets\]\[19\]\[Configuration\]\[Appearance\]\nshowSeconds=true'

  # Display flag in keyboard layout
  sed-appletsrc 'org\.kde\.plasma\.keyboardlayout' '\[Containments\]\[8\]\[Applets\]\[18\]\[Configuration\]\[General\]\ndisplayStyle=Flag'

  # Keyboard
  kwriteconfig5 --file kxkbrc --group Layout --key LayoutList "us,sk"
  kwriteconfig5 --file kxkbrc --group Layout --key Use --type bool true
  kwriteconfig5 --file kxkbrc --group Layout --key DisplayNames ","
  kwriteconfig5 --file kglobalshortcutsrc --group "KDE Keyboard Layout Switcher" --key "Switch to Next Keyboard Layout" "Ctrl+Alt+K,Ctrl+Alt+K,Switch to Next Keyboard Layout"

  # Region -> Slovakia
  kwriteconfig5 --file plasma-localerc --group Formats --key LANG sk_SK.UTF-8

  # Disabling Power Management
  kwriteconfig5 --file powermanagementprofilesrc --group AC --group DPMSControl --key idleTime --delete
  kwriteconfig5 --file powermanagementprofilesrc --group AC --group DPMSControl --key lockBeforeTurnOff --delete
  kwriteconfig5 --file powermanagementprofilesrc --group AC --group DimDisplay --key idleTime --delete
  kwriteconfig5 --file powermanagementprofilesrc --group AC --group SuspendSession --key idleTime --delete
  # Note - reloading config via qdbus no longer supported since Plasma 5.27

  # Disabling screen locking
  kwriteconfig5 --file kscreenlockerrc --group Daemon --key Autolock false

  # Turn on Num Lock on login
  kwriteconfig5 --file kcminputrc --group Keyboard --key NumLock 0
}

function os-configuration {
  # Important software installation
  sudo apt install -y linux-generic
  sudo apt remove -y linux-generic-hwe-${OS_VERSION} linux-hwe-* linux-modules-6.1*
  sudo apt autoremove -y
  sudo apt install -y krusader wine 7zip unzip qdbus-qt6 crudini icoutils flatpak synaptic curl
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  sudo flatpak config --set languages "en;sk"
  sudo flatpak update -y

  # GRUB
  ## Set GRUB timeout to 0
  sudo sed --in-place 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
  grep -q '^GRUB_TIMEOUT=' /etc/default/grub || echo 'GRUB_TIMEOUT=0' | sudo tee --append /etc/default/grub
  sudo update-grub

  # Remove Discover to prevent unintentional installation of updates
  sudo apt remove -y plasma-discover

  # Firewall
  sudo ufw allow ssh
  sudo ufw enable
}


OS_VERSION=24.04
PROGRAMS_DIR=~/programs
mkdir --parents $PROGRAMS_DIR
echo "Sudo is required for installation of some packages via system package manager"

# Global - OS configuration, software installed for all users
os-configuration
install-optional-software
install-video-software
install-obs-with-ndi

# User specific - desktop settings, programs, icons
configure-kde-plasma
add-menu-entry-to-kde-panel "org.kde.krusader"
configure-software
install-opensong "$PROGRAMS_DIR/opensong"
install-xnview-classic "$PROGRAMS_DIR/xnview"
install-deskreen "$PROGRAMS_DIR/deskreen"
install-openlp "$PROGRAMS_DIR/openlp"
install-fonts
install-firefox
add-menu-entry-to-kde-panel "com.obsproject.Studio"

echo "Installation finished. Re-login please!"

# Installation instructions

## BIOS

- GPU memory - Auto (2GB) -> 512MB
- after POST waiting time - 3s -> 1s

## OS

- openSUSE Leap 15.6
    - Keyboard layout - EN
    - region - Slovakia
    - package group - _KDE Desktop_

## Configuration

- yast - boot loader (GRUB) waiting time
- /etc/fstab
    - options for filesystems (ext4 - discard, nodelassoc, ...)
    - tempfs for temp. directories
- /etc/zypp/zypp.conf - `download.use_deltarpm = false`
- KDE System Settings
    - /Regional Settings/Formats/Region - Slovensko
    - /Sprava napajania/Setrenie energie/Setrenie energie obrazovky - OFF
    - /Spravanie pracovnej plochy/Zamykanie obrazovky
        - Zamknut obrazovku - OFF
        - Po prebudeni zo spanku - OFF
    - /Input Devices/Keyboard
        - /Hardware - Numlock on Plasma Startup - Turn on
        - /Layouts
            - Show flag
            - Add layout - Slovak

## Software

- general

  ```shell
  zypper -n install krusader wine mc htop krename p7zip-full zip arj rar unar keepassxc audacity arandr dcraw darktable exiftool smplayer
  ```

- _VLC_ (to have additional multimedia codecs), _ffmpeg_ and _gstreamer_ from _packman_ repository:

  ```shell
  zypper addrepo -cfp 90 http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_15.6 packman
  zypper --gpg-auto-import-keys refresh
  zypper dist-upgrade --from packman --allow-downgrade --allow-vendor-change
  zypper -n install --from packman ffmpeg gstreamer-plugins-bad gstreamer-plugins-libav gstreamer-plugins-ugly vlc vlc-codecs
  ```

- DVD playback

  ```shell
  zypper addrepo -f http://opensuse-guide.org/repo/openSUSE_Leap_15.6/ dvd
  zypper --gpg-auto-import-keys refresh
  zypper -n install libdvdcss2
  ```

- OpenLP - na video
    - OpenLP 2.4.6 uz v openSUSE (15.4+) nefunguje, chyba mu balik python3-qtwebkit ("ImportError: cannot import name 'QtWebKit'"), ktory uz nie je
      podporovany v openSUSE 15.4 (je neudrziavany a nahradeny balikom python3-qtwebengine, na ktory vsak nie je OpenLP 2.4.6 prisposobeny
    - OpenLP 3.x (v. 3.0.0 released in December 2022) is not packages for openSUSE Leap 15.6 yet, however, source package can be used - run [openlp-install.sh](openlp-install.sh) script in `/opt/openlp` folder 
        - register into KDE menu (path: `/opt/openlp/run.sh`)

- XnViewMP
    - register into KDE menu
    - configure full screen
- XnView
    - configure full screen
- fonts
    - basic MS fonts `zypper -n install fetchmsttfonts`
    - all TTF files from `Windows7DefaultFonts.zip` package
    - Century Gothic `century-gothic-cufonfonts.zip`
- OpenSong
    - unpack `opensong.7z` package to `~/Programs`
    - create PNG icon from ICO (multipage - use the page with the higher resolution)
    - register into KDE menu using PNG icon
- git
    - git: `zypper -n install git`
    - IntelliJ IDEA, download and unpack to ~/Programs, to be used as git GUI
    - register IDEA into KDE menu from within IDEA itself
    - clone all OpenSong repos (i.e. replace most of the existing songs with GitHub clones)
- LibreOffice 3.x (do not install desktop integration because it overrides existing file associations of libreoffice document types) - [
  `install-libreoffice3.sh`](install-libreoffice3.sh)
    - register into KDE menu:
        - icon: /opt/libreoffice3.6/program/flat_logo.png
        - command: /opt/libreoffice3.6/program/soffice
- OpenOffice 4.x (ikonky do menu nejdu nainstalovat - konflikt s aktualnym LibreOffice 7.x - a tiez by to mohlo zmenit file associations) - [
  `install-openoffice4.sh`](install-openoffice4.sh)
    - register into KDE menu:
        - icon: /opt/openoffice4/program/logo.png
        - command: /opt/openoffice4/program/soffice
- OpenOffice 3.x - unavailable - it cannot be installed via rpm because is obsoleted by OpenOffice 4.x

- OBS Studio (openSUSE specific instructions: https://cubiclenate.com/2020/08/11/obs-ndi-plugin-on-opensuse/) from _packman_ repository
    - install

      ```shell
      zypper -n install alien rpm-build obs-studio libsrt1_5
      # NDI plugin - only DEBs available - convert them to RPMs
      curl -SLo libndi4_amd64.deb https://github.com/Palakis/obs-ndi/releases/download/4.9.1/libndi4_4.5.1-1_amd64.deb
      alien -r libndi4_amd64.deb
      zypper in ./libndi*.rpm
      rm libndi4*.deb libndi4*.rpm
      curl -SLo obs-ndi_amd64.deb https://github.com/Palakis/obs-ndi/releases/download/4.9.1/obs-ndi_4.9.1-1_amd64.deb
      alien -r obs-ndi_amd64.deb
      zypper in obs-ndi*.rpm
      ln -s /usr/lib/obs-plugins/obs-ndi.so /usr/lib64/obs-plugins/obs-ndi.so
      rm obs-ndi*.deb obs-ndi*.rpm
      # Disable firewall so that NDI communication works (FW not needed in local network)
      systemctl stop firewalld
      systemctl disable firewalld
      ```

    - configure
        - Add Source - Capturing screen - Zachytávanie monitora (XSHM)
        - Add Filter to created Source - Dedicated NDI Output
    - start automatically - System Settings/Startup and Shutdown/Autostart/Add Program... - choose OBS Studio

- Video Download Helper extension for Firefox
  - install the extension
  - install the companion application - https://www.downloadhelper.net/install-coapp-v2

## Already installed:

- Libreoffice 24.8.1.2

## Known problems

- XnViewClassic - neviem otvorit obrazky v XnView priamo z file managera (Krusader), suvisi to s tym, ze to ide cez Wine
- XnViewMP currently displays everything to the first monitor - wait for bugfix

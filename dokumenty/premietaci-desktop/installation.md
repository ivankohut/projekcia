# Instalačný postup prostredia pre projekciu

## Počítač

Je potrebné rýchle internetové pripojenie.

### Premietací počítač na Palisádach

Nastavenia v BIOSe (dostať sa doň pomocou tlačidiel F2 alebo Del):

- Boot / Boot Configuration / POST Delay Time - 1 sec
- Advanced / NB Configuration / UMA Frame Buffer Size - 2G
- Advanced / APM Configuration / Power On By PCI-E - Enabled

### Iný počítač, skutočný alebo virtuálny (VirtualBox)

- disk veľkosti aspoň 20 GB
- RAM veľkosti aspoň 4 GB

## Operačný systém

- Linux, konkrétne Kubuntu 24.04, [stiahnuť ISO obraz](https://cdimage.ubuntu.com/kubuntu/releases/24.04.4/release/kubuntu-24.04.4-desktop-amd64.iso)
- napáliť obraz na DVD, resp. nahrať na USB, resp. vložiť do virtuálnej CD mechaniky vo VirtualBox-e
- naštartovať počítač z ISO obrazu, spustiť inštaláciu, použiť nasledovné voľby pre inštaláciu vo VirtualBox-e
  (na fyzickom počítači treba byť opatrný pri nastavovaní _Storage_, teda kam sa systém nainštaluje):
  - v boot menu ISO obrazu: _Try or Install Kubuntu_
  - _Install Kubuntu_
  - v inštalátore Kubuntu, krok:
    - _Uvítanie_ vybrať jazyk: _slovenčina_
    - _Umiestnenie_ - len klik _Ďalej_ (potvrdiť oblasť _Europe_ a zónu _Bratislava_)
    - _Klávesnica_ - len klik _Ďalej_ (potvrdiť _Slovak_ / _Default_)
    - _Customize_ - vybrať _Normal installation_ a zaškrtnúť _Download and install updates following installation_
    - _Oddiely_ - vybrať _Vymazanie disku_ a _Odkladací priestor v súbore_ zmeniť na _No swap_
    - _Používatelia_ 
      - Celé meno: `Projekcia`
      - Prihlásenie: `projekcia`
      - Názov počítača: `projekcia`
      - Heslo a zopakovanie hesla: je to na vás, napr. `projekcia`
      - zaškrtnúť _Prihlásiť automaticky bez pýtania hesla._
    - _Súhrn_ - len klik _Inštalovať_ a potom _Install Now_
    - _Dokončenie_ - len klik _Dokončiť_
- voliteľné pre fyzický počítač: nakonfigurovať oddiely v `/etc/fstab`
  - _options_ pre systémy súborov (ext4 - `discard`, `nodelassoc`, ...)
  - _tempfs_ pre priečinky dočasných súborov
- spustiť nainštalovaný počítač (automatické prihlásenie ako používateľ _Projekcia_)
- v nainštalovanom systéme pomocou webového prehliadača otvoriť tento dokument (https://github.com/ivankohut/projekcia/blob/main/dokumenty/premietaci-desktop/installation.md),
  aby ste z neho mohli kopírovať príkazy do terminálu, a pokračujte ďalším krokom
- otvoriť terminál (teda spustiť program _Konsole_) a spustiť v ňom tieto príkazy (bude vyžadovať zadanie hesla):

  ```shell
  git clone https://github.com/ivankohut/projekcia.git && cd projekcia/dokumenty/premietaci-desktop && ./install-stable-kernel.sh
  ```

- reštartovať počítač

## VirtualBox Guest Additions (ak je počítač virtuálny)

- vo VirtualBox menu bežiaceho virtuálneho počítača spustiť: _Devices_ / _Insert Guest Additions CD Image..._
- v termináli (program _Konsole_) spustiť (bude vyžadovať zadanie hesla):

  ```shell
  sudo apt install -y build-essential dkms \
    && sudo mkdir -p /media/vbox-additions \
    && sudo mount /dev/sr0 /media/vbox-additions \
    && sudo /media/vbox-additions/VBoxLinuxAdditions.run --accept \
    && sudo umount /media/vbox-additions
  ```
- vo VirtualBox menu bežiaceho virtuálneho počítača spustiť: _Devices_ / _Shared Clipboard / Bidirectional_

## Programy a pracovná plocha

Otvoriť terminál (teda spustiť program _Konsole_) a spustiť v ňom tieto príkazy (bude vyžadovať zadanie hesla):

```shell
cd projekcia/dokumenty/premietaci-desktop && ./install-programs.sh
```

Následne je potrebné sa odhlásiť a zase prihlásiť.

Presunúť spúšťacie ikony programov z oblasti napravo od "systray" do oblasti napravo od tlačidla "štart". 

### OBS

OBS aj s podporou NDI sa síce nainštaluje v predošlom kroku, ale jeho konfiguráciu treba spraviť manuálne (konfigurácia je uložená v JSON databáze, ktorú nie je
možné editovať priamo cez nejaký skript):

- pridať _zdroj_ typu _Display Capture (XSHM)_, vybrať obrazovku, ktorá sa bude posielať do NDI (za účelom streamovania)
- do vytvoreného zdroja pridať _filter_ (pravý klik na zdroj, klik na _Filters_, potom klik na _+_) typu _Dedicated NDI (R) output_, nastaviť _NDI (R) Name_ na `Projekcia`

### Rozšírenia pre Firefox

Vo Firefoxe kliknúť na puzzle ikonku vpravo hore, potom _Spravovať rozšírenia_:

- uBlock Origin - blokovač reklám
- Video DownloadHelper - sťahovanie videí napr. z YouTube

## Premietací počítač na Palisádach - sieťové nastavenia

Statická IP adresa je užitočná nato 

* aby v mobile, ktorý zobrazuje obraz premietaný na plátne, nebolo treba v _Chrome_ meniť IP adresu pri pripájaní sa na _Deskreen_ (aby stačilo zmeniť len 6-ciferný kód na konci internetovej adresy),
* aby sa dalo na počítač pripojiť vzdialene cez VPN.

Vzdialený prístup - potrebuje Wake on LAN (vzdalené zapnutie), SSH server (vzdialené prihlásenie cez terminál) a VNC server (vzdialené prihlásenie cez VNC).

V termináli (program _Konsole_) spustiť:

```shell
# Statická IP adresa a Wake on LAN (pre vzdialené zapnutie počítača)
NM_CONNECTION_NAME="Wired connection 1"
sudo nmcli connection modify "$NM_CONNECTION_NAME" \
  ipv4.addresses 192.168.20.80/24 \
  ipv4.gateway 192.168.20.1 \
  ipv4.dns "1.1.1.1,1.0.0.1" \
  ipv4.method manual \
  802-3-ethernet.wake-on-lan magic
sudo nmcli connection up "$NM_CONNECTION_NAME"

# SSH server
sudo apt install -y openssh-server
sudo systemctl enable --now ssh

# VNC server
sudo apt install -y tigervnc-scraping-server tigervnc-common
sudo ufw allow 5900/tcp
vncpasswd
cat > ~/.config/autostart/x0vncserver.desktop << EOF
[Desktop Entry]
Type=Application
Name=TigerVNC x0vncserver
Exec=sh -c "sleep 3 && x0vncserver -display :0 -rfbauth ~/.vnc/passwd -localhost=no"
X-KDE-autostart-after=panel
EOF
```

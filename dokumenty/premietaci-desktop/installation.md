# Instalačný postup prostredia pre projekciu

## Počítač

Je potrebné rýchle internetové priprojenie.

### Premietací počítač na Palisádach

Nastavenia v BIOSe (dostať sa doň pomocou tlačidiel F2 alebo Del):

- Boot / Boot Configuration / POST Delay Time - 1 sec
- Advanced / NB Configuration / UMA Frame Buffer Size - 2G
- Advanced / APM Configuration / Power On By PCI-E - Enabled

### Iný počítač, skutočný alebo virtuálny (VirtualBox)

- disk veľkosti aspoň 20 GB

## Operačný systém

- Linux, konkrétne openSUSE Leap 16.0, [stiahnuť ISO obraz](https://download.opensuse.org/distribution/leap/16.0/offline/Leap-16.0-offline-installer-x86_64.install.iso)
- napáliť obraz na DVD, resp. nahrať na USB, resp. vložiť do virtuálnej CD mechaniky vo VirtualBox-e
- naštartovať počítač z ISO obrazu, spustiť inštaláciu, použiť nasledovné voľby pre inštaláciu vo VirtualBox-e
  (na fyzickom počítači treba venovať patričnú pozornosť správnemu nastaveniu _Storage_, teda kam sa openSUSE nainštaluje) :
  - Select a product - _Leap 16.0_
  - v ľavom menu Localization - Language / Change: _Slovak_, Time zone / Change: _Europe-Bratislava_
  - v ľavom menu Storage - New partitions will be created for...
    - zmeniť File system pre partíciu "/" na _Ext4_
    - odstrániť _swap_ 
  - v ľavom menu Software - Change selection
    - zapnúť _KDE Applications and Plasma Desktop_  
    - vypnúť _SELinux Support_
  - v ľavom menu Authentication
    - First user / Define a user now
      - Full name: `Projekcia`
      - Username: `projekcia`
      - Password a Password confirmation: je to na vás, napr. `projekcia`
  - vpravo hore kliknúť na _Install_ a potvrdiť pomocou _Continue_
- voliteľné pre fyzický počítač: nakonfigurovať partície v `/etc/fstab`
  - _options_ pre systémy súborov (ext4 - `discard`, `nodelassoc`, ...)
  - _tempfs_ for temp. directories
- nainštalovať aktualizácie - v termináli (program _Konsole_) spustiť (bude vyžadovať zadanie hesla):
  ```shell
  sudo zypper update -y
  sudo reboot
  ```
- pre virtuálny počítač vo VirtualBox-e treba nainštalovať _Guest Additions_
  - vo VirtualBox menu bežiaceho virtuálneho počítača spustiť: _Devices_ / _Insert Guest Additions CD Image..._
  - v termináli (program _Konsole_) spustiť (bude vyžadovať zadanie hesla) 
    ```shell
    sudo zypper install -y kernel-devel \
      && sudo mkdir -p /media/vbox-additions \
      && sudo mount /dev/sr0 /media/vbox-additions \
      && sudo /media/vbox-additions/VBoxLinuxAdditions.run --accept \
      && sudo umount /media/vbox-additions
    ```
  - vo VirtualBox menu bežiaceho virtuálneho počítača spustiť: _Devices_ / _Shared Clipboard / Bidirectional_

## Programy a pracovná plocha

Spustiť nainštalovaný počítač (automatické prihlásenie ako používateľ _Projekcia_),
otvoriť terminál (teda spustiť program _Konsole_) a spustiť v ňom tieto príkazy (bude vyžadovať zadanie hesla):

```shell
sudo zypper install -y git \
  && git clone https://github.com/ivankohut/projekcia.git \
  && cd projekcia/dokumenty/premietaci-desktop \
  && ./install-programs.sh
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
- Video DownloadHelper - sťahovanie videí napr. z YouTube. Jeho _co-app_ ("companion application") je už nainštalovaná,  
  ale samotné rozšírenie treba nainštalovať ručne.

## Premietací počítač na Palisádach - sieťové nastavenia

Statická IP adresa je užitočná nato 

* aby v mobile, ktorý zobrazuje obraz premietaný na plátne, nebolo treba v _Chrome_ meniť IP adresu pri pripájaní sa na _Deskreen_ (aby stačilo zmeniť len 6-ciferný kód na konci internetovej adresy),
* aby sa dalo na počítač pripojiť vzdialene cez VPN.

Vzdialený prístup - potrebuje Wake on LAN (vzdalené zapnutie) a SSH server (vzdialené prihlásenie cez terminál).

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
sudo zypper install -y openssh
sudo systemctl enable --now sshd
sudo firewall-cmd --permanent --add-service ssh
sudo firewall-cmd --reload
``` 

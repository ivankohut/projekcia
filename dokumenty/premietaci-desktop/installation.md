# Instalačný postup prostredia pre projekciu

## Počítač

Je potrebné rýchle internetové priprojenie.

### Premietací počítač na Palisádach

Nastavenia v BIOSe:

- GPU memory - Auto (2GB) -> 512MB
- after POST waiting time - 3s -> 1s

### Iný počítač, skutočný alebo virtuálny (VirtualBox)

- disk veľkosti aspoň 20 GB

## Operačný systém

- Linux, konkrétne openSUSE Leap 16.0, [stiahnuť ISO obraz](https://download.opensuse.org/distribution/leap/16.0/offline/Leap-16.0-offline-installer-x86_64.install.iso)
- napáliť obraz na DVD, resp. nahrať na USB, resp. vložiť do virtuálnej CD mechaniky vo VirtualBox-e
- spustiť inštaláciu openSUSE, použiť nasledovné voľby pre inštaláciu vo VirtualBox-e
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

- add Source of type _Display Capture (XSHM)_, select the display you want to send to NDI (for streaming purposes)
- add Filter (right-click on the source, click Filter, then click +) of type _Dedicated NDI (R) output_, set _NDI (R) Name_ to `Projekcia`

### Rozšírenia pre Firefox

Vo Firefoxe kliknúť na puzzle ikonku vpravo hore, potom _Spravovať rozšírenia_:

- uBlock Origin - blokovač reklám
- Video DownloadHelper - sťahovanie videí napr. z YouTube. Jeho _co-app_ ("companion application") je už nainštalovaná,  
  ale samotné rozšírenie treba nainštalovať ručne . Odporúčam zmeniť adresár, do ktorého ukladá stiahnuté videá - 
  kliknúť na puzzle ikonku vpravo hore, potom _Video DownloadHelper_, potom ozubené koliesko vľavo dole, potom _More settings_, potom _Download directory_ a _Change_ a vyberte štandardný priečinok pre stiahnuté súbory.

## Premietací počítač - statická IP adresa

Statická IP adresa je užitočná nato, aby v mobile, ktorý zobrazuje obraz premietaný na plátne, nebolo treba v _Chrome_ meniť IP adresu pri pripájaní sa na _Deskreen_ (aby stačilo zmeniť len 6-ciferný kód na konci internetovej adresy).

V termináli (program _Konsole_) spustiť:

```shell
sudo nmcli con mod "Wired connection 1" \
  ipv4.addresses 192.168.20.80/24 \
  ipv4.gateway 192.168.20.1 \
  ipv4.dns "1.1.1.1,1.0.0.1" \
  ipv4.method manual
sudo nmcli con up "Wired connection 1"
```
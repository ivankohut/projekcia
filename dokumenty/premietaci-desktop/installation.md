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

- Linux, konkrétne openSUSE Leap 15.6, [stiahnuť ISO obraz](https://download.opensuse.org/distribution/leap/15.6/iso/openSUSE-Leap-15.6-DVD-x86_64-Media.iso)
- napáliť obraz na DVD, resp. nahrať na USB, resp. vložiť do virtuálnej CD mechaniky vo VirtualBox-e
- spustiť inštaláciu openSUSE, použiť nasledovné voľby pre inštaláciu vo VirtualBox-e
  (na fyzickom počítači treba venovať patričnú pozornosť správnemu nastaveniu Disk Partitioning (rozdelenie disku), teda kam sa openSUSE nainštaluje) :
  - Language (Jazyk) - _Slovak - Slovenčina_, Rozloženie klávesnice - _Anglická (US)_, potom _Dopredu_
  - Online repozitáre - _Áno_
  - Zoznam On-line repozitárov - _Dopredu_
  - Systémová rola - _Personal computer with KDE Plasma_, potom _Dopredu_
  - Rozdelenie disku - _Dopredu_
  - Hodiny a časové pásmo - _Dopredu_
  - Lokálni používatelia - 
    - Celé meno používateľa: `Projekcia`
    - Používateľské meno: `projekcia`
    - Heslo a Potvrďte heslo: je to na vás, napr. `projekcia`
    - potom _Dopredu_
  - Nastavenie inštalácie - _Inštalovať_
  - Potvrdiť inštaláciu - _Inštalovať_
- voliteľné pre fyzický počítač: nakonfigurovať partície v `/etc/fstab`
  - _options_ pre systémy súborov (ext4 - `discard`, `nodelassoc`, ...)
  - _tempfs_ for temp. directories
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

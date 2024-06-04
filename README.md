# To Do-Listen-Verwaltung: Dokumentation
## Einrichten eines Raspberry Pi als Webserver
### Netzwerkkonfiguration mit einer statischen IP-Adresse im lokalen Subnetz
Vorraussetzungen: Raspberry Pi mit geflashtem Raspberry PiOS 12 Bookworm, gegebene Infrastruktur, zuzuweisende IP-Adresse (192.168.24.181), Subnetzmaske und DNS (beides 192.168.24.254) bekannt

Mit SSH am Pi anmelden
``` sh
ssh pi@172.168.24.136
```

Statische LAN-IP-Adresse konfigurieren
``` sh
sudo nmcli c mod "Wired connection 1" ipv4.addresses 192.168.24.181/24 ipv4.method manual
sudo nmcli con mod "Wired connection 1" ipv4.gateway 192.168.24.254
sudo nmcli con mod "Wired connection 1" ipv4.dns 192.168.24.254
```

Unter neuer Adresse über SSH anmelden
``` sh
ssh pi@192.168.24.181
```

### Zwei lokale Nutzer
#### "willi" - Normaler Benutzer ohne Administratorrechten
Nutzer "willi" anlegen
``` sh
sudo adduser willi
```
#### "fernzugriff" Benutzer für den Zugriff von außen mittels SSH mit sudo-Rechten
Nutzer "fernzugriff" anlegen
``` sh
sudo adduser fernzugriff
sudo visudo 
```
### SSH-Dienst für den Benutzer "fernzugriff" zur Administration
``` sh 
sudo nano /etc/ssh/sshd_config
```

### Deployment der Web-App "To Do-Listen-Verwaltung" als Docker-Container
# To Do-Listen-Verwaltung
_Hinweis:_
Einige Komponenten wurden gemeinsam mit @snieb erstellt.

## Einrichten eines Raspberry Pi als Webserver
### Voraussetzungen:

- Raspberry Pi mit geflashtem Raspberry Pi OS 12 (basierend auf Debian 12 "Bookworm")
- RPi im selben Netzwerk angeschlossen & erreichbar
  (hier: 192.168.24.136 (automatisch vergeben))
- zuzuweisende IP-Adresse & Subnetzmaske bekannt
  (hier: 192.168.24.181/24)
- Standard-Gateway und DNS bekannt
  (hier: beides 192.168.24.254)
  - Internet via Gateway erreichbar

### Anmeldung am RPi via SSH
``` sh
ssh pi@192.168.24.136
```

Ggf. Fingerprint mit `yes` bestätigen.
Standard-Passwort ist `raspberry`.

_Hinweis:_
Der ggf. auftretende Verbindungsfehler `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` kann behoben werden, indem der veraltete Eintrag für die IP des R aus `~/.ssh/known_hosts` entfernt wird (manuell oder `ssh-keygen -R 192.168.24.136`)

_Hinweis:_
Für alle weiteren Befehle auf dem RPi werden Admin-Rechte vorausgesetzt.
Dazu nach jedem Login via SSH in eine Root-Shell wechseln:

```
sudo -i
```


### Netzwerkkonfiguration mit einer statischen IP-Adresse im lokalen Subnetz
``` sh
nmcli con mod "Wired connection 1" ipv4.addresses 192.168.24.181/24 ipv4.method manual
nmcli con mod "Wired connection 1" ipv4.gateway 192.168.24.254
nmcli con mod "Wired connection 1" ipv4.dns 192.168.24.254
```

Danach RPi neustarten, um die Konfiguration anzuwenden:

```
systemctl reboot
# alternativ nur Netzwerkverbindung neustarten:
# nmcli con down "Wired connection 1" && nmcli con up con up "Wired connection 1"
```

Hierbei wird die Verbindung getrennt.

Danach sollte Anmeldung unter der neuen Adresse möglich sein:

``` sh
ssh pi@192.168.24.181
```

### Zwei lokale Nutzer
#### "willi" - Normaler Benutzer ohne Administratorrechten
Nutzer "willi" anlegen.

``` sh
adduser willi --comment ""
# Passwort für den neuen Nutzer eingeben
```

_Hinweis:_
Die interaktive Abfrage von [zusätzlichen Informationen](https://de.wikipedia.org/wiki/GECOS-Feld) wie Name & Telefonnummer wird hier mit `--comment ""` übersprungen.

#### "fernzugriff"-Benutzer für den Zugriff von außen mittels SSH mit sudo-Rechten
Nutzer "fernzugriff" anlegen & zur standardmäßig existierenden Gruppe `sudo` hinzufügen:

``` sh
adduser fernzugriff --comment ""
# Passwort für den neuen Nutzer eingeben
usermod -aG sudo fernzugriff
```

### SSH-Login mit Password nur für "fernzugriff" zur Administration
In einem Texteditor eine neue Datei erstellen unter:
``` sh 
nano /etc/ssh/sshd_config.d/sicherheit.conf
```

Folgenden Inhalt einfügen & speichern:

```
AllowUsers fernzugriff
```

SSH-Daemon neustarten:

``` sh
systemctl restart sshd
```

Nach dem Ausloggen sollte eine Anmeldung mit `fernzugriff` möglich sein;
für allen anderen (z.B. `pi`) aber verweigert werden (`Permission denied (publickey,password).`).


### Deployment der Web-App "To Do-Listen-Verwaltung" als Docker-Container
_Hinweis:_
Auch hier überall Root-Rechte benötigt! (ggf. `sudo`)

#### Docker installieren
S. Anleitung in [get.docker.com](https://get.docker.com), oder blind vertrauen:

``` sh
curl https://get.docker.com | sudo sh
```

Grundinstallation testen mit:

```
docker run hello-world
```


#### Inhalte dieses Repos auf den RPi übertragen
_Hinweis:_
`docker build` direkt mit dem Repo-Link ist problematisch, da dieses Repo nicht öffentlich ist.

##### Option 1: `git clone` mit interaktiver Authentifizierung auf dem RPi
``` sh
git clone https://github.com/snieb/todo_liste_api.git
```

##### Option 2: Dateien manuell via `scp` kopieren
Quelldateien von anderem Rechner aus auf den RPi übertragen:
``` sh
scp -r ../todo_liste_api fernzugriff@192.168.24.181:~/todo_liste_api
```

#### Image bauen & Container starten
``` sh
docker build -t todo-api ~/todo_liste_api
docker run -p 80:5000 -d todo-api
```

Dann sollte die API nun von außen über den Port 80 erreichbar sein.

```
curl 192.168.24.181/lists
```

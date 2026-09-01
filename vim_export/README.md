# Pluginfreier Vim-Export

Dieses Verzeichnis uebertraegt die wichtigsten Gewohnheiten aus der privaten
Neovim-Konfiguration auf ein unveraendertes Vim. Es enthaelt keinen
Plugin-Manager, keine Downloadlogik und keine Verweise auf fremde
Git-Repositories. Beim Start werden keine externen Programme ausgefuehrt.

Ziel ist das normale `vim`-Paket von Debian Trixie (Vim 9.1), nicht
`vim-tiny`. Die Konfiguration ist absichtlich in klassischem Vimscript
geschrieben und laeuft auch mit dem zum Testen verwendeten Vim 8.2.

## Verwendung

Zum unverbindlichen Starten:

```sh
vim -Nu /absoluter/pfad/zu/vim_export/vimrc datei.php
```

Fuer die dauerhafte Nutzung das komplette Verzeichnis an einen erlaubten Ort
kopieren und in `~/.vimrc` genau diese Datei sourcen:

```vim
source /absoluter/pfad/zu/vim_export/vimrc
```

Das komplette Verzeichnis muss zusammenbleiben, damit die Einstellungen unter
`after/ftplugin` gefunden werden. Es gibt absichtlich kein Installationsskript.

Beim ersten Start erzeugt Vim fuer persistentes Undo ein privates Verzeichnis
unter `$XDG_STATE_HOME/vim/undo` oder, wenn die Variable nicht gesetzt ist,
unter `~/.local/state/vim/undo`.

## Wichtigste Tasten

`<Leader>` ist die Leertaste.

| Taste | Funktion |
| --- | --- |
| `n`, `r`, `s`, `l` | links, unten, rechts, oben |
| `z`, `Z` | naechster/vorheriger Suchtreffer |
| `u`, `U` | Insert am Cursor/Zeilenanfang |
| `ä`, `Ä` | Undo/Redo |
| `e`, `t`, `i` | Wort vor, Wort zurueck, Wortende |
| `b`, `B` | bis vor das naechste/vorherige Zeichen |
| `nr` im Insert-Modus | zurueck in den Normal-Modus |
| `<Esc><Esc>` im Terminal | Terminal-Normalmodus |
| `<Leader>ws/wl/wr/wn` | Split rechts/oben/unten/links fokussieren |
| `\` | lokalen netrw-Dateibrowser umschalten |

Wie im Neovim-Setup sind `h`, `j` und `k` im Normal-, Visual- und
Operator-Pending-Modus deaktiviert. Das Mapping `nr` kann nach einem einzelnen
`n` im Insert-Modus hoechstens `timeoutlen` (300 ms) auf das zweite Zeichen
warten.

## Dateien, Suche und Quickfix

| Taste/Befehl | Funktion |
| --- | --- |
| `<Leader>sf` / `:Files` | Projektdateien in Quickfix anzeigen |
| `<Leader>sg` / `:ProjectGrep muster` | Projekt rekursiv mit `grep` durchsuchen |
| `<Leader>sw` | Wort unter dem Cursor projektweit suchen |
| `<Leader>s.` / `:Recent` | zuletzt verwendete, noch vorhandene Dateien |
| `<Leader><Leader>` | Buffer auflisten und eine Buffernummer abfragen |
| `<Leader>sh` | `:help` vorbereiten |
| `<Leader>sk` | aktive Mappings anzeigen |
| `<Leader>q` | Quickfix oeffnen |
| `]q`, `[q` | naechster/vorheriger Quickfix-Eintrag |
| `<Leader>sv` | diese exportierte `vimrc` bearbeiten |

Innerhalb eines Git-Arbeitsverzeichnisses verwendet `:Files` ausschliesslich
lokale `git ls-files`-Daten und respektiert `.gitignore`. Ausserhalb davon wird
`find` benutzt. Suche und Dateiliste lassen `.git`, `node_modules`, `vendor`,
`target`, `.venv`, `dist` und `build` aus. Quickfix-Eintraege werden mit
`Enter` geoeffnet; innerhalb der Liste kann normal mit `/` gesucht werden.

## Git

`<Leader>gs` zeigt den Status und `<Leader>gd` den Diff. Der allgemeine Befehl

```vim
:Git status
:Git log --oneline -20
:Git add pfad/zur/datei
```

fuehrt die Argumente im aktuellen Arbeitsverzeichnis aus. Auch Netzwerkbefehle
passieren nur, wenn sie ausdruecklich hinter `:Git` eingegeben werden; die
Konfiguration selbst fuehrt niemals Clone, Fetch, Pull oder Push aus.

## Einrueckung, Completion und Formatter

PHP verwendet Tabs mit Breite 2. Lua verwendet zwei Leerzeichen. Python, Rust
und Shell verwenden vier Leerzeichen. Vims Einrueckung fuer den gesamten
Buffer ist `gg=G`.

Eingebaute Completion:

| Taste im Insert-Modus | Funktion |
| --- | --- |
| `<C-n>` / `<C-p>` | naechster/vorheriger Vorschlag |
| `<C-x><C-f>` | Dateipfade |
| `<C-x><C-o>` | Filetype-Omni-Completion, sofern Vim sie anbietet |
| `<C-x><C-l>` | ganze Zeilen |

Ein bereits installiertes, stdin-faehiges Projektwerkzeug kann explizit den
gesamten Buffer formatieren:

```vim
:Format black -q -
:Format stylua -
:Format rustfmt
:Format shfmt
```

`<Leader>f` bereitet `:Format` vor. Vim erkennt und installiert keine
Formatter. Nur bei Exit-Status 0 wird der Buffer ersetzt, und er wird danach
nicht automatisch gespeichert. Dateibasierte Formatter ohne stdin/stdout-
Schnittstelle sind von diesem Helfer nicht abgedeckt.

## Bewusste Grenzen

Ohne Erweiterungen gibt es keine LSP-Code-Actions, semantische Completion,
Inlay-Hints, Treesitter-Hervorhebung, Telescope-Fuzzysuche, Git-Zeichen pro
Zeile oder automatische Diagnosen. Als Bordmittel bleiben insbesondere:

- `gd`, `%`, `:help` und die Include-Suche fuer einfache Navigation,
- `/`, `*`, `:ProjectGrep` und Quickfix fuer Suche,
- Vims Syntax- und Filetype-Runtime fuer Hervorhebung und Einrueckung,
- `:Git diff` fuer Aenderungen sowie interne Vim-Register zum Kopieren.

Das Debian-Terminalpaket kann ohne `+clipboard` gebaut sein. In diesem Fall
bleiben Yanks innerhalb Vims verfuegbar; fuer die System-Zwischenablage muss
die Markier-/Kopierfunktion des verwendeten Terminals genutzt werden.

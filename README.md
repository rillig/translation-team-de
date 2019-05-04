# translation-team-de

Dokumentensammlung für das [Deutsch-Team](http://translationproject.org/team/de.html) von translationproject.org

Anmerkung: die hier aufgezählten Dokumente sind keine Richtlinien, die man unbedingt befolgen muss, sondern freiwillig.

# Infos für Neulinge

* Der erste Anlaufpunkt für alles rund ums Übersetzen ist die [Mailingliste](https://sourceforge.net/projects/translation/lists/translation-team-de). Auch wenn dort meistens wenig los ist, sind Fragen trotzdem gern gesehen und werden auch beantwortet.

* Die einzig wahre Quelle für die zu übersetzenden Texte ist [die Teamseite](https://translationproject.org/team/de.html), denn dort landen die von den Projekten zur Übersetzung freigegebenen Versionen.

* Bevor du anfängst, ein Projekt zu übersetzen, frag lieber noch mal kurz auf der Mailingliste nach, damit sich nicht zwei Leute unnötig Arbeit machen.

# Übersetzen

## Regelwerke anderer Projekte

* Debian: https://www.debian.org/international/German/
* GNOME: https://wiki.gnome.org/TranslationProject
* KDE: http://i18n.kde.org/
* Microsoft: [Terminologie](http://www.microsoft.com/Language/en-US/Terminology.aspx), [Style Guide](http://www.microsoft.com/Language/en-US/StyleGuides.aspx)
* http://sourceforge.net/p/translation/mailman/message/33262772/ (Mail von Mario)
* http://fuelproject.org/portfolio/german/
* https://wiki.debian.org/Wortliste

## Notizen

* Dateicodierung der .po-Dateien: UTF-8
* Anführungszeichen: entweder „so“ oder »so«, aber pro Datei immer einheitlich
* Gleiche Begriffe im Englischen werden gleiche Begriffe im Deutschen
* Die Satzstruktur muss nicht erhalten bleiben, sondern soll wie natürliches Deutsch klingen
* Siezen, nicht duzen
* Großschreibung am Anfang eines Satzes: ja
* Großschreibung am Anfang jeder Message: derzeit uneinheitlich

## Übersetzen von [y/n] – [j/n], [yes/no] – [ja/nein]

Je nachdem, wie der Programmcode aussieht, muss das [y/n] entweder so belassen werden oder in [j/n] übersetzt werden.

* Wenn im Programmcode `rpmatch` auftaucht, ist [j/n] die richtige Variante
* Wenn im Programmcode `ch == 'y'` oder etwas ähnliches auftaucht, muss auch in der Übersetzung das `y` bleiben

# Korrekturlesen

Möglicher Ablauf:

1. Der Korrekturleser lädt die .po-Datei herunter und schreibt seine Vorschläge direkt in die Datei
1. Der Korrekturleser schickt die .po-Datei an den ursprünglichen Übersetzer
1. Der Übersetzer benutzt ein Tool zum Vergleichen von Dateien (WinMerge, Eclipse, Notepad++, Emacs) und pflegt die Korrekturvorschläge ein

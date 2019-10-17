termsuite-galaxy-docker
=====================

Implémentation de TermSuite pour la plateforme Galaxy



## Liste des fichiers

Dans ce répertoire, on a :

 * Dockerfile : fichier de configuration pour créer l’image Docker de l’outil
 * README.md : ce fichier
 * TermSuiteJson2Tsv.pl : script pour convertir la sortie JSON de TermSuite en liste de termes par document
 * TermSuiteTsv2DocTerm.pl : script pour transformer une liste de termes en fichier "doc x terme" 
 * TermSuiteWrapper.sh : script shell encapsulant l’application TermSuite
 * TermSuiteWrapper2.sh : variante travaillant à partir des titres et résumés présents dans un fichier de métadonnées
 * termsuite_wrapper2_en.xml : fichier de configuration XML de `TermSuiteWrapper2.sh` pour Galaxy en anglais
 * termsuite_wrapper2_fr.xml : fichier de configuration XML de `TermSuiteWrapper2.sh` pour Galaxy en français
 * termsuite_wrapper_en.xml : fichier de configuration XML de `TermSuiteWrapper.sh` pour Galaxy en anglais
 * termsuite_wrapper_fr.xml : fichier de configuration XML de `TermSuiteWrapper.sh` en français pour Galaxy
 * tsv2docterm.xml : fichier de configuration XML de `TermSuiteTsv2DocTerm.pl` pour Galaxy (en français)

## Installation de TermSuite comme outil pour Galaxy

1 - Cloner ce projet

```bash
git clone https://github.com/VisaTM/termsuite-docker-galaxy
```

2 - Construire l’image Docker

```bash
docker build -t visatm/termsuite-wrapper .
```

Si vous utilisez un proxy, ne pas oublier d’indiquer les paramètres correspondants. Par exemple, pour l’INIST, cela donne :

```bash
docker build --build-arg http_proxy="$http_proxy" \
             --build-arg https_proxy="$https_proxy" \
             --build-arg no_proxy="$no_proxy" \
             -t visatm/termsuite-wrapper .
```

## Configuration de la plateforme Galaxy

Dans le fichier `config/tool_conf.xml` de Galaxy, ajouter la section suivante :

```XML
  <section id="termsuite" name="TermSuite">
    <tool file="termsuite/termsuite_wrapper.xml" />
    <tool file="termsuite/termsuite_wrapper2.xml" />
    <tool file="termsuite/tsv2docterm.xml" />
  </section>
```

Dans le répertoire `tools` de Galaxy, créer un répertoire `termsuite` et créer dans ce répertoire les fichiers `termsuite_wrapper.xml`, `termsuite_wrapper2.xml` et `tsv2docterm.xml` à partir de la version française ou anglaise des fichiers de configuration correspondants. 


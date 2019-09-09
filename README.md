termsuite-galaxy-docker
=====================

Implémentation de TermSuite pour la plateforme Galaxy



## Liste des fichiers

Dans ce répertoire, on a :

 * Dockerfile : fichier de configuration pour créer l’image Docker de l’outil
 * README.md : ce fichier
 * TermSuiteWrapper.sh : script shell encapsulant l’application TermSuite
 * termsuite_wrapper.xml : fichier de configuration XML pour Galaxy

## Installation de TermSuite comme outil pour Galaxy

1 - Cloner ce projet

```bash
git clone http://vsgit.intra.inist.fr:60000/git/VisaTM/termsuite-galaxy-docker.git
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
  </section>
```

Dans le répertoire `tools` de Galaxy, créer un répertoire `termsuite` et copier dans ce répertoire le fichier `termsuite_wrapper.xml`. 

